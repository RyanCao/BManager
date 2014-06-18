/*******************************************************************************
 * Class name:	BinaryManager.as
 * Description:	二进制加载管理(管理加载线程)
 * Author:		Ryan
 * Create:		Jun 11, 2014 5:33:00 PM
 * Update:		Jun 11, 2014 5:33:00 PM
 ******************************************************************************/
package org.rcSpark.resManager.manager
{

import com.adobe.crypto.MD5Stream;

import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import org.rcSpark.rcant;
import org.rcSpark.resManager.data.BinaryInfo;
import org.rcSpark.resManager.data.WaitToWake;
import org.rcSpark.resManager.events.BinaryEvent;
import org.rcSpark.resManager.loader.BinaryLoader;
import org.rcSpark.resManager.util.URLCode;
import org.rcSpark.tools.file.IFileCookie;

import tools.ILogger;

//-----------------------------------------------------------------------------
// import_declaration
//-----------------------------------------------------------------------------

public final class BinaryManager
{
	//-----------------------------------------------------------------------------
	// Var
	//-----------------------------------------------------------------------------
	private static var __instance : BinaryManager;
	
	public static var TRACE_FLAG:Boolean = false ;
	public static var MAX_THREAD:uint = 3;
	public static var RETRY_LIMIT:uint =1;
	
	public static var OVER_LOOK:Boolean = false ;
	public static var OVER_TIME:uint = 5 ;
	/**
	 * 是否将文件自动保存到缓存中
	 */
	//	public static var AUTO_SAVE:Boolean = true ;
	/**
	 * 加载文件前是否判断本地缓存 默认不加载本地缓存
	 */
	public static var READ_LOACL_FILE:Boolean = true ;
	/**
	 * Log 记录 请先实现再打开log开关
	 */
	public static var ilog:tools.ILogger ;
	/**
	 * Version 记录 请先实现再进行加载
	 */
	public static var iversion:IVersion ;
	/**
	 * 本地文件记录 请先实现再使用
	 */
	public static var ifile:IFileCookie ;
	
	/**
	 * 资源地址库[String]
	 * */
	private var _urlDic:Dictionary;
	/***
	 * 重複加載庫
	 * */
	private var retryDic:Dictionary;
	/***
	 * 已经加载完成的资源[BinaryInfo]
	 * */
	private var loadedDic:Dictionary;
	/**
	 * 不能加载的资源
	 * */
	private var errorDic:Dictionary ;
	/**
	 *正在加载的资源列表
	 */
	private var _loadingList:Vector.<BinaryInfo>;
	/**
	 * 等待加载库
	 * see BinaryInfo
	 * */
	private var _waitList:Vector.<BinaryInfo>;
	/**
	 * 等待加载库
	 * see WaitToWake
	 * */
	private var _waitToWake:Dictionary;
	/**
	 * 当前正在进行的文件加载数量
	 * */
	private var _loadingCount:uint = 0;
	
	//-----------------------------------------------------------------------------
	// Constructor
	//-----------------------------------------------------------------------------
	public function BinaryManager()
	{
		if(__instance){
			throw new Error("BinaryManager is single!")
			return ;
		}
		loadedDic = new Dictionary(true);
		errorDic = new Dictionary(true);
		_waitToWake = new Dictionary(true);
	}
	public static function instance() : BinaryManager {
		if (!__instance)
			__instance = new BinaryManager();
		return __instance;
	}
	//-----------------------------------------------------------------------------
	// Methods
	//-----------------------------------------------------------------------------
	/**
	 * 按设置的方式加载资源
	 * @param url url地址 可以是String 也可以是UrlRequest
	 * @param loadLevel 加载优先级
	 * @param onCompleteHandler 完成函数回调接口
	 * @param onProgressHandler 进度函数回调接口
	 * @param onErrorHandler 资源加载异常捕捉接口
	 * @return
	 *
	 */
	rcant function load(url : Object, loadLevel : int = 0, onCompleteHandler : Function = null, onProgressHandler : Function = null, onErrorHandler : Function = null,isSave:Boolean = true) : void
	{
		toLoad(url, loadLevel, onCompleteHandler, onProgressHandler, onErrorHandler,isSave);
	}
	
	/**
	 * 清除加载队列中不需要加载的【慎重使用】
	 * @param url url地址 可以是String 也可以是UrlRequest
	 * @return
	 *
	 */
	rcant function clearload(url : Object) : void
	{
		//查找 
		var urlReq : URLRequest = urlHandle(url);
		if(!urlReq)
			return ;
		//先查询是否存在内存文件 再查询是否存在本地文件 最后决定是否加载新文件
		var rUrl : String = URLCode.encode(urlReq);
		var bi: BinaryInfo= new BinaryInfo()
		bi.url = rUrl;
		removeUrlFromWaitList(bi);
	}
	
	/**
	 * 初始化版本内容
	 * @return
	 */
	rcant function initResVersion(dic : Dictionary) : void
	{
		if(iversion){
			iversion.initVersion(dic);
		}else{
			throw new Error("no Version Instance,must instance First");
		}
	}
	
	private function toLoad(url : Object,loadLevel:uint,onCompleteHandler : Function, onProgressHandler : Function, onErrorHandler : Function,isSave:Boolean) : void
	{
		var urlReq : URLRequest = urlHandle(url);
		if(!urlReq)
			return ;
		//先查询是否存在内存文件 再查询是否存在本地文件 最后决定是否加载新文件
		var rUrl : String = URLCode.encode(urlReq);
		var keyUrl:String = getKeyUrl(rUrl);
		var versionUrl:String = getNewestUrl(rUrl);
		var resData:BinaryInfo = new BinaryInfo();
		resData.url = keyUrl ;
		resData.md5sum = getVersion(keyUrl);
		urlReq = urlHandle(versionUrl);
		resData.loadLevel = loadLevel ;
		resData.urlReq = urlReq ;
		resData.onCompleteHandle = onCompleteHandler ;
		resData.onProgressHandle = onProgressHandler ;
		resData.onErrorHandle = onErrorHandler ;
		resData.isSave = isSave ;
		resData.state = BinaryInfo.WAITING;
		if(TRACE_FLAG&&ilog){
			ilog.debug("---BinaryManager--add--url--{0}",keyUrl,rUrl,versionUrl);
		}
		handleBinaryInfo(resData);
	}
	
	/**
	 * 处理url，查看是否需要
	 * @param url
	 * @return
	 */
	private function urlHandle(url: Object):URLRequest{
		if(url==""||url==null) return null;
		var urlReq : URLRequest = null;
		if (url is String) {
			urlReq = URLCode.decode(url as String);
		} else {
			urlReq = url as URLRequest;
		}
		return urlReq ;
	}
	
	/**
	 * 获取唯一键值Url，作为索引使用
	 * @param url
	 * @return urlString
	 */
	private function getVersion(url:String):String{
		if(iversion){
			return iversion.getVersion(url);
		}
		return "";
	}
	
	/**
	 * 获取唯一键值Url，作为索引使用
	 * @param url
	 * @return urlString
	 */
	private function getKeyUrl(url:String):String{
		if(iversion){
			return iversion.getKeyUrl(url);
		}
		return url;
	}
	
	/**
	 * 获取唯一键值Url，作为唯一地址使用，用于访问文件的最新版本地址
	 * @param url
	 * @return urlString
	 */
	private function getNewestUrl(url:String):String{
		if(iversion){
			return iversion.getNewestUrl(url);
		}
		return url;
	}
	
	
	private function handleBinaryInfo(si:BinaryInfo):void{
		var resEvent:BinaryEvent ;
		if(loadedDic[si.url])
		{
			//已加载完成
			resEvent =new BinaryEvent(BinaryEvent.COMPLETED);
			resEvent.binaryInfo = BinaryInfo(loadedDic[si.url]);
			si.onCompleteHandle(resEvent);
			return ;
		}
		
		if(READ_LOACL_FILE&&ifile){
			si.ba = ifile.readFileData(si.url,si.md5sum);
			if(si.ba){
				si.bytesLoaded = si.bytesTotal = si.ba.bytesAvailable ;
				loadedDic[si.url] = si ;
				resEvent =new BinaryEvent(BinaryEvent.COMPLETED);
				resEvent.binaryInfo = BinaryInfo(loadedDic[si.url]);
				si.onCompleteHandle(resEvent);
				return ;
			}
		}
		
		if(errorDic[si.url])
		{
			resEvent =new BinaryEvent(BinaryEvent.ERROR);
			resEvent.binaryInfo = si ;
			si.onErrorHandle(resEvent);
			return ;
		}
		
		addUrlToWaitList(si);
		_waitList.sort(compareWaitRes);
		startLoad();
	}
	
	protected function startLoad() : void {
		if (this._loadingCount < MAX_THREAD && this._waitList.length > 0) {
			var resData:BinaryInfo = this._waitList.shift();
			if (resData != null) {
				resData.state = BinaryInfo.LOADING;
				this._loadingCount++;
				if(!_loadingList)
					_loadingList = new Vector.<BinaryInfo>();
				_loadingList.push(resData);
				var loader : BinaryLoader = new BinaryLoader(resData);
				loader.overTime = BinaryManager.OVER_TIME ;
				loader.overlook = BinaryManager.OVER_LOOK ;
				if(!loader.hasEventListener(BinaryEvent.COMPLETED))
					loader.addEventListener(BinaryEvent.COMPLETED, onCompleteHandler,false,0,true);
				if(!loader.hasEventListener(BinaryEvent.ERROR))
					loader.addEventListener(BinaryEvent.ERROR, onErrorHandler,false,0,true);
				if(!loader.hasEventListener(BinaryEvent.PROGRESS))
					loader.addEventListener(BinaryEvent.PROGRESS, onProgressHandler,false,0,true);
				loader.load(resData.urlReq);
				if(TRACE_FLAG&&ilog){
					ilog.debug("---BinaryManager--startLoad--url--{0}",URLCode.encode(resData.urlReq));
				}
			} else {
			}
		}
	}
	
	protected function onProgressHandler(evt : BinaryEvent) : void {
		var loader : BinaryLoader = (evt.target as BinaryLoader);
		var reData : BinaryInfo = loader.getResData();
		reData.bytesLoaded = evt.bytesLoaded;
		reData.bytesTotal = evt.bytesTotal;
		if(reData.onProgressHandle!=null)
			reData.onProgressHandle(evt);
		var toWake:WaitToWake = _waitToWake[reData.url];
		if(toWake)
			toWake.onProgressHandle(evt);
	}
	
	protected function onCompleteHandler(evt : BinaryEvent) : void {
		var loader : BinaryLoader = (evt.target as BinaryLoader);
		if(loader.hasEventListener(BinaryEvent.COMPLETED))
			loader.removeEventListener(BinaryEvent.COMPLETED, onCompleteHandler);
		if(loader.hasEventListener(BinaryEvent.PROGRESS))
			loader.removeEventListener(BinaryEvent.PROGRESS, onProgressHandler);
		if(loader.hasEventListener(BinaryEvent.ERROR))
			loader.removeEventListener(BinaryEvent.ERROR, onErrorHandler);
		var streamInfo:BinaryInfo = loader.getResData() ;
		var keyUrl:String = getKeyUrl(streamInfo.url);
		
		var md5String:String = getMd5String(streamInfo.ba,streamInfo.md5sum);
		var ver:String = getVersion(keyUrl);
		if(ver&&ver!=""&& md5String != ver){
			if(TRACE_FLAG&&ilog){
				//文件不匹配
				ilog.debug("---BinaryManager--md5numWrong----url,needmd5,itsmd5----{0},{1},{2}--",[URLCode.encode(streamInfo.urlReq),ver,md5String]);
			}
		}
		
		if(TRACE_FLAG&&ilog){
			ilog.debug("---BinaryManager--loadComplete----url----{0}--",URLCode.encode(streamInfo.urlReq));
		}
		
		removeUrlFromLoadingList(streamInfo);
		if(streamInfo.onCompleteHandle!=null)
			streamInfo.onCompleteHandle(evt);
		var toWake:WaitToWake = _waitToWake[keyUrl];
		if(toWake)
			toWake.onCompleteHandle(evt);
		delete _waitToWake[keyUrl];
		loadedDic[keyUrl] = streamInfo ;
		this._loadingCount--;
		startLoad();
		
		if(streamInfo.isSave&&ifile){
			//成功加载的文件需要保存
			ifile.saveFileData(keyUrl,streamInfo.ba,md5String);
			if(TRACE_FLAG&&ilog){
				ilog.debug("---BinaryManager--saveFile----url----{0}--",keyUrl);
			}
		}
	}
	/**
	 * 获取Md5String 
	 * @param ba
	 * @param version
	 * @return 
	 * 
	 */	
	private function getMd5String(ba:ByteArray,version:String = ""):String{
		var md5String:String = version ;
		
		var md5:MD5Stream = new MD5Stream();
		md5String = md5.complete(ba);
		
		return md5String ;
	}
	
	/***
	 *
	 * */
	protected function onErrorHandler(evt : BinaryEvent):void
	{
		var loader : BinaryLoader = (evt.target as BinaryLoader);
		
		if(loader.hasEventListener(BinaryEvent.COMPLETED))
			loader.removeEventListener(BinaryEvent.COMPLETED, onCompleteHandler);
		if(loader.hasEventListener(BinaryEvent.PROGRESS))
			loader.removeEventListener(BinaryEvent.PROGRESS, onProgressHandler);
		if(loader.hasEventListener(BinaryEvent.ERROR))
			loader.removeEventListener(BinaryEvent.ERROR, onErrorHandler);
		var streamInfo:BinaryInfo = loader.getResData() ;
		var keyUrl:String = getKeyUrl(streamInfo.url);
		
		if(TRACE_FLAG&&ilog){
			ilog.debug("---BinaryManager--loadError----url----{0}--",keyUrl,streamInfo.url);
		}
		
		if(errorDic[keyUrl]==null)
			errorDic[keyUrl] = true ;
		if(streamInfo.onErrorHandle!=null)
			streamInfo.onErrorHandle(evt);
		var toWake:WaitToWake = _waitToWake[keyUrl];
		if(toWake)
			toWake.onErrorHandle(evt);
		delete _waitToWake[keyUrl];
		loader.dispose();
		loader = null ;
		
		this._loadingCount--;
		startLoad();
	}
	
	
	/***
	 * 添加地址到等待列表中
	 * */
	private function addUrlToWaitList(vo:BinaryInfo):void
	{
		if(!vo)
			return ;
		var i:int = 0;
		var compair:BinaryInfo ;
		var toWake:WaitToWake ;
		
		if(!_waitList){
			_waitList = new Vector.<BinaryInfo>() ;
			_waitList.push(vo);
			return ;
		}
		
		while (i < _waitList.length) {
			compair = (_waitList[i] as BinaryInfo);
			if (compair.url == vo.url){
				compair.loadLevel = Math.max(Math.min(vo.loadLevel, compair.loadLevel), 0);
				compair.isSave = ((vo.isSave) || (compair.isSave));
				toWake = _waitToWake[compair.url];
				if (!(toWake)){
					toWake = new WaitToWake();
				}
				toWake.url = compair.url;
				toWake.addCompleteHandle(vo.onCompleteHandle);
				toWake.addProgressHandles(vo.onProgressHandle);
				toWake.addErrorHandles(vo.onErrorHandle);
				_waitToWake[compair.url] = toWake;
				return;
			}
			i++;
		}
		i = 0;
		while (i < _loadingList.length) {
			compair = (_loadingList[i] as BinaryInfo);
			if (compair.url == vo.url){
				compair.loadLevel = Math.max(Math.min(vo.loadLevel, compair.loadLevel), 0);
				compair.isSave = ((vo.isSave) || (compair.isSave));
				toWake = _waitToWake[compair.url];
				if (!(toWake)){
					toWake = new WaitToWake();
				}
				toWake.url = compair.url;
				toWake.addCompleteHandle(vo.onCompleteHandle);
				toWake.addProgressHandles(vo.onProgressHandle);
				toWake.addErrorHandles(vo.onErrorHandle);
				_waitToWake[compair.url] = toWake;
				return;
			}
			i++;
		}
		_waitList.push(vo);
	}
	
	private function compareWaitRes(resData1:BinaryInfo,resData2:BinaryInfo):Number{
		if(resData1.loadLevel<resData2.loadLevel) return -1 ;
		else if(resData1.loadLevel==resData2.loadLevel) return 0 ;
		else  return 1 ;
	}
	
	private function removeUrlFromWaitList(vo:BinaryInfo):void
	{
		if(!vo)
			return ;
		var i:int = 0;
		while (i < _waitList.length) {
			if (_waitList[i].url == getKeyUrl(vo.url)){
				_waitList.splice(i, 1);
				break;
			}
			i++;
		}
	}
	private function removeUrlFromLoadingList(vo:BinaryInfo):void
	{
		if(!vo)
			return ;
		var i:int;
		while (i < _loadingList.length) {
			if (_loadingList[i].url == getKeyUrl(vo.url)){
				_loadingList.splice(i, 1);
				break;
			}
			i++;
		}
	}
	private function getStreamInfoFromLoadingList(url:String):BinaryInfo
	{
		if(!url||url=="")
			return null;
		for each (var itemInfo:BinaryInfo in _loadingList)
		{
			if(itemInfo.url == url)
			{
				return itemInfo;
			}
		}
		return null ;
	}
	/**
	 * 以指定url为键值，并以指定类型获取唯一的资源,
	 * @param url
	 * @param type
	 * @return
	 *
	 */
	public function getResByUrl(url : String) : * {
		if(loadedDic[url])
			return (loadedDic[url] as BinaryInfo).ba;
		return null;
	}
	
	public function memoryClean():void{
		for (var key1:* in loadedDic) {
			delete loadedDic[key1];
		}
	}
}
}