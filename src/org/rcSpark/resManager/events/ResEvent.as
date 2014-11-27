/**
 * Class name: ResEvent.as
 * Description:对应与 ResManager
 * Author: caoqingshan
 * Create: 14-9-17 下午4:20
 */
package org.rcSpark.resManager.events {
import flash.events.Event;

import org.rcSpark.resManager.data.ResInfo;

public class ResEvent extends Event {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    /**
     * 资源初始化完成
     * 如果不能初始化，返回二进制数据
     */
    public static const COMPLETED:String = "completed";
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
     *        <tr><td><code>text</code></td><td>要显示为错误消息的文本。</td></tr>
     *  </table>
     *
     */
    public static const ERROR:String = "error";
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
     *       <tr><td><code>target</code></td><td>调度了事件的对象。target 不一定是侦听该事件的对象。使用 currentTarget 属性可以访问侦听该事件的对象。</td></tr>
     *  </table>
     *
     */
    public static const PROGRESS:String = "progress";

    public var bytesLoaded:int;
    public var bytesTotal:int;

    public var content:*;

    public var url:String;

    public function ResEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    override public function toString():String {
        return formatToString("ResEvent", "type", "bubbles", "cancelable", "binaryInfo", "bytesLoaded", "bytesTotal");
    }

    override public function clone():Event {
        var evt:ResEvent = new ResEvent(type, bubbles, cancelable);
        evt.content = content;
        evt.bytesLoaded = bytesLoaded;
        evt.bytesTotal = bytesTotal;
        evt.url = url;
        return evt;
    }
}
}
