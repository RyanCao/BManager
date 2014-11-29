/**
 * Class name: AWPResParse.as
 * Description:
 * Author: caoqingshan
 * Create: 14-9-25 下午4:33
 */
package org.rcSpark.resManager.parse {
//import com.hurlant.util.Base64;

import flash.utils.ByteArray;
import flash.utils.Endian;

public class EAWPResParse extends ResParseBase {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    /**
     * 外部设置解密函数
     */
    public static var decodeByteArray:Function;

    public static function supportsType(extension:String):Boolean {
        extension = extension.toLowerCase();
        return (["pap"].indexOf(extension) > -1);
    }

    public function EAWPResParse() {
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
        var outString:String = outBa.readUTFBytes(outBa.length);
        outString = outString.replace(/\n/g, "");
        var decodeBa:ByteArray //= Base64.decodeToByteArray(outString);
        finishParse(decodeBa);
        return true;
    }
}
}
