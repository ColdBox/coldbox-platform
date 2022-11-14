/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Provides ColdBox/Module settings capabilities in delegated objects
 */
component accessors="true" singleton {

	// DI
	property
		name    ="controller"
		inject  ="coldbox"
		delegate="getSetting,getColdBoxSetting,settingExists,setSetting";

	/**
	 * Get a module's settings structure or a specific setting if the setting key is passed
	 *
	 * @module       The module to retrieve the configuration settings from
	 * @setting      The setting to retrieve if passed
	 * @defaultValue The default value to return if setting does not exist
	 *
	 * @return struct or any
	 */
	any function getModuleSettings( required module, setting, defaultValue ) cbMethod{
		var moduleSettings = getModuleConfig( arguments.module ).settings;
		// return specific setting?
		if ( !isNull( arguments.setting ) ) {
			return (
				structKeyExists( moduleSettings, arguments.setting ) ? moduleSettings[ arguments.setting ] : arguments.defaultValue
			);
		}
		return moduleSettings;
	}

	/**
	 * Get a module's configuration structure
	 *
	 * @module The module to retrieve the configuration structure from
	 *
	 * @return The struct requested
	 *
	 * @throws InvalidModuleException - The module passed is invalid
	 */
	struct function getModuleConfig( required module ) cbMethod{
		var mConfig = variables.controller.getSetting( "modules" );
		if ( structKeyExists( mConfig, arguments.module ) ) {
			return mConfig[ arguments.module ];
		}
		throw(
			message = "The module you passed #arguments.module# is invalid.",
			detail  = "The loaded modules are #structKeyList( mConfig )#",
			type    = "InvalidModuleException"
		);
	}

}
