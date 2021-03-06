package org.osflash.async {

public function whenOneArray(promises:Array):Promise {
    if (promises.length == 0) {
        const noArrayPromise:Deferred = new Deferred();
        noArrayPromise.resolve(null);
        return noArrayPromise;
    }
    else {
        // A Promise composed of all the supplied promises is returned; this Promise will only resolve once
        // all of the child promises have completed.
        const combinedPromise:Deferred = new Deferred();

        const totalPromises:uint = promises.length;
        const promiseOutcomes:Array = new Array(totalPromises);
        var completedPromises:uint = 0;

        var onChildPromiseResolved:Function = function (outcome:*):void {
            promiseOutcomes[completedPromises] = outcome;
            completedPromises += 1;
            combinedPromise.progress(completedPromises / totalPromises);
            onChildPromiseProgress(1);
            if (completedPromises == totalPromises) {
                combinedPromise.resolve(promiseOutcomes);
            }
            else {
                resolveNextPromise();
            }
        };

        var onChildPromiseProgress:Function = function (value:Number):void {
            combinedPromise.progressArray([completedPromises, totalPromises, value]);
        };

        var resolveNextPromise:Function = function ():void {
            // Allow non Promises to pass thru.
            if (!(promises[completedPromises] is Promise)) {
                onChildPromiseResolved(promises[completedPromises]);
            }
            else {
                (promises[completedPromises] as Promise)
                        .completes(onChildPromiseResolved)
                        .progresses(onChildPromiseProgress)
                        .fails(combinedPromise.reject);
            }
        };


        resolveNextPromise();

        return combinedPromise;
    }
}
}
