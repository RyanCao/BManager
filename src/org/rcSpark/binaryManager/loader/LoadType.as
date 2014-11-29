/**
 * Class Name: LoadType
 * Description:文件加载类型 区别不同的加载文件与加载队列
 * Created by Ryan on 2014/11/27 22:21.
 */
package org.rcSpark.binaryManager.loader {
public class LoadType {
    //-----------------------------------------
    //Var
    //-----------------------------------------

    /**
     * 其他文件 ，未指定加载类型的统一归到此类，
     * 1.保证其他所有列表中的文件加载完成以后加载
     * 2.指定此类最多只有几个加载链接,同时加载要有限制
     */
    public static const OTHER:uint = 0;

    /**
     *类库,必要资源
     */
    public static const LIB:uint = 1 ;
    /**
     * 核心文件,必要资源
     */
    public static const CORE_FILES:uint = 2 ;

    /**
     * 3D资源文件  可尝试拆封
     * */
    public static const AWAY3D_FILES:uint = 3 ;
    /**
     * ICON文件
     */
    public static const ICON:uint = 4 ;
    /**
     * Movie文件
     */
    public static const MOVIE:uint = 5 ;
    /**
     * 外部Swf特效文件
     */
    public static const EXTERNAL_SWF_EFFECT:uint = 6 ;
    /**
     *地图文件
     */
    public static const MAP_FILES:uint = 7 ;

    public function LoadType() {
    }

    //-----------------------------------------
    //Methods
    //-----------------------------------------
}
}
