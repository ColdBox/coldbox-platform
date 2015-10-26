/**
********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* Allows you to maninpulate CF mappings
*/
component{

	/**
	* For Adobe CF, Slight difference in older versions
	*/
	function addMapping( required string name, required string path ){

		if ( listFirst( server.coldfusion.productVersion ) == 9 ) {
			addMappingCF9( name, path);
		} else if ( listFirst( server.coldfusion.productVersion ) == 10 ) {
			addMappingCF10( name, path);
		} else {
			addMappingCF( name, path);
		}
	}

	// No workaround neccessary for CF11 and up
	function addMappingCF( required string name, required string path ) {
		var appSettings = getApplicationMetadata();
		appSettings.mappings[ arguments.name ] = arguments.path;
	}

	// For CF10, Add the mappings into the the application settings map
	// This is because getApplicationMetadata().mappings is null if none exist
	function addMappingCF10( required string name, required string path ) {
		var appSettings = application.getApplicationSettingsMap();
		appSettings.mappings[ arguments.name ] = arguments.path;
	}

	// CF9 is same as CF10, but with Slightly different method name
	function addMappingCF9( required string name, required string path ) {
		var appSettings = application.getApplicationSettings();
		appSettings.mappings[ arguments.name ] = arguments.path;
	}


}