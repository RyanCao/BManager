/*******************************************************************************
 * Class name:    BinaryLoader.as
 * Description:    二进制加载类
 * Author:        Ryan
 * Create:        Jun 11, 2014 6:10:33 PM
 * Update:        Jun 11, 2014 6:10:33 PM
 ******************************************************************************/
package org.rcSpark.resManager.loader {
//-----------------------------------------------------------------------------
// import_declaration
//-----------------------------------------------------------------------------
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLStream;
import flash.utils.ByteArray;

import org.rcSpark.resManager.data.BinaryInfo;
import org.rcSpark.resManager.events.BinaryEvent;
import org.rcSpark.tools.time.TimerManager;

import tools.ILogger;

public class BinaryLoader extends BaseLoader {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    protected var _data:BinaryInfo;
    private var range:int = 1024000; //每次下载的字节
    /**
     * 设置下载监视<br>
     * value : false 不进行监视
     * value : true 进行监视
     * */
    public var overlook:Boolean = false;

    /**
     * 设置超时时间<br>
     * 秒为单位
     * */
    public var overTime:uint = 3;

    private var countTime:uint = 0;

    /**
     * 加载状态，在报错与加载完成时结合判断
     */
    private var _httpStatus:int = -1;
    /**
     * 加载中止或者加载出错的文件 重试次数
     */
    private var _reloadTimes:int = 0;
    /**
     * 关键性资源重试次数
     */
    public static var reloadTimesMax:int = 3;

    public var TRACE_FLAG:Boolean;
    public var ilog:ILogger;

    //-----------------------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------------------
    public function BinaryLoader(data:BinaryInfo, target:IEventDispatcher = null) {
        super(target);
        _data = data;
        _loader = new URLStream();
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    public function getResData():BinaryInfo {
        return this._data;
    }

    //
    override public function load(urlReq:URLRequest):void {
        var loader:URLStream = _loader as URLStream;

        var useWeakReference:Boolean = false;

        if (!loader.hasEventListener(Event.COMPLETE))
            loader.addEventListener(Event.COMPLETE, onCompleteHandler);

        if (!loader.hasEventListener(HTTPStatusEvent.HTTP_STATUS))
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusHandle);

        if (!loader.hasEventListener(ProgressEvent.PROGRESS))
            loader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, useWeakReference);

        if (!loader.hasEventListener(IOErrorEvent.IO_ERROR))
            loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandle, false, 0, useWeakReference);

        if (!loader.hasEventListener(SecurityErrorEvent.SECURITY_ERROR))
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorHandle, false, 0, useWeakReference);

        loader.load(urlReq);

        countTime = 0;
        if (_data) {
            _data.urlReq = urlReq;
        }

        if (overlook)
            TimerManager.addFunction(timeHandle);
        else
            TimerManager.removeFunction(timeHandle);

        _data.state = BinaryInfo.LOADING;
    }

    /**
     * 移除监听
     */
    protected function removeLoaderHandler():void {
        var loader:URLStream = _loader as URLStream;

        if(!loader)
            return ;

        if (loader.hasEventListener(Event.COMPLETE))
            loader.removeEventListener(Event.COMPLETE, onCompleteHandler);

        if (loader.hasEventListener(HTTPStatusEvent.HTTP_STATUS))
            loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusHandle);

        if (loader.hasEventListener(SecurityErrorEvent.SECURITY_ERROR))
            loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorHandle);

        if (loader.hasEventListener(IOErrorEvent.IO_ERROR))
            loader.removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandle);

        if (loader.hasEventListener(ProgressEvent.PROGRESS))
            loader.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler);
    }


    private function timeHandle():void {
        countTime++;
        if (_data && _data.state == BinaryInfo.LOADING) {
            //只有 在加载中才回进行  判定
            if (countTime > overTime) {
                //超时无反应 重新加载
                if (TRACE_FLAG && ilog)
                    ilog.debug("BinaryLoader timeHandle {0} {1}", _data.url)
                stopLoading();
                clearDirtyData();
                startLoading();
            }
        }
    }

    /**
     * 开始加载（可以断点续传）
     * */
    override public function startLoading():void {
        if (!_data)
            return;
        load(_data.urlReq);
    }

    /**
     * 断点续传 (暫時無用)
     */
    private function downloadByRange():void {
        var startPoint:int = _data.ba ? _data.ba.bytesAvailable : 0;
        var endPoint:int = _data.bytesTotal;
        var newUrlReq:URLRequest = new URLRequest(_data.urlReq.url);
        var header:URLRequestHeader = new URLRequestHeader("Range", "bytes=" + startPoint + "-" + endPoint)//注意这里很关键，我们在请求的Header里包含对Range的描述，这样服务器会返回文件的某个部分
        newUrlReq.requestHeaders.push(header);
        if (startPoint >= endPoint) {
            return;
        }
        var loader:URLStream = _loader as URLStream;
        loader.load(newUrlReq);
    }

    /**
     * 暂停加载
     * */
    override public function stopLoading():void {
        var loader:URLStream = _loader as URLStream;
        if (loader && loader.connected)
            loader.close();
    }

    /**
     * 清理脏数据
     */
    private function clearDirtyData():void {
        if (_data) {
            _data.bytesLoaded = 0;
            _data.bytesTotal = 0;
            _data.state = BinaryInfo.NONE;
            if (_data.ba != null) {
                _data.ba.clear();
            }
        }
    }

    /**
     * 最终要执行的错误函数
     */
    protected function onFinallyErrorHandle():void {
        var resEvent:BinaryEvent = new BinaryEvent(BinaryEvent.ERROR);
        resEvent.binaryInfo = _data;
        dispatchEvent(resEvent);
        removeLoaderHandler();
        TimerManager.removeFunction(timeHandle);
        countTime = 0;
    }

    protected function onErrorHandle(evt:ErrorEvent):void {
        // 判断是不是关键资源
        if (ilog && TRACE_FLAG)
            ilog.debug("onErrorHandle: " + _data.url + _data.loadLevel + "," + _httpStatus + ", evt: " + evt);

        _data.state = BinaryInfo.ERROR;

//        if (_data.loadLevel != LoadLevel.LIB && _httpStatus >= 400) {
        if (_httpStatus >= 400) {
            //400以上的错误一定找不到文件了，直接报错
            onFinallyErrorHandle();
        } else {
            //关键性资源重试
            //TODO  关键性资源重试 判断条件需要修改
//            if (_data.loadLevel == LoadLevel.LIB)
            if ([LoadType.LIB,LoadType.CORE_FILES].indexOf(_data.loadType)>-1)
                repeatLoad();
        }
    }


    override protected function onHttpStatusHandle(evt:HTTPStatusEvent):void {
        _httpStatus = evt.status;

        if (TRACE_FLAG && ilog)
            ilog.debug("onHttpStatusHandle " + _data.urlReq.url + ", " + evt.status);

        if (evt.status >= 400) {
        } else if (evt.status == 0) {
        }
    }

    protected function onCompleteHandler(evt:Event):void {
        var loader:URLStream = _loader as URLStream;
        if (evt.type == Event.COMPLETE) {

            if (!_data.ba)
                _data.ba = new ByteArray();

            var bytes:ByteArray = _data.ba;

            if (loader.bytesAvailable > 0)
                loader.readBytes(bytes, bytes.length, loader.bytesAvailable);

            if (TRACE_FLAG && ilog)
                ilog.debug("LoadCompleted "
                        + _data.urlReq.url + ", len:"
                        + _data.ba.length + ", total:"
                        + _data.bytesTotal + ", hs:"
                        + _httpStatus);

            if ((_httpStatus >= 200 && _httpStatus < 400) || (_data.ba.length > 0 && (_data.bytesTotal == _data.ba.length || _data.bytesTotal == 0))) {
                //状态完成 或者 获取到的二进制文件完整  表示文件已完成
                removeLoaderHandler()

                _data.state = BinaryInfo.COMPLETED;
                var resEvent:BinaryEvent = new BinaryEvent(BinaryEvent.COMPLETED);
                resEvent.binaryInfo = _data;
                this.dispatchEvent(resEvent);

                if (loader.connected) {
                    loader.close();
                }

                TimerManager.removeFunction(timeHandle);
                countTime = 0;
            } else {
                repeatLoad();
            }
        }

    }

    protected function repeatLoad():void {
        // 进入重新加载流程  //BinaryLoader timeHandle
        countTime = 0;
        if (_reloadTimes < reloadTimesMax) {
            stopLoading();
            clearDirtyData();
            startLoading();
            _reloadTimes++;
            if (TRACE_FLAG && ilog)
                ilog.debug("repeatLoad " + _data.urlReq.url + ", reloadTimes:" + _reloadTimes);
        } else {
            onFinallyErrorHandle();
        }
    }


    override protected function onProgressHandler(evt:ProgressEvent):void {
        var resEvent:BinaryEvent = new BinaryEvent(BinaryEvent.PROGRESS);
        resEvent.bytesLoaded = evt.bytesLoaded;
        resEvent.bytesTotal = evt.bytesTotal;
        _data.bytesLoaded = resEvent.bytesLoaded;
        _data.bytesTotal = resEvent.bytesTotal;
        var loader:URLStream = _loader as URLStream;
        if (!_loader.connected) return;
        if (!_data.ba)
            _data.ba = new ByteArray();
        var bytes:ByteArray = _data.ba;
        if (loader.bytesAvailable > 0)
            loader.readBytes(bytes, bytes.length, loader.bytesAvailable);
        _data.state = BinaryInfo.LOADING;
        resEvent.binaryInfo = _data;
        this.dispatchEvent(resEvent);
        //有数据过来  重置监视时间点
        countTime = 0;
    }

    /**
     * 销毁方法
     * */
    override public function dispose():void {
        stopLoading();
        removeLoaderHandler();
        _loader = null;
        _data = null;
    }
}
}