/*******************************************************************************
 * Class name:	Version.as
 * Description:	修改url的版本控制类
 * Author:		Ryan
 * Create:		Jun 11, 2014 5:52:48 PM
 * Update:		Jun 11, 2014 5:52:48 PM
 ******************************************************************************/
package org.rcSpark.binaryManager.manager
{
//-----------------------------------------------------------------------------
// import_declaration
//-----------------------------------------------------------------------------
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.utils.Dictionary;

import org.rcSpark.binaryManager.util.URLCode;


public class Version implements IVersion
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
	
	public static var VersionFlag:String = "res_Version";
	//-----------------------------------------------------------------------------
	// Constructor
	//-----------------------------------------------------------------------------
	public function Version()
	{
	}
	public static function instance():IVersion
	{
		if(!__instance)
			__instance = new Version();
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
		return addVersionToUrl(url,version);
	}
	
	private function addVersionToUrl(url:Object,ver:String):String{
		var urlReq : URLRequest = null;
		if (url is String) {
			urlReq = URLCode.decode(url as String);
		} else {
			urlReq = url as URLRequest;
		}
		removeVersionToUrl(urlReq);
		if(ver){
			if(!urlReq.data)
				urlReq.data = new URLVariables();
			urlReq.data[VersionFlag] = ver;
		}
		return URLCode.encode(urlReq);
	}
	
	/**
	 * 通过删除Url的Version键值来作为加载类的唯一键值
	 * @param url
	 * @return urlString
	 */
	private function removeVersionToUrl(url:Object):String{
		var urlReq : URLRequest = null;
		if (url is String) {
			urlReq = URLCode.decode(url as String);
		} else {
			urlReq = url as URLRequest;
		}
		if(urlReq.data)
			delete urlReq.data[VersionFlag];
		return URLCode.encode(urlReq);
	}
	
	public function getNewestUrl(url:String):String
	{
		if(_resVersionDic[url])
			return getVersionUrl(url,_resVersionDic[url]) ;
		return getKeyUrl(url);
	}
	
	public function getKeyUrl(url:String):String
	{
		return removeVersionToUrl(url);
	}
}
}