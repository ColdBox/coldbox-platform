<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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
		<cfargument name="definition" required="true" hint="The injection dsl definition structure to process. Keys: name, dsl"/>
		<cfscript>
			var DSLNamespace 		= listFirst(arguments.definition.dsl,":");
			
			switch( DSLNamespace ){
				case "ioc" 				: { return getIOCDSL(arguments.definition);} 
				case "ocm" 				: { return getOCMDSL(arguments.definition);}
				case "webservice" 		: { return getWebserviceDSL(arguments.definition);}
				case "javaloader" 		: { return getJavaLoaderDSL(arguments.definition);}
				case "entityService" 	: { return getEntityServiceDSL(arguments.definition);} 
				case "coldbox" 			: { return getColdboxDSL(arguments.definition); }
			}
		</cfscript>    	
    </cffunction>	
	
	<!--- Get a ColdBox Datasource --->
	<cffunction name="getDatasource" access="private" output="false" returnType="any" hint="I will return to you a datasourceBean according to the alias of the datasource you wish to get from the configstruct" colddoc:generic="coldbox.system.core.db.DatasourceBean">
		<cfargument name="alias" type="any" hint="The alias of the datasource to get from the configstruct (alias property in the config file)">
		<cfscript>
		var datasources = instance.coldbox.getSetting("Datasources");
		//Try to get the correct datasource.
		if ( structKeyExists(datasources, arguments.alias) ){
			return createObject("component","coldbox.system.core.db.DatasourceBean").init(datasources[arguments.alias]);
		}
		</cfscript>
	</cffunction>
	
	<!--- getWebserviceDSL --->
	<cffunction name="getWebserviceDSL" access="private" returntype="any" hint="Get webservice dependencies" output="false" >
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfscript>
			var oWebservices 	= instance.coldbox.getPlugin("Webservices");
			var webserviceName  = listLast(arguments.definition.dsl,":");

			// Get Dependency, if not found, exception is thrown.
			return oWebservices.getWSobj( webserviceName );
		</cfscript>
	</cffunction>
	
	<!--- getJavaLoaderDSL --->
	<cffunction name="getJavaLoaderDSL" access="private" returntype="any" hint="Get JavaLoader Dependency" output="false" >
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfscript>
			var className  		= listLast(arguments.definition.dsl,":");

			// Get Dependency, if not found, exception is thrown
			return instance.coldbox.getPlugin("JavaLoader").create( className );
		</cfscript>
	</cffunction>
	
	<!--- getEntityServiceDSL --->
	<cffunction name="getEntityServiceDSL" access="private" returntype="any" hint="Get a virtual entity service object" output="false" >
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfscript>
			var entityName  = getToken(arguments.definition.dsl,2,":");

			// Do we have an entity name? If we do create virtual entity service
			if( len(entityName) ){
				return createObject("component","coldbox.system.orm.hibernate.VirtualEntityService").init( entityName );
			}

			// else Return Base ORM Service
			return createObject("component","coldbox.system.orm.hibernate.BaseORMService").init();
		</cfscript>
	</cffunction>
	
	<!--- getColdboxDSL --->
	<cffunction name="getColdboxDSL" access="private" returntype="any" hint="Get dependencies using the coldbox dependency DSL" output="false" >
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfscript>
			var thisType 			= arguments.definition.dsl;
			var thisTypeLen 		= listLen(thisType,":");
			var thisLocationType 	= "";
			var thisLocationKey 	= "";
			
			// DSL stages
			switch(thisTypeLen){
				// coldbox only DSL
				case 1: { return instance.coldbox; }
				// coldbox:{key} stage 2
				case 2: {
					thisLocationKey = getToken(thisType,2,":");
					switch( thisLocationKey ){
						case "fwconfigbean" 		: { return createObject("component","coldbox.system.core.collections.ConfigBean").init( instance.coldbox.getColdboxSettings() ); }
						case "configbean" 			: { return createObject("component","coldbox.system.core.collections.ConfigBean").init( instance.coldbox.getConfigSettings() ); }
						case "mailsettingsbean"		: { 
							return createObject("component","coldbox.system.core.mail.MailSettingsBean").init(instance.coldbox.getSetting("MailServer"),
									instance.coldbox.getSetting("MailUsername"),
									instance.coldbox.getSetting("MailPassword"), 
									instance.coldbox.getSetting("MailPort"));
						}
						case "loaderService"		: { return instance.coldbox.getLoaderService(); }
						case "requestService"		: { return instance.coldbox.getrequestService(); }
						case "debuggerService"		: { return instance.coldbox.getDebuggerService();}
						case "pluginService"		: { return instance.coldbox.getPluginService(); }
						case "handlerService"		: { return instance.coldbox.gethandlerService(); }
						case "interceptorService"	: { return instance.coldbox.getinterceptorService(); }
						case "cacheManager"			: { return instance.coldbox.getColdboxOCM(); }
						case "moduleService"		: { return instance.coldbox.getModuleService(); }
					}//end of services
					break;
				}
				//coldobx:{key}:{target} Usually for named factories
				case 3: {
					thisLocationType = getToken(thisType,2,":");
					thisLocationKey  = getToken(thisType,3,":");
					switch(thisLocationType){
						case "setting" 				: { return instance.coldbox.getSetting(thisLocationKey); }
						case "fwSetting" 			: { return instance.coldbox.getSetting(thisLocationKey,true); }
						case "plugin" 				: { return instance.coldbox.getPlugin(thisLocationKey);}
						case "myplugin" 			: {
							// module plugin
							if( find("@",thisLocationKey) ){
								return instance.coldbox.getPlugin(plugin=listFirst(thisLocationKey,"@"),customPlugin=true,module=listLast(thisLocationKey,"@"));
							}
							// normal custom plugin
							return instance.coldbox.getPlugin(plugin=thisLocationKey,customPlugin=true);
						}
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
	
	<!--- getIOCDSL --->
	<cffunction name="getIOCDSL" access="private" returntype="any" hint="Get an IOC dependency" output="false" >
		<cfargument name="definition" required="true" type="any" hint="The dependency definition structure">
		<cfscript>
			var thisTypeLen 	= listLen(arguments.definition.dsl,":");
			var beanName		= "";
			var oIOC		 	= instance.coldbox.getPlugin("IOC");
			
			// DSL stages
			switch(thisTypeLen){
				// ioc only, so get name from definition
				case 1: { beanName = arguments.definition.name; break;}
				// ioc:beanName, so get it from here
				case 2: { beanName = getToken(arguments.definition.dsl,2,":"); break;}
			}

			// Check for Bean existence first
			if( oIOC.getIOCFactory().containsBean(beanName) ){
				return oIOC.getBean(beanName);
			}
			else if( instance.log.canDebug() ){
				instance.log.debug("getIOCDSL() cannot find IOC Bean: #beanName# using definition: #arguments.definition.toString()#");
			}
		</cfscript>
	</cffunction>

	<!--- getOCMDSL --->
	<cffunction name="getOCMDSL" access="private" returntype="any" hint="Get OCM dependencies" output="false" >
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfscript>
			var thisTypeLen = listLen(arguments.definition.dsl,":");
			var cacheKey 	= "";
			var cache		= instance.cacheBox.getCache('default');
			
			// DSL stages
			switch(thisTypeLen){
				// ocm only
				case 1: { cacheKey = arguments.definition.name; break;}
				// ocm:objectKey
				case 2: { cacheKey = getToken(arguments.definition.dsl,2,":"); break;}
			}

			// Verify that dependency exists in the Cache container: Change this later once cache compat is removed
			if( cache.lookup(cacheKey) ){
				return cache.get(cacheKey);
			}
			else if( instance.log.canDebug() ){
				instance.log.debug("getOCMDSL() cannot find cache Key: #cacheKey# using definition: #arguments.definition.toString()#");
			}
		</cfscript>
	</cffunction>	
	
</cfcomponent>