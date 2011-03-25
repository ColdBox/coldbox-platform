<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The WireBox builder for components, java, etc. I am in charge of building stuff and 
	integration dsl builders.

TODO: update dsl consistency, so it is faster.
----------------------------------------------------------------------->
<cfcomponent hint="The WireBox builder for components, java, etc. I am in charge of building stuff and integration dsl builders." output="false" serializable="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
		
	<!--- init --->
	<cffunction name="init" access="public" returntype="Builder" hint="Constructor. If called without a configuration binder, then WireBox will instantiate the default configuration binder found in: coldbox.system.ioc.config.DefaultBinder" output="false" >
		<cfargument name="injector" type="any" required="true" hint="The linked WireBox injector" colddoc:generic="coldbox.system.ioc.Injector"/>
		<cfscript>
			instance = {
				injector 	= arguments.injector,
				logBox		= arguments.injector.getLogBox(),
				log		 	= arguments.injector.getLogBox().getlogger(this),
				utility		= arguments.injector.getUtil(),
				customDSL	= structnew()
			};
			
			// Do we need to build the coldbox DSL namespace
			if( instance.injector.isColdBoxLinked() ){
				instance.coldboxDSL = createObject("component","coldbox.system.ioc.dsl.ColdBoxDSL").init( arguments.injector );
			}
			// Is CacheBox Linked?
			if( instance.injector.isCacheBoxLinked() ){
				instance.cacheBoxDSL = createObject("component","coldbox.system.ioc.dsl.CacheBoxDSL").init( arguments.injector );
			}
			return this;
		</cfscript>
	</cffunction>
	
	<!--- getCustomDSL --->
    <cffunction name="getCustomDSL" output="false" access="public" returntype="any" hint="Get the registered custom dsl instances structure" colddoc:generic="struct">
    	<cfreturn instance.customDSL>
    </cffunction>
	
	<!--- registerCustomBuilders --->
    <cffunction name="registerCustomBuilders" output="false" access="public" returntype="any" hint="Register custom DSL builders with this main wirebox builder">
    	<cfscript>
    		var customDSL 	= instance.injector.getBinder().getCustomDSL();
    		var key				= "";
			
    		// Register Custom DSL Builders
			for(key in customDSL){
				instance.customDSL[key] = createObject("component",customDSL[key]).init( instance.injector );
				// Debugging
				if( instance.log.canDebug() ){
					instance.log.debug("Registered custom DSL Builder: #customDSL[key]# with namespace: #key#");
				}
			}		
		</cfscript>
    </cffunction>	
	
	<!--- buildProviderMixer --->
    <cffunction name="buildProviderMixer" output="false" access="public" returntype="any" hint="Used to provider providers via mixers on targeted objects">
    	<cfscript>
    		// return the instance from the injected counterparts
			return this.$wbScopeStorage.get(this.$wbScopeInfo.key, this.$wbScopeInfo.scope)
						.getInstance( this.$wbProviders[ getFunctionCalledName() ] );
		</cfscript>
    </cffunction>
	
	<!--- buildCFC --->
    <cffunction name="buildCFC" output="false" access="public" returntype="any" hint="Build a cfc class via mappings">
    	<cfargument name="mapping" 			required="true" 	hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfargument name="initArguments" 	required="false"	default="#structnew()#" 	hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfscript>
			var thisMap = arguments.mapping;
			var oModel 	= createObject("component", thisMap.getPath() );
			var constructorArgs = "";
		</cfscript>
		
		<!--- Constructor initialization? --->
		<cfif thisMap.isAutoInit()  AND structKeyExists(oModel,thisMap.getConstructor())>
			<!--- Get Arguments --->
			<cfset constructorArgs = buildArgumentCollection(thisMap, thisMap.getDIConstructorArguments() )>
			
			<!--- Do We have initArguments to override --->
			<cfif NOT structIsEmpty(arguments.initArguments)>
				<cfset structAppend(constructorArgs,arguments.initArguments,true)>
			</cfif>
			
			<cftry>
				<!--- Invoke constructor --->
				<cfinvoke component="#oModel#"
						  method="#thisMap.getConstructor()#"
						  argumentcollection="#constructorArgs#">
						  
				<cfcatch type="any">
					<!--- Controlled Exception --->
					<cfthrow message="Error building: #thisMap.getName()# -> #cfcatch.message# #cfcatch.detail# with constructor arguments: #constructorArgs.toString()#" 
							 detail="Mapping: #thisMap.getMemento().toString()#, Stacktrace: #cfcatch.stacktrace#" 
							 type="Builder.BuildCFCDependencyException">
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfreturn oModel>
    </cffunction>
	
	<!--- buildFactoryMethod --->
    <cffunction name="buildFactoryMethod" output="false" access="public" returntype="any" hint="Build an object using a factory method">
    	<cfargument name="mapping" 			required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfargument name="initArguments" 	required="false"	default="#structnew()#" 	hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
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
			if( NOT structIsEmpty(arguments.initArguments) ){
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
			var thisMap 	= arguments.mapping;

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

			// init?
			if( thisMap.isAutoInit() ){
				if( arrayLen(args) ){
					return evaluate('createObject("java",arguments.mapping.getPath()).init(#arrayToList(args)#)');
				}
				return createObject("java",arguments.mapping.getPath()).init();
			}
			
			// return with no init
			return createObject("java",arguments.mapping.getPath());
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
					args[ DIArgs[x].name ] = buildDSLDependency( DIArgs[x] );
					continue;
				}
				
				// If we get here then it is by ref id, so let's verify it exists and optional
				if( len(instance.injector.containsInstance( DIArgs[x].ref )) ){
					args[ DIArgs[x].name ] = instance.injector.getInstance(name=DIArgs[x].ref);
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
    	<cfargument name="initArguments" 	required="false"	default="#structnew()#" 	hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfscript>
    		var argStruct 	= {};
			var DIArgs 		= arguments.mapping.getDIConstructorArguments();
			var DIArgsLen   = arraylen(DIArgs);
    		
			// Loop Over Arguments for wsdl args
			for(x=1;x lte DIArgsLen; x=x+1){
				argStruct[ DIArgs[x].name ] = DIArgs[x].value;
			}
			
			// Do we ahve overrides
			if( NOT structIsEmpty(arguments.initArguments) ){
				structAppend(argStruct, arguments.initArguments,true);
			}
			
			return createObject("webservice", arguments.mapping.getPath(), argStruct );
		</cfscript>
    </cffunction>
	
	<!--- buildFeed --->
    <cffunction name="buildFeed" output="false" access="public" returntype="any" hint="Build an rss feed the WireBox way">
    	<cfargument name="mapping" 	required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfset var results = {}>
		
    	<cffeed action="read" source="#arguments.mapping.getPath()#" query="results.items" properties="results.metadata" timeout="20">
    	
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
				// ColdBox Context DSL
				case "ioc" : case "ocm" : case "webservice" : case "javaloader" : case "entityService" :case "coldbox" : { 
					refLocal.dependency = instance.coldboxDSL.process(arguments.definition); break; 
				} 
				// CacheBox Context DSL
				case "cacheBox"			 : { refLocal.dependency = instance.cacheBoxDSL.process(arguments.definition); break;}
				// WireBox Internal DSL for models and id
				case "model" : case "id" : { refLocal.dependency = getModelDSL(arguments.definition); break; }
				// logbox injection DSL always available
				case "logbox"			 : { refLocal.dependency = getLogBoxDSL(arguments.definition); break;}
				// provider injection DSL always available
				case "provider"			 : { refLocal.dependency = getProviderDSL(arguments.definition); break; }
				// wirebox injection DSL always available
				case "wirebox"			 : { refLocal.dependency = getWireBoxDSL(arguments.definition); break;}
				
				// No internal DSL's found, then check custom DSL's
				default : {
					// Check if Custom DSL exists, if it does, execute it
					if( structKeyExists(instance.customDSL, DSLNamespace) ){
						refLocal.dependency = instance.customDSL[ DSLNamespace ].process( arguments.definition );
					}
				}
			}
				
			// return only if found, else returns null
			if( structKeyExists(refLocal,"dependency") ){ return refLocal.dependency; }
			
			// Some warning data
			if( instance.log.canWarn() ){
				instance.log.warn("The DSL dependency definition: #arguments.definition.toString()# did not produce any resulting dependency");
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- DSL BUILDER METHODS ------------------------------------------>

	<!--- getWireBoxDSL --->
	<cffunction name="getWireBoxDSL" access="private" returntype="any" hint="Get dependencies using the wirebox dependency DSL" output="false" >
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfscript>
			var thisType 			= arguments.definition.dsl;
			var thisTypeLen 		= listLen(thisType,":");
			var thisLocationType 	= "";
			var thisLocationKey 	= "";
			
			// DSL stages
			switch(thisTypeLen){
				// WireBox injector
				case 1 : { return instance.injector; }
				// Level 2 DSL
				case 2 : {
					thisLocationKey = getToken(thisType,2,":");
					switch( thisLocationKey ){
						case "parent" 		: { return instance.injector.getParent(); }
						case "eventManager" : { return instance.injector.getEventManager(); }
						case "binder" 		: { return instance.injector.getBinder(); }
						case "populator" 	: { return instance.injector.getObjectPopulator(); }
					}
					break;
				}
				// Scopes
				case 3 : {
					thisLocationType 	= getToken(thisType,2,":");
					thisLocationKey 	= getToken(thisType,3,":");
					// DSL Level 2 Stage Types
					switch(thisLocationType){
						// Scope DSL
						case "scope" : { return instance.injector.getScope(thisLocationKey); break; }
					}
					break;
				} // end level 3 main DSL
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

	<!--- getProviderDSL --->
	<cffunction name="getProviderDSL" access="private" returntype="any" hint="Get dependencies using the our provider pattern DSL" output="false" >
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
				return createObject("component","coldbox.system.ioc.Provider").init(instance.injector.getScopeRegistration(), instance.injector.getScopeStorage(), providerName);
			}
			else if( instance.log.canDebug() ){
				instance.log.debug("getProviderDSL() cannot find model object #providerName# using definition #arguments.definition.toString()#");
			}
		</cfscript>
	</cffunction>
		
</cfcomponent>