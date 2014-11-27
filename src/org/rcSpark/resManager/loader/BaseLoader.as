/**
 *  Copyright (c) 2009 - 2010 LOOKBACKON All rights reserved.
 */
package org.rcSpark.resManager.loader
{
//--------------------------------------------------------------------------
//
//  Imports
//
//--------------------------------------------------------------------------
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;


/****
 * BaseResLoader.as class. Created Aug 18, 2012 11:44:06 AM
 * <br>
 * Description:
 * @author ryan
 * @langversion 3.0
 * @playerversion Flash 10
 ****/
public class BaseLoader extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	/**
	 * ResStreamLoader - ByteArray
	 *
	 * */
	protected var _loader:*;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	public function BaseLoader(target:IEventDispatcher=null)
	{
		super(target);
	}
	
	//--------------------------------------------------------------------------
	//
	//  methods
	//
	//--------------------------------------------------------------------------
	public function load(urlReq:URLRequest):void
	{
		throw new Error("must be override");
	}
	public function loadBytes(bytes:ByteArray, ct:LoaderContext):void
	{
		throw new Error("must be override");
	}
	/**
	 * 资源加载完成
	 * @param evt
	 *
	 */
	private function onCompleteHandler(evt:Event):void
	{
		if (evt.target != null)
		{
			var loader:IEventDispatcher = evt.target as IEventDispatcher ;
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
		}
	}
	
	/**
	 * 资源加载进度
	 * @param evt
	 *
	 */
	protected function onProgressHandler(evt:ProgressEvent):void
	{
	}
	
	/**
	 * 资源加载进度
	 * @param evt
	 *
	 */
	protected function onHttpStatusHandle(evt:HTTPStatusEvent):void
	{
		if(evt.status >= 400){
			//trace("錯誤請求");
		}
		//trace(evt.type,evt.status);
	}
	
	/**
	 * 资源加载进度
	 * @param evt
	 *
	 */
    private function onErrorHandle(evt:ErrorEvent):void
	{
		if (evt.target != null)
		{
			var loader:IEventDispatcher = evt.target as IEventDispatcher ;
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
		}
	}
	
	/**
	 * 开始加载
	 * */
	public function startLoading():void
	{
	}
	/**
	 * 暂停加载
	 * */
	public function stopLoading():void
	{
		
	}
	
	/**
	 * 销毁方法
	 * */
	public function dispose():void
	{
	}
}

}