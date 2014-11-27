/**
 *  Copyright (c) 2009 - 2010 LOOKBACKON All rights reserved.
 */
package org.rcSpark.tools.time
{
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.rcSpark.tools.data.DataUtil;

	//--------------------------------------------------------------------------
	//
	//  Imports
	//
	//--------------------------------------------------------------------------
	
	/****
	 * ServiceTime.as class. Created 10:24:36 AM Sep 13, 2012
	 * <br>
	 * Description: 服务器时间
	 * @author ryan
	 * @langversion 3.0
	 * @playerversion Flash 10
	 ****/
	public final class ServiceTime
	{
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		static private var _instance:ServiceTime;
		private var mode:int;
		private var offest:Number;
		private var prevServiceOffest:Number;
		private var _timeFunDic:Dictionary ;
		private var _timeFunctionArr:Array = [];
		
		private var nowTime:uint ;
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		public function ServiceTime(serviceTime:Number = NaN,mode:int = 1)
		{
			_instance = this;
			this.mode = mode;
			if (!isNaN(serviceTime))
				this.setServiceTime(serviceTime);
		}
		
		//--------------------------------------------------------------------------
		//
		//  methods
		//
		//--------------------------------------------------------------------------
		static public function get instance():ServiceTime
		{
			if (!_instance)
				_instance = new ServiceTime();
			
			return _instance;
		}
		/**
		 * 
		 * @param serviceTime 毫秒数
		 * 
		 */		
		public function setServiceTime(serviceTime:Number):void
		{
			// TODO Auto Generated method stub
			offest = (new Date()).getTime() - serviceTime;
			prevServiceOffest = serviceTime - getTimer();
		}
		
		/**
		 * 返回服务器时间
		 * @return 返回一个Date对象
		 * 
		 */
		public function getDate():Date
		{
			return new Date(getTime());
		}
		
		/**
		 * 返回服务器时间  毫秒数
		 * @return 返回一个Number
		 */
		public function getTime():Number
		{
			if (mode == 0)
				return new Date().getTime() - offest;
			else
				return isNaN(prevServiceOffest) ? new Date().getTime() : prevServiceOffest + getTimer();
		}
		
		
		/**
		 * 在某一时间触发函数
		 * @param fun 函数
		 * @param time 秒数
		 * 
		 */		
		public function addTimeFunction(fun:Function,time:uint):void{
			nowTime = getTime()/1000 ;
			if(time < nowTime)
				return ;
			if(time == nowTime)
			{
				fun();
				return ;
			}
			if(!_timeFunDic)
				_timeFunDic = new Dictionary(true);
			var timeFunArr:Array = _timeFunDic[time];
			if(!timeFunArr)
				timeFunArr = [] ;
			var index:int = timeFunArr.indexOf(fun);
			if (index == -1){
				timeFunArr.push(fun);
				_timeFunDic[time] = timeFunArr;
				TimerManager.addFunction(runServerTime);
			}
		}
		
		private function runServerTime():void
		{
			nowTime ++ ;
			for (var time:* in _timeFunDic) 
			{
				if(uint(time) <= nowTime)
				{
					var tArr:Array = _timeFunDic[time] ;
					for each (var timeFunction:Function in tArr) {
						timeFunction();
					}
					tArr = null ;
					_timeFunDic[time] = null ;
					delete _timeFunDic[time] ;
				}
			}
			if(DataUtil.isEmpty(_timeFunDic))
				TimerManager.removeFunction(runServerTime);
		}
	}
}