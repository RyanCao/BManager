/**
 * Created with IntelliJ IDEA.
 * User: Ryan
 * Date: 14-11-27
 * Time: 下午11:59
 * To change this template use File | Settings | File Templates.
 */
package {
import flash.text.TextField;
import flash.utils.getTimer;

import org.osflash.async.LoaderDeferred;
import org.osflash.async.ResFormat;
import org.osflash.async.whenOneArray;
import org.rcSpark.rcant;
import org.rcSpark.binaryManager.loader.LoadType;
import org.rcSpark.binaryManager.manager.NBinaryManager;

import tools.JSLogger;

use namespace rcant;

[SWF(width=700,height=400)]
public class BinaryTest extends TestSprite{
//    private var cdn:String = "d:/app/nginx-1.7.7/html/";
//    private var cdn:String = "http://localhost/";
    private var cdn:String = "http://sssj.static.xyimg.net/test/resource_stone/prepare/resource_stone/zh_cn/assets/";
//    private var cdn:String = "ftp://172.27.108.2:2121/Tencent/QQfile_recv/";
//    private var assets:Array = [
//        "DSC_0091.JPG",
//        "DSC_0095.JPG",
//        "DSC_0196.JPG",
//        "DSC_0222.JPG"
//    ];
    private var assets:Array = [
        ["monsters/lianyexiaoyao/encode/model.pad",LoadType.LIB,4,ResFormat.BINARY],
        ["interElements/textures/moxing_03_66.png",LoadType.LIB,5,ResFormat.BITMAP],
        ["interElements/textures/xulie_25_25.png",LoadType.LIB,6,ResFormat.BITMAP],
        ["swf/zidongxunlu.swf",LoadType.LIB,2,ResFormat.BINARY],
        ["itemIcons/7.png",LoadType.LIB,1,ResFormat.BITMAP],
        ["swf/iconLoading.swf",LoadType.LIB,3,ResFormat.BINARY],
        ["interElements/textures/moxing_03_16.png",LoadType.CORE_FILES,1,ResFormat.BITMAP],
        ["itemIcons/3.png",LoadType.OTHER,4,ResFormat.BITMAP],
        ["itemIcons/5.png",LoadType.OTHER,8,ResFormat.BITMAP],
        ["interElements/textures/moxing_05_03.png",LoadType.OTHER,1,ResFormat.BITMAP],
        ["itemIcons/2.png",LoadType.OTHER,10,ResFormat.BITMAP]
    ];
    private var h:uint = 0 ;
    private var lastTime:int = 0;
    private var startTime:int = 0;
    public function BinaryTest() {
    }

    override protected function initUI():void {
        super.initUI();
//        BinaryManager.TRACE_FLAG = true ;
//        BinaryManager.ilog = JSLogger.instance() ;

        startTime = getTimer();
        
        NBinaryManager.TRACE_FLAG = true ;
        NBinaryManager.ilog = JSLogger.instance() ;

        NBinaryManager.instance().rcant::useSingleThread();

        var alll:Array = [];
        for(var i:int = 0,len:uint = assets.length;i<len;i++){
            var l:LoaderDeferred = new LoaderDeferred();
            l.load(cdn + assets[i][0],ResFormat.BINARY,assets[i][1],assets[i][2]).completes(addText);
            alll.push(l);
        }
        whenOneArray(alll).completes(completeHandler);

    }


    private function addText(e:*):void {
        var nowTime:int = getTimer();

        var t:TextField = new TextField();
        addChild(t);
        t.width = stage.stageWidth ;
        t.height = 20 ;
        t.text = (e as LoaderDeferred).url.replace(cdn,"") + " bytes:" + (e as LoaderDeferred).data.length+ " t:" + (nowTime - (lastTime?lastTime:startTime));
        t.y = h ;
        h+=20;

        lastTime = nowTime;
    }

    private function completeHandler(e:*):void {
        var t:TextField = new TextField();
        addChild(t);
        t.width = stage.stageWidth ;
        t.height = 20 ;
        t.text = "全部加载成功，总耗时间:"+ " " + (getTimer() - startTime);
        t.y = h ;
        h+=20;
    }
}
}
