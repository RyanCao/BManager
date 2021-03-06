/*******************************************************************************
 * Class name:	SharedObejctFileCookie.as
 * Description:	文件缓存
 * Author:		Ryan
 * Create:		Jun 18, 2014 2:42:45 PM
 * Update:		Jun 18, 2014 2:42:45 PM
 ******************************************************************************/
package org.rcSpark.tools.file
{
import flash.net.SharedObject;

//-----------------------------------------------------------------------------
// import_declaration
//-----------------------------------------------------------------------------

public class SharedObejctFileCookie implements IFileCookie
{
	//-----------------------------------------------------------------------------
	// Var
	//-----------------------------------------------------------------------------
	private static var __instance:IFileCookie;
	
	//索引名
	private static const INDEX_NAME:String = "index_name";
	//文件夹名
	private static const DIR_NAME:String = "files";
	//域名
	private var __domainName:String = "sscq" ;
	/**
	 * 索引文件
	 * name1|ver1
	 * name2|ver2
	 */
	private var indexData:Object = {};
	//索引文件是否初始化
	private var __init:Boolean = false;
	/**
	 * so
	 * */
	private var __so:SharedObject;
	/**
	 * 存取队列
	 * */
	private var saveWaitList:Array ;
	private var MAX_THREAD:uint = 1;
	private var _loadingCount:uint = 0;
	//-----------------------------------------------------------------------------
	// Constructor
	//-----------------------------------------------------------------------------
	public function SharedObejctFileCookie()
	{
	}
	public static function instance():IFileCookie
	{
		if(!__instance)
			__instance = new SharedObejctFileCookie();
		return __instance ;
	}
	//-----------------------------------------------------------------------------
	// Methods
	//-----------------------------------------------------------------------------
	public function initIndex(domainName:String):*
	{
		__domainName = domainName ;
		var _so:SharedObject = getSharedObject() ;
		indexData = _so.data[INDEX_NAME];
		if(!indexData){
			if(_so.data[INDEX_NAME] == null){
				_so.data[INDEX_NAME] = {} ;
				_so.flush();
			}
			indexData = {};
		}
		__init = true ;
		return indexData ;
	}
	
	private function getSharedObject():SharedObject{
		return __so ||= SharedObject.getLocal(__domainName) ;
	}
	
	public function saveIndexData(fileName:String, ver:String=""):String
	{
		if(!__init)
			initIndex(__domainName);
		var _so:SharedObject = getSharedObject() ;
		_so.data[INDEX_NAME][fileName] = ver ;
		indexData[fileName] = ver ;
		return _so.flush();
	}
	
	public function readFileData(key:String, ver:String=""):*
	{
		if(!__init)
			initIndex(__domainName);
		if(isFileExist(key,ver))
		{
			var _so:SharedObject = getSharedObject() ;
			return _so.data[DIR_NAME][key];
		}
		return null ;
	}
	
	public function saveFileData(key:String, value:*, ver:String=""):String
	{
		if(!__init)
			initIndex(__domainName);
		if(!saveWaitList)
			saveWaitList = [] ;
		saveWaitList.push([key,value,ver]);
		doSaveWaitList();
		return "";
	}
	
	private function doSaveWaitList():void{
		if (saveWaitList.length > 0 && _loadingCount < MAX_THREAD) {
			_loadingCount ++ ;
			var saveData:Array = this.saveWaitList.shift();
			var key:String = saveData[0];
			var value:* = saveData[1];
			var ver:String=saveData[2];
			
			var _so:SharedObject = getSharedObject() ;
			if(_so.data[DIR_NAME] == null){
				_so.data[DIR_NAME] = {} ;
				_so.flush();
			}
			saveIndexData(key,ver);
			_so.data[DIR_NAME][key] = value ;
			_so.flush();
			
			_loadingCount -- ;
		}
	}
	
	public function isFileExist(fileName:String, ver:String=""):Boolean
	{
		if(!__init)
			initIndex(__domainName);
		var fVer:String = indexData[fileName];
		if(fVer!="undefined"&&fVer!="null"&&fVer!=null){
			if(ver&&ver!="")
				return ver==fVer ;
			else
				return true ;
		}
		return false ;
	}
}
}