/*******************************************************************************
 * Interface name:	IVersion.as
 * Description:	版本控制
 * Author:		Ryan
 * Create:		Jun 11, 2014 5:35:32 PM
 * Update:		Jun 11, 2014 5:35:32 PM
 ******************************************************************************/
package org.rcSpark.resManager.manager
{
import flash.utils.Dictionary;

public interface IVersion
{
	/**
	 * 初始化版本库
	 * @param dic 库
	 */
	function initVersion(dic:Dictionary):void;
	
	/**
	 * 获取文件版本号 
	 * @param url 默认文件索引
	 * @return  文件版本号
	 */
	function getVersion(url:String):String;
	/**
	 * 获取文件某一版本地址 
	 * @param url 默认文件索引
	 * @param version 文件版本号
	 * @return 真实地址
	 */
	function getVersionUrl(url:String,version:String):String;
	/**
	 * 获取文件最新地址 
	 * @param url 默认文件索引
	 * @return 
	 */
	function getNewestUrl(url:String):String;
	/**
	 * 获取不加版本号的文件地址,一般作为索引Key存在 
	 * @param url  不清是否带有版本号的文件地址
	 * @return 
	 * 
	 */	
	function getKeyUrl(url:String):String ;
}
}