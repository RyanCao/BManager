/*******************************************************************************
 * Class name:	BinaryInfo.as
 * Description:	基础加载信息
 * Author:		Ryan
 * Create:		Jun 11, 2014 6:02:11 PM
 * Update:		Jun 11, 2014 6:02:11 PM
 ******************************************************************************/
package org.rcSpark.binaryManager.data
{
import flash.net.URLRequest;
import flash.utils.ByteArray;

//-----------------------------------------------------------------------------
// import_declaration
//-----------------------------------------------------------------------------

public class BinaryInfo
{
	//-----------------------------------------------------------------------------
	// Var
	//-----------------------------------------------------------------------------
	/**还沒有添加该资源**/
	public static const NONE:String="none";
	/**资源等待中*/
	public static const WAITING:String="waiting";
	/**资源下载中*/
	public static const LOADING:String="loading";
	/**资源已下载*/
	public static const COMPLETED:String="completed";
	/**资源下载错误*/
	public static const ERROR:String="error";
	
	/**当前状态*/
	public var state:String=NONE;
	/**
	 * 數據內容
	 */
	public var ba:ByteArray ;
	public var url:String ;
	public var urlReq:URLRequest ;
	/**
	 * 文件md5值
	 */
	public var md5sum:String = "";
	/**已加载的字节数*/
	public var bytesLoaded:uint=0;
	/**资源总大小
	 * <p>如果资源是实时流,或大小未知,那麼總大小與<code>bytesLoaded</code>的值一样,会随着下载数据增加而动态增加</p>
	 * <p>可用于数据绑定</p>
	 */
    public var bytesTotal:uint = 0;
    /**
     * 加载类型 不用于解析文件，只用于加载限制
     */
    public var loadType:int;
    /***
	 * 加载等级
	 * */
	public var loadLevel:uint = 0;
	/**
	 * 文件加载完成以后是否保存到本地
	 * */
	public var isSave:Boolean = false;
	public var onCompleteHandle:Function ;
	public var onErrorHandle:Function ;
	public var onProgressHandle:Function ;

	//-----------------------------------------------------------------------------
	// Constructor
	//-----------------------------------------------------------------------------
	public function BinaryInfo()
	{
	}
	
	//-----------------------------------------------------------------------------
	// Methods
	//-----------------------------------------------------------------------------
	public function clone():BinaryInfo{
		var bi:BinaryInfo = new BinaryInfo();
		bi.ba = ba ;
		bi.bytesLoaded = bytesLoaded;
		bi.bytesTotal = bytesTotal;
		bi.isSave = isSave;
		bi.loadLevel = loadLevel ;
		bi.md5sum = md5sum;
		bi.onCompleteHandle = onCompleteHandle;
		bi.onErrorHandle = onErrorHandle;
		bi.onProgressHandle = onProgressHandle;
		bi.state = state;
		bi.url = url;
		bi.urlReq = urlReq ;
		return bi ;
	}
    public function dispose():void{
        if(ba){
            ba.clear();
            ba = null ;
        }
        onCompleteHandle = null ;
        onErrorHandle = null ;
        onProgressHandle = null ;

    }
}
}