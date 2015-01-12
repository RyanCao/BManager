/**
 * Class name: InitData.as
 * Description:
 * Author: caoqingshan
 * Create: 14-12-8 下午1:45
 */
package org.rcSpark.instManager.data {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.utils.ByteArray;

public class InstData {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------

    public function InstData() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    /**
     * 实例内容
     */
    public var content:*;
    /**
     * 实例类型
     */
    public var type:String;
    /**
     * 实例URL
     */
    public var url:String;
    /**
     * 被引用次数
     */
    public var count:int = 0;

    /**
     * 获取一个复制的实例
     * @return
     */
    public function getContent():* {
        var rc:*;
        if (content is BitmapData) {
            rc = new Bitmap(content);
            count++;
            return rc;
        } else if (content is Bitmap) {
            rc = new Bitmap((content as Bitmap).bitmapData);
            count++;
            return rc;
        } else if (content is MovieClip) {
            count++;
            return content as MovieClip;
        } else if (content is XML) {
            count++;
            return content;
        } else if (content is String) {
            count++;
            return content;
        } else if (content is ByteArray) {
            count++;
            content.position = 0;
            return content;
        }
        return rc;
    }

    private function duplicateDisplayObject(source:DisplayObject):DisplayObject{
        var soureClass:Class = Object(source).constructor;
        var duplicate:DisplayObject = new soureClass();
        duplicate.transform = source.transform;
        duplicate.filters = source.filters;
        duplicate.cacheAsBitmap = source.cacheAsBitmap;
        duplicate.opaqueBackground = source.opaqueBackground;
        duplicate.scale9Grid = source.scale9Grid;
        return duplicate ;
    }

    private function doClone(source:Object):*{
        var ba:ByteArray = new ByteArray();
        ba.writeObject(source);
        ba.position = 0;
        return ba.readObject();
    }

    /**
     * 删除一个引用
     */
    public function delOneUse():void {
        count--;
    }

    /**
     * 清空内存
     * //可以清空内存
     */
    public function dispose():void {
        if (content is BitmapData) {
            (content as BitmapData).dispose();
        } else if (content is Bitmap) {
            (content as Bitmap).bitmapData.dispose();
        } else if (content is MovieClip) {
            (content as MovieClip).gotoAndStop(1);
        } else if (content is ByteArray) {
            (content as ByteArray).clear()
        }
        content = null;
    }

}
}
