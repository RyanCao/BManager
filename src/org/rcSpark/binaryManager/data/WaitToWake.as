/**
 *  Copyright (c) 2009 - 2010 LOOKBACKON All rights reserved.
 */
package org.rcSpark.binaryManager.data
{
//--------------------------------------------------------------------------
//
//  Imports
//
//--------------------------------------------------------------------------

/****
 * WaitToWake.as class. Created Aug 26, 2012 11:44:50 AM
 * <br>
 * Description: 每个资源可能会被多次加载，这里会记载多次被加载所触发的函数，当触发事件以后统一调用函数
 * @author ryan
 * @langversion 3.0
 * @playerversion Flash 10
 ****/
public class WaitToWake
{
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    public var url:String = "";
    public var completeHandles:Vector.<Function> ;
    public var progressHandles:Vector.<Function> ;
    public var errorHandles:Vector.<Function> ;

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function WaitToWake()
    {
        completeHandles = new Vector.<Function>();
        progressHandles = new Vector.<Function>();
        errorHandles = new Vector.<Function>();
    }

    //--------------------------------------------------------------------------
    //
    //  methods
    //
    //--------------------------------------------------------------------------
    public function addCompleteHandle(value:Function):void{
        if(value==null)
            return ;
        if(completeHandles.indexOf(value)>-1)
            return ;
        completeHandles.push(value);
    }
    public function addProgressHandles(value:Function):void{
        if(value==null)
            return ;
        if(progressHandles.indexOf(value)>-1)
            return ;
        progressHandles.push(value);
    }
    public function addErrorHandles(value:Function):void{
        if(value==null)
            return ;
        if(errorHandles.indexOf(value)>-1)
            return ;
        errorHandles.push(value);
    }

    public function onCompleteHandle(value:*):void{
        for (var i:int = 0; i < completeHandles.length; i++)
        {
            var handle:Function = completeHandles[i];
            handle(value);
        }
    }

    public function onProgressHandle(value:*):void{
        for (var i:int = 0; i < progressHandles.length; i++)
        {
            var handle:Function = progressHandles[i];
            handle(value);
        }
    }

    public function onErrorHandle(value:*):void{
        for (var i:int = 0; i < errorHandles.length; i++)
        {
            var handle:Function = errorHandles[i];
            handle(value);
        }
    }
}

}