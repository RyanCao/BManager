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
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getTimer;
	
	[Event(name="tick",type="org.rcSpark.tools.time.TickEvent")]
	
	/****
	 * Tick.as class. Created Aug 18, 2012 12:33:34 AM
	 * <br>
	 * Description:这个类提供了发布ENTER_FRAME事件的功能，唯一的区别在于在发布的事件里会包含一个interval属性，表示两次事件的间隔毫秒数。
	 * 利用这种机制，接收事件方可以根据interval来动态调整动画播放间隔，单次移动距离，以此实现动画在任何客户机上的恒速播放，
	 * 不再受ENTER_FRAME发布频率的影响，也就是所谓的“跳帧”。
	 * 
	 * 相比其他同样利用getTimer()的方式，这种方法并不会进行多余的计算。
	 * 
	 * @author ryan
	 * @langversion 3.0
	 * @playerversion Flash 10
	 ****/   	 
	public class Tick extends EventDispatcher
	{		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		static private var __instance:Tick;
		/**
		 * 全局默认帧频
		 */
		static public var frameRate:Number = NaN;
		
		/**
		 * 最大两帧间隔（防止待机后返回卡死） 
		 */
		static private var MAX_INTERVAL:uint = 3000;
		static private var MIN_INTERVAL:uint = 0;
		
		private var displayObject:Shape;
		private var prevTime:int;
		private var speed:Number = 1.0;
		
		/**
		 * 是否停止发布Tick事件
		 * 
		 * Tick事件的发布影响的内容非常多，一般情况不建议设置此属性，而是设置所有需要暂停物品的pause属性。
		 */		
		private var pause:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		
		public function Tick()
		{
			displayObject = new Shape();
			displayObject.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  methods
		//
		//--------------------------------------------------------------------------
		static public function get instance():Tick
		{
			if (!__instance)
				__instance = new Tick();
			
			return __instance;
		}
		/**
		 * 重写方法使得默认使用弱引用监听，这样更接近ENTER_FRAME的用法
		 */
		public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=true):void
		{
			super.addEventListener(type,listener,useCapture,priority,useWeakReference);
		}
		
		/**
		 * 清除掉积累的时间（在暂停之后）
		 * 
		 */
		public function clear():void
		{
			this.prevTime = 0;
		}
		
		protected function enterFrameHandler(event:Event):void
		{
			var nextTime:int = getTimer();
			if (!pause)
			{
				var interval:int;
				if (prevTime == 0)
					interval = 0;
				else
				{
					interval = Math.max(MIN_INTERVAL,Math.min(nextTime - prevTime,MAX_INTERVAL));
					var e:TickEvent = new TickEvent(TickEvent.TICK);
					e.interval = interval * speed;
					dispatchEvent(e);
				}
			}
			prevTime = nextTime;
		}
	}
	
}