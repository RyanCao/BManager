/**
 * Class name: ResManager.as
 * Description:加载初始化资源
 * Author: caoqingshan
 * Create: 14-9-17 下午4:16
 */
package org.rcSpark.resManager.manager {
import flash.display.BitmapData;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import org.rcSpark.binaryManager.data.WaitToWake;
import org.rcSpark.binaryManager.manager.*;
import org.rcSpark.binaryManager.util.URLCode;
import org.rcSpark.rcant;
import org.rcSpark.resManager.data.ResInfo;
import org.rcSpark.resManager.events.ResEvent;
import org.rcSpark.resManager.parse.EAWDResParse;
import org.rcSpark.resManager.parse.EAWPResParse;
import org.rcSpark.resManager.parse.ImageResParse;
import org.rcSpark.resManager.parse.ResParseBase;

use namespace rcant;

public class ResManager {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    private static var _parsers:Vector.<Class> = Vector.<Class>([ ImageResParse, EAWDResParse, EAWPResParse]);

    /**
     * 加密文件后缀
     */
    private static var _enCodeArray:Array = [];
    /**
     * 解密文件后缀
     */
    private static var _deCodeArray:Array = [];

    private static var __instance:ResManager;

    /***
     * 已经初始化完成的资源[具体对象]
     * 如果是BITMAP对象就是 bitmapData
     * */
    private var _initedDic:Dictionary;

    /**
     * 等待初始化库
     * see WaitToWake
     * */
    private var _waitToWake:Dictionary;

    /**
     * 加载队列
     */
    private var _initList:Vector.<ResInfo>;

    public function ResManager() {
        if (__instance) {
            throw new Error("ResManager is single!")
            return;
        }
        _initedDic = new Dictionary(true);
        _waitToWake = new Dictionary(true);
        _initList = new Vector.<ResInfo>();
    }

    public static function instance():ResManager {
        if (!__instance)
            __instance = new ResManager();
        return __instance;
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    rcant function load(url:Object, loadLevel:int = 0, onCompleteHandler:Function = null, onProgressHandler:Function = null, onErrorHandler:Function = null, isSave:Boolean = true):void {
        toLoad(url, loadLevel, onCompleteHandler, onProgressHandler, onErrorHandler, isSave);
    }

    private function toLoad(url:Object, loadLevel:int, onCompleteHandler:Function, onProgressHandler:Function, onErrorHandler:Function, isSave:Boolean):void {
        var urlReq:URLRequest = urlHandle(url);
        if (!urlReq)
            return;
        var rUrl:String = URLCode.encode(urlReq);

        var resData:ResInfo = new ResInfo();
        resData.url = rUrl;
        resData.loadLevel = loadLevel;
        resData.onCompleteHandle = onCompleteHandler;
        resData.onProgressHandle = onProgressHandler;
        resData.onErrorHandle = onErrorHandler;
        resData.isSave = isSave;

        handleResInfo(resData);
    }

    private function handleResInfo(si:ResInfo):void {
        var keyUrl:String = getKeyUrl(si.url);

        var resEvent:ResEvent;
        if (_initedDic[keyUrl]) {
            //已经初始化完成
            resEvent = new ResEvent(ResEvent.COMPLETED);
            resEvent.content = _initedDic[keyUrl];
            if (si.onCompleteHandle != null) {
                var t:uint = setTimeout(function ():void {
                    si.onCompleteHandle(resEvent)
                    clearTimeout(t);
                }, 20);
            }
            return;
        }

        var newUrl:Boolean = addUrlToInitList(si);
        if (newUrl) {
            //开始加载
            if (BinaryManager.TRACE_FLAG && BinaryManager.ilog) {
                BinaryManager.ilog.info("---ResManager--LoadNew--url--{0}", si.url);
            }
            si.load(onCompleteHandler, onProgressHandler, onErrorHandler);
        } else {
            if (BinaryManager.TRACE_FLAG && BinaryManager.ilog) {
                BinaryManager.ilog.info("---ResManager--Waiting--url--{0}", si.url);
            }
        }

    }

    protected function onProgressHandler(evt:ResEvent):void {
        var keyUrl:String = getKeyUrl(evt.url);
        var toWake:WaitToWake = _waitToWake[keyUrl];
        if (toWake)
            toWake.onProgressHandle(evt);
    }

    protected function onCompleteHandler(evt:ResEvent):void {
        var keyUrl:String = getKeyUrl(evt.url);

        var i:int = keyUrl.lastIndexOf('.');
        if (evt.content is BitmapData)
            _initedDic[keyUrl] = evt.content;
        removeUrlFromInitList(keyUrl);
        var toWake:WaitToWake = _waitToWake[keyUrl];
        if (toWake)
            toWake.onCompleteHandle(evt);
        delete _waitToWake[keyUrl];

        if (BinaryManager.TRACE_FLAG && BinaryManager.ilog) {
            BinaryManager.ilog.info("---ResManager--Complete--url--{0}", keyUrl);
        }
    }

    /***
     *
     * */
    protected function onErrorHandler(evt:ResEvent):void {
        var keyUrl:String = getKeyUrl(evt.url);
        removeUrlFromInitList(keyUrl);
        var toWake:WaitToWake = _waitToWake[keyUrl];
        if (toWake)
            toWake.onErrorHandle(evt);
        delete _waitToWake[keyUrl];
    }

    /**
     * 处理url，查看是否需要
     * @param url
     * @return
     */
    private function urlHandle(url:Object):URLRequest {
        if (url == "" || url == null) return null;
        var urlReq:URLRequest = null;
        if (url is String) {
            urlReq = URLCode.decode(url as String);
        } else {
            urlReq = url as URLRequest;
        }
        return urlReq;
    }

    /***
     * 添加地址到等待列表中
     * */
    private function addUrlToInitList(vo:ResInfo):Boolean {
        if (!vo)
            return false;
        var i:int = 0;
        var compair:ResInfo;
        var toWake:WaitToWake;
        while (i < _initList.length) {
            compair = (_initList[i] as ResInfo);
            if (compair.url == vo.url) {
                toWake = _waitToWake[compair.url];
                if (!(toWake)) {
                    toWake = new WaitToWake();
                }
                toWake.url = compair.url;
                toWake.addCompleteHandle(vo.onCompleteHandle);
                toWake.addProgressHandles(vo.onProgressHandle);
                toWake.addErrorHandles(vo.onErrorHandle);
                _waitToWake[compair.url] = toWake;
                return false;
            }
            i++;
        }
        _initList.push(vo);
        return true;
    }

    /**
     * 移除正在初始化项目引用
     * @param vo
     */
    private function removeUrlFromInitList(url:String):void {
        if (!url)
            return;
        var i:int;
        while (i < _initList.length) {
            if (_initList[i].url == url) {
                _initList.splice(i, 1);
                break;
            }
            i++;
        }
    }

    public function memoryClean():void {
        for (var key1:* in _initedDic) {
            memoryCleanByUrl(key1)
        }
    }

    public function memoryCleanByUrl(url:String):void {
        var content:* = _initedDic[url];
        if (content) {
            if (content is BitmapData) {
                (content as BitmapData).dispose();
            } else if (content is ByteArray) {
                (content as ByteArray).clear();
            }
            content = null;
        }
//        var bi:ResInfo = _initedDic[url];
//        if(bi){
//            bi.dispose();
//        }
        delete _initedDic[url];
        BinaryManager.instance().memoryCleanByUrl(url);
    }

    /**
     * 获取可以解析此文件的解析器
     * @param url
     * @return
     */
    public static function getParserFromSuffix(url:String):ResParseBase {
        var base:String = (url.indexOf('?') > 0) ? url.split('?')[0] : url;
        var i:int = base.lastIndexOf('.');
        var _fileExtension:String = base.substr(i + 1).toLowerCase();

        var len:uint = _parsers.length;
        for (i = len - 1; i >= 0; i--) {
            if (_parsers[i].supportsType(_fileExtension))
                return new _parsers[i]();
        }
        return null;
    }

    /**
     * 获取此文件的关键字索引
     * @param url
     * @return
     */
    public static function getKeyUrl(url:String):String {
        var base:String = (url.indexOf('?') > 0) ? url.split('?')[0] : url;
        return base;
    }

    public static function enableParser(parser:Class):void {
        if (_parsers.indexOf(parser) < 0)
            _parsers.push(parser);
    }

    public static function enableParsers(parsers:Vector.<Class>):void {
        var pc:Class;
        for each (pc in parsers)
            enableParser(pc);
    }

    /**
     * 设置使用加密文件是否开启  ，如果开启则加载时使用加密文件
     * @param value
     */
    public static function set encodeOn(value:Boolean):void {
        if (value) {
            _deCodeArray = ["awd", "awp"];
            _enCodeArray = ["pad", "pap"];
            _parsers = Vector.<Class>([ ImageResParse, EAWDResParse, EAWPResParse]);
        } else {
            _deCodeArray = [];
            _enCodeArray = [];
            _parsers = Vector.<Class>([ ImageResParse]);
        }
    }

    /**
     * 获取加密过后的文件名
     * @param url
     * @return
     */
    public static function getEncryptUrl(url:String):String {
        var base:String = (url.indexOf('?') > 0) ? url.split('?')[0] : url;
        var i:int = base.lastIndexOf('.');
        var _fileExtension:String = base.substr(i + 1);
        var _fileName:String = base.substr(0, i);
        var ii:int = base.lastIndexOf('/');
        var _singleName:String = _fileName.substr(ii + 1);
        var _decodeIndex:int = _deCodeArray.indexOf(_fileExtension.toLowerCase());
        if (_decodeIndex > -1) {
            //名字首先放入加密文件夹中
            _singleName = "encode/" + _singleName;
            _fileExtension = _enCodeArray[_decodeIndex];
            var newEncryptUrl:String = _fileName.substr(0, ii) + "/" + _singleName + "." + _fileExtension;
            return newEncryptUrl;
        }
        return url;
    }
}
}
