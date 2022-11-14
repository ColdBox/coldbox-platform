/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Provides ability to locate files and/or directories within a ColdBox application
 */
component singleton {

	// DI
	property
		name    ="controller"
		inject  ="coldbox"
		delegate="locateFilePath,locateDirectoryPath";

}
