/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Allows you to manipulate CF mappings
 */
component {

	/**
	 * Add a ColdFusion mapping
	 *
	 * @name The name of the mapping
	 * @path The path of the mapping
	 */
	CFMappingHelper function addMapping( required string name, required string path ){
		var appSettings                        = getApplicationMetadata();
		appSettings.mappings[ arguments.name ] = arguments.path;
		return this;
	}

	/**
	 * Register a struct of CF Mappings
	 *
	 * @mappings The struct of mappings to register
	 */
	CFMappingHelper function addMappings( required mappings ){
		getApplicationMetadata().mappings.append( arguments.mappings );
		return this;
	}

}
