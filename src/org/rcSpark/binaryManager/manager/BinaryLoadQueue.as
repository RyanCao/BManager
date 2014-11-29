/**
 * Class Name: BinaryLoadQueue
 * Description:二进制加载队列
 * Created by Ryan on 2014/11/27 22:57.
 */
package org.rcSpark.binaryManager.manager {
import org.rcSpark.binaryManager.data.BinaryInfo;
import org.rcSpark.binaryManager.loader.LoadType;

public class BinaryLoadQueue {
    //-----------------------------------------
    //Var
    //-----------------------------------------
    /**
     * 类型
     */
    public var type:uint = LoadType.OTHER ;
    /**
     * 此队列最大线程数
     */
    public var maxThread:uint = 3;
    /**
     * 此队列当前线程数
     */
    public var nowThread:uint = 0;

    /**
     * 当前加载队列数据
     */
    private var _waitList:Vector.<BinaryInfo>;

    public function BinaryLoadQueue(_type:uint = 0,_maxThread:uint = 3) {
        _waitList = new Vector.<BinaryInfo>();
        type = _type ;
        maxThread = _maxThread ;
    }

    //-----------------------------------------
    //Methods
    //-----------------------------------------
    /**
     * 通过url获取BinaryInfo信息
     * @param url
     * @return
     */
    public function getBinaryInfoByUrl(url:String):BinaryInfo {
        var i:int = 0;
        while (i < _waitList.length) {
            if(_waitList[i].url === url){
                return _waitList[i];
                break;
            }
            i++;
        }
        return null;
    }

    /**
     * 向队列中添加一个数据
     * @param vo
     */
    public function addItem(vo:BinaryInfo):void {
        _waitList.push(vo);
        _waitList.sort(compareWaitRes);
    }

    private function compareWaitRes(resData1:BinaryInfo,resData2:BinaryInfo):Number{
        if(resData1.loadLevel<resData2.loadLevel) return -1 ;
        else if(resData1.loadLevel==resData2.loadLevel) return 0 ;
        else  return 1 ;
    }

    public function get waitList():Vector.<BinaryInfo> {
        return _waitList;
    }

    public function removeItem(vo:BinaryInfo):void {
        var i:int = 0;
        while (i < _waitList.length) {
            if (_waitList[i].url == vo.url){
                _waitList.splice(i, 1);
                break;
            }
            i++;
        }
    }
}
}
