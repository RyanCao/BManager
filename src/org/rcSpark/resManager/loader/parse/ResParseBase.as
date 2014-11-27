/**
 * Class name: ResParseBase.as
 * Description:
 * Author: caoqingshan
 * Create: 14-9-17 下午4:30
 */
package org.rcSpark.resManager.loader.parse {
import flash.utils.ByteArray;

import org.rcSpark.resManager.error.AbstractMethodError;
import org.rcSpark.tools.core.AsyncCallQuene;

public class ResParseBase {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    /**
     * 需要解析的资源数据
     */
    protected var _data:*;
    /**
     * 解析成功后的回调函数
     */
    protected var _parseCompleteHandler:Function;

    public function ResParseBase() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    /**
     * Parse the next block of data.
     * @return Whether or not more data needs to be parsed. Can be <code>ParserBase.PARSING_DONE</code> or
     * <code>ParserBase.MORE_TO_PARSE</code>.
     */
    protected function proceedParsing():Boolean {
        throw new AbstractMethodError();
        return true;
    }

    protected function getByteData():ByteArray {
        return _data;
    }

    public function parse(data:*, parseCompleteHandler:Function = null):void {
        _data = data;
        _parseCompleteHandler = parseCompleteHandler;
        //proceedParsing()
        //更换成异步处理 by cqs
        AsyncCallQuene.instance().asyncCallByTick(proceedParsing);
    }

    protected function finishParse(data:*):void {
        if (_parseCompleteHandler != null)
            _parseCompleteHandler(data)
    }

    /**
     * 获取加密文件名
     * @param url
     * @return
     */
    public function getEncryptUrl(url:String):String {
        return url ;
    }
}
}
