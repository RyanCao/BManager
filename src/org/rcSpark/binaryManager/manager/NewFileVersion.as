/*******************************************************************************
 * Class name:	NewFileVersion.as
 * Description:	使用新文件的版本控制类
 * Author:		Ryan
 * Create:		Jun 18, 2014 10:58:54 AM
 * Update:		Jun 18, 2014 10:58:54 AM
 ******************************************************************************/
package org.rcSpark.binaryManager.manager
{
//-----------------------------------------------------------------------------
// import_declaration
//-----------------------------------------------------------------------------
import flash.utils.Dictionary;

public class NewFileVersion implements IVersion
{
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    private static var __instance:IVersion;
    /**
     * 存取格式：
     * key:keyUrl,data:md5version
     */
    private var _resVersionDic:Dictionary;

    /**
     * 版本串格式
     */
    public static var versionRegExp:RegExp = /_[a-f0-9]{32}/;
    //-----------------------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------------------
    public function NewFileVersion()
    {
    }
    public static function instance():IVersion
    {
        if(!__instance)
            __instance = new NewFileVersion();
        return __instance ;
    }
    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    public function initVersion(dic:Dictionary):void
    {
        _resVersionDic = dic ;
    }

    public function getVersion(url:String):String
    {
        return _resVersionDic[url];
    }

    public function getVersionUrl(url:String, version:String):String
    {
        var checkString:String =("_"+version).replace(versionRegExp,"");
        if(checkString == "")
        {
            //版本号正确
            var keyUrl:String = getKeyUrl(url);
            var fileArr:Array = getFileNameAndExt(keyUrl);
            fileArr[0] += "_"+version ;
            if(String(fileArr[1]).length>0)
                return fileArr.join(".");
            return fileArr[0];
        }
        return url;
    }

    public function getNewestUrl(url:String):String
    {
        var keyUrl:String = getKeyUrl(url);
        if(_resVersionDic[keyUrl])
            return getVersionUrl(url,_resVersionDic[url]) ;
        return url;
    }

    /**
     * 通过文件路径获取文件前缀与后缀
     * @param url
     * @return
     */
    private function getFileNameAndExt(url:String):Array{
        var fileArr:Array = url.split(".");
        //文件后缀名
        var fileExtString:String = "" ;
        //文件名 无后缀
        var fileNameNoExtString:String = "" ;
        if(fileArr.length>1){
            if(fileArr.length > 2)
                fileNameNoExtString = fileArr.slice(0,fileArr.length-1).join(".");
            else
                fileNameNoExtString = fileArr[0];
            fileExtString = fileArr[fileArr.length - 1];
        }else{
            fileNameNoExtString = fileArr[0];
            fileExtString = "" ;
        }
        return [fileNameNoExtString,fileExtString];
    }

    /**
     * 通过文件前缀获取最可能的版本号与文件前缀Key
     * @param fileNameNoExtString
     * @return
     */
    private function getMostPossibleVersions(fileNameNoExtString:String):Array{
        var rmVersionFileName:String ="" ;
        var versionStr:String = "" ;

        var fileNames:Array = String(fileNameNoExtString).split("_");
        if(fileNames.length > 2)
            rmVersionFileName = fileNames.slice(0,fileNames.length-1).join("_");
        else
            rmVersionFileName = fileNames[0];

        if(fileNames.length > 1)
            versionStr = fileNames[fileNames.length - 1];
        else
            versionStr = "";
        return [rmVersionFileName,versionStr];
    }

    public function getKeyUrl(url:String):String
    {
        var keyUrl:String = url.replace(versionRegExp,"");
        if(getVersion(keyUrl))
            return keyUrl;
        return url ;
    }
}
}