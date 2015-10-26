<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
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
			// Build LogBox DSL Namespace
			instance.logBoxDSL = createObject("component","coldbox.system.ioc.dsl.LogBoxDSL").init( arguments.injector );

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
    		var customDSL = instance.injector.getBinder().getCustomDSL();

    		// Register Custom DSL Builders
			for( var key in customDSL ){
				registerDSL( namespace=key, path=customDSL[ key ] );
			}
		</cfscript>
    </cffunction>

    <!--- registerDSL --->
    <cffunction name="registerDSL" output="false" access="public" returntype="any" hint="A direct way of registering custom DSL namespaces">
    	<cfargument name="namespace" 	required="true" hint="The namespace you would like to register"/>
		<cfargument name="path" 		required="true" hint="The instantiation path to the CFC that implements this scope, it must have an init() method and implement: coldbox.system.ioc.dsl.IDSLBuilder"/>
		<cfscript>
			// register dsl
			instance.customDSL[ arguments.namespace ] = createObject( "component", arguments.path ).init( instance.injector );
			// Debugging
			if( instance.log.canDebug() ){
				instance.log.debug("Registered custom DSL Builder with namespace: #arguments.namespace#");
			}
		</cfscript>
    </cffunction>

	<!--- buildProviderMixer --->
    <cffunction name="buildProviderMixer" output="false" access="public" returntype="any" hint="Used to provider providers via mixers on targeted objects">
    	<cfscript>
			var targetInjector = this.$wbScopeStorage.get(this.$wbScopeInfo.key, this.$wbScopeInfo.scope);
			var targetProvider = this.$wbProviders[ getFunctionCalledName() ];

			// Verify if this is a mapping first?
			if( targetInjector.containsInstance( targetProvider ) ){
				return targetInjector.getInstance(name=targetProvider, targetObject=this);
			}

			// else treat as full DSL
			return targetInjector.getInstance(dsl=targetProvider, targetObject=this);
		</cfscript>
    </cffunction>

	<!--- buildCFC --->
    <cffunction name="buildCFC" output="false" access="public" returntype="any" hint="Build a cfc class via mappings">
    	<cfargument name="mapping" 			required="true" 	hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfargument name="initArguments" 	required="false"	default="#structnew()#" 	hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfscript>
			var thisMap 		= arguments.mapping;
			var oModel 			= createObject("component", thisMap.getPath() );
			var constructorArgs = "";
			var viMapping		= "";

			// Do we have virtual inheritance?
			if( arguments.mapping.isVirtualInheritance() ){
				// retrieve the VI mapping.
				viMapping = instance.injector.getBinder().getMapping( arguments.mapping.getVirtualInheritance() );
				// Does it match the family already?
				if( NOT isInstanceOf(oModel, viMapping.getPath() ) ){
					toVirtualInheritance( viMapping, oModel );
				}
			}
		</cfscript>

		<!--- Constructor initialization? --->
		<cfif thisMap.isAutoInit()  AND structKeyExists(oModel,thisMap.getConstructor())>
			<!--- Get Arguments --->
			<cfset constructorArgs = buildArgumentCollection(thisMap, thisMap.getDIConstructorArguments(), oModel )>

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
				throw(message="The factory mapping: #factoryName# is not registered with the injector",type="Builder.InvalidFactoryMappingException");
			}
    		// get Factory mapping
			oFactory = instance.injector.getInstance( factoryName );
			// Get Method Arguments
			methodArgs = buildArgumentCollection(thisMap, thisMap.getDIMethodArguments(), oFactory);
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
    	<cfargument name="mapping" 			required="true"  hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfargument name="argumentArray" 	required="true"  hint="The argument array of data"/>
    	<cfargument name="targetObject" 	required="true"  hint="The target object we are building the DSL dependency for"/>
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
					args[ DIArgs[x].name ] = buildDSLDependency( definition=DIArgs[x], targetID=thisMap.getName(), targetObject=arguments.targetObject );
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
					instance.log.error("Target: #thisMap.getName()# -> Argument reference not located: #DIArgs[x].name# for mapping: #arguments.mapping.getMemento().toString()#", DIArgs[x]);
					// not found but required, then throw exception
					throw(message="Argument reference not located: #DIArgs[x].name#",
									  		 detail="Injecting: #thisMap.getMemento().toString()#. The argument details are: #DIArgs[x].toString()#.",
									  		 type="Injector.ArgumentNotFoundException");
				}
				// else just log it via debug
				else if( instance.log.canDebug() ){
					instance.log.debug("Target: #thisMap.getName()# -> Argument reference not located: #DIArgs[x].name# for mapping: #arguments.mapping.getMemento().toString()#", DIArgs[x]);
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
		<cfargument name="dsl" 			required="true" 	hint="The dsl string to build">
		<cfargument name="targetID" 	required="true" 	hint="The target ID we are building this dependency for"/>
		<cfargument name="targetObject" required="false"	default="" 	hint="The target object we are building the DSL dependency for"/>
		<cfscript>
			var definition = {
				required=true,
				name = "",
				dsl = arguments.dsl
			};
			return buildDSLDependency( definition=definition, targetID=arguments.targetID, targetObject=arguments.targetObject );
		</cfscript>
	</cffunction>

	<!--- buildDSLDependency --->
	<cffunction name="buildDSLDependency" output="false" access="public" returntype="any" hint="Build a DSL Dependency, if not found, returns null">
		<cfargument name="definition" 	required="true"  hint="The dependency definition structure: name, dsl as keys">
		<cfargument name="targetID" 	required="true"  hint="The target ID we are building this dependency for"/>
		<cfargument name="targetObject" required="false" default="" hint="The target object we are building the DSL dependency for. If empty, means we are just requesting building"/>
		<cfscript>
			var refLocal 			= {};
			var DSLNamespace 		= listFirst(arguments.definition.dsl,":");

			// Check if Custom DSL exists, if it does, execute it
			if( structKeyExists( instance.customDSL, DSLNamespace ) ){
				return instance.customDSL[ DSLNamespace ].process(argumentCollection=arguments);
			}

			// Determine Type of Injection according to type
			// Some namespaces requires the ColdBox context, if not found, an exception is thrown.
			switch( DSLNamespace ){
				// ColdBox Context DSL
				case "ocm" : case "coldbox" : {
					refLocal.dependency = instance.coldboxDSL.process(argumentCollection=arguments); break;
				}
				// CacheBox Context DSL
				case "cacheBox"			 : {
					// check if linked
					if( !instance.injector.isCacheBoxLinked() AND !instance.injector.isColdBoxLinked() ){
						throw(message="The DSLNamespace: #DSLNamespace# cannot be used as it requires a ColdBox/CacheBox Context",type="Builder.IllegalDSLException");
					}
					// retrieve it
					refLocal.dependency = instance.cacheBoxDSL.process(argumentCollection=arguments); break;
				}
				// logbox injection DSL always available
				case "logbox"			 : { refLocal.dependency = instance.logBoxDSL.process(argumentCollection=arguments); break;}
				// WireBox Internal DSL for models and id
				case "model" : case "id" : { refLocal.dependency = getModelDSL(argumentCollection=arguments); break; }
				// provider injection DSL always available
				case "provider"			 : { refLocal.dependency = getProviderDSL(argumentCollection=arguments); break; }
				// wirebox injection DSL always available
				case "wirebox"			 : { refLocal.dependency = getWireBoxDSL(argumentCollection=arguments); break;}
				// java class
				case "java"				 : { refLocal.dependency = getJavaDSL(argumentCollection=arguments); break; }
				// coldfusion type annotation
				case "bytype"			 : { refLocal.dependency = getByTypeDSL(argumentCollection=arguments); break; }

				// No internal DSL's found, then check custom DSL's
				default : {

					// If no DSL's found, let's try to use the name as the empty namespace
					if( NOT find( ":", arguments.definition.dsl ) ){
						arguments.definition.dsl = "id:#arguments.definition.dsl#";
						refLocal.dependency = getModelDSL(argumentCollection=arguments);
					}
				}
			}

			// return only if found
			if( structKeyExists( refLocal, "dependency" ) ){ return refLocal.dependency; }

			// was dependency required? If so, then throw exception
			if( arguments.definition.required ){
				// Logging
				if( instance.log.canError() ){
					instance.log.error("Target: #arguments.targetID# -> DSL Definition: #arguments.definition.toString()# did not produce any resulting dependency");
				}

				// Throw exception as DSL Dependency requested was not located
				throw(message="The DSL Definition #arguments.definition.toString()# did not produce any resulting dependency",
										 detail="The target requesting the dependency is: '#arguments.targetID#'",
										 type="Builder.DSLDependencyNotFoundException");
			}
			// else return void, no dependency found that was required
		</cfscript>
	</cffunction>

<!------------------------------------------- DSL BUILDER METHODS ------------------------------------------>

	<!--- getJavaDSL --->
	<cffunction name="getJavaDSL" access="private" returntype="any" hint="Get a Java object" output="false" >
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfargument name="targetObject" required="false" hint="The target object we are building the DSL dependency for. If empty, means we are just requesting building"/>
		<cfscript>
			var javaClass  = getToken( arguments.definition.dsl, 2, ":" );

			return createObject("java", javaClass);
		</cfscript>
	</cffunction>

	<!--- getWireBoxDSL --->
	<cffunction name="getWireBoxDSL" access="private" returntype="any" hint="Get dependencies using the wirebox dependency DSL" output="false" >
		<cfargument name="definition" 	required="true"  hint="The dependency definition structure">
		<cfargument name="targetObject" required="false" hint="The target object we are building the DSL dependency for. If empty, means we are just requesting building"/>

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
						case "properties" 	: { return instance.injector.getBinder().getProperties(); }
					}
					break;
				}
				// Level 3 DSL
				case 3 : {
					thisLocationType 	= getToken(thisType,2,":");
					thisLocationKey 	= getToken(thisType,3,":");
					// DSL Level 2 Stage Types
					switch(thisLocationType){
						// Scope DSL
						case "scope" 	: { return instance.injector.getScope( thisLocationKey ); break; }
						case "property" : { return instance.injector.getBinder().getProperty( thisLocationKey );break; }
					}
					break;
				} // end level 3 main DSL
			}
		</cfscript>
	</cffunction>

	<!--- getModelDSL --->
	<cffunction name="getModelDSL" access="private" returntype="any" hint="Get dependencies using the model dependency DSL" output="false" >
		<cfargument name="definition" 	required="true"  hint="The dependency definition structure">
		<cfargument name="targetObject" required="false" hint="The target object we are building the DSL dependency for. If empty, means we are just requesting building"/>
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

	<!--- getProviderDSL --->
	<cffunction name="getProviderDSL" access="private" returntype="any" hint="Get dependencies using the our provider pattern DSL" output="false" >
		<cfargument name="definition" 	required="true"  hint="The dependency definition structure">
		<cfargument name="targetObject" required="false" default="" hint="The target object we are building the DSL dependency for. If empty, means we are just requesting building"/>
		<cfscript>
			var thisType 		= arguments.definition.dsl;
			var thisTypeLen 	= listLen(thisType,":");
			var providerName 	= "";
			var args			= {};

			// DSL stages
			switch( thisTypeLen ){
				// provider default, get name of the provider from property
				case 1: { providerName = arguments.definition.name; break; }
				// provider:{name} stage
				case 2: { providerName = getToken(thisType,2,":"); break; }
				// multiple stages then most likely it is a full DSL being used
				default : {
					providerName = replaceNoCase( thisType, "provider:", "" );
				}
			}

			// Build provider arguments
			args = {
				scopeRegistration = instance.injector.getScopeRegistration(),
				scopeStorage = instance.injector.getScopeStorage(),
				targetObject = arguments.targetObject
			};

			// Check if the passed in provider is an ID directly
			if( instance.injector.containsInstance( providerName ) ){
				args.name = providerName;
			}
			// Else try to tag it by FULL DSL
			else{
				args.dsl = providerName;
			}

			// Build provider and return it.
			return createObject("component","coldbox.system.ioc.Provider").init( argumentCollection=args );
		</cfscript>
	</cffunction>

	<!--- getByTypeDSL --->
	<cffunction name="getByTypeDSL" access="private" returntype="any" hint="Get dependencies using the mapped type" output="false" >
		<cfargument name="definition" 	required="true"  hint="The dependency definition structure">
		<cfargument name="targetObject" required="false" hint="The target object we are building the DSL dependency for. If empty, means we are just requesting building"/>
		<cfscript>
			var injectType 	=  arguments.definition.type;

			if( instance.injector.containsInstance( injectType ) ){
				return instance.injector.getInstance( injectType );
			}
		</cfscript>
	</cffunction>

	<!--- toVirtualInheritance --->
    <cffunction name="toVirtualInheritance" output="false" access="public" returntype="void" hint="Do our virtual inheritance magic">
    	<cfargument name="mapping" 	required="true" hint="The mapping to convert to"/>
		<cfargument name="target" 	required="true" hint="The target object"/>
		<cfscript>
			var baseObject 		= "";
			var familyPath 		= "";
			var constructorArgs = "";
			var excludedProperties = "$super,$wbaopmixed,$mixed,$WBAOPTARGETMAPPING,$WBAOPTARGETS";

			// Mix it up baby
			instance.utility.getMixerUtil().start( arguments.target );

			// Create base family object
			baseObject = instance.injector.getInstance( arguments.mapping.getName() );

			// Check if init already exists in target and base?
			if( structKeyExists( arguments.target, "init" ) AND structKeyExists( baseObject,"init" ) ){
				arguments.target.$superInit = baseObject.init;
			}

			// Mix in methods
			for( var key in baseObject ){
				// If target has overriden method, then don't override it with mixin, simulated inheritance
				if( NOT structKeyExists( arguments.target, key ) AND NOT listFindNoCase( excludedProperties, key ) ){
					arguments.target.injectMixin( key, baseObject[ key ] );
				}
			}
			// Mix in virtual super class
			arguments.target.$super = baseObject;
			// Verify if we need to init the virtualized object
			if( structKeyExists( arguments.target, "$superInit" ) ){
				// get super constructor arguments.
				constructorArgs = buildArgumentCollection( arguments.mapping, arguments.mapping.getDIConstructorArguments(), baseObject );
				// Init the virtualized inheritance
				arguments.target.$superInit( argumentCollection=constructorArgs );
			}
		</cfscript>
    </cffunction>

</cfcomponent>
