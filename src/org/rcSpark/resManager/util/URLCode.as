/**
 *  Copyright (c) 2009 - 2010 LOOKBACKON All rights reserved.
 */
package org.rcSpark.resManager.util
{
import flash.net.URLRequest;
import flash.net.URLVariables;

//--------------------------------------------------------------------------
//
//  Imports
//
//--------------------------------------------------------------------------

/****
 * URLCode.as class. Created 4:28:08 PM Aug 20, 2012
 * <br>
 * Description:
 * @author ryan
 * @langversion 3.0
 * @playerversion Flash 10
 ****/
public final class URLCode
{
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function URLCode()
    {
    }

    //--------------------------------------------------------------------------
    //
    //  methods
    //
    //--------------------------------------------------------------------------
    public static function decode(url:String):URLRequest
    {
        //url=url.toLowerCase();
        var arr:Array=url.split("?");
        var urlReq:URLRequest=new URLRequest(arr.shift());//arr.shift().toLowerCase()
        if (arr.length > 0)
        {
            var urlVars:URLVariables=new URLVariables(arr.shift());
            urlReq.data=urlVars;
        }
        return urlReq;
    }

    public static function encode(urlReq:URLRequest):String
    {
        var url:String=urlReq.url;
        if (urlReq.data != null)
        {
            url+="?" + urlReq.data.toString();
        }
        return url;
    }
}
}