/**
 * Class name: ToInstInfo.as
 * Description:
 * Author: caoqingshan
 * Create: 14-12-8 下午3:27
 */
package org.rcSpark.instManager.data {
import flash.utils.ByteArray;

public class ToInstInfo {
    public var url:String;
    public var onCompleteHandle:Function;
    public var ba:ByteArray;
    public var type:String;
    public var inDomain:Boolean;
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------

    public function ToInstInfo() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------

    public function dispose():void {
        onCompleteHandle = null;
        ba = null;
    }
}
}
