/**
 * Class name: ResInfo.as
 * Description:
 * Author: caoqingshan
 * Create: 14-9-17 下午5:45
 */
package org.rcSpark.resManager.data {

import flash.display.BitmapData;
import flash.utils.ByteArray;

import org.rcSpark.rcant;
import org.rcSpark.resManager.events.BinaryEvent;
import org.rcSpark.resManager.events.ResEvent;
import org.rcSpark.resManager.loader.parse.ResParseBase;
import org.rcSpark.resManager.manager.BinaryManager;
import org.rcSpark.resManager.manager.ResManager;

use namespace rcant;

public class ResInfo {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    /**还沒有添加该资源**/
    public static const NONE:String = "none";
    /**资源等待中*/
    public static const WAITING:String = "waiting";
    /**资源下载中*/
    public static const LOADING:String = "loading";
    /**资源已下载*/
    public static const COMPLETED:String = "completed";
    /**资源下载错误*/
    public static const ERROR:String = "error";

    /**当前状态*/
    public var state:String = NONE;
    /**
     * 數據內容
     */
    public var content:*;
    /**
     * 原文件名
     */
    public var url:String;
    /**
     * 加密文件名
     */
    public var encrypturl:String;

    /**
     * 文件md5值
     */
    public var md5sum:String = "";
    /**已加载的字节数*/
    public var bytesLoaded:uint = 0;
    /**资源总大小
     * <p>如果资源是实时流,或大小未知,那麼總大小與<code>bytesLoaded</code>的值一样,会随着下载数据增加而动态增加</p>
     * <p>可用于数据绑定</p>
     */
    public var bytesTotal:uint = 0;
    /***
     * 加载等级
     * */
    public var loadLevel:uint = 0;
    /**
     * 文件加载完成以后是否保存到本地
     * */
    public var isSave:Boolean = false;
    public var onCompleteHandle:Function;
    public var onErrorHandle:Function;
    public var onProgressHandle:Function;

    private var _onBinaryParseComplete:Function;
    private var _onBinaryParseProcess:Function;
    private var _onBinaryParseError:Function;

    public function ResInfo() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    public function clone():ResInfo {
        var bi:ResInfo = new ResInfo();
        bi.content = content;
        bi.bytesLoaded = bytesLoaded;
        bi.bytesTotal = bytesTotal;
        bi.isSave = isSave;
        bi.loadLevel = loadLevel;
        bi.md5sum = md5sum;
        bi.onCompleteHandle = onCompleteHandle;
        bi.onErrorHandle = onErrorHandle;
        bi.onProgressHandle = onProgressHandle;

        bi._onBinaryParseComplete = _onBinaryParseComplete;
        bi._onBinaryParseProcess = _onBinaryParseProcess;
        bi._onBinaryParseError = _onBinaryParseError;

        bi.state = state;
        bi.url = url;
        bi.encrypturl = encrypturl;
        return bi;
    }

    public function dispose():void{
        if(content){
            if(content is BitmapData){
                (content as BitmapData).dispose();
            }else if(content is ByteArray){
                (content as ByteArray).clear();
            }
            content = null ;
        }
        onCompleteHandle = null ;
        onErrorHandle = null ;
        onProgressHandle = null ;

        _onBinaryParseComplete = null ;
        _onBinaryParseProcess = null ;
        _onBinaryParseError = null ;
    }

    public function load(onBinaryParseComplete:Function = null, onBinaryParseProcess:Function = null, onBinaryParseError:Function = null):void {
        _onBinaryParseComplete = onBinaryParseComplete;
        _onBinaryParseProcess = onBinaryParseProcess;
        _onBinaryParseError = onBinaryParseError;

        encrypturl = ResManager.getEncryptUrl(url);
        BinaryManager.instance().rcant::load(encrypturl, loadLevel, onBinaryLoadComplete, onBinaryLoadProcess, onBinaryLoadError);
    }

    private function onBinaryLoadComplete(evt:BinaryEvent):void {
        var res:ResParseBase = ResManager.getParserFromSuffix(encrypturl);
        var resEvt:ResEvent;
        if (res) {
            res.parse(evt.binaryInfo.ba, function (b:*):void {
                resEvt = new ResEvent(ResEvent.COMPLETED);
                resEvt.content = b;
                resEvt.url = url;
                if (onCompleteHandle != null)
                    onCompleteHandle(resEvt);
                if (_onBinaryParseComplete != null)
                    _onBinaryParseComplete(resEvt);
            });
        } else {
            resEvt = new ResEvent(ResEvent.COMPLETED);
            resEvt.content = evt.binaryInfo.ba;
            resEvt.url = url;
            if (onCompleteHandle != null)
                onCompleteHandle(resEvt);
            if (_onBinaryParseComplete != null)
                _onBinaryParseComplete(resEvt);
        }
    }

    private function onBinaryLoadProcess(evt:BinaryEvent):void {
        var resEvt:ResEvent = new ResEvent(ResEvent.PROGRESS);
        resEvt.bytesLoaded = evt.bytesLoaded;
        resEvt.bytesTotal = evt.bytesTotal;
        resEvt.url = url;
        if (onProgressHandle != null)
            onProgressHandle(resEvt);
        if (_onBinaryParseProcess != null)
            _onBinaryParseProcess(resEvt);

    }

    private function onBinaryLoadError(evt:BinaryEvent):void {
        var resEvt:ResEvent = new ResEvent(ResEvent.ERROR);
        resEvt.url = url;
        if (onErrorHandle != null)
            onErrorHandle(resEvt);
        if (_onBinaryParseError != null)
            _onBinaryParseError(resEvt);
    }
}
}
