/*******************************************************************************
 * Class name:	SharedObjectFileCookieWorker.as
 * Description:	使用线程的存取类
 * Author:		Ryan
 * Create:		Jun 19, 2014 2:18:20 PM
 * Update:		Jun 19, 2014 2:18:20 PM
 ******************************************************************************/
package org.rcSpark.tools.file
{
import flash.events.Event;
import flash.net.SharedObject;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.system.WorkerState;
import flash.utils.ByteArray;

//-----------------------------------------------------------------------------
// import_declaration
//-----------------------------------------------------------------------------

public class SharedObjectFileCookieWorker implements IFileCookie
{
	//-----------------------------------------------------------------------------
	// Var
	//-----------------------------------------------------------------------------
	private static var __instance:IFileCookie;
	
	//索引名
	private static const INDEX_NAME:String = "index_name";
	//文件夹名
	private static const DIR_NAME:String = "files";
	//域名
	private var __domainName:String = "sscq" ;
	/**
	 * 索引文件
	 * name1|ver1
	 * name2|ver2
	 */
	private var indexData:Object = {};
	//索引文件是否初始化
	private var __init:Boolean = false;
	/**
	 * so
	 * */
	private var __so:SharedObject;
	/**
	 * 存取队列
	 * */
	private var saveWaitList:Array ;
	private var MAX_THREAD:uint = 1;
	private var _loadingCount:uint = 0;
	
	/**
	 * 线程是否初始化
	 */	
	private var __work_init:Boolean = false ;
	/**
	 * 线程运行状态
	 * */
	private var isSaveing:Boolean= false;
	private var bgWorker:Worker;
	private var saveBaChannel:MessageChannel;
	private var saveCommandChannel:MessageChannel;
	private var saveResultChannel:MessageChannel;
	//-----------------------------------------------------------------------------
	// Constructor
	//-----------------------------------------------------------------------------
	public function SharedObjectFileCookieWorker()
	{
		bgWorker = WorkerDomain.current.createWorker(SharedObjectWorkers.BackgroundWorker);
		
		saveBaChannel = Worker.current.createMessageChannel(bgWorker);
		bgWorker.setSharedProperty("saveBaChannel", saveBaChannel);
		
		saveCommandChannel = Worker.current.createMessageChannel(bgWorker);
		bgWorker.setSharedProperty("saveCommandChannel", saveCommandChannel);
		
		saveResultChannel = bgWorker.createMessageChannel(Worker.current);
		saveResultChannel.addEventListener(Event.CHANNEL_MESSAGE, handleResultMessage)
		bgWorker.setSharedProperty("saveResultChannel", saveResultChannel);
		
		bgWorker.addEventListener(Event.WORKER_STATE, handleBGWorkerStateChange);
		bgWorker.start();
	}
	private function handleBGWorkerStateChange(event:Event):void
	{
		if (bgWorker.state == WorkerState.RUNNING) 
		{
			__work_init = true ;
			doSaveWaitList();
		}
	}
	
	private function handleResultMessage(event:Event):void
	{
		var _currentChannel:MessageChannel = event.currentTarget as MessageChannel ;
		if (!_currentChannel.messageAvailable)
			return;
		var message:Array = _currentChannel.receive() as Array;
		
		isSaveing = false ;
		//保存 索引
		saveIndexData(message[1],message[2]);
		doSaveWaitList();
	}		
	
	public static function instance():IFileCookie
	{
		if(!__instance)
			__instance = new SharedObjectFileCookieWorker();
		return __instance ;
	}
	//-----------------------------------------------------------------------------
	// Methods
	//-----------------------------------------------------------------------------
	public function initIndex(domainName:String):*
	{
		__domainName = domainName ;
		var _so:SharedObject = SharedObject.getLocal(__domainName) ;
		indexData = _so.data[INDEX_NAME];
		if(!indexData){
			if(_so.data[INDEX_NAME] == null){
				_so.data[INDEX_NAME] = {} ;
				_so.flush();
			}
			indexData = {};
		}
		
		if(_so.data[DIR_NAME] == null){
			_so.data[DIR_NAME] = {} ;
			_so.flush();
		}
		
		__init = true ;
		return indexData ;
	}
	
	private function getSharedObject():SharedObject{
		return __so ||= SharedObject.getLocal(__domainName) ;
	}
	
	public function saveIndexData(fileName:String, ver:String=""):String
	{
		if(!__init)
			initIndex(__domainName);
		var _so:SharedObject = SharedObject.getLocal(__domainName) ;
		_so.data[INDEX_NAME][fileName] = ver ;
		indexData[fileName] = ver ;
		return _so.flush();
	}
	
	public function readFileData(key:String, ver:String=""):*
	{
		if(!__init)
			initIndex(__domainName);
		var _so:SharedObject = SharedObject.getLocal(__domainName) ;
		if(isFileExist(key,ver))
		{
			return _so.data[DIR_NAME][key];
		}
		return null ;
	}
	
	public function saveFileData(key:String, value:*, ver:String=""):String
	{
		if(!__init)
			initIndex(__domainName);
		if(!saveWaitList)
			saveWaitList = [] ;
		saveWaitList.push([key,value,ver]);
		doSaveWaitList();
		return "";
	}
	
	private function doSaveWaitList():void{
		if(!__work_init){
			//线程未初始化
			return ;
		}
		if(isSaveing){
			//线程进行中
			return ;
		}
		
		if (saveWaitList&&saveWaitList.length > 0) {
			isSaveing = true ;
			var saveData:Array = this.saveWaitList.shift();
			var key:String = saveData[0];
			var value:* = saveData[1];
			var ver:String=saveData[2];
			
			(value as ByteArray).shareable = true ;
			saveBaChannel.send(value);
			saveCommandChannel.send([key,ver]);
		}
	}
	
	public function isFileExist(fileName:String, ver:String=""):Boolean
	{
		if(!__init)
			initIndex(__domainName);
		var fVer:String = indexData[fileName];
		if(fVer!="undefined"&&fVer!="null"&&fVer!=null){
			if(ver&&ver!="")
				return ver==fVer ;
			else
				return true ;
		}
		return false ;
	}
}
}