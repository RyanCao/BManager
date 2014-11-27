/**
 * Class Name: BindingData
 * Description:绑定数据基类
 * Created by Ryan on 2014/10/18 16:53.
 */
package org.rcSpark.binding {
import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

public class BindingData implements IBindingData {
    //-----------------------------------------
    //Var
    //-----------------------------------------
    private var _dataChanged:Signal

    public function BindingData() {
    }

    //-----------------------------------------
    //Methods
    //-----------------------------------------
    public function update(propertyName:String,protertyValue:*):void{
        if(_dataChanged)
            _dataChanged.dispatch([propertyName,protertyValue]);
    }

    public function get dataChanged():ISignal {
        return _dataChanged ||= new Signal(Array);
    }
}
}
