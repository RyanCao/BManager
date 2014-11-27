package tools {
import flash.utils.Dictionary;

/**
 * @author ryan
 */
public class CmdHandle {

    private var _dic:Dictionary;
    private var _infodic:Dictionary;
    private var _lendic:Dictionary;

    /**
     * 注册脚本指令
     */
    public function CmdHandle() {
        _dic = new Dictionary(true);
        _infodic = new Dictionary(true);
        _lendic = new Dictionary(true);
    }

    public function register(cmdname:String = "", argslen:int = 0, handle:Function = null, info:String = "", isshow:Boolean = true):void {
        if (_dic) {
            _dic[cmdname] = handle;
        }

        if (_infodic) {
            if (isshow)
                _infodic[cmdname] = info;
        }

        if (_lendic) {
            _lendic[cmdname] = argslen;
        }
    }

    public function handle(cmdname:String = "", args:Array = null):void {
        if (_dic && _dic[cmdname]) {
            var f:Function = _dic[cmdname];
            var needargs:int = _lendic[cmdname];

            var len:int = 0;
            if (args)
                len = args.length;
            if (needargs == 0)
                f();
            else if (args && args.length >= needargs)
                f.apply(null,args);
            else
                JSLogger.error("--CmdHandle--Error--当前命令的参数不对，应该有" + needargs + "个，现在是" + len + "个\n");
        }
    }

    public function get infoDic():Dictionary {
        return _infodic;
    }
}
}
