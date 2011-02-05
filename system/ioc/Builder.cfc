<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The WireBox injector is the pivotal class in WireBox that performs
	dependency injection.  It can be used standalone or it can be used in conjunction
	of a ColdBox application context.  It can also be configured with a mapping configuration
	file called a binder, that can provide object/mappings and configuration data.
	
	Easy Startup:
	injector = new coldbox.system.ioc.Injector();
	
	Binder Startup
	injector = new coldbox.system.ioc.Injector(new MyBinder());
	
	Binder Path Startup
	injector = new coldbox.system.ioc.Injector("config.MyBinder");

----------------------------------------------------------------------->
<cfcomponent hint="A WireBox Injector: Builds the graphs of objects that make up your application." output="false" serializable="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
		
	<!--- init --->
	<cffunction name="init" access="public" returntype="Builder" hint="Constructor. If called without a configuration binder, then WireBox will instantiate the default configuration binder found in: coldbox.system.ioc.config.DefaultBinder" output="false" >
		<cfargument name="injector" type="any" required="true" hint="The linked WireBox injector" colddoc:generic="coldbox.system.ioc.Injector"/>
		<cfscript>
			instance = {
				injector 	= arguments.injector,
				logBox		= arguments.injector.getLogBox(),
				log		 	= arguments.injector.getLogBox().getlogger(this),
				utility		= arguments.injector.getUtil()
			};
			// Wire up coldbox context and cachebox if linked.
			if( instance.injector.isColdBoxLinked() ){
				instance.coldbox = instance.injector.getColdBox();
			}
			if( instance.injector.isCacheBoxLinked() ){
				instance.cachebox = instance.injector.getCacheBox();
			}
			return this;
		</cfscript>
	</cffunction>
	
	<!--- buildProviderMixer --->
    <cffunction name="buildProviderMixer" output="false" access="public" returntype="any" hint="Used to provider providers via mixers on targeted objects">
    	<cfscript>
    		// return the instance from the injected counterparts
			return this.$wirebox.getInstance( this.$wireboxProviders[ getFunctionCalledName() ] );
		</cfscript>
    </cffunction>
	
	<!--- buildCFC --->
    <cffunction name="buildCFC" output="false" access="public" returntype="any" hint="Build a cfc class via mappings">
    	<cfargument name="mapping" 			required="true" 	hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfargument name="initArguments" 	required="false" 	hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfscript>
			var thisMap = arguments.mapping;
			var oModel 	= createObject("component", thisMap.getPath() );
			var constructorArgs = "";
		</cfscript>
		
		<!--- Constructor initialization? --->
		<cfif thisMap.isAutoInit()>
			<!--- Get Arguments --->
			<cfset constructorArgs = buildArgumentCollection(thisMap, thisMap.getDIConstructorArguments() )>
			<!--- Do We have initArguments to override --->
			<cfif structKeyExists(Arguments,"initArguments")>
				<cfset structAppend(constructorArgs,arguments.initArguments,true)>
			</cfif>
			<!--- Invoke constructor --->
			<cfinvoke component="#oModel#"
					  method="#thisMap.getConstructor()#"
					  argumentcollection="#constructorArgs#">
		</cfif>
		
		<cfreturn oModel>
    </cffunction>
	
	<!--- buildFactoryMethod --->
    <cffunction name="buildFactoryMethod" output="false" access="public" returntype="any" hint="Build an object using a factory method">
    	<cfargument name="mapping" 			required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfargument name="initArguments" 	required="false" 	hint="The structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfscript>
    		var thisMap 	= arguments.mapping;
			var oFactory 	= "";
			var oModel		= "";
			var factoryName = thisMap.getPath();
			var methodArgs  = "";
			
			// check if factory exists, else throw exception
			if( NOT instance.injector.containsInstance( factoryName ) ){
				instance.utility.throwIt(message="The factory mapping: #factoryName# is not registered with the injector",type="Builder.InvalidFactoryMappingException");
			}
    		// get Factory mapping
			oFactory = instance.injector.getInstance( factoryName );
			// Get Method Arguments
			methodArgs = buildArgumentCollection(thisMap, thisMap.getDIMethodArguments() );
			// Do we have overrides
			if( structKeyExists(Arguments, "initArguments") ){
				structAppend(methodArgs,arguments.initArguments,true);
			}
		</cfscript>
		
		<!--- Get From Factory --->
		<cfinvoke component="#oFactory#"
				  returnvariable="oModel"
				  method="#thisMap.getMethod()#"
			  	  argumentcollection="#methodArgs#">
		
		<!--- Return factory bean --->
		<cfreturn oModel>
    </cffunction>

	
	<!--- buildJavaClass --->
    <cffunction name="buildJavaClass" output="false" access="public" returntype="any" hint="Build a Java class via mappings">
    	<cfargument name="mapping" 	required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfscript>
			var x 			= 1;
			var DIArgs 		= arguments.mapping.getDIConstructorArguments();
			var DIArgsLen 	= arrayLen(DIArgs);
			var args		= [];

			// Loop Over Arguments
			for(x = 1; x <= DIArgsLen; x++){
				// do we have javacasting?
				if( structKeyExists(DIArgs[x],"javaCast") ){
					ArrayAppend(args, "javaCast(DIArgs[#x#].javaCast, DIArgs[#x#].value)");
				}	
				else{
					ArrayAppend(args, "DIArgs[#x#].value");
				}
			}

			return evaluate('createObject("java",arguments.mapping.getPath()).init(#arrayToList(args)#)');
		</cfscript>
    </cffunction>
	
	<!--- buildArgumentCollection --->
    <cffunction name="buildArgumentCollection" output="false" access="public" returntype="any" hint="Build arguments for a mapping and return the structure representation">
    	<cfargument name="mapping" 			required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfargument name="argumentArray" 	required="true" hint="The argument array of data"/>
    	<cfscript>
			var x 			= 1;
			var thisMap 	= arguments.mapping;
			var DIArgs 		= arguments.argumentArray;
			var DIArgsLen 	= arrayLen(DIArgs);
			var args		= structnew();
			
			// Loop Over Arguments
			for(x=1;x lte DIArgsLen; x=x+1){
				// Is value set in mapping? If so, add it and continue
				if( structKeyExists(DIArgs[x],"value") ){
					args[ DIArgs[x].name ] = DIArgs[x].value;
					continue;
				}
				
				// Is it by DSL construction? If so, add it and continue, if not found it returns null, which is ok
				if( structKeyExists(DIArgs[x],"dsl") ){
					args[ DIArgs[x].name ] = buildDSLDependency( DIArgs[x].dsl );
					continue;
				}
				
				// If we get here then it is by ref id, so let's verify it exists and optional
				if( len(instance.injector.containsInstance( DIArgs[x].ref )) ){
					args[ DIArgs[x].name ] = instance.injector.getInstance( DIArgs[x].ref );
					continue;
				}
				
				// Not found, so check if it is required
				if( DIArgs[x].required ){
					// Log the error
					instance.log.error("Argument reference not located: #DIArgs[x].name# for mapping: #arguments.mapping.getMemento().toString()#", DIArgs[x]);
					// not found but required, then throw exception
					instance.utility.throwIt(message="Argument reference not located: #DIArgs[x].name#",
									  		 detail="Injecting: #thisMap.getMemento().toString()#. The argument details are: #DIArgs[x].toString()#.",
									  		 type="Injector.ArgumentNotFoundException");
				}
				// else just log it via debug
				else if( instance.log.canDebug() ){
					instance.log.debug("Argument reference not located: #DIArgs[x].name# for mapping: #arguments.mapping.getMemento().toString()#", DIArgs[x]);
				}
				
			}
			
			return args;
		</cfscript>
    </cffunction>
	
	<!--- buildWebservice --->
    <cffunction name="buildWebservice" output="false" access="public" returntype="any" hint="Build a webservice object">
    	<cfargument name="mapping" 			required="true" 	hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfargument name="initArguments" 	required="false" 	hint="The structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfscript>
    		var argStruct 	= {};
			var DIArgs 		= arguments.mapping.getDIConstructorArguments();
			var DIArgsLen   = arraylen(DIArgs);
    		
			// Loop Over Arguments for wsdl args
			for(x=1;x lte DIArgsLen; x=x+1){
				argStruct[ DIArgs[x].name ] = DIArgs[x].value;
			}
			
			// Do we ahve overrides
			if( structKeyExists(Arguments,"initArguments") ){
				structAppend(argStruct, arguments.initArguments,true);
			}
			
			return createObject("webservice", arguments.mapping.getPath(), argStruct );
		</cfscript>
    </cffunction>
	
	<!--- buildFeed --->
    <cffunction name="buildFeed" output="false" access="public" returntype="any" hint="Build an rss feed the WireBox way">
    	<cfargument name="mapping" 	required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfset var results = {}>
		
    	<cffeed action="read" source="#arguments.mapping.getPath()#" query="results.items" properties="results.metadata">
    	
		<cfreturn results>
    </cffunction>
	
<!------------------------------------------- Internal DSL Builders ------------------------------------------>

	<!--- buildSimpleDSL --->
	<cffunction name="buildSimpleDSL" output="false" access="public" returntype="any" hint="Build a DSL Dependency using a simple dsl string">
		<cfargument name="dsl" required="true" 	hint="The dsl string to build">
		<cfscript>
			var definition = {
				name = "",
				dsl = arguments.dsl
			};
			return buildDSLDependency( definition );
		</cfscript>
	</cffunction>

	<!--- buildDSLDependency --->
	<cffunction name="buildDSLDependency" output="false" access="public" returntype="any" hint="Build a DSL Dependency, if not found, returns null">
		<cfargument name="definition" required="true" hint="The dependency definition structure: name, dsl as keys">
		<cfscript>
			var refLocal 			= {};
			var DSLNamespace 		= listFirst(arguments.definition.dsl,":");
			var coldboxDSLRegex		= "^(ioc|ocm|webservice|javaloader|entityService|coldbox|cachebox)$";

			// coldbox context check
			if( refindNoCase(coldboxDSLRegex,DSLNamespace) AND NOT instance.injector.isColdBoxLinked() ){
				instance.utility.throwIt(message="The DSLNamespace: #DSLNamespace# cannot be used as it requires a ColdBox Context",type="Builder.IllegalDSLException");
			}
			// cachebox context check
			else if( refindNoCase("^cachebox",DSLNamespace) AND NOT instance.injector.isCacheBoxLinked() ){
				instance.utility.throwIt(message="The DSLNamespace: #DSLNamespace# cannot be used as it requires a CacheBox Context",type="Builder.IllegalDSLException");
			}
			
			// Determine Type of Injection according to Internal Types first
			// Some namespaces requires the ColdBox context, if not found, an exception is thrown.
			switch(DSLNamespace){
				// ioc dependency usually only when coldbox context is connected
				case "ioc" 				 : { refLocal.dependency = getIOCDSL(arguments.definition); break; }
				// ocm is used only on coldbox context
				case "ocm" 				 : { refLocal.dependency = getOCMDSL(arguments.definition); break; }
				// coldbox webservice is used only on coldbox context
				case "webservice" 		 : { refLocal.dependency = getWebserviceDSL(arguments.definition); break; }
				// javaloader only used on coldbox context
				case "javaloader"		 : { refLocal.dependency = getJavaLoaderDSL(arguments.definition); break;}
				// entity service only used on coldbox context
				case "entityService"	 : { refLocal.dependency = getEntityServiceDSL(arguments.definition); break;}
				// coldbox is used only on coldbox context
				case "coldbox" 			 : { refLocal.dependency = getColdboxDSL(arguments.definition); break; }
				// basic wirebox injection DSL
				case "model" : case "id" : { refLocal.dependency = getModelDSL(arguments.definition); break; }
				// logbox injection DSL
				case "logbox"			 : { refLocal.dependency = getLogBoxDSL(arguments.definition); break;}
				// cachebox injection DSL
				case "cacheBox"			 : { refLocal.dependency = getCacheBoxDSL(arguments.definition); break;}
				// provider injection DSL
				case "provider"			: { refLocal.dependency = getProviderDSL(arguments.definition); break; }
				
				// No internal DSL's found, then check custom DSL's
				default : {
					// TODO: custom DSL's
				}
			}
				
			// return only if found, else returns null
			if( structKeyExists(refLocal,"dependency") ){ return refLocal.dependency; }
			
			// Some warning data
			if( instance.log.canWarn() ){
				instance.log.warn("The DSL dependency definition: #arguments.definition# did not produce any resulting dependency");
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- DSL BUILDER METHODS ------------------------------------------>

	<!--- getIOCDSL --->
	<cffunction name="getIOCDSL" access="private" returntype="any" hint="Get an IOC dependency" output="false" >
		<cfargument name="definition" required="true" type="any" hint="The dependency definition structure">
		<cfscript>
			var thisTypeLen 	= listLen(arguments.definition.dsl,":");
			var beanName		= "";
			
			// DSL stages
			switch(thisTypeLen){
				// ioc only, so get name from definition
				case 1: { beanName = arguments.definition.name; break;}
				// ioc:beanName, so get it from here
				case 2: { beanName = getToken(arguments.definition.dsl,2,":"); break;}
			}

			// Check for Bean existence first
			if( oIOC.getIOCFactory().containsBean(beanName) ){
				return instance.coldbox.getPlugin("IOC").getBean(beanName);
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
								return instance.coldbox.getMyPlugin(plugin=listFirst(thisLocationKey,"@"),module=listLast(thisLocationKey,"@"));
							}
							// normal custom plugin
							return instance.coldbox.getMyPlugin(thisLocationKey);
						}
						case "datasource" 			: { return getDatasource(thisLocationKey); }
						case "interceptor" 			: { return instance.coldbox.getInterceptorService().getInterceptor(thisLocationKey,true); }
					}//end of services
					break;
				}
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
	
	<!--- getModelDSL --->
	<cffunction name="getModelDSL" access="private" returntype="any" hint="Get dependencies using the model dependency DSL" output="false" >
		<cfargument name="definition" required="true" 	type="any" hint="The dependency definition structure">
		<cfscript>
			var thisType 		= arguments.definition.dsl;
			var thisTypeLen 	= listLen(thisType,":");
			var methodCall 		= "";
			var modelName 		= "";
			var oModel			= "";

			// DSL stages
			switch(thisTypeLen){
				//model default, get name from property name
				case 1: { modelName = arguments.definition.name; break; }
				//model:{name} stage
				case 2: { modelName = getToken(thisType,2,":"); break;
				}
				//model:{name}:{method} stage
				case 3: {
					modelName 	= getToken(thisType,2,":");
					methodCall 	= getToken(thisType,3,":");
					break;
				}
			}

			// Check if model Exists
			if( instance.injector.containsInstance( modelName ) ){
				// Get Model object
				oModel = instance.injector.getInstance( modelName );
				// Factories: TODO: Add arguments with 'ref()' parsing for argument references or 'dsl()'
				if( len(methodCall) ){
					return evaluate("oModel.#methodCall#()");
				}
				return oModel;
			}
			else if( instance.log.canDebug() ){
				instance.log.debug("getModelDSL() cannot find model object #modelName# using definition #arguments.definition.toString()#");
			}
		</cfscript>
	</cffunction>
	
	<!--- getLogBoxDSL --->
	<cffunction name="getLogBoxDSL" access="private" returntype="any" hint="Get dependencies using the logbox dependency DSL" output="false" >
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfscript>
			var thisType 			= arguments.definition.dsl;
			var thisTypeLen 		= listLen(thisType,":");
			var thisLocationType 	= "";
			var thisLocationKey 	= "";
			
			// DSL stages
			switch(thisTypeLen){
				// LogBox
				case 1 : { return instance.logBox; }
				// logbox:root 
				case 2 : {
					thisLocationKey = getToken(thisType,2,":");
					switch( thisLocationKey ){
						case "root" : { return instance.logbox.getRootLogger(); }
					}
					break;
				}
				// Named Loggers
				case 3 : {
					thisLocationType 	= getToken(thisType,2,":");
					thisLocationKey 	= getToken(thisType,3,":");
					// DSL Level 2 Stage Types
					switch(thisLocationType){
						// Get a named Logger
						case "logger" : { return instance.logBox.getLogger(thisLocationKey); break; }
					}
					break;
				} // end level 3 main DSL
			}
		</cfscript>
	</cffunction>

	<!--- getCacheBoxDSL --->
	<cffunction name="getCacheBoxDSL" access="private" returntype="any" hint="Get dependencies using the cacheBox dependency DSL" output="false" >
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfscript>
			var thisType 			= arguments.definition.dsl;
			var thisTypeLen 		= listLen(thisType,":");
			var cacheName 			= "";
			var cacheElement 		= "";
			
			// DSL stages
			switch(thisTypeLen){
				// CacheBox
				case 1 : { return instance.cacheBox; }
				// CacheBox:CacheName
				case 2 : {
					cacheName = getToken(thisType,2,":");
					// Verify that cache exists
					if( instance.cacheBox.cacheExists( cacheName ) ){
						return instance.cacheBox.getCache( cacheName );
					}
					else if( instance.log.canDebug() ){
						instance.log.debug("getCacheBoxDSL() cannot find named cache #cacheName# using definition: #arguments.definition.toString()#. Existing cache names are #instance.cacheBox.getCacheNames().toString#");
					}
					break;
				}
				// CacheBox:CacheName:Element
				case 3 : {
					cacheName 		= getToken(thisType,2,":");
					cacheElement 	= getToken(thisType,3,":");
					// Verify that dependency exists in the Cache container
					if( instance.cacheBox.getCache( cacheName ).lookup( cacheElement ) ){
						return instance.cacheBox.getCache( cacheName ).get( cacheElement );
					}
					else if( instance.log.canDebug() ){
						instance.log.debug("getCacheBoxDSL() cannot find cache Key: #cacheElement# in the #cacheName# cache using definition: #arguments.definition.toString()#");
					}
					break;
				} // end level 3 main DSL
			}
		</cfscript>
	</cffunction>
	
	<!--- geProviderDSL --->
	<cffunction name="geProviderDSL" access="private" returntype="any" hint="Get dependencies using the our provider pattern DSL" output="false" >
		<cfargument name="definition" required="true" 	type="any" hint="The dependency definition structure">
		<cfscript>
			var thisType 		= arguments.definition.dsl;
			var thisTypeLen 	= listLen(thisType,":");
			var providerName 	= "";
			
			// DSL stages
			switch(thisTypeLen){
				// provider default, get name of the provider from property
				case 1: { providerName = arguments.definition.name; break; }
				// provider:{name} stage
				case 2: { providerName = getToken(thisType,2,":"); break;
				}
			}

			// Check if model Exists
			if( instance.injector.containsInstance( providerName ) ){
				// Build provider and return it.
				return createObject("component","coldbox.system.ioc.Provider").init(instance.injector, providerName);
			}
			else if( instance.log.canDebug() ){
				instance.log.debug("getProviderDSL() cannot find model object #providerName# using definition #arguments.definition.toString()#");
			}
		</cfscript>
	</cffunction>
		
</cfcomponent>