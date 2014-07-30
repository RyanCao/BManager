/*******************************************************************************
 * Class name:	BgSharedObjectWorker.as
 * Description:	背后SharedObject保存线程
 * Author:		Ryan
 * Create:		Jun 19, 2014 1:49:24 PM
 * Update:		Jun 19, 2014 1:49:24 PM
 ******************************************************************************/
package 
{
//-----------------------------------------------------------------------------
// import_declaration
//-----------------------------------------------------------------------------
import flash.display.Sprite;
import flash.events.Event;
import flash.net.SharedObject;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.utils.ByteArray;

import tools.JSLogger;


public class BgSharedObjectSaveWorker extends Sprite
{
	//-----------------------------------------------------------------------------
	// Var
	//-----------------------------------------------------------------------------
	/**
	 * 主线程 -->副线程  存取 
	 */
	private var saveCommandChannel:MessageChannel;
	/**
	 * 主线程 -->副线程  主要数据
	 */
	private var saveBaChannel:MessageChannel;
	/**
	 *  副线程-->主线程  存取结果，是否完成 
	 */
	private var saveResultChannel:MessageChannel;
	/**
	 * 当前要存取的文件内容
	 * */
	private var nowba:ByteArray;
	//-----------------------------------------------------------------------------
	// Constructor
	//-----------------------------------------------------------------------------
	public function BgSharedObjectSaveWorker()
	{
		initialize();
	}
	
	//-----------------------------------------------------------------------------
	// Methods
	//-----------------------------------------------------------------------------
	private function initialize():void
	{
		//为管道注册类型
		//		registerClassAlias("com.adobe.test.vo.CountResult", CountResult);
		
		saveBaChannel = Worker.current.getSharedProperty("saveBaChannel") as MessageChannel;
		saveBaChannel.addEventListener(Event.CHANNEL_MESSAGE, handleBaCommandMessage);
		
		saveCommandChannel = Worker.current.getSharedProperty("saveCommandChannel") as MessageChannel;
		saveCommandChannel.addEventListener(Event.CHANNEL_MESSAGE, handleCommandMessage);
		
		
		saveResultChannel = Worker.current.getSharedProperty("saveResultChannel") as MessageChannel;
	}		
	
	
	private function handleBaCommandMessage(event:Event):void{
		if (!saveCommandChannel.messageAvailable)
			return;
		nowba = saveCommandChannel.receive() as ByteArray;
	}
	
	private function handleCommandMessage(event:Event):void
	{
		if (!saveCommandChannel.messageAvailable)
			return;
		
		var message:Array = saveCommandChannel.receive() as Array;
		if (message != null)
		{
			saveFileData("sscq","files",message[0],message[1],nowba);
		}
	}
	
	private function saveFileData(__domainName:String ,DIR_NAME:String, key:String, ver:String,value:*):void
	{
		var _so:SharedObject = SharedObject.getLocal(__domainName) ;
		if(_so.data[DIR_NAME] == null){
			_so.data[DIR_NAME] = {} ;
			_so.flush();
		}
		_so.data[DIR_NAME][key] = value ;
		var returnString:String =  _so.flush();
		saveResultChannel.send(returnString);
		JSLogger.info("saveFileData(__domainName,DIR_NAME,key,ver),{0}",__domainName,DIR_NAME,key,ver);
	}
}
}