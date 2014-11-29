/*******************************************************************************
 * Class name:	BinaryEvent.as
 * Description:	
 * Author:		Ryan
 * Create:		Jun 11, 2014 6:15:19 PM
 * Update:		Jun 11, 2014 6:15:19 PM
 ******************************************************************************/
package org.rcSpark.binaryManager.events
{
//-----------------------------------------------------------------------------
// import_declaration
//-----------------------------------------------------------------------------
import flash.events.Event;

import org.rcSpark.binaryManager.data.BinaryInfo;


public class BinaryEvent extends Event
{
	//-----------------------------------------------------------------------------
	// Var
	//-----------------------------------------------------------------------------
	/**
	 * 定义 <code>destory</code> 事件对象的 <code>type</code> 属性值。
	 *
	 * <p>此事件具有以下属性:</p>
	 *  <table class="innertable" width="100%">
	 *     <tr><th>属性</th><th>值</th></tr>
	 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
	 *     <tr><td><code>cancelable</code></td><td><code>false</code>; 没有要取消的默认行为。</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>当前正在使用某个事件侦听器处理事件对象的对象。</td></tr>
	 *     <tr><td><code>content</code></td><td><code>null</code>; 销毁一个资源 </td></tr>
	 *     <tr><td><code>resData</code></td><td><code>null</code>; 加载完成的资源数据，ResData格式 </td></tr>
	 *		<tr><td><code>target</code></td><td>调度了事件的对象。target 不一定是侦听该事件的对象。使用 currentTarget 属性可以访问侦听该事件的对象。</td></tr>
	 *  </table>
	 *
	 */
	public static const DESTORY:String="destory";
	
	/**
	 * 定义 <code>destory</code> 事件对象的 <code>type</code> 属性值。
	 *
	 * <p>此事件具有以下属性:</p>
	 *  <table class="innertable" width="100%">
	 *     <tr><th>属性</th><th>值</th></tr>
	 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
	 *     <tr><td><code>cancelable</code></td><td><code>false</code>; 没有要取消的默认行为。</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>当前正在使用某个事件侦听器处理事件对象的对象。</td></tr>
	 *     <tr><td><code>content</code></td><td><code>null</code>; 一个资源加入等待列队 </td></tr>
	 *     <tr><td><code>resData</code></td><td><code>null</code>; 加载完成的资源数据，ResData格式 </td></tr>
	 *		<tr><td><code>target</code></td><td>调度了事件的对象。target 不一定是侦听该事件的对象。使用 currentTarget 属性可以访问侦听该事件的对象。</td></tr>
	 *  </table>
	 *
	 */
	public static const ADD_TO_WAIT:String="addToWait";
	/**
	 * 定义 <code>destory</code> 事件对象的 <code>type</code> 属性值。
	 *
	 * <p>此事件具有以下属性:</p>
	 *  <table class="innertable" width="100%">
	 *     <tr><th>属性</th><th>值</th></tr>
	 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
	 *     <tr><td><code>cancelable</code></td><td><code>false</code>; 没有要取消的默认行为。</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>当前正在使用某个事件侦听器处理事件对象的对象。</td></tr>
	 *     <tr><td><code>content</code></td><td><code>null</code>; 一个资源加入下载列队 </td></tr>
	 *     <tr><td><code>resData</code></td><td><code>null</code>; 加载完成的资源数据，ResData格式 </td></tr>
	 *		<tr><td><code>target</code></td><td>调度了事件的对象。target 不一定是侦听该事件的对象。使用 currentTarget 属性可以访问侦听该事件的对象。</td></tr>
	 *  </table>
	 *
	 */
	public static const ADD_TO_LOAD:String="addToLoad";
	
	/**
	 * 定义 <code>completed</code> 事件对象的 <code>type</code> 属性值。
	 *
	 * <p>此事件具有以下属性:</p>
	 *  <table class="innertable" width="100%">
	 *     <tr><th>属性</th><th>值</th></tr>
	 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
	 *     <tr><td><code>cancelable</code></td><td><code>false</code>; 没有要取消的默认行为。</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>当前正在使用某个事件侦听器处理事件对象的对象。</td></tr>
	 *     <tr><td><code>bytesLoaded</code></td><td><code>0</code>; 在侦听器处理事件时加载的项数或字节数。 </td></tr>
	 *     <tr><td><code>bytesTotal</code></td><td><code>0</code>; 如果加载过程成功，将加载的总项数或总字节数。</td></tr>
	 *     <tr><td><code>content</code></td><td><code>null</code>; 加载完成的内容 </td></tr>
	 *     <tr><td><code>resData</code></td><td><code>null</code>; 加载完成的资源数据，ResData格式 </td></tr>
	 *		<tr><td><code>target</code></td><td>调度了事件的对象。target 不一定是侦听该事件的对象。使用 currentTarget 属性可以访问侦听该事件的对象。</td></tr>
	 *  </table>
	 *
	 */
	public static const COMPLETED:String="completed";
	
	/**
	 * 定义 <code>error</code> 事件对象的 <code>type</code> 属性值。
	 *
	 * <p>此事件具有以下属性:</p>
	 *  <table class="innertable" width="100%">
	 *     <tr><th>属性</th><th>值</th></tr>
	 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
	 *     <tr><td><code>cancelable</code></td><td><code>false</code>; 没有要取消的默认行为。</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>当前正在使用某个事件侦听器处理事件对象的对象。</td></tr>
	 *     <tr><td><code>target</code></td><td>报告安全错误的网络对象。</td></tr>
	 *		<tr><td><code>text</code></td><td>要显示为错误消息的文本。</td></tr>
	 *  </table>
	 *
	 */
	public static const ERROR:String="error";
	/**
	 * 定义 <code>progress</code> 事件对象的 <code>type</code> 属性值。
	 *
	 * <p>此事件具有以下属性:</p>
	 *  <table class="innertable" width="100%">
	 *     <tr><th>属性</th><th>值</th></tr>
	 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
	 *     <tr><td><code>cancelable</code></td><td><code>false</code>; 没有要取消的默认行为。</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>当前正在使用某个事件侦听器处理事件对象的对象。</td></tr>
	 *     <tr><td><code>bytesLoaded</code></td><td><code>0</code>; 在侦听器处理事件时加载的项数或字节数。 </td></tr>
	 *     <tr><td><code>bytesTotal</code></td><td><code>0</code>; 如果加载过程成功，将加载的总项数或总字节数。</td></tr>
	 *     <tr><td><code>content</code></td><td><code>null</code>; 加载完成的内容 </td></tr>
	 *     <tr><td><code>resData</code></td><td><code>null</code>; 加载完成的资源数据，ResData格式 </td></tr>
	 *	   <tr><td><code>target</code></td><td>调度了事件的对象。target 不一定是侦听该事件的对象。使用 currentTarget 属性可以访问侦听该事件的对象。</td></tr>
	 *  </table>
	 *
	 */
	public static const PROGRESS:String="progress";
	
	public var bytesLoaded:int;
	public var bytesTotal:int;
	/**
	 * 加载的数据
	 * */
	public var binaryInfo:BinaryInfo;
	//-----------------------------------------------------------------------------
	// Constructor
	//-----------------------------------------------------------------------------
	public function BinaryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
	}
	
	//-----------------------------------------------------------------------------
	// Methods
	//-----------------------------------------------------------------------------
	override public function toString():String
	{
		return formatToString("BinaryEvent", "type", "bubbles", "cancelable", "binaryInfo", "bytesLoaded", "bytesTotal");
	}
	
	override public function clone():Event
	{
		var evt:BinaryEvent=new BinaryEvent(type, bubbles, cancelable);
		evt.binaryInfo=binaryInfo;
		evt.bytesLoaded=bytesLoaded;
		evt.bytesTotal=bytesTotal;
		return evt;
	}
}
}