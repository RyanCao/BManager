/**
 * Created with IntelliJ IDEA.
 * User: Ryan
 * Date: 14-11-28
 * Time: 上午12:00
 * To change this template use File | Settings | File Templates.
 */
package {
import flash.display.Sprite;
import flash.events.Event;

public class TestSprite extends Sprite {
    public function TestSprite() {
        super();
        if(stage){
            onAddToStageHandler(null);
        }else{
            stage.addEventListener(Event.ADDED_TO_STAGE, onAddToStageHandler);
        }
    }

    private function onAddToStageHandler(event:Event):void {
        stage.removeEventListener(Event.ADDED_TO_STAGE, onAddToStageHandler);
        initUI();
    }

    protected function initUI():void {

    }
}
}
