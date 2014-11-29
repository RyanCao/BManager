/**
 * Class name: Parsers.as
 * Description: 资源解析
 * Author: caoqingshan
 * Create: 14-9-17 下午4:27
 */
package org.rcSpark.resManager.parse {
import org.rcSpark.resManager.manager.ResManager;

public class ResParsers {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    public static const ALL_BUNDLED:Vector.<Class> = Vector.<Class>([
        ImageResParse
    ]);

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    public static function enableAllBundled():void
    {
        ResManager.enableParsers(ALL_BUNDLED);
    }
}
}
