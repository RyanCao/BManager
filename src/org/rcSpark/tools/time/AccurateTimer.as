/**
 *  Copyright (c) 2009 - 2010 LOOKBACKON All rights reserved.
 */
package org.rcSpark.tools.time
{
	//--------------------------------------------------------------------------
	//
	//  Imports
	//
	//--------------------------------------------------------------------------
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	
	/****
	 * AccurateTimer.as class.Created Aug 16, 2012 11:19:59 PM
	 * <br>
	 * Description:计时类
	 * @author ryan
	 * @langversion 3.0
	 ****/   	 
	public class AccurateTimer extends EventDispatcher
	{		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		private var _repeat:int;
		private var _tick:int;
		private var _timer:Timer;
		private var _offset:int;
		private var _time:int;
		private var _currentCount:int;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		/**
		 * 
		 * @param delay		计算计时时间片<br>（最好比tick小3倍比较准确）
		 * @param tick		计时时间片
		 * @param repeat	重复
		 * 
		 */
		public function AccurateTimer(delay:int, tick:int, repeat:int=0)
		{
			this._repeat = repeat;
			this._timer = new Timer(delay);
			this._tick = tick;
		}
		
		//--------------------------------------------------------------------------
		//
		//  methods
		//
		//--------------------------------------------------------------------------
		/**
		 * 核心思想：<br>
		 * 1.将每次时间计时的误差累计起来<br>
		 * 2.当误差时间大于时间片的时候，主动做一次时间片工作<br>
		 * */
		private function timerHandler(event:TimerEvent):void{
			var time:int = getTimer();
			var delay:int = time - _time;
			_time = time;
			_offset += delay;
			if (_offset > _tick){
				_offset -= _tick ;
				_currentCount++;
				if (_repeat > 0 && _currentCount > _repeat){
					stop();
					return;
				}
				dispatchEvent(new TimerEvent(TimerEvent.TIMER));
			}
		}
		
		public function get running():Boolean{
			return _timer.running;
		}
		public function get currentCount():int{
			return _currentCount;
		}
		
		/**
		 * 开始计时
		 */
		public function start():void{
			if (running){
				return;
			}
			_offset = 0;
			_time = getTimer();
			if(!_timer.hasEventListener(TimerEvent.TIMER))
				_timer.addEventListener(TimerEvent.TIMER, timerHandler);
			_currentCount = 0;
			_timer.reset();
			_timer.start();
		}
		
		public function stop():void{
			if (!running){
				return;
			}
			if(_timer.hasEventListener(TimerEvent.TIMER))
				_timer.removeEventListener(TimerEvent.TIMER, timerHandler);
			_timer.stop();
		}
		
		/**
		 * 销毁方法
		 * 
		 */		
		public function destroy():void
		{
			stop();
			_timer = null ;
		}
	}
	
}