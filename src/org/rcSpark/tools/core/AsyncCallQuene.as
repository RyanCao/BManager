/**
 * 异步执行队列，执行过程中判断每个单项执行时间，优化帧效率问题
 * Created by Ryan on 2014/10/17.
 */
package org.rcSpark.tools.core {
import flash.utils.getTimer;

import org.rcSpark.tools.time.Tick;
import org.rcSpark.tools.time.TickEvent;

public class AsyncCallQuene {

    private static var __instance:AsyncCallQuene;
    /**
     * 单个时间片内可执行最长时间
     */
    private static const tickMaxTime:uint = 15;

    /**
     * 函数
     */
    private var asyncQueue:Vector.<Function>;
    /**
     * 参数
     */
    private var asyncQueuePara:Array;

    /**
     * 时间片到达
     */
    private var _tickStart:int;
    /**
     * 当前时间片
     */
    private var _tickTouch:int;

    public function AsyncCallQuene() {
        asyncQueue = new Vector.<Function>();
        asyncQueuePara = [];
        Tick.instance.addEventListener(TickEvent.TICK,tickHandler);
    }

    //-----------------------------------------
    //Methods
    //-----------------------------------------

    public static function instance(): AsyncCallQuene{
        if(!__instance)
            __instance = new AsyncCallQuene();
        return __instance ;
    }

    /**
     * 加入到异步处理列表中，等待帧空闲时调用
     * @param f
     * @param para
     */
    public function asyncCallByTick(f:Function,para:Array = null):void
    {
        asyncQueue[asyncQueue.length] = f;
        asyncQueuePara[asyncQueuePara.length] = para;
    }

    private function tickHandler(event:TickEvent):void {
        _tickStart = getTimer();
        if(asyncQueue.length < 1)
            return;
        while(isCPUIdle){
            if(asyncQueue.length<1)
                break;
            var async:Function = asyncQueue.shift();
            var para:Array = asyncQueuePara.shift();
            if(para){
                async.apply(null,para);
            }else{
                async();
            }
            _tickTouch = getTimer();
        }
    }

    /**
     * 判断当前CPU是否空闲
     */
    private function get isCPUIdle():Boolean{
        //return true;
        return _tickTouch-_tickStart < tickMaxTime;
    }
}
}
