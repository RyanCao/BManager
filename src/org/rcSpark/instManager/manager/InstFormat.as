package org.rcSpark.instManager.manager {
/**
 * 定义资源文件加载完毕后需要转换的格式
 * @author zhangyu
 *
 */
public class InstFormat {
    /**
     * 文本格式
     */
    public static const TEXT:String = "text";

    /**
     * 二进制数组
     */
    public static const BINARY:String = "binary";

    /**
     * XML
     */
    public static const XML:String = "xml";

    /**
     * flash.display.Loader
     * 这个格式化类型主要是为了少写几个字的代码
     */
    public static const LOADER:String = "loader";

    /**
     * 位图
     */
    public static const BITMAP:String = "bitmap";

}
}