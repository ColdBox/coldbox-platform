/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Process DSL functions via ColdBox
**/
component implements="coldbox.system.ioc.dsl.IDSLBuilder" accessors="true"{

	/**
	 * Injector Reference
	 */
	property name="injector";

	/**
	 * CacheBox Reference
	 */
	property name="cachebox";

	/**
	 * ColdBox Reference
	 */
	property name="coldbox";

	/**
	 * Log Reference
	 */
	property name="log";

	/**
	 * Configure the DSL Builder for operation and returns itself
	 *
	 * @injector The linked WireBox Injector
	 * @injector.doc_generic coldbox.system.ioc.Injector
	 *
	 * @return coldbox.system.ioc.dsl.IDSLBuilder
	 */
	function init( required injector ){
		variables.injector 	= arguments.injector;
		variables.coldbox 	= variables.injector.getColdBox();
		variables.cacheBox 	= variables.injector.getCacheBox();
		variables.log		= variables.injector.getLogBox().getLogger( this );

		return this;
	}

	/**
	 * Process an incoming DSL definition and produce an object with it
	 *
	 * @definition The injection dsl definition structure to process. Keys: name, dsl
	 * @targetObject The target object we are building the DSL dependency for. If empty, means we are just requesting building
	 *
	 * @return coldbox.system.ioc.dsl.IDSLBuilder
	 */
	function process( required definition, targetObject ){
		var DSLNamespace = listFirst( arguments.definition.dsl, ":" );

		switch( DSLNamespace ){
			case "coldbox" : { return getColdboxDSL( argumentCollection=arguments ); }
		}

		// else ignore not our DSL
	}

	/******************************** PRIVATE ****************************************************************/

	/**
	 * Process a ColdBox DSL
	 *
	 * @definition The injection dsl definition structure to process. Keys: name, dsl
	 * @targetObject The target object we are building the DSL dependency for. If empty, means we are just requesting building
	 */
	private function getColdBoxDSL( required definition, targetObject ){
		var thisName 			= arguments.definition.name;
		var thisType 			= arguments.definition.dsl;
		var thisTypeLen 		= listLen( thisType, ":" );
		var thisLocationType 	= "";
		var thisLocationKey 	= "";
		var moduleSettings		= "";

		// Support shortcut for specifying name in the definition instead of the DSl for supporting namespaces
		if(	thisTypeLen eq 2
			and listFindNoCase( "setting,fwSetting,datasource,interceptor", listLast( thisType, ":" ) )
			and len( thisName )
		){
			// Add the additional alias to the DSL
			thisType 	= thisType & ":" & thisName;
			thisTypeLen = 3;
		}

		// DSL stages
		switch( thisTypeLen ){
			// coldbox only DSL
			case 1 : {
				return variables.coldbox;
			}

			// coldbox:{key} stage 2
			case 2 : {
				thisLocationKey = getToken( thisType, 2, ":" );
				switch( thisLocationKey ){
					case "configSettings"		: { return variables.coldbox.getConfigSettings(); }
					case "dataMarshaller"		: { return variables.coldbox.getDataMarshaller(); }
					case "flash"		 		: { return variables.coldbox.getRequestService().getFlashScope(); }
					case "fwSettings"			: { return variables.coldbox.getColdboxSettings(); }
					case "handlerService"		: { return variables.coldbox.getHandlerService(); }
					case "interceptorService"	: { return variables.coldbox.getInterceptorService(); }
					case "loaderService"		: { return variables.coldbox.getLoaderService(); }
					case "moduleService"		: { return variables.coldbox.getModuleService(); }
					case "requestContext"		: { return variables.coldbox.getRequestService().getContext(); }
					case "requestService"		: { return variables.coldbox.getRequestService(); }
					case "router"				: { return variables.injector.getInstance( "router@coldbox" ); }
					case "routingService"		: { return variables.coldbox.getRoutingService(); }
					case "renderer"				: { return variables.coldbox.getRenderer(); }
				} // end of services

				break;
			}

			//coldbox:{key}:{target} Usually for named factories
			case 3 : {
				thisLocationType = getToken( thisType, 2, ":" );
				thisLocationKey  = getToken( thisType, 3, ":" );
				switch( thisLocationType ){
					case "setting" 				: {
						// module setting?
						if( find( "@", thisLocationKey ) ){
							moduleSettings = variables.coldbox.getSetting( "modules" );
							if( structKeyExists( moduleSettings, listlast(thisLocationKey, "@" ))
								and structKeyExists( moduleSettings[ listlast(thisLocationKey, "@" ) ],"settings" )
								and structKeyExists( moduleSettings[ listlast(thisLocationKey, "@" ) ].settings,listFirst( thisLocationKey, "@" ) )
								){
								return moduleSettings[ listlast(thisLocationKey, "@" ) ].settings[ listFirst( thisLocationKey, "@" ) ];
							}
							else if( variables.log.canDebug() ){
								variables.log.debug( "The module requested: #listlast( thisLocationKey, "@" )# does not exist in the loaded modules. Loaded modules are #structKeyList(moduleSettings)#" );
							}
						}
						// just get setting
						return variables.coldbox.getSetting( thisLocationKey );
					}
					case "modulesettings"		: {
						moduleSettings = variables.coldbox.getSetting( "modules" );
						if( structKeyExists( moduleSettings, thisLocationKey ) ){
							return moduleSettings[ thisLocationKey ].settings;
						}
						else if( variables.log.canDebug() ){
							variables.log.debug( "The module requested: #thisLocationKey# does not exist in the loaded modules. Loaded modules are #structKeyList(moduleSettings)#" );
						}
					}
					case "moduleconfig"		: {
						moduleSettings = variables.coldbox.getSetting( "modules" );
						if( structKeyExists( moduleSettings, thisLocationKey ) ){
							return moduleSettings[ thisLocationKey ];
						}
						else if( variables.log.canDebug() ){
							variables.log.debug( "The module requested: #thisLocationKey# does not exist in the loaded modules. Loaded modules are #structKeyList(moduleSettings)#" );
						}
					}
					case "fwSetting" 			: { return variables.coldbox.getSetting( thisLocationKey, true ); }
					case "interceptor" 			: { return variables.coldbox.getInterceptorService().getInterceptor( thisLocationKey, true ); }
				}//end of services

				break;
			}
		}

		// If we get here we have a problem.
		throw(
			type 	= "ColdBoxDSL.InvalidDSL",
			message = "The DSL provided was not valid: #arguments.definition.toString()#"
		);
	}

}