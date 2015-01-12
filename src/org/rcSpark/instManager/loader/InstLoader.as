/**
 * Class name: InitLoader.as
 * Description:
 * Author: caoqingshan
 * Create: 14-12-8 下午3:52
 */
package org.rcSpark.instManager.loader {

import flash.display.Loader;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

import org.rcSpark.binaryManager.loader.BaseLoader;

import org.rcSpark.instManager.data.ToInstInfo;

public class InstLoader extends BaseLoader {
    private var _data:ToInstInfo;
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------

    public function InstLoader(data:ToInstInfo, target:IEventDispatcher = null) {
        super(target);
        _loader = new Loader();
        _data = data;
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    public function getToInitData():ToInstInfo {
        return this._data;
    }

    override public function loadBytes(bytes:ByteArray, ct:LoaderContext):void {
        var loader:Loader = _loader as Loader;
        if (!loader.contentLoaderInfo.hasEventListener(Event.COMPLETE))
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
        loader.loadBytes(bytes, ct);
    }

    override protected function onCompleteHandler(evt:Event):void {
        var loader:Loader = _loader as Loader;
        if (loader && loader.contentLoaderInfo && loader.contentLoaderInfo.hasEventListener(Event.COMPLETE))
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompleteHandler);
        this.dispatchEvent(evt);
    }

    /**
     * 销毁方法
     * */
    override public function dispose():void {
        var loader:Loader = _loader as Loader;
        if (loader) {
            if (loader.contentLoaderInfo && loader.contentLoaderInfo.hasEventListener(Event.COMPLETE))
                loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompleteHandler);
            loader.unloadAndStop();
            loader = null;
        }
        if (_data) {
            _data.dispose();
            _data = null;
        }
    }

    public function get loader():Loader {
        return _loader as Loader;
    }
}
}
