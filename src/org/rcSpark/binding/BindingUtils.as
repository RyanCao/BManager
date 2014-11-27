/**
 * Class Name: BindingUtils
 * Description:
 * Created by Ryan on 2014/10/18 18:19.
 */
package org.rcSpark.binding {
public class BindingUtils {
    //-----------------------------------------
    //Var
    //-----------------------------------------

    public function BindingUtils() {
    }

    //-----------------------------------------
    //Methods
    //-----------------------------------------

    public static function bindProperty(
            site:Object, prop:String,
            host:IBindingData, access:Object):ChangeWatcher
    {
        var w:ChangeWatcher =
                ChangeWatcher.watch(host, access, null);

        if (w != null)
        {
            var assign:Function = function(event:*):void
            {
                site[prop] = w.getValue();
            };
            w.setHandler(assign);
            assign(null);
        }

        return w;
    }
}
}
