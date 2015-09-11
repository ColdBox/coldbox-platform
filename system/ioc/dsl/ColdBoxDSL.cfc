<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The DSL processor for all ColdBox related stuff

----------------------------------------------------------------------->
<cfcomponent hint="The DSL builder for all ColdBox related stuff" implements="coldbox.system.ioc.dsl.IDSLBuilder" output="false">

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Configure the DSL for operation and returns itself" colddoc:generic="coldbox.system.ioc.dsl.IDSLBuilder">
    	<cfargument name="injector" type="any" required="true" hint="The linked WireBox injector" colddoc:generic="coldbox.system.ioc.Injector"/>
		<cfscript>
			instance = {
				injector = arguments.injector
			};
			instance.coldbox 	= instance.injector.getColdBox();
			instance.cachebox	= instance.injector.getCacheBox();
			instance.log		= instance.injector.getLogBox().getLogger( this );

			return this;
		</cfscript>
    </cffunction>

	<!--- process --->
    <cffunction name="process" output="false" access="public" returntype="any" hint="Process an incoming DSL definition and produce an object with it.">
		<cfargument name="definition" 	required="true"  hint="The injection dsl definition structure to process. Keys: name, dsl"/>
		<cfargument name="targetObject" required="false" hint="The target object we are building the DSL dependency for. If empty, means we are just requesting building"/>
		<cfscript>
			var DSLNamespace 		= listFirst(arguments.definition.dsl,":");

			switch( DSLNamespace ){
				case "ocm" 				: { return getOCMDSL(argumentCollection=arguments);}
				case "coldbox" 			: { return getColdboxDSL(argumentCollection=arguments); }
			}
		</cfscript>
    </cffunction>

	<!--- Get a ColdBox Datasource --->
	<cffunction name="getDatasource" access="private" output="false" returnType="any" hint="I will return to you a datasourceBean according to the alias of the datasource you wish to get from the configstruct" colddoc:generic="coldbox.system.core.db.DatasourceBean">
		<cfargument name="alias" type="any" hint="The alias of the datasource to get from the configstruct (alias property in the config file)">
		<cfscript>
		var datasources = instance.coldbox.getSetting( "Datasources" );
		//Try to get the correct datasource.
		if ( structKeyExists( datasources, arguments.alias ) ){
			return datasources[ arguments.alias ];
		}
		</cfscript>
	</cffunction>

	<!--- getColdboxDSL --->
	<cffunction name="getColdboxDSL" access="private" returntype="any" hint="Get dependencies using the coldbox dependency DSL" output="false" >
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfargument name="targetObject" required="false" hint="The target object we are building the DSL dependency for. If empty, means we are just requesting building"/>
		<cfscript>
			var thisName 			= arguments.definition.name;
			var thisType 			= arguments.definition.dsl;
			var thisTypeLen 		= listLen(thisType,":");
			var thisLocationType 	= "";
			var thisLocationKey 	= "";
			var moduleSettings		= "";

			// Support shortcut for specifying name in the definition instead of the DSl for supporting namespaces
			if(	thisTypeLen eq 2
				and listFindNoCase("setting,fwSetting,datasource,interceptor",listLast(thisType,":"))
				and len(thisName)){
				// Add the additional alias to the DSL
				thisType = thisType & ":" & thisName;
				thisTypeLen = 3;
			}

			// DSL stages
			switch(thisTypeLen){
				// coldbox only DSL
				case 1: { return instance.coldbox; }
				// coldbox:{key} stage 2
				case 2: {
					thisLocationKey = getToken(thisType,2,":");
					switch( thisLocationKey ){
						case "flash"		 		: { return instance.coldbox.getRequestService().getFlashScope(); }
						case "loaderService"		: { return instance.coldbox.getLoaderService(); }
						case "requestService"		: { return instance.coldbox.getrequestService(); }
						case "handlerService"		: { return instance.coldbox.gethandlerService(); }
						case "interceptorService"	: { return instance.coldbox.getinterceptorService(); }
						case "moduleService"		: { return instance.coldbox.getModuleService(); }
						case "renderer"				: { return instance.coldbox.getRenderer(); }
						case "dataMarshaller"		: { return instance.coldbox.getDataMarshaller(); }
						case "configSettings"		: { return instance.coldbox.getConfigSettings(); }
						case "fwSettings"			: { return instance.coldbox.getColdboxSettings(); }
					} // end of services

					break;
				}
				//coldobx:{key}:{target} Usually for named factories
				case 3: {
					thisLocationType = getToken(thisType,2,":");
					thisLocationKey  = getToken(thisType,3,":");
					switch(thisLocationType){
						case "setting" 				: {
							// module setting?
							if( find("@",thisLocationKey) ){
								moduleSettings = instance.coldbox.getSetting("modules");
								if( structKeyExists(moduleSettings, listlast(thisLocationKey,"@") ) ){
									return moduleSettings[ listlast(thisLocationKey,"@") ].settings[ listFirst(thisLocationKey,"@") ];
								}
								else if( instance.log.canDebug() ){
									instance.log.debug("The module requested: #listlast(thisLocationKey,"@")# does not exist in the loaded modules. Loaded modules are #structKeyList(moduleSettings)#");
								}
							}
							// just get setting
							return instance.coldbox.getSetting( thisLocationKey );
						}
						case "modulesettings"		: {
							moduleSettings = instance.coldbox.getSetting("modules");
							if( structKeyExists(moduleSettings, thisLocationKey ) ){
								return moduleSettings[ thisLocationKey ].settings;
							}
							else if( instance.log.canDebug() ){
								instance.log.debug("The module requested: #thisLocationKey# does not exist in the loaded modules. Loaded modules are #structKeyList(moduleSettings)#");
							}
						}
						case "moduleconfig"		: {
							moduleSettings = instance.coldbox.getSetting("modules");
							if( structKeyExists(moduleSettings, thisLocationKey ) ){
								return moduleSettings[ thisLocationKey ];
							}
							else if( instance.log.canDebug() ){
								instance.log.debug("The module requested: #thisLocationKey# does not exist in the loaded modules. Loaded modules are #structKeyList(moduleSettings)#");
							}
						}
						case "fwSetting" 			: { return instance.coldbox.getSetting(thisLocationKey,true); }
						case "datasource" 			: { return getDatasource(thisLocationKey); }
						case "interceptor" 			: { return instance.coldbox.getInterceptorService().getInterceptor(thisLocationKey,true); }
					}//end of services
					break;
				}
			}

			// debug info
			if( instance.log.canDebug() ){
				instance.log.debug("getColdboxDSL() cannot find dependency using definition: #arguments.definition.toString()#");
			}
		</cfscript>
	</cffunction>

	<!--- getOCMDSL --->
	<cffunction name="getOCMDSL" access="private" returntype="any" hint="Get OCM dependencies" output="false" >
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfargument name="targetObject" required="false" hint="The target object we are building the DSL dependency for. If empty, means we are just requesting building"/>
		<cfscript>
			throw( "This DSL has been deprecated in favor of the 'cachebox' Namespace." );
		</cfscript>
	</cffunction>

</cfcomponent>