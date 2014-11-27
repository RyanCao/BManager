/*******************************************************************************
 * Class name:	JSLogger.as
 * Description:	
 * Author:		ryancao
 * Create:		Jul 31, 2013 2:13:13 PM
 * Update:		Jul 31, 2013 2:13:13 PM
 ******************************************************************************/
package tools
{
	//-----------------------------------------------------------------------------
	// import_declaration
	//-----------------------------------------------------------------------------
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.utils.describeType;
	
	import mx.utils.StringUtil;
	
	
	public class JSLogger extends EventDispatcher implements ILogger	
	{
		//-----------------------------------------------------------------------------
		// Var
		//-----------------------------------------------------------------------------
		public static var enabled:Boolean = true;
		public static var _isExternalInterfaceAvailable:Boolean;
		public static var isInit:Boolean;
		public static var __instance:ILogger;
		
		//-----------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------
		public function JSLogger(target:IEventDispatcher=null)
		{
			super(target);
		}
		//-----------------------------------------------------------------------------
		// Methods
		//-----------------------------------------------------------------------------
		public static function instance():ILogger
		{
			if(!__instance)
				__instance = new JSLogger();
			return __instance ;
		}
		
		public function get category():String
		{
			return "JSlogger";
		}
		
		public function log(level:int, message:String, ...parameters):void
		{
			send("log",message,parameters);
		}
		
		public function debug(message:String, ...parameters):void
		{
			send("debug",message,parameters);
		}
		
		public function error(message:String, ...parameters):void
		{
			send("error",message,parameters);
		}
		
		public function fatal(message:String, ...parameters):void
		{
			send("fatal",message,parameters);
		}
		
		public function info(message:String, ...parameters):void
		{
			send("info",message,parameters);
		}
		
		public function warn(message:String, ...parameters):void
		{
			send("warn",message,parameters);
		}

		public static function log(level:int, message:String, ...parameters):void
		{
			instance().log(level,message,parameters);
		}
		
		public static function debug(message:String, ...parameters):void
		{
			instance().debug(message,parameters);
		}
		
		public static function error(message:String, ...parameters):void
		{
			instance().error(message,parameters);
		}
		
		public static function fatal(message:String, ...parameters):void
		{
			instance().fatal(message,parameters);
		}
		
		public static function info(message:String, ...parameters):void
		{
			instance().info(message,parameters);
		}
		
		public static function warn(message:String, ...parameters):void
		{
			instance().warn(message,parameters);
		}
		
		public static function get isExternalInterfaceAvailable():Boolean{
			if(!isInit){
				_isExternalInterfaceAvailable = ExternalInterface.available;
				isInit = true;
			}
			return _isExternalInterfaceAvailable;
		}
		
		/**
		 * makes the call to console
		 * */
		private static function send(type:String,message:String,parameters:*):void{
			if(enabled){
                trace("console."+type,StringUtil.substitute(message,parameters));
				if( isExternalInterfaceAvailable) {
					ExternalInterface.call("console."+type, StringUtil.substitute(message,parameters));
				}
			}
		}
		
		public static function describeObject(obj:Object):String{
			return describeType(obj).@name.toString();//.split("::")[1];
		}
		
		public static function logDescribe(obj:Object,...rest):void{
			instance().log(1,describeObject(obj),rest);
		}
		
		public static function disable():void{
			enabled = false;
		}
		
		public static function enable():void{
			enabled = true;
		}
	}
}


