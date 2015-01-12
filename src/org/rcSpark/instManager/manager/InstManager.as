/**
 * Class name: InstManager.as
 * Description:
 * Author: caoqingshan
 * Create: 14-12-8 下午1:43
 */
package org.rcSpark.instManager.manager {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import org.rcSpark.binaryManager.data.WaitToWake;

import org.rcSpark.instManager.data.InstData;
import org.rcSpark.instManager.data.ToInstInfo;
import org.rcSpark.instManager.loader.InstLoader;
import org.rcSpark.tools.core.AsyncCallQuene;

public class InstManager {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    /**
     * 缓存
     */
    private var _contentDatas:Dictionary;

    /**
     * 初始化等待列表
     */
    private var _waitToWake:Dictionary;

    /**
     * 等待初始列表
     * */
    private var _waitList:Vector.<ToInstInfo>;
    /**
     * 正在初始化列表
     * */
    private var _instList:Vector.<ToInstInfo>;
    /**
     * 当前初始化数量
     */
    private var _instCount:uint;

    private static var __instance:InstManager;

    private static const MAX_THREAD:uint = 20;


    public function InstManager() {
        if (__instance) {
            throw new Error("LDInitManager is single!")
            return;
        }
        _contentDatas = new Dictionary(true);
        _waitToWake = new Dictionary(true);

        _waitList = new Vector.<ToInstInfo>();
        _instList = new Vector.<ToInstInfo>();
    }

    public static function instance():InstManager {
        if (!__instance)
            __instance = new InstManager();
        return __instance;
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    /**
     * 获取一个新的实例对象
     * @param url
     * @return
     */
    public function getInstData(url:String):* {
        var initData:InstData = _contentDatas[url];
        if (initData) {
            return initData.getContent();
        }
        return null;
    }

    /**
     * 向管理器中添加一个新的图片
     * @param url
     * @return
     */
    public function initBaData(url:String, ba:ByteArray, onCompleteHandler:Function = null, inDomain:Boolean = false, type:String = ""):void {
        if (_contentDatas[url] != undefined) {
            if (onCompleteHandler != null) {
                onCompleteHandler.apply(null, [(_contentDatas[url] as InstData).getContent()]);
            }
            return;
        }

        var toInstInfo:ToInstInfo = new ToInstInfo();
        toInstInfo.url = url;
        toInstInfo.ba = ba;
        toInstInfo.type = type;
        toInstInfo.inDomain = inDomain;
        toInstInfo.onCompleteHandle = onCompleteHandler;

        addUrlToWaitList(toInstInfo);
        startInst();
        return;
    }

    public function initData(url:String, content:*,type:String = ""):* {
        var content_n:* = getInstData(url);
        if(content_n){
            return content_n;
        }
        var instData:InstData = new InstData();
        instData.content = content;
        instData.url = url;
        instData.count = 0;
        instData.type = type;
        _contentDatas[instData.url] = instData;
        return instData.getContent();
    }

    protected function startInst():void {
        if (this._instCount < MAX_THREAD && this._waitList.length > 0) {
            var toInstInfo:ToInstInfo = this._waitList.shift();
            if (toInstInfo != null) {
                this._instCount++;
                if (!_instList)
                    _instList = new Vector.<ToInstInfo>();
                _instList.push(toInstInfo);

                if ([InstFormat.LOADER, InstFormat.BITMAP].indexOf(toInstInfo.type) > -1) {
                    var loader:InstLoader = new InstLoader(toInstInfo);
                    //TODO 此处处理有无必要 使用异步处理
                    loader.addEventListener(Event.COMPLETE, loaderCompleteHandlerAsync);
                    //loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
                    var lc:LoaderContext = new LoaderContext();
                    lc.allowCodeImport = true;
                    if (toInstInfo.inDomain) {
                        lc.applicationDomain = ApplicationDomain.currentDomain;
                    }
                    loader.loadBytes(toInstInfo.ba, lc);
                } else {
                    toInstInfo.ba.position = 0;
                    var instData:InstData;
                    switch (toInstInfo.type) {
                        case InstFormat.BINARY :
                            instData = new InstData();
                            instData.content = toInstInfo.ba;
                            break;
                        case InstFormat.TEXT :
                            var text:String = toInstInfo.ba.readUTFBytes(toInstInfo.ba.bytesAvailable);
                            instData = new InstData();
                            instData.content = text;
                            break;
                        case InstFormat.XML :
                            var str:String = toInstInfo.ba.readUTFBytes(toInstInfo.ba.bytesAvailable);
                            var xml:XML = new XML(str);
                            instData = new InstData();
                            instData.content = xml;
                            break;
                        default :
                            instData = new InstData();
                            instData.content = toInstInfo.ba;
                            break;
                    }
                    removeUrlFromInstingList(toInstInfo);
                    if (instData) {
                        instData.url = toInstInfo.url;
                        instData.count = 0;
                        instData.type = toInstInfo.type;
                        _contentDatas[instData.url] = instData;

                        if (toInstInfo.onCompleteHandle != null) {
                            toInstInfo.onCompleteHandle.apply(null, [instData.getContent()])
                        }
                        var toWake:WaitToWake = _waitToWake[toInstInfo.url];
                        if (toWake) {
                            for (var i:int = 0; i < toWake.completeHandles.length; i++) {
                                var handle:Function = toWake.completeHandles[i];
                                if (handle != null)
                                    handle.apply(null, [instData.getContent()]);
                            }
                        }
                    }
                    delete _waitToWake[toInstInfo.url];
                    this._instCount--;
                    startInst();
                }
            }
        }
    }

    private function loaderCompleteHandlerAsync(event:Event):void {
        var loader:InstLoader = event.currentTarget as InstLoader;
        if (loader.hasEventListener(Event.COMPLETE))
            loader.removeEventListener(Event.COMPLETE, loaderCompleteHandlerAsync);
        AsyncCallQuene.instance().asyncCallByTick(loaderCompleteHandler, [event]);
    }


    private function loaderCompleteHandler(event:Event):void {
        var loader:InstLoader = event.currentTarget as InstLoader;
        if (loader.hasEventListener(Event.COMPLETE))
            loader.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
        if (!loader || !loader.loader || !loader.loader.content) {
            throw new Error("why no content");
            return;
        }

        var toInitInfo:ToInstInfo = loader.getToInitData();

        var instData:InstData;
        if (InstFormat.BITMAP == toInitInfo.type) {
            if (loader.loader.content is Bitmap) {
                instData = new InstData();
                instData.content = Bitmap(loader.loader.content).bitmapData;

            } else if (loader.loader.content is MovieClip) {
                var mc:MovieClip = MovieClip(loader.loader.content);
                var bitmapData:BitmapData = new BitmapData(mc.width, mc.height, true, 0);
                bitmapData.draw(mc, null, null, null, null, false);
                mc.stop();
                instData = new InstData();
                instData.content = bitmapData;
            }

            instData.url = toInitInfo.url;
            instData.count = 0;
            instData.type = toInitInfo.type;
            _contentDatas[instData.url] = instData;

        } else if (InstFormat.LOADER == toInitInfo.type) {
            instData = new InstData();
            instData.content = loader.loader.content;
            instData.url = toInitInfo.url;
            instData.count = 0;
            instData.type = toInitInfo.type;
        }


        if (instData) {
            if (toInitInfo.onCompleteHandle != null) {
                toInitInfo.onCompleteHandle.apply(null, [instData.getContent()])
            }
            var toWake:WaitToWake = _waitToWake[toInitInfo.url];
            if (toWake) {
                for (var i:int = 0; i < toWake.completeHandles.length; i++) {
                    var handle:Function = toWake.completeHandles[i];
                    if (handle != null)
                        handle.apply(null, [instData.getContent()]);
                }
            }
        }
        removeUrlFromInstingList(toInitInfo);

        loader.dispose();

        delete _waitToWake[toInitInfo.url];
        this._instCount--;
        startInst();
    }

    private function removeUrlFromInstingList(vo:ToInstInfo):void {
        if (!vo)
            return;
        var i:int;
        while (i < _instList.length) {
            if (_instList[i].url == vo.url) {
                _instList.splice(i, 1);
                break;
            }
            i++;
        }
    }

    /***
     * 添加地址到等待列表中
     * */
    private function addUrlToWaitList(vo:ToInstInfo):void {
        if (!vo)
            return;
        var i:int = 0;
        var compair:ToInstInfo;
        var toWake:WaitToWake;

        if (!compair) {
            i = 0;
            while (i < _instList.length) {
                if (_instList[i].url == vo.url) {
                    compair = _instList[i];
                    break;
                }
                i++;
            }
        }

        if (!compair) {
            i = 0;
            while (i < _waitList.length) {
                if (_waitList[i].url == vo.url) {
                    compair = _waitList[i];
                    break;
                }
                i++;
            }
        }

        if (compair) {
            toWake = _waitToWake[compair.url];
            if (!(toWake)) {
                toWake = new WaitToWake();
            }
            toWake.url = compair.url;
            toWake.addCompleteHandle(vo.onCompleteHandle);
            _waitToWake[compair.url] = toWake;
            return;
        }
        _waitList.push(vo);
    }

    /**
     * 清理实例化Bitmap的内存
     * TODO 暂时只有自减计数器
     * @param url
     * @return
     */
    public function disposeOne(url:String):Boolean {
        var initData:InstData = _contentDatas[url];
        if (initData != null) {
            //存在属性
            initData.delOneUse();
            return true;
        }
        return false;
    }

    //TODO
    //定期清理部分内存
    public function gc():void {
        for (var key:Object in _contentDatas) {
            var initData:InstData = _contentDatas[key];
            if (initData.count == 0) {
                initData.dispose();
                delete _contentDatas[key];
            }
        }
    }
}
}
