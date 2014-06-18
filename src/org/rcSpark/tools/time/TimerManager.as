/**
 *  Copyright (c) 2009 - 2010 LOOKBACKON All rights reserved.
 */
package org.rcSpark.tools.time
{
	import flash.events.TimerEvent;

	//--------------------------------------------------------------------------
	//
	//  Imports
	//
	//--------------------------------------------------------------------------
	
	/****
	 * TimerManager.as class.Created Aug 16, 2012 11:40:08 PM
	 * <br>
	 * Description:计时类
	 * @author ryan
	 * @langversion 3.0
	 ****/   	 
	public final class TimerManager
	{		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		public static var DELAY:uint = 100;
		public static var TICK:uint = 1000;
		public static var REPEAT:uint = 0;
		private static var _timer:AccurateTimer = new AccurateTimer(DELAY, TICK, REPEAT);
		private static var _timeFunctionArr:Array = [];
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		public function TimerManager()
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 添加时间函数<br> TimerManager.addFunction
		 * 如果不用的时候记得需要移除 removeFunction <br/>
		 * Ex:<br/>
		 * if(time>0){<br/>
		 * 		TimerManager.addFunction(timeHandler);<br/>
		 * }else{<br/>
		 * 		TimerManager.removeFunction(timeHandler);<br/>
		 * }<br/>
		 * @param fun
		 */
		public static function addFunction(fun:Function):void{
			var index:int = _timeFunctionArr.indexOf(fun);
			if (index == -1){
				_timeFunctionArr.push(fun);
				if (!_timer.running){
					_timer.addEventListener(TimerEvent.TIMER, timerHandler);
					_timer.start();
				}
			}
		}
		
		/**
		 * TimerManager.removeFunction(timeHandler);
		 * @param fun
		 * 
		 */
		public static function removeFunction(fun:Function):void{
			var index:int = _timeFunctionArr.indexOf(fun);
			if (index == -1)
				return;
			_timeFunctionArr.splice(index, 1);
			if (_timeFunctionArr.length == 0){
				if (_timer.running){
					_timer.removeEventListener(TimerEvent.TIMER, timerHandler);
					_timer.stop();
				}
			}
		}
		
		public static function get running():Boolean{
			return _timer.running ? true : (_timeFunctionArr.length > 0);
		}
		
		private static function timerHandler(event:TimerEvent):void{
			var timeFunction:Function;
			if (_timeFunctionArr.length == 0){
				_timer.removeEventListener(TimerEvent.TIMER, timerHandler);
				_timer.stop();
				return;
			}
			for each (timeFunction in _timeFunctionArr) {
				timeFunction();
			}
			event.updateAfterEvent();
		}
	}
	
}