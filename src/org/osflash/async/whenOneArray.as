package org.osflash.async
{

import org.osflash.async.*;

public function whenOneArray(promises:Array):Promise
{
	if(promises.length == 0)
	{
		return null;
	}
	else
	{
		const combinedPromise:Deferred = new Deferred();
		
		const totalPromises:uint = promises.length;
		const promiseOutcomes:Array = new Array(totalPromises);
		var completedPromises:uint = 0;
		
		var onChildPromiseResolved:Function = function (outcome:*):void
		{
			promiseOutcomes[completedPromises] = outcome;
			completedPromises += 1;
			combinedPromise.progress2(completedPromises,totalPromises);
			if (completedPromises == totalPromises)
			{
				combinedPromise.resolve(promiseOutcomes);
			}
			else
			{
				resolveNextPromise();
			}
		};
		
		var resolveNextPromise:Function = function ():void
		{
			// Allow non Promises to pass thru.
			if (!(promises[completedPromises] is Promise))
			{
				onChildPromiseResolved(promises[completedPromises]);
			}
			else
			{
				(promises[completedPromises] as Promise)
				.completes(onChildPromiseResolved)
					.fails(combinedPromise.reject);
			}
		};
		
		resolveNextPromise();
		return combinedPromise;
	}
}
}
