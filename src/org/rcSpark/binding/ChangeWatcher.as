/**
 * Class Name: ChangeWatcher
 * Description:绑定 观察者
 * Created by Ryan on 2014/10/18 17:10.
 */
package org.rcSpark.binding {

public class ChangeWatcher {
    //-----------------------------------------
    //Var
    //-----------------------------------------
    private var _host:IBindingData;
    private var _name:String;
    private var _handler:Function;

    public static function watch(host:IBindingData,access:Object,handler:Function):ChangeWatcher{
        var c:ChangeWatcher = new ChangeWatcher(access,handler);
        c.reset(host);
        return c;
    }

    public function ChangeWatcher(access:Object, handler:Function) {
        _host = null;
        _name = access is String ? access as String : access.name;
        _handler = handler;
    }

    //-----------------------------------------
    //Methods
    //-----------------------------------------

    private function reset(newHost:IBindingData):void {
        if (_host != null)
        {
            _host.dataChanged.remove(wrapHandler);
        }

        _host = newHost;

        if (_host != null)
        {
            _host.dataChanged.add(wrapHandler);
        }
    }

    /**
     *  @private
     *  Listener for change events.
     *  Resets chained watchers and calls user-supplied handler.
     */
    private function wrapHandler(pDatas:Array):void
    {
        var propertyName:String = pDatas[0] ;
        if(propertyName === _name){
            //自己的属性发生变化了
            var propertyData:* = pDatas[1] ;
            _handler(propertyData);
        }
    }

    public function unwatch():void{
        reset(null);
    }

    public function getValue():* {
        return _host == null ? null : _host[_name];
    }

    public function setHandler(handler:Function):void {
        _handler = handler;
    }
}
}
