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
		var _so:SharedObject = SharedObject.getLocal(__domainName) ;
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
	
	public function saveIndexData(fileName:String, ver:String=""):String
	{
		if(!__init)
			initIndex(__domainName);
		var _so:SharedObject = SharedObject.getLocal(__domainName) ;
		_so.data[INDEX_NAME][fileName] = ver ;
		indexData[fileName] = ver ;
		return _so.flush();
	}
	
	public function readFileData(key:String, ver:String=""):*
	{
		if(!__init)
			initIndex(__domainName);
		var _so:SharedObject = SharedObject.getLocal(__domainName) ;
		if(isFileExist(key,ver))
		{
			return _so.data[DIR_NAME][key];
		}
		return null ;
	}
	
	public function saveFileData(key:String, value:*, ver:String=""):String
	{
		if(!__init)
			initIndex(__domainName);
		var _so:SharedObject = SharedObject.getLocal(__domainName) ;
		if(_so.data[DIR_NAME] == null){
			_so.data[DIR_NAME] = {} ;
			_so.flush();
		}
		saveIndexData(key,ver);
		_so.data[DIR_NAME][key] = value ;
		return _so.flush();
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