/**
 * Class Name: IBindingData
 * Description:
 * Created by Ryan on 2014/10/18 16:50.
 */
package org.rcSpark.binding {
import org.osflash.signals.ISignal;

public interface IBindingData {
    /**
     * 数据改变通知
     * @param propertyName
     * @param protertyValue
     */
    function update(propertyName:String,protertyValue:*):void;

    function get dataChanged():ISignal ;
}
}
