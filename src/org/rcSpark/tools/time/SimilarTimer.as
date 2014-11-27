/**
 * Class name: SimilarTimer.as
 * Description: 毫秒级不精确,可精确到1/10秒
 * Author: caoqingshan
 * Create: 14-9-18 下午8:17
 */
package org.rcSpark.tools.time {
import flash.events.TimerEvent;

public class SimilarTimer {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    public static var DELAY:uint = 3;
    public static var TICK:uint = 10;
    public static var REPEAT:uint = 0;
    private static var _timer:AccurateTimer = new AccurateTimer(DELAY, TICK, REPEAT);
    /**
     * 延时函数库
     */
    private static var _similarHandlers:Vector.<SimilarHandlerVO>;

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    public static function setTimeOut(fun:Function, delay:uint, ...rest):SimilarHandlerVO {
        var vo:SimilarHandlerVO = new SimilarHandlerVO(fun, delay, rest);
        if(!_similarHandlers)
            _similarHandlers = new Vector.<SimilarHandlerVO>();
        _similarHandlers.push(vo);
        if (!_timer.running) {
            _timer.addEventListener(TimerEvent.TIMER, timerHandler);
            _timer.start();
        }
        return vo;
    }

    public static function clearTimeOut(vo:SimilarHandlerVO):void {
        var index:int = _similarHandlers.indexOf(vo);
        if (index == -1)
            return;
        _similarHandlers.splice(index, 1);
        vo.dispose();
    }

    public static function get running():Boolean {
        return _timer.running ? true : (_similarHandlers.length > 0);
    }

    private static function timerHandler(event:TimerEvent):void {
        event.stopImmediatePropagation();
        event.stopPropagation();

        var similarVo:SimilarHandlerVO;
        if (_similarHandlers.length == 0) {
            _timer.removeEventListener(TimerEvent.TIMER, timerHandler);
            _timer.stop();
            return;
        }

        var toDels:Array = [];
        for each (similarVo in _similarHandlers) {
            if (similarVo.isExpired()) {
                toDels.push(similarVo);
            } else {
                similarVo.run()
            }
        }

        for each(similarVo in toDels) {
            var index:int = _similarHandlers.indexOf(similarVo);
            similarVo.dispose();
            if (index > -1) {
                _similarHandlers.splice(index, 1);
            }
        }
        toDels = [];
        event.updateAfterEvent();
    }
}
}

import org.rcSpark.tools.time.SimilarTimer;

class SimilarHandlerVO {
    private var delay:uint;
    private var count:uint;
    private var maxCount:uint;
    private var handle:Function;
    private var handle_params:Array;

    private var _isExpired:Boolean;

    public function SimilarHandlerVO(fun:Function = null, _delay:uint = 0, _rest:Array = null) {
        if (fun != null) {
            handle = fun;
            delay = _delay;
            handle_params = _rest;
            count = 0;
            maxCount = Math.round(delay / SimilarTimer.TICK);
        }
    }

    /**
     * 判断句柄是否过期
     * 已经执行过函数，则句柄过期
     * @return
     */
    public function isExpired():Boolean {
        return _isExpired;
    }

    /**
     * 执行句柄
     */
    public function run():void {
        if (count >= maxCount) {
            //执行函数，记录函数过期
            if (handle != null) {
                handle.apply(null, handle_params);
            }
            _isExpired = true;
            return;
        }
        touch();
    }

    /**
     * 时间到，触摸下
     */
    private function touch():void {
        count++;
    }

    public function clone():SimilarHandlerVO {
        var newSimilar:SimilarHandlerVO = new SimilarHandlerVO();
        newSimilar.delay = delay;
        newSimilar.count = count;
        newSimilar.maxCount = maxCount;
        newSimilar.handle = handle;
        newSimilar.handle_params = handle_params;
        newSimilar._isExpired = _isExpired;
        return newSimilar;
    }

    public function dispose():void {
        handle_params = [];
        handle = null;
    }
}
