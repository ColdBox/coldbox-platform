/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Creation of mappings via Lucee
 */
component {

	/**
	 * Add a Lucee mapping
	 *
	 * @name The name of the mapping
	 * @path The path of the mapping
	 */
	LuceeMappingHelper function addMapping( required name, required path ){
		var appSettings            = getApplicationSettings();
		var mappings               = appSettings.mappings;
		mappings[ arguments.name ] = arguments.path;

		// Workaround for Lucee reverting the sessionCluster, clientCluster, and cgiReadOnly settings to defaults
		// https://luceeserver.atlassian.net/browse/LDEV-2555
		appSettings.sessionCluster = appSettings.sessionCluster ?: false;
		appSettings.clientCluster  = appSettings.clientCluster ?: false;
		appSettings.cgiReadOnly    = appSettings.cgiReadOnly ?: true;
		application
			action        ="update"
			mappings      ="#mappings#"
			sessionCluster="#appSettings.sessionCluster#"
			clientCluster ="#appSettings.clientCluster#"
			cgiReadOnly   ="#appSettings.cgiReadOnly#";

		return this;
	}

	/**
	 * Add a Lucee mapping using a struct of mappings
	 *
	 * @mappings A struct of mappings to register
	 */
	LuceeMappingHelper function addMappings( required mappings ){
		var appSettings = getApplicationSettings();
		var newMappings = appSettings.mappings.append( arguments.mappings );

		// Workaround for Lucee reverting the sessionCluster, clientCluster, and cgiReadOnly settings to defaults
		// https://luceeserver.atlassian.net/browse/LDEV-2555
		appSettings.sessionCluster = appSettings.sessionCluster ?: false;
		appSettings.clientCluster  = appSettings.clientCluster ?: false;
		appSettings.cgiReadOnly    = appSettings.cgiReadOnly ?: true;
		application
			action        ="update"
			mappings      ="#newMappings#"
			sessionCluster="#appSettings.sessionCluster#"
			clientCluster ="#appSettings.clientCluster#"
			cgiReadOnly   ="#appSettings.cgiReadOnly#";
		return this;
	}

}
