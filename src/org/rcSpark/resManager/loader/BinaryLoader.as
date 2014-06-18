/*******************************************************************************
 * Class name:	BinaryLoader.as
 * Description:	二进制加载类
 * Author:		Ryan
 * Create:		Jun 11, 2014 6:10:33 PM
 * Update:		Jun 11, 2014 6:10:33 PM
 ******************************************************************************/
package org.rcSpark.resManager.loader
{
//-----------------------------------------------------------------------------
// import_declaration
//-----------------------------------------------------------------------------
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLStream;
import flash.utils.ByteArray;

import org.rcSpark.resManager.data.BinaryInfo;
import org.rcSpark.resManager.events.BinaryEvent;
import org.rcSpark.tools.time.TimerManager;

public class BinaryLoader extends BaseLoader
{
	//-----------------------------------------------------------------------------
	// Var
	//-----------------------------------------------------------------------------
	protected var _data:BinaryInfo;
	private var range:int = 1024000; //每次下载的字节
	
	/**
	 * 设置下载监视<br>
	 * value : false 不进行监视
	 * value : true 进行监视
	 * */
	public var overlook:Boolean = false;
	
	/**
	 * 设置超时时间<br>
	 * 秒为单位
	 * */
	public var overTime:uint = 3 ;
	
	private var countTime:uint = 0 ;
	
	//-----------------------------------------------------------------------------
	// Constructor
	//-----------------------------------------------------------------------------
	public function BinaryLoader(data:BinaryInfo, target:IEventDispatcher=null)
	{
		super(target);
		_data=data;
		_loader = new URLStream();
	}
	
	//-----------------------------------------------------------------------------
	// Methods
	//-----------------------------------------------------------------------------
	public function getResData():BinaryInfo
	{
		return this._data;
	}
	
	override public function load(urlReq:URLRequest):void
	{
		var loader:URLStream=_loader as URLStream;
		
		if(!loader.hasEventListener(Event.COMPLETE))
			loader.addEventListener(Event.COMPLETE, onCompleteHandler);
		
		if(!loader.hasEventListener(ProgressEvent.PROGRESS))
			loader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
		
		if(!loader.hasEventListener(IOErrorEvent.IO_ERROR))
			loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandle);
		
		if(!loader.hasEventListener(SecurityErrorEvent.SECURITY_ERROR))
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onErrorHandle);
		
		loader.load(urlReq);
		
		countTime = 0 ;
		if(_data){
			_data.urlReq = urlReq;
		}
		
		if(overlook)
			TimerManager.addFunction(timeHandle);
		else
			TimerManager.removeFunction(timeHandle);
	}
	
	private function timeHandle():void
	{
		countTime ++ ;
		if(_data&&_data.state == BinaryInfo.LOADING){
			//只有 在加载中才回进行  判定
			if(countTime > overTime)
			{
				//超时无反应  重新加载
				stopLoading();
				startLoading();
			}
		}
	}
	
	/**
	 * 开始加载（可以断点续传）
	 * */
	override public function startLoading():void
	{
		if(!_data)
			return ;
		//			if(!_data.byteArray)
		load(_data.urlReq);
		//			else
		//				downloadByRange();
	}
	
	/**
	 * 断点续传 (暫時無用)
	 */
	private function downloadByRange():void
	{
		var startPoint:int = _data.ba?_data.ba.bytesAvailable:0 ;
		var endPoint:int = _data.bytesTotal;
		var newUrlReq:URLRequest = new URLRequest(_data.urlReq.url);
		var header:URLRequestHeader = new URLRequestHeader("Range","bytes="+startPoint+"-"+endPoint)//注意这里很关键，我们在请求的Header里包含对Range的描述，这样服务器会返回文件的某个部分
		newUrlReq.requestHeaders.push(header);
		if(startPoint>=endPoint)
		{
			return;
		}
		var loader:URLStream = _loader as URLStream ;
		loader.load(newUrlReq);
	}
	
	/**
	 * 暂停加载
	 * */
	override public function stopLoading():void
	{
		var loader:URLStream = _loader as URLStream ;
		if(loader && loader.connected)
			loader.close();
	}
	
	override protected function onErrorHandle(evt:ErrorEvent):void
	{
		super.onErrorHandle(evt);
		var resEvent:BinaryEvent = new BinaryEvent(BinaryEvent.ERROR);
		resEvent.binaryInfo = _data;
		dispatchEvent(resEvent);
		TimerManager.removeFunction(timeHandle);
		countTime = 0;
	}
	
	override protected function onCompleteHandler(evt:Event):void
	{
		var loader:URLStream = _loader as URLStream ;
		if (evt.type == Event.COMPLETE && evt.target == this._loader)
		{
			if(!_data.ba)
				_data.ba = new ByteArray();
			var bytes:ByteArray = _data.ba;
			if (loader.bytesAvailable > 0)
				loader.readBytes(bytes,bytes.length,loader.bytesAvailable);
			_data.state = BinaryInfo.COMPLETED ;
		}
		if(loader.connected)
			loader.close();
		super.onCompleteHandler(evt);
		var resEvent:BinaryEvent=new BinaryEvent(BinaryEvent.COMPLETED);
		resEvent.binaryInfo = _data;
		this.dispatchEvent(resEvent);
		TimerManager.removeFunction(timeHandle);
		countTime = 0 ;
	}
	
	override protected function onProgressHandler(evt:ProgressEvent):void
	{
		var resEvent:BinaryEvent=new BinaryEvent(BinaryEvent.PROGRESS);
		resEvent.bytesLoaded=evt.bytesLoaded;
		resEvent.bytesTotal=evt.bytesTotal;
		_data.bytesLoaded = resEvent.bytesLoaded ;
		_data.bytesTotal = resEvent.bytesTotal ;
		var loader:URLStream = _loader as URLStream ;
		if (!_loader.connected) return;
		if(!_data.ba)
			_data.ba = new ByteArray();
		var bytes:ByteArray = _data.ba;
		if (loader.bytesAvailable > 0)
			loader.readBytes(bytes,bytes.length,loader.bytesAvailable );
		_data.state = BinaryInfo.LOADING ;
		resEvent.binaryInfo=_data;
		this.dispatchEvent(resEvent);
		
		//有数据过来  重置监视时间点
		countTime = 0 ;
	}
	
	/**
	 * 销毁方法
	 * */
	override public function dispose():void
	{
		stopLoading();
		var loader:URLStream = _loader as URLStream ;
		if(loader.hasEventListener(Event.COMPLETE))
			loader.removeEventListener(Event.COMPLETE, onCompleteHandler);
		if(loader.hasEventListener(HTTPStatusEvent.HTTP_STATUS))
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusHandle);
		if(loader.hasEventListener(SecurityErrorEvent.SECURITY_ERROR))
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorHandle);
		if(loader.hasEventListener(IOErrorEvent.IO_ERROR))
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandle);
		if(loader.hasEventListener(ProgressEvent.PROGRESS))
			loader.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler);
		loader = null ;
		_data = null ;
	}
}
}