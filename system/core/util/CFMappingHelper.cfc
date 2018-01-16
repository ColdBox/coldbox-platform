/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Allows you to maninpulate CF mappings
*/
component{

	/**
	 * Add a ColdFusion mapping
	 * 
	 * @name The name of the mapping
	 * @path The path of the mapping
	*/
	CFMappingHelper function addMapping( required string name, required string path ){
		var appSettings = getApplicationMetadata();
		appSettings.mappings[ arguments.name ] = arguments.path;
		return this;
	}

}