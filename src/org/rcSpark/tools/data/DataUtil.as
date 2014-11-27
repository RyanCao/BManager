/**
 *  Copyright (c) 2009 - 2010 LOOKBACKON All rights reserved.
 */
package org.rcSpark.tools.data
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	//--------------------------------------------------------------------------
	//
	//  Imports
	//
	//--------------------------------------------------------------------------
	
	/****
	 * DataUtil.as class. Created Aug 18, 2012 12:24:35 AM
	 * <br>
	 * Description:
	 * @author ryan
	 * @langversion 3.0
	 * @playerversion Flash 10
	 ****/   	 
	public final class DataUtil
	{		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		public function DataUtil()
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  methods
		//
		//--------------------------------------------------------------------------
		/**
		 * 判断对象是否为空对象
		 * 
		 * @param obj
		 * @return 
		 * 
		 */
		public static function isEmpty(obj:*):Boolean
		{
			for (var o:* in obj)
				return false;
			
			return true;
		}
		
		/**
		 * 复制对象
		 *  
		 * @param obj	要复制的对象
		 * @param includeClass	是否包括自定义类，否则输出的是普通的Object
		 * @param otherClasses	复制时涉及到的其他自定义类
		 * @return 
		 * 
		 */
		public static function clone(obj:*,includeClass:Boolean = false,otherClasses:Array = null):*
		{
			if (includeClass)
				registerClassAlias(getQualifiedClassName(obj),obj["constructor"]);
			
			if (otherClasses)
			{
				for each (var cls:Class in otherClasses)
				registerClassAlias(getQualifiedClassName(cls),cls);
			}
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(obj);
			bytes.position = 0;
			return bytes.readObject();
		}
		
		/**
		 * 将属性值复制到另一个对象上
		 * 
		 * @param source	源对象
		 * @param target	目标对象
		 * 
		 */		
		public static function copy(source:*,target:* = null):*
		{
			if (!target)
				target = new Object();
			
			for (var key:* in source)
				target[key] = source[key]
			
			return target;
		}
	}
	
}