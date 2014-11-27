/**
 *  Copyright (c) 2009 - 2010 LOOKBACKON All rights reserved.
 */
package org.rcSpark.tools.time {
//--------------------------------------------------------------------------
//
//  Imports
//
//--------------------------------------------------------------------------
import flash.events.Event;


/****
 * TickEvent.as class. Created Aug 18, 2012 12:35:35 AM
 * <br>
 * Description:
 * @author ryan
 * @langversion 3.0
 * @playerversion Flash 10
 ****/
public class TickEvent extends Event {
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    public static const TICK:String = "tick";

    public var interval:int;

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function TickEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }

    //--------------------------------------------------------------------------
    //
    //  methods
    //
    //--------------------------------------------------------------------------
    public override function clone():Event {
        var evt:TickEvent = new TickEvent(type, bubbles, cancelable);
        evt.interval = this.interval;
        return evt;
    }
}

}