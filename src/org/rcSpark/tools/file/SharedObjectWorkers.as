/*******************************************************************************
 * Class name:	SharedObjectWorkers.as
 * Description:	
 * Author:		Ryan
 * Create:		Jun 19, 2014 2:16:05 PM
 * Update:		Jun 19, 2014 2:16:05 PM
 ******************************************************************************/
package org.rcSpark.tools.file
{
import flash.utils.ByteArray;

//-----------------------------------------------------------------------------
// import_declaration
//-----------------------------------------------------------------------------

public class SharedObjectWorkers
{
	//-----------------------------------------------------------------------------
	// Var
	//-----------------------------------------------------------------------------
//	[Embed(source="../libs/BgSharedObjectSaveWorker.swf", mimeType="application/octet-stream")]
	private static var BackgroundWorker_ByteClass:Class;
	//-----------------------------------------------------------------------------
	// Constructor
	//-----------------------------------------------------------------------------
	public function SharedObjectWorkers()
	{
	}
	
	//-----------------------------------------------------------------------------
	// Methods
	//-----------------------------------------------------------------------------
	public static function get BackgroundWorker():ByteArray
	{
		return new BackgroundWorker_ByteClass();
	}
}
}