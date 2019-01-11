/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Creation of mappings via Lucee
*/
component{

	/**
	 * Add a Lucee mapping
	 *
	 * @name The name of the mapping
	 * @path The path of the mapping
	*/
	LuceeMappingHelper function addMapping( required name, required path ) {
		var mappings = getApplicationSettings().mappings;
		mappings[ arguments.name ] = arguments.path;
		application action='update' mappings='#mappings#';

		return this;
	}

	/**
	 * Add a Lucee mapping using a struct of mappings
	 *
	 * @mappings A struct of mappings to register
	*/
	LuceeMappingHelper function addMappings( required mappings ) {
		var newMappings = getApplicationSettings().mappings.append( arguments.mappings );
		application action='update' mappings='#newMappings#';

		return this;
	}

}