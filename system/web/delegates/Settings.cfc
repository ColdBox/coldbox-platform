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
		delegate="getSetting,getColdBoxSetting,settingExists,setSetting,getModuleSettings,getModuleConfig,getUserSessionIdentifier";

}
