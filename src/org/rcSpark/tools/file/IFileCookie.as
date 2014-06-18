/*******************************************************************************
 * Interface name:	IFileCookie.as
 * Description:	文件缓存操作接口
 * Author:		Ryan
 * Create:		Jun 18, 2014 2:35:34 PM
 * Update:		Jun 18, 2014 2:35:34 PM
 ******************************************************************************/
package org.rcSpark.tools.file
{
public interface IFileCookie
{
	/**
	 * 初始化存取类
	 * @param domainName 域名
	 * @return 
	 */	
	function initIndex(domainName:String):*;
	/**
	 * 存取并更新索引文件 
	 * @param fileName
	 * @param ver
	 * @return 
	 */	
	function saveIndexData(fileName:String,ver:String=""):String;
	/**
	 * 读取对应版本号文件 
	 * @param key
	 * @param ver
	 * @return 
	 */	
	function readFileData(key:String,ver:String=""):*;
	/**
	 * 存取对应版本号文件
	 * @param key
	 * @param value
	 * @param ver
	 * @return 
	 */	
	function saveFileData(key:String,value:*,ver:String=""):String;
	/**
	 * 判断对应版本文件是否存在 
	 * @param fileName
	 * @param ver 文件版本号（验证是否是需要的文件）可以不填
	 * @return 
	 */	
	function isFileExist(fileName:String,ver:String=""):Boolean;
}
}