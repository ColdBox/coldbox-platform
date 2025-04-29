/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Creation of mappings via BoxLang
 */
component {

	/**
	 * Add an absolute custom tag path to the running application
	 *
	 * @path The absolute path to the directory containing the custom tags
	 */
	BoxLangMappingHelper function addCustomTagPath( required path ){
		application
			action        ="update"
			customTagPaths="#getApplicationSettings().customTagPaths.append( arguments.path )#";
		return this;
	}

	/**
	 * Add a mapping
	 *
	 * @name The name of the mapping
	 * @path The path of the mapping
	 */
	BoxLangMappingHelper function addMapping( required name, required path ){
		return addMappings( { "#arguments.name#" : arguments.path } );
	}

	/**
	 * Add a mapping using a struct of mappings
	 *
	 * @mappings A struct of mappings to register: { name : path }
	 */
	BoxLangMappingHelper function addMappings( required struct mappings ){
		application action="update" mappings=getApplicationSettings().mappings.append( arguments.mappings );
		return this;
	}

}
