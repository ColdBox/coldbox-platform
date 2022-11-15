/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Allows you to manipulate CF mappings and custom tags
 */
component {

	/**
	 * Add an absolute custom tag path to the running application
	 *
	 * @path The absolute path to the directory containing the custom tags
	 */
	CFMappingHelper function addCustomTagPath( required path ){
		var appMetadata = getApplicationMetadata();
		if ( isNull( appMetadata.customTagPaths ) ) {
			appMetadata.customTagPaths = "";
		}
		getPageContext()
			.getFusionContext()
			.getAppHelper()
			.getAppScope()
			.setApplicationCustomTagPaths( appMetadata.customTagPaths.listAppend( arguments.path ) );
		return this;
	}

	/**
	 * Add a ColdFusion mapping
	 *
	 * @name The name of the mapping
	 * @path The path of the mapping
	 */
	CFMappingHelper function addMapping( required string name, required string path ){
		return addMappings( { "#arguments.name#" : arguments.path } );
	}

	/**
	 * Register a struct of CF Mappings
	 *
	 * @mappings The struct of mappings to register
	 */
	CFMappingHelper function addMappings( required struct mappings ){
		getApplicationMetadata().mappings.append( arguments.mappings );
		return this;
	}

}
