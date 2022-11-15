/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Creation of mappings via Lucee
 */
component {

	/**
	 * Add an absolute custom tag path to the running application
	 *
	 * @path The absolute path to the directory containing the custom tags
	 */
	LuceeMappingHelper function addCustomTagPath( required path ){
		// Workaround for Lucee reverting the sessionCluster, clientCluster, and cgiReadOnly settings to defaults
		// https://luceeserver.atlassian.net/browse/LDEV-2555
		appSettings.sessionCluster = appSettings.sessionCluster ?: false;
		appSettings.clientCluster  = appSettings.clientCluster ?: false;
		appSettings.cgiReadOnly    = appSettings.cgiReadOnly ?: true;
		application
			action        ="update"
			customTagPaths="#getApplicationSettings().customTagPaths.append( arguments.path )#"
			sessionCluster="#appSettings.sessionCluster#"
			clientCluster ="#appSettings.clientCluster#"
			cgiReadOnly   ="#appSettings.cgiReadOnly#";
		return this;
	}

	/**
	 * Add a Lucee mapping
	 *
	 * @name The name of the mapping
	 * @path The path of the mapping
	 */
	LuceeMappingHelper function addMapping( required name, required path ){
		return addMappings( { "#arguments.name#" : arguments.path } );
	}

	/**
	 * Add a Lucee mapping using a struct of mappings
	 *
	 * @mappings A struct of mappings to register: { name : path }
	 */
	LuceeMappingHelper function addMappings( required struct mappings ){
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
