/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* The WireBox builder for components, java, etc. I am in charge of building stuff and integration dsl builders.
**/
component output="false" serializable="false" accessors="true"{

	/**
	 * Constructor. If called without a configuration binder, then WireBox will instantiate the default configuration binder found coldbox.system.ioc.config.DefaultBinder
	 *
	 * @injector The linked WireBox injector
	 * @injector.doc_generic coldbox.system.ioc.Injector
	 *
	 * @return coldbox.system.ioc.Builder
	 */
	function init(required injector){
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
	}


	/**
	 * Get the registered custom dsl instances structure
	 *
	 * @doc_generic struct
	 */
    function getCustomDSL() {
    	return instance.customDSL;
    }

	/**
	 * Register custom DSL builders with this main wirebox builder
	 *
	 */
    function registerCustomBuilders() {
		var customDSL = instance.injector.getBinder().getCustomDSL();

		// Register Custom DSL Builders
		for( var key in customDSL ){
			registerDSL( namespace=key, path=customDSL[ key ] );
		}
	}

	/**
	 * A direct way of registering custom DSL namespaces
	 *
	 * @namespace The namespace you would like to register
	 * @path The instantiation path to the CFC that implements this scope, it must have an init() method and implement: coldbox.system.ioc.dsl.IDSLBuilder
	 */
    function registerDSL(required namespace, required path) {
		// register dsl
		instance.customDSL[ arguments.namespace ] = createObject( "component", arguments.path ).init( instance.injector );
		// Debugging
		if( instance.log.canDebug() ){
			instance.log.debug("Registered custom DSL Builder with namespace: #arguments.namespace#");
		}
	}

	/**
	 * Used to provider providers via mixers on targeted objects
	 */
	function buildProviderMixer() {
		var targetInjector = this.$wbScopeStorage.get(this.$wbScopeInfo.key, this.$wbScopeInfo.scope);
		var targetProvider = this.$wbProviders[ getFunctionCalledName() ];

		// Verify if this is a mapping first?
		if( targetInjector.containsInstance( targetProvider ) ){
			return targetInjector.getInstance(name=targetProvider, targetObject=this);
		}

		// else treat as full DSL
		return targetInjector.getInstance(dsl=targetProvider, targetObject=this);
	}

	/**
	 * Build a cfc class via mappings
	 *
	 * @mapping The mapping to construct
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @initArguments.doc_generic struct
	 */
	function buildCFC(required mapping, initArguments = structNew()) {
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

		<!--- Constructor initialization? --->
		if(thisMap.isAutoInit()  AND structKeyExists(oModel,thisMap.getConstructor())) {
			<!--- Get Arguments --->
			constructorArgs = buildArgumentCollection(thisMap, thisMap.getDIConstructorArguments(), oModel );

			<!--- Do We have initArguments to override --->
			if(NOT structIsEmpty(arguments.initArguments)) {
				structAppend(constructorArgs,arguments.initArguments,true);
			}

			try {
				<!--- Invoke constructor --->
				invoke("#oModel#", "#thisMap.getConstructor()#", "#constructorArgs#");
			} catch(e) {
				throw( 
					type="Builder.BuildCFCDependencyException",
					message="Error building: #thisMap.getName()# -> #cfcatch.message#.",
					detail="DSL: #thisMap.getDSL()#, Path: #thisMap.getPath()#, Error Location: #cfcatch.tagContext[ 1 ].template#:#cfcatch.tagContext[ 1 ].line#"
				);
			}
		}

		return oModel;
    }

	/**
	 * Build an object using a factory method
	 *
	 * @mapping The mapping to construct
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @initArguments.doc_generic struct
	 */
	function buildFactoryMethod(required mapping, initArguments=structNew()) {
		var thisMap 	= arguments.mapping;
		var oFactory 	= "";
		var oModel		= "";
		var factoryName = thisMap.getPath();
		var methodArgs  = "";

		// check if factory exists, else throw exception
		if( NOT instance.injector.containsInstance( factoryName ) ){
			throw( 
				message="The factory mapping: #factoryName# is not registered with the injector", 
				type="Builder.InvalidFactoryMappingException" 
			);
		}
		// get Factory mapping
		oFactory = instance.injector.getInstance( factoryName );
		// Get Method Arguments
		methodArgs = buildArgumentCollection(thisMap, thisMap.getDIMethodArguments(), oFactory);
		// Do we have overrides
		if( NOT structIsEmpty(arguments.initArguments) ){
			structAppend(methodArgs,arguments.initArguments,true);
		}

		<!--- Get From Factory --->
		oModel = invoke("#oFactory#", "#thisMap.getMethod()#", "#methodArgs#");

		<!--- Return factory bean --->
		return oModel;
   	}

	/**
	 * Build a Java class via mappings
	 *
	 * @mapping The mapping to construct
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 */
	function buildJavaClass(required mapping) {
		var x 			= 1;
		var DIArgs 		= arguments.mapping.getDIConstructorArguments();
		var DIArgsLen 	= arrayLen(DIArgs);
		var args		= [];
		var thisMap 	= arguments.mapping;

		// Loop Over Arguments
		for(x = 1; x <= DIArgsLen; x++){
			var thisDIArg = DIArgs[ x ];
			// do we have javacasting?
			if( !isNull( thisDIArg.javaCast ) ){
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
	}

	/**
	 * Build arguments for a mapping and return the structure representation
	 *
	 * @mapping The mapping to construct
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 * @argumentArray The argument array of data
	 * @targetObject The target object we are building the DSL dependency for
	 */
	 function buildArgumentCollection(required mapping, required argumentArray, required targetObject) {
		var x 			= 1;
		var thisMap 	= arguments.mapping;
		var DIArgs 		= arguments.argumentArray;
		var DIArgsLen 	= arrayLen(DIArgs);
		var args		= structnew();

		// Loop Over Arguments
		for(x=1;x lte DIArgsLen; x=x+1){
			var thisDIArg = DIArgs[ x ];
			// Is value set in mapping? If so, add it and continue
			if( !isNull( thisDIArg.value ) ){
				args[ thisDIArg.name ] = thisDIArg.value;
				continue;
			}

			// Is it by DSL construction? If so, add it and continue, if not found it returns null, which is ok
			if( !isNull( thisDIArg.dsl ) ){
				args[ thisDIArg.name ] = buildDSLDependency( definition=thisDIArg, targetID=thisMap.getName(), targetObject=arguments.targetObject );
				continue;
			}

			// If we get here then it is by ref id, so let's verify it exists and optional
			if( len(instance.injector.containsInstance( thisDIArg.ref )) ){
				args[ thisDIArg.name ] = instance.injector.getInstance(name=thisDIArg.ref);
				continue;
			}

			// Not found, so check if it is required
			if( thisDIArg.required ){
				// Log the error
				instance.log.error("Target: #thisMap.getName()# -> Argument reference not located: #DIArgs[ x ].name# for mapping: #arguments.mapping.getMemento().toString()#", thisDIArg);
				// not found but required, then throw exception
				throw(message="Argument reference not located: #thisDIArg.name#",
								  		 detail="Injecting: #thisMap.getMemento().toString()#. The argument details are: #thisDIArg.toString()#.",
								  		 type="Injector.ArgumentNotFoundException");
			}
			// else just log it via debug
			else if( instance.log.canDebug() ){
				instance.log.debug("Target: #thisMap.getName()# -> Argument reference not located: #thisDIArg.name# for mapping: #arguments.mapping.getMemento().toString()#", thisDIArg);
			}

		}

		return args;
    }

    /**
	 * Build a webservice object
	 *
	 * @mapping The mapping to construct
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @initArguments.doc_generic struct
	 */
	function buildWebservice(required mapping, initArguments = StructNew()) {
		var argStruct 	= {};
		var DIArgs 		= arguments.mapping.getDIConstructorArguments();
		var DIArgsLen   = arraylen( DIArgs );

		// Loop Over Arguments for wsdl args
		for(var x=1; x lte DIArgsLen; x++ ){
			argStruct[ DIArgs[ x ].name ] = DIArgs[ x ].value;
		}

		// Do we ahve overrides
		if( NOT structIsEmpty(arguments.initArguments) ){
			structAppend(argStruct, arguments.initArguments,true);
		}

		return createObject( "webservice", arguments.mapping.getPath(), argStruct );
	}

	/**
	 * Build an rss feed the WireBox way
	 *
	 * @mapping The mapping to construct
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 */
	function buildFeed(required mapping) {
    	var results = {};

    	feed action="read" source="#arguments.mapping.getPath()#" query="results.items" properties="results.metadata" timeout="20";

		return results;
    }

<!------------------------------------------- Internal DSL Builders ------------------------------------------>

	/**
	 * Build a DSL Dependency using a simple dsl string
	 *
	 * @dsl The dsl string to build
	 * @targetID The target ID we are building this dependency for
	 * @targetObject The target object we are building the DSL dependency for
	 */
	function buildSimpleDSL(required dsl, required targetID, required targetObject = "") {
		var definition = {
			required = true,
			name     = "",
			dsl      = arguments.dsl
		};
		return buildDSLDependency( 
			definition   = definition, 
			targetID     = arguments.targetID, 
			targetObject = arguments.targetObject 
		);
	}

	/**
	 * Build a DSL Dependency, if not found, returns null
	 *
	 * @definition The dependency definition structure: name, dsl as keys
	 * @targetID The target ID we are building this dependency for
	 * @targetObject The target object we are building the DSL dependency for
	 */
	function buildDSLDependency(required definition, required targetID, targetObject = "") {
		var refLocal 			= {};
		var DSLNamespace 		= listFirst( arguments.definition.dsl, ":" );

		// Check if Custom DSL exists, if it does, execute it
		if( structKeyExists( instance.customDSL, DSLNamespace ) ){
			return instance.customDSL[ DSLNamespace ].process( argumentCollection=arguments );
		}

		// Determine Type of Injection according to type
		// Some namespaces requires the ColdBox context, if not found, an exception is thrown.
		switch( DSLNamespace ){
			
			// ColdBox Context DSL
			case "coldbox" : {
				refLocal.dependency = instance.coldboxDSL.process( argumentCollection=arguments ); 
				break;
			}

			// CacheBox Context DSL
			case "cacheBox"			 : {
				// check if linked
				if( !instance.injector.isCacheBoxLinked() AND !instance.injector.isColdBoxLinked() ){
					throw(
						message	= "The DSLNamespace: #DSLNamespace# cannot be used as it requires a ColdBox/CacheBox Context",
						type	= "Builder.IllegalDSLException"
					);
				}
				// retrieve it
				refLocal.dependency = instance.cacheBoxDSL.process( argumentCollection=arguments ); 
				break;
			}

			// logbox injection DSL always available
			case "logbox"			 : { 
				refLocal.dependency = instance.logBoxDSL.process( argumentCollection=arguments ); 
				break;
			}

			// WireBox Internal DSL for models and id
			case "model" : case "id" : { 
				refLocal.dependency = getModelDSL( argumentCollection=arguments ); 
				break; 
			}

			// provider injection DSL always available
			case "provider"			 : { 
				refLocal.dependency = getProviderDSL( argumentCollection=arguments ); 
				break; 
			}

			// wirebox injection DSL always available
			case "wirebox"			 : { 
				refLocal.dependency = getWireBoxDSL( argumentCollection=arguments ); 
				break;
			}

			// java class
			case "java"				 : { 
				refLocal.dependency = getJavaDSL( argumentCollection=arguments ); 
				break; 
			}

			// coldfusion type annotation
			case "bytype"			 : { 
				refLocal.dependency = getByTypeDSL( argumentCollection=arguments ); 
				break; 
			}

			// If no DSL's found, let's try to use the name as the empty namespace
			default : {
				refLocal.dependency = getModelDSL( argumentCollection=arguments );
			}
		}

		// return only if found
		if( structKeyExists( refLocal, "dependency" ) ){ 
			return refLocal.dependency; 
		}

		// was dependency required? If so, then throw exception
		if( arguments.definition.required ){
			// Logging
			if( instance.log.canError() ){
				instance.log.error( "Target: #arguments.targetID# -> DSL Definition: #arguments.definition.toString()# did not produce any resulting dependency" );
			}

			// Throw exception as DSL Dependency requested was not located
			throw(
				message = "The DSL Definition #arguments.definition.toString()# did not produce any resulting dependency",
				detail  = "The target requesting the dependency is: '#arguments.targetID#'",
				type    = "Builder.DSLDependencyNotFoundException"
			);
		}
		// else return void, no dependency found that was required
	}

<!------------------------------------------- DSL BUILDER METHODS ------------------------------------------>

	/**
	 * Get a Java object
	 *
	 * @definition The dependency definition structure: name, dsl as keys
	 * @targetObject The target object we are building the DSL dependency for
	 */
	private any function getJavaDSL(required definition, targetObject) {
		var javaClass  = getToken( arguments.definition.dsl, 2, ":" );

		return createObject("java", javaClass);
	}

	/**
	 * Get dependencies using the wirebox dependency DSL
	 *
	 * @definition The dependency definition structure: name, dsl as keys
	 * @targetObject The target object we are building the DSL dependency for
	 */
	private any function getWireBoxDSL(required definition, targetObject) {
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
	}

	/**
	 * Get dependencies using the model dependency DSL
	 *
	 * @definition The dependency definition structure: name, dsl as keys
	 * @targetObject The target object we are building the DSL dependency for
	 */
	private any function getModelDSL(required definition, targetObject) {
		var thisType 		= arguments.definition.dsl;
		var thisTypeLen 	= listLen( thisType, ":" );
		var methodCall 		= "";
		var modelName 		= "";
		
		// DSL stages
		switch( thisTypeLen ){
			// No injection defined, use property name: property name='luis' inject;
			case 0 : {
				modelName = arguments.definition.name;
				break; 
			}
			// Injected defined, can be different scenarios
			// property name='luis' inject="id"; use property name
			// property name='luis' inject="model"; use property name
			// property name='luis' inject="alias";
			case 1 : {
				// Are we the key identifiers
				if( listFindNoCase( "id,model", arguments.definition.dsl ) ){
					modelName = arguments.definition.name;
				} 
				// else we are a real ID
				else {
					modelName = arguments.definition.dsl;
				}
				
				break; 
			}
			// model:{alias} stage
			case 2 : { 
				modelName = getToken( thisType, 2, ":" );
				break;
			}
			// model:{alias}:{method} stage
			case 3 : {
				modelName 	= getToken( thisType, 2, ":" );
				methodCall 	= getToken( thisType, 3, ":" );
				break;
			}
		}
		
		// Check if model Exists
		if( instance.injector.containsInstance( modelName ) ){
			// Get Model object
			var oModel = instance.injector.getInstance( modelName );
			// Factories: TODO: Add arguments with 'ref()' parsing for argument references or 'dsl()'
			if( len( methodCall ) ){
				return evaluate( "oModel.#methodCall#()" );
			}
			return oModel;
		} else if ( instance.log.canDebug() ){
			instance.log.debug( "getModelDSL() cannot find model object #modelName# using definition #arguments.definition.toString()#" );
		}
	}

	/**
	 * Get dependencies using the our provider pattern DSL
	 *
	 * @definition The dependency definition structure
	 * @targetObject The target object we are building the DSL dependency for. If empty, means we are just requesting building
	 */
	private any function getProviderDSL(required definition, targetObject="") {
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
	}

	/**
	 * Get dependencies using the mapped type
	 *
	 * @definition The dependency definition structure
	 * @targetObject The target object we are building the DSL dependency for. If empty, means we are just requesting building
	 */
	private any function getByTypeDSL(required definition, targetObject) {
		var injectType 	=  arguments.definition.type;

		if( instance.injector.containsInstance( injectType ) ){
			return instance.injector.getInstance( injectType );
		}
	}

	/**
	 * Do our virtual inheritance magic
	 *
	 * @mapping The mapping to convert to
	 * @target The target object
	 */
	function toVirtualInheritance(required mapping, required target) {
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
	}

}