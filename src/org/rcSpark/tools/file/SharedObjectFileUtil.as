/**
 * Class name:SharedObjectFileUtil.as
 * Description:
 * Author: Ryan
 * Created: 13-12-13 上午11:38
 */
package org.rcSpark.tools.file {
import flash.net.SharedObject;

public class SharedObjectFileUtil {
    //---------------------------------------------------------------
    //Var
    //---------------------------------------------------------------
    //域名
    private static var __domainName:String = "sscq" ;
    //索引名
    private static const INDEX_NAME:String = "index_name";
    //文件夹名
    private static const DIR_NAME:String = "files";
    /**
     * 索引文件
     * name1|ver1
     * name2|ver2
     */
    private static var indexData:Object = {};
    public function SharedObjectFileUtil() {
    }

    //---------------------------------------------------------------
    //Methods
    //---------------------------------------------------------------
    /**
     * 初始化存取类
     * @param domainName 域名
     * @return
     */
    public static function initIndex(domainName:String):*{
        __domainName = domainName ;
        var _so:SharedObject = SharedObject.getLocal(__domainName) ;
        indexData = _so.data[INDEX_NAME];
        if(!indexData){
            if(_so.data[INDEX_NAME] == null){
                _so.data[INDEX_NAME] = {} ;
                _so.flush();
            }
            indexData = {};
        }
        return indexData ;
    }

    /**
     * 存取并更新索引文件
     * @param fileName
     * @param ver
     */
    private static function saveIndexData(fileName:String,ver:String=""):String{
        var _so:SharedObject = SharedObject.getLocal(__domainName) ;
        _so.data[INDEX_NAME][fileName] = ver ;
        indexData[fileName] = ver ;
        return _so.flush();
    }

    public static function readFileData(key:String,ver:String=""):*{
        var _so:SharedObject = SharedObject.getLocal(__domainName) ;
        if(isFileExist(key,ver))
        {
            return _so.data[DIR_NAME][key];
        }
        return null ;
    }

    /**
     * 永久存取在机器上
     * @param key
     * @param value toByteArray
     * @param fileType 文件类型
     * @param ver 文件
     * @return
     *
     */
    public static function saveFileData(key:String,value:*,ver:String=""):String{
        var _so:SharedObject = SharedObject.getLocal(__domainName) ;
        if(_so.data[DIR_NAME] == null){
            _so.data[DIR_NAME] = {} ;
            _so.flush();
        }
        saveIndexData(key,ver);
        _so.data[DIR_NAME][key] = value ;
        return _so.flush();
    }

    /**
     * 判断某个文件是否存于本地
     * @param fileName 文件名称
     * @param ver      文件版本号（验证是否是需要的文件）
     * @return
     */
    private static function isFileExist(fileName:String,ver:String=""):Boolean{
        var fVer:String = indexData[fileName];
        if(fVer!="undefined"&&fVer!="null"&&fVer!=null){
            if(ver!="")
                return ver==fVer ;
            else
                return true ;
        }
        return false ;
    }
}
}
