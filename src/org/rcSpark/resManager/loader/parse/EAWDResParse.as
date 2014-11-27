/**
 * Class name: AWDResParse.as
 * Description:
 * Author: caoqingshan
 * Create: 14-9-25 下午4:33
 */
package org.rcSpark.resManager.loader.parse {
import flash.utils.ByteArray;
import flash.utils.Endian;

public class EAWDResParse extends ResParseBase {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    /**
     * 外部设置解密函数
     */
    public static var decodeByteArray:Function;

    public static function supportsType(extension:String):Boolean {
        extension = extension.toLowerCase();
        return (["pad"].indexOf(extension) > -1);
    }

    public function EAWDResParse() {
        super();
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    /**
     * @inheritDoc
     */
    protected override function proceedParsing():Boolean {
        var _byteData:ByteArray = new ByteArray();
        _byteData.endian = Endian.LITTLE_ENDIAN;
        _byteData.writeBytes(getByteData())
        var outBa:ByteArray = decodeByteArray(_byteData);
        finishParse(outBa);
        return true;
    }
}
}
