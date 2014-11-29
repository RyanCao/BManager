/**
 * Class name: AbstractMethodError.as
 * Description:
 * Author: caoqingshan
 * Create: 14-9-17 下午4:36
 */
package org.rcSpark.binaryManager.error {
public class AbstractMethodError extends Error {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------

    public function AbstractMethodError(message:String = null, id:int = 0) {
        super(message || "An abstract method was called! Either an instance of an abstract class was created, or an abstract method was not overridden by the subclass.", id);
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------

}
}
