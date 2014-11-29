package org.osflash.async {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

import org.rcSpark.rcant;
import org.rcSpark.resManager.events.BinaryEvent;
import org.rcSpark.resManager.manager.NBinaryManager;
import org.rcSpark.tools.core.AsyncCallQuene;

public class LoaderDeferred extends Deferred {

    private var _loader:Loader;
    private var _success:Boolean;
    private var _inDomain:Boolean;

    private var _data:*;
    private var _url:String;
    private var _contentFormat:String;
    private var _info:*;
    private var _bitmapData:BitmapData

    public function get url():String {
        return _url;
    }

    public function LoaderDeferred() {
        _success = false;
    }

    public function dispose():void {
        if (loader) {
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadIOErrorHandler);
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandlerAsync);
            loader.unload();

        }
    }

    //--------------------------------------------------------------------------
    //		Event Handler
    //--------------------------------------------------------------------------
    /**
     * 加载函数
     * @param url 绝对地址
     * @param contentFormat 初始化类型 参考 ResFormat
     * @param loadLv 加载优先级  越小，加载顺序越靠前
     * @param inDomain  是否加载到主域【主要用于加载类库】
     * @return
     *
     */
    public function load(url:String, contentFormat:String,type:int,inDomain:Boolean=true):LoaderDeferred
    {
        if (_success == false )
        {
            this._contentFormat = contentFormat
            this._url  =url;
            _inDomain = inDomain ;
            //BinaryManager.instance().rcant::load(url,0,onCompleteHandler,onProgressHandler,onErrorHandler);
            NBinaryManager.instance().rcant::load(url,type,0,onCompleteHandlerAsync,onProgressHandler,onErrorHandler);
        }
        return this;
    }

    protected function onProgressHandler(event:BinaryEvent):void {
        if (url != event.binaryInfo.url)
            return;
        //更新进度
//		progress2(event.bytesLoaded,event.bytesTotal);
        progress(event.bytesLoaded / event.bytesTotal);
    }

    protected function onErrorHandler(event:BinaryEvent):void {
        if (url != event.binaryInfo.url)
            return;
        reject(new Error("ioErrorHandler" + url))
    }

    private function onCompleteHandlerAsync(e:BinaryEvent):void {
        AsyncCallQuene.instance().asyncCallByTick(onCompleteHandler, [e]);
    }

    protected function onCompleteHandler(event:BinaryEvent):void {
        if (url != event.binaryInfo.url)
            return;
        _success = true;
        var ba:ByteArray = event.binaryInfo.ba;
        ba.position = 0;
        switch (_contentFormat) {
            case ResFormat.BINARY :
                data = ba;
                break;
            case ResFormat.TEXT :
                var text:String = ba.readUTFBytes(ba.bytesAvailable);
                data = text;
                break;
            case ResFormat.XML :
                var str:String = ba.readUTFBytes(ba.bytesAvailable);
                var xml:XML = new XML(str);
                data = xml;
                break;
            case ResFormat.LOADER:
            case ResFormat.BITMAP :
                loader = new Loader();
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandlerAsync);
                loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadIOErrorHandler);
                var lc:LoaderContext = new LoaderContext();
                if (_inDomain)
                    lc.applicationDomain = ApplicationDomain.currentDomain;
                lc.allowCodeImport = true;
                loader.loadBytes(ba, lc);
                return;
                break;
            default :
                break;
        }
        resolve(this);
    }

    override public function resolve(outcome:* = null):void {
        super.resolve(outcome);
    }

    protected function loadIOErrorHandler(event:IOErrorEvent):void {
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadIOErrorHandler);
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandlerAsync);
    }

    private function loaderCompleteHandlerAsync(event:Event):void {
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadIOErrorHandler);
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandlerAsync);
        AsyncCallQuene.instance().asyncCallByTick(loaderCompleteHandler, [event]);
    }

    private function loaderCompleteHandler(event:Event):void {
        if (!_loader || !_loader.content)
            return;
        if (ResFormat.BITMAP == contentFormat) {

            if (_loader.content is Bitmap) {
                if (_bitmapData == null)_bitmapData = Bitmap(_loader.content).bitmapData;
            }
            else if (_loader.content is MovieClip) {
                if (_bitmapData == null) {
                    var mc:MovieClip = MovieClip(_loader.content);
                    var bitmapData:BitmapData = new BitmapData(mc.width, mc.height, true, 0);
                    bitmapData.draw(mc, null, null, null, null, false);
                    _bitmapData = bitmapData;
                }
            }

        } else if (ResFormat.LOADER == contentFormat) {
            data = _loader.content
        }

        resolve(this)
    }

    public function set loader(value:Loader):void {
        _loader = value;
    }

    public function get loader():Loader {
        return _loader;
    }

    public function get bitmapData():BitmapData {
        return _bitmapData;
    }

    public function set bitmapData(value:BitmapData):void {
        _bitmapData = value;
    }

    public function get data():* {
        return _data;
    }

    public function set data(value:*):void {
        _data = value;
    }

    public function get contentFormat():String {
        return _contentFormat;
    }

    public function set contentFormat(value:String):void {
        _contentFormat = value;
    }

    public function get info():* {
        return _info;
    }

    public function set info(value:*):void {
        _info = value;
    }


}
}
