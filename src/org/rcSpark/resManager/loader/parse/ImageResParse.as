/**
 * Class name: ImageResParse.as
 * Description:
 * Author: caoqingshan
 * Create: 14-9-17 下午4:31
 */
package org.rcSpark.resManager.loader.parse {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.system.System;
import flash.utils.ByteArray;

public class ImageResParse extends ResParseBase {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    private var _byteData:ByteArray;
    private var _loader:Loader;
    private var _startedParsing:Boolean = false;

    public function ImageResParse() {
        super();
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    /**
     * Indicates whether or not a given file extension is supported by the parser.
     * @param extension The file extension of a potential file to be parsed.
     * @return Whether or not the given file type is supported.
     */

    public static function supportsType(extension:String):Boolean {
        extension = extension.toLowerCase();
//        return ["jpg","jpeg","png","gif","bmp","atf"].indexOf(extension)>-1;
        return (["jpg", "jpeg", "png", "gif", "bmp"].indexOf(extension) > -1);
    }

    /**
     * Tests whether a data block can be parsed by the parser.
     * @param data The data block to potentially be parsed.
     * @return Whether or not the given data is supported.
     */
    public static function supportsData(data:*):Boolean {
        if (!(data is ByteArray))
            return false;

        var ba:ByteArray = data as ByteArray;
        ba.position = 0;
        if (ba.readUnsignedShort() == 0xffd8)
            return true; // JPEG, maybe check for "JFIF" as well?

        ba.position = 0;
        if (ba.readShort() == 0x424D)
            return true; // BMP

        ba.position = 1;
        if (ba.readUTFBytes(3) == 'PNG')
            return true;

        ba.position = 0;
        if (ba.readUTFBytes(3) == 'GIF' && ba.readShort() == 0x3839 && ba.readByte() == 0x61)
            return true;

//        ba.position = 0;
//        if (ba.readUTFBytes(3) == 'ATF')
//            return true;

        return false;
    }

    /**
     * @inheritDoc
     */
    protected override function proceedParsing():Boolean {
        _byteData = getByteData();
        if (!_startedParsing) {
            _byteData.position = 0;
            _loader = new Loader();
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete,false,0,false);
            _loader.loadBytes(_byteData,new LoaderContext());
            _startedParsing = true;
        }
        return true;
    }

    /**
     * Called when "loading" is complete.
     */
    private function onLoadComplete(event:Event):void {
        var bmp:BitmapData = Bitmap(_loader.content).bitmapData;
		Bitmap(_loader.content).bitmapData = null;
        _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
		//_loader.contentLoaderInfo.content = null;
        _loader.unloadAndStop();
		//System.gc();
        _loader = null;
        finishParse(bmp);		
    }
}
}
