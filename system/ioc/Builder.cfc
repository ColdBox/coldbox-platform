/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * The WireBox builder for components, java, etc. I am in charge of building stuff and integration dsl builders.
 **/
component serializable="false" accessors="true" {

	/**
	 * Injector Reference
	 */
	property name="injector";

	/**
	 * LogBox reference
	 */
	property name="logBox";

	/**
	 * Logging utility object
	 */
	property name="log";

	/**
	 * ColdBox Utility
	 */
	property name="utility";

	/**
	 * Custom DSL Map Storage
	 */
	property name="customDSL" type="struct";

	/**
	 * ColdBox DSL Utility
	 */
	property name="coldboxDSL";

	/**
	 * CacheBox DSL Utility
	 */
	property name="cacheBoxDSL";

	/**
	 * LogBox DSL Utility
	 */
	property name="logBoxDSL";

	/**
	 * Constructor. If called without a configuration binder, then WireBox will instantiate the default configuration binder found coldbox.system.ioc.config.DefaultBinder
	 *
	 * @injector The linked WireBox injector
	 * @injector.doc_generic coldbox.system.ioc.Injector
	 *
	 * @return coldbox.system.ioc.Builder
	 */
	Builder function init( required injector ){
		variables.injector  = arguments.injector;
		variables.logBox    = arguments.injector.getLogBox();
		variables.log       = arguments.injector.getLogBox().getlogger( this );
		variables.utility   = arguments.injector.getUtil();
		variables.customDSL = {};

		// Internal DSL Registry
		variables.internalDSL = [
			"coldbox",
			"box",
			"executor",
			"cachebox",
			"logbox",
			"model",
			"id",
			"provider",
			"wirebox",
			"java",
			"byType"
		];

		// Do we need to build the coldbox DSL namespace
		if ( variables.injector.isColdBoxLinked() ) {
			variables.coldboxDSL = new coldbox.system.ioc.dsl.ColdBoxDSL( arguments.injector );
		}

		// Is CacheBox Linked?
		if ( variables.injector.isCacheBoxLinked() ) {
			variables.cacheBoxDSL = new coldbox.system.ioc.dsl.CacheBoxDSL( arguments.injector );
		}

		// Build LogBox DSL Namespace
		variables.logBoxDSL = new coldbox.system.ioc.dsl.LogBoxDSL( arguments.injector );

		return this;
	}

	/**
	 * Register custom DSL builders with this main wirebox builder
	 *
	 */
	Builder function registerCustomBuilders(){
		var customDSL = variables.injector.getBinder().getCustomDSL();

		// Register Custom DSL Builders
		for ( var key in customDSL ) {
			registerDSL( namespace = key, path = customDSL[ key ] );
		}
		return this;
	}

	/**
	 * A direct way of registering custom DSL namespaces
	 *
	 * @namespace The namespace you would like to register
	 * @path The instantiation path to the CFC that implements this scope, it must have an init() method and implement: coldbox.system.ioc.dsl.IDSLBuilder
	 */
	Builder function registerDSL( required namespace, required path ){
		// register dsl
		variables.customDSL[ arguments.namespace ] = new "#arguments.path#"( variables.injector );
		// Debugging
		if ( variables.log.canDebug() ) {
			variables.log.debug( "Registered custom DSL Builder with namespace: #arguments.namespace#" );
		}
		return this;
	}

	/**
	 * Used to provider providers via mixers on targeted objects
	 */
	function buildProviderMixer(){
		var targetInjector = this.$wbScopeStorage.get( this.$wbScopeInfo.key, this.$wbScopeInfo.scope );
		var targetProvider = this.$wbProviders[ getFunctionCalledName() ];

		// Verify if this is a mapping first?
		if ( targetInjector.containsInstance( targetProvider ) ) {
			return targetInjector.getInstance( name = targetProvider, targetObject = this );
		}

		// else treat as full DSL
		return targetInjector.getInstance( dsl = targetProvider, targetObject = this );
	}

	/**
	 * Build a cfc class via mappings
	 *
	 * @mapping The mapping to construct
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @initArguments.doc_generic struct
	 */
	function buildCFC( required mapping, initArguments = structNew() ){
		var thisMap = arguments.mapping;
		var oModel  = createObject( "component", thisMap.getPath() );

		// Do we have virtual inheritance?
		var constructorArgs     = thisMap.getDIConstructorArguments();
		var constructorArgNames = constructorArgs.map( function( arg ){
			return arg.name;
		} );
		if ( thisMap.isVirtualInheritance() ) {
			// retrieve the VI mapping.
			var viMapping = variables.injector.getBinder().getMapping( thisMap.getVirtualInheritance() );
			// Does it match the family already?
			if ( NOT isInstanceOf( oModel, viMapping.getPath() ) ) {
				// Virtualize it.
				toVirtualInheritance( viMapping, oModel, thisMap );
				// Only add virtual inheritance constructor args if we don't already have one with that name.
				arrayAppend(
					constructorArgs,
					viMapping
						.getDIConstructorArguments()
						.filter( function( arg ){
							return !arrayContainsNoCase( constructorArgNames, arg.name );
						} ),
					true
				);
			}
		}

		// Constructor initialization?
		if ( thisMap.isAutoInit() AND structKeyExists( oModel, thisMap.getConstructor() ) ) {
			// Get Arguments
			var constructorArgCollection = buildArgumentCollection( thisMap, constructorArgs, oModel );

			// Do We have initArguments to override
			if ( NOT structIsEmpty( arguments.initArguments ) ) {
				structAppend(
					constructorArgCollection,
					arguments.initArguments,
					true
				);
			}

			try {
				// Invoke constructor
				invoke(
					oModel,
					thisMap.getConstructor(),
					constructorArgCollection
				);
			} catch ( any e ) {
				var reducedTagContext = e.tagContext
					.reduce( function( result, file ){
						if ( !result.done ) {
							if ( file.template.listLast( "/\" ) == "Builder.cfc" ) {
								result.done = true;
							} else {
								result.rows.append( "#file.template#:#file.line#" );
							}
						}
						return result;
					}, { rows : [], done : false } )
					.rows
					.toList( chr( 13 ) & chr( 10 ) );

				throw(
					type    = "Builder.BuildCFCDependencyException",
					message = "Error building: #thisMap.getName()# -> #e.message#
					#e.detail#.",
					detail = "DSL: #thisMap.getDSL()#, Path: #thisMap.getPath()#,
					Error Location:
					#reducedTagContext#"
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
	function buildFactoryMethod( required mapping, initArguments = structNew() ){
		var thisMap     = arguments.mapping;
		var factoryName = thisMap.getPath();

		// check if factory exists, else throw exception
		if ( NOT variables.injector.containsInstance( factoryName ) ) {
			throw(
				message = "The factory mapping: #factoryName# is not registered with the injector",
				type    = "Builder.InvalidFactoryMappingException"
			);
		}

		// get Factory mapping
		var oFactory   = variables.injector.getInstance( factoryName );
		// Get Method Arguments
		var methodArgs = buildArgumentCollection(
			thisMap,
			thisMap.getDIMethodArguments(),
			oFactory
		);
		// Do we have overrides
		if ( NOT structIsEmpty( arguments.initArguments ) ) {
			structAppend( methodArgs, arguments.initArguments, true );
		}

		// Get From Factory
		var oModel = invoke( oFactory, thisMap.getMethod(), methodArgs );

		// Return factory bean
		return oModel;
	}

	/**
	 * Build a Java class via mappings
	 *
	 * @mapping The mapping to construct
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 */
	function buildJavaClass( required mapping ){
		var DIArgs  = arguments.mapping.getDIConstructorArguments();
		var args    = [];
		var thisMap = arguments.mapping;

		// Process arguments to constructor call.
		for ( var thisArg in DIArgs ) {
			if ( !isNull( thisArg.javaCast ) ) {
				args.append( javacast( thisArg.javacast, thisArg.value ) );
			} else {
				args.append( thisArg.value );
			}
		}

		// init?
		if ( thisMap.isAutoInit() ) {
			if ( args.len() ) {
				return invoke(
					createObject( "java", arguments.mapping.getPath() ),
					"init",
					args
				);
			}
			return createObject( "java", arguments.mapping.getPath() ).init();
		}

		// return with no init
		return createObject( "java", arguments.mapping.getPath() );
	}

	/**
	 * Build arguments for a mapping and return the structure representation
	 *
	 * @mapping The mapping to construct
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 * @argumentArray The argument array of data
	 * @targetObject The target object we are building the DSL dependency for
	 */
	function buildArgumentCollection(
		required mapping,
		required argumentArray,
		required targetObject
	){
		var thisMap = arguments.mapping;
		var DIArgs  = arguments.argumentArray;
		var args    = {};

		// Process Arguments
		for ( var thisArg in DIArgs ) {
			// Process if we have a value and continue
			if ( !isNull( thisArg.value ) ) {
				args[ thisArg.name ] = thisArg.value;
				continue;
			}

			// Is it by DSL construction? If so, add it and continue, if not found it returns null, which is ok
			if ( !isNull( thisArg.dsl ) ) {
				args[ thisArg.name ] = buildDSLDependency(
					definition   = thisArg,
					targetID     = thisMap.getName(),
					targetObject = arguments.targetObject
				);
				continue;
			}

			// If we get here then it is by ref id, so let's verify it exists and optional
			if ( variables.injector.containsInstance( thisArg.ref ) ) {
				args[ thisArg.name ] = variables.injector.getInstance( name = thisArg.ref );
				continue;
			}

			// Not found, so check if it is required
			if ( thisArg.required ) {
				// Log the error
				variables.log.error(
					"Target: #thisMap.getName()# -> Argument reference not located: #thisArg.name#",
					thisArg
				);
				// not found but required, then throw exception
				throw(
					message = "Argument reference not located: #thisArg.name#",
					detail  = "Injecting: #thisMap.getName()#. The argument details are: #thisArg.toString()#.",
					type    = "Injector.ArgumentNotFoundException"
				);
			}
			// else just log it via debug
			else if ( variables.log.canDebug() ) {
				variables.log.debug(
					"Target: #thisMap.getName()# -> Argument reference not located: #thisArg.name#",
					thisArg
				);
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
	function buildWebservice( required mapping, initArguments = {} ){
		var argStruct = {};
		var DIArgs    = arguments.mapping.getDIConstructorArguments();

		// Process args
		for ( var thisArg in DIArgs ) {
			argStruct[ thisArg.name ] = thisArg.value;
		}

		// Do we have overrides
		if ( NOT structIsEmpty( arguments.initArguments ) ) {
			structAppend( argStruct, arguments.initArguments, true );
		}

		return createObject(
			"webservice",
			arguments.mapping.getPath(),
			argStruct
		);
	}

	/**
	 * Build an rss feed the WireBox way
	 *
	 * @mapping The mapping to construct
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 */
	function buildFeed( required mapping ){
		var results        = {};
		var feedAttributes = {
			action     : "read",
			source     : arguments.mapping.getPath(),
			query      : "results.items",
			properties : "results.metadata",
			timeout    : "20",
			userAgent  : "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36"
		};

		include "/coldbox/system/core/util/cffeed.cfm";

		return results;
	}

	// Internal DSL Builders

	/**
	 * Build a DSL Dependency using a simple dsl string
	 *
	 * @dsl The dsl string to build
	 * @targetID The target ID we are building this dependency for
	 * @targetObject The target object we are building the DSL dependency for
	 *
	 * @return The requested DSL object
	 */
	function buildSimpleDSL(
		required dsl,
		required targetID,
		required targetObject = ""
	){
		var definition = { required : true, name : "", dsl : arguments.dsl };
		return buildDSLDependency(
			definition   = definition,
			targetID     = arguments.targetID,
			targetObject = arguments.targetObject
		);
	}

	/**
	 * Verifies if the incoming string is a valid registered DSL namespace
	 *
	 * @target The string to verify if it's a registered namespace
	 */
	boolean function isDSLNamespace( required target ){
		return (
			variables.customDSL.keyExists( arguments.target )
			||
			arrayContainsNoCase( variables.internalDSL, arguments.target )
		);
	}

	/**
	 * Verifies if the incoming string is a valid registered DSL string
	 *
	 * @target The string to verify if it's a potential DSL
	 */
	boolean function isDSLString( required target ){
		return (
			isDSLNamespace( arguments.target )
			||
			find( ":", arguments.target )
		);
	}

	/**
	 * Build a DSL Dependency, if not found, returns null
	 *
	 * @definition The dependency definition structure: name, dsl as keys
	 * @targetID The target ID we are building this dependency for
	 * @targetObject The target object we are building the DSL dependency for
	 *
	 * @throws IllegalDSLException - When requesting a ColdBox/CacheBox DSL dependency and the library is not linked
	 * @throws DSLDependencyNotFoundException - If the requested object is not found and it is required
	 *
	 * @return The requested object or null if not found and not required
	 */
	function buildDSLDependency(
		required definition,
		required targetID,
		targetObject = ""
	){
		var refLocal     = {};
		var DSLNamespace = listFirst( arguments.definition.dsl, ":" );

		// Check if Custom DSL exists, if it does, execute it
		if ( structKeyExists( variables.customDSL, DSLNamespace ) ) {
			return variables.customDSL[ DSLNamespace ].process( argumentCollection = arguments );
		}

		// Determine Type of Injection according to type
		// Some namespaces requires the ColdBox context, if not found, an exception is thrown.
		switch ( DSLNamespace ) {
			// ColdBox Context DSL
			case "coldbox":
			case "box": {
				if ( !variables.injector.isColdBoxLinked() ) {
					throw(
						message = "The DSLNamespace: #DSLNamespace# cannot be used as it requires a ColdBox Context",
						type    = "Builder.IllegalDSLException"
					);
				}
				refLocal.dependency = variables.coldboxDSL.process( argumentCollection = arguments );
				break;
			}

			// Executor
			case "executor": {
				// retrieve it
				refLocal.dependency = getExecutorDSl( argumentCollection = arguments );
				break;
			}

			// CacheBox Context DSL
			case "cacheBox": {
				// check if linked
				if ( !variables.injector.isCacheBoxLinked() AND !variables.injector.isColdBoxLinked() ) {
					throw(
						message = "The DSLNamespace: #DSLNamespace# cannot be used as it requires a ColdBox/CacheBox Context",
						type    = "Builder.IllegalDSLException"
					);
				}
				// retrieve it
				refLocal.dependency = variables.cacheBoxDSL.process( argumentCollection = arguments );
				break;
			}

			// logbox injection DSL always available
			case "logbox": {
				refLocal.dependency = variables.logBoxDSL.process( argumentCollection = arguments );
				break;
			}

			// WireBox Internal DSL for models and id
			case "model":
			case "id": {
				refLocal.dependency = getModelDSL( argumentCollection = arguments );
				break;
			}

			// provider injection DSL always available
			case "provider": {
				refLocal.dependency = getProviderDSL( argumentCollection = arguments );
				break;
			}

			// wirebox injection DSL always available
			case "wirebox": {
				refLocal.dependency = getWireBoxDSL( argumentCollection = arguments );
				break;
			}

			// java class
			case "java": {
				refLocal.dependency = getJavaDSL( argumentCollection = arguments );
				break;
			}

			// coldfusion type annotation
			case "bytype": {
				refLocal.dependency = getByTypeDSL( argumentCollection = arguments );
				break;
			}

			// If no DSL's found, let's try to use the name as the empty namespace
			default: {
				if ( len( DSLNamespace ) && left( DSLNamespace, 1 ) == "@" ) {
					arguments.definition.dsl = arguments.definition.name & arguments.definition.dsl;
				}
				refLocal.dependency = getModelDSL( argumentCollection = arguments );
			}
		}

		// return only if found
		if ( !isNull( refLocal.dependency ) ) {
			return refLocal.dependency;
		}

		// was dependency required? If so, then throw exception
		if ( arguments.definition.required ) {
			// Build human-readable description of the mapping
			var depDesc = [];
			if ( !isNull( arguments.definition.name ) ) {
				depDesc.append( "Name of '#arguments.definition.name#'" );
			}
			if ( !isNull( arguments.definition.DSL ) ) {
				depDesc.append( "DSL of '#arguments.definition.DSL#'" );
			}
			if ( !isNull( arguments.definition.REF ) ) {
				depDesc.append( "REF of '#arguments.definition.REF#'" );
			}

			var injectMessage = "The target '#arguments.targetID#' requested a missing dependency with a #depDesc.toList( " and " )#";

			// Logging
			if ( variables.log.canError() ) {
				variables.log.error( injectMessage, arguments.definition );
			}

			// Throw exception as DSL Dependency requested was not located
			throw(
				message = injectMessage,
				// safe serialization that won't blow uo on complex values or do weird things with nulls (looking at you, Adobe)
				detail  = serializeJSON(
					arguments.definition.map( function( k, v ){
						if ( isNull( v ) ) {
							return;
						} else if ( !isSimpleValue( v ) ) {
							return "[complex value]";
						} else {
							return v;
						}
					} )
				),
				type = "Builder.DSLDependencyNotFoundException"
			);
		}
		// else return void, no dependency found that was required
	}

	// INTERNAL DSL BUILDER METHODS

	/**
	 * Get a Java object
	 *
	 * @definition The dependency definition structure: name, dsl as keys
	 * @targetObject The target object we are building the DSL dependency for
	 */
	private any function getJavaDSL( required definition, targetObject ){
		var javaClass = getToken( arguments.definition.dsl, 2, ":" );

		return createObject( "java", javaClass );
	}

	/**
	 * Get dependencies using the wirebox dependency DSL
	 *
	 * @definition The dependency definition structure: name, dsl as keys
	 * @targetObject The target object we are building the DSL dependency for
	 */
	private any function getWireBoxDSL( required definition, targetObject ){
		var thisType         = arguments.definition.dsl;
		var thisTypeLen      = listLen( thisType, ":" );
		var thisLocationType = "";
		var thisLocationKey  = "";

		// DSL stages
		switch ( thisTypeLen ) {
			// WireBox injector
			case 1: {
				return variables.injector;
			}

			// Level 2 DSL
			case 2: {
				thisLocationKey = getToken( thisType, 2, ":" );
				switch ( thisLocationKey ) {
					case "parent": {
						return variables.injector.getParent();
					}
					case "eventManager": {
						return variables.injector.getEventManager();
					}
					case "asyncManager": {
						return variables.injector.getAsyncManager();
					}
					case "binder": {
						return variables.injector.getBinder();
					}
					case "populator": {
						return variables.injector.getObjectPopulator();
					}
					case "properties": {
						return variables.injector.getBinder().getProperties();
					}
				}
				break;
			}

			// Level 3 DSL
			case 3: {
				thisLocationType = getToken( thisType, 2, ":" );
				thisLocationKey  = getToken( thisType, 3, ":" );
				// DSL Level 2 Stage Types
				switch ( thisLocationType ) {
					// Scope DSL
					case "scope": {
						return variables.injector.getScope( thisLocationKey );
						break;
					}
					case "property": {
						return variables.injector.getBinder().getProperty( thisLocationKey );
						break;
					}
				}
				break;
			}
			// end level 3 main DSL
		}
	}

	/**
	 * Get executors
	 *
	 * @definition The dependency definition structure: name, dsl as keys
	 * @targetObject The target object we are building the DSL dependency for
	 */
	private any function getExecutorDSl( required definition, targetObject ){
		var asyncManager = variables.injector.getAsyncManager();
		var thisType     = arguments.definition.dsl;
		var thisTypeLen  = listLen( thisType, ":" );
		var executorName = "";

		// DSL stages
		switch ( thisTypeLen ) {
			// property name='myExecutorService' inject="executor";
			case 1: {
				executorName = arguments.definition.name;
				break;
			}
			// executor:{alias} stage
			case 2: {
				executorName = getToken( thisType, 2, ":" );
				break;
			}
		}

		// Check if executor Exists
		if ( asyncManager.hasExecutor( executorName ) ) {
			return asyncManager.getExecutor( executorName );
		} else if ( variables.log.canDebug() ) {
			variables.log.debug(
				"X getExecutorDsl() cannot find executor #executorName# using definition #arguments.definition.toString()#"
			);
		}
	}

	/**
	 * Get dependencies using the model dependency DSL
	 *
	 * @definition The dependency definition structure: name, dsl as keys
	 * @targetObject The target object we are building the DSL dependency for
	 */
	private any function getModelDSL( required definition, targetObject ){
		var thisType    = arguments.definition.dsl;
		var thisTypeLen = listLen( thisType, ":" );
		var methodCall  = "";
		var modelName   = "";

		// DSL stages
		switch ( thisTypeLen ) {
			// No injection defined, use property name: property name='luis' inject;
			case 0: {
				modelName = arguments.definition.name;
				break;
			}
			// Injected defined, can be different scenarios
			// property name='luis' inject="id"; use property name
			// property name='luis' inject="model"; use property name
			// property name='luis' inject="alias";
			case 1: {
				// Are we the key identifiers
				if ( listFindNoCase( "id,model", arguments.definition.dsl ) ) {
					modelName = arguments.definition.name;
				}
				// else we are a real ID
				else {
					modelName = arguments.definition.dsl;
				}

				break;
			}
			// model:{alias} stage
			case 2: {
				modelName = getToken( thisType, 2, ":" );
				break;
			}
			// model:{alias}:{method} stage
			case 3: {
				modelName  = getToken( thisType, 2, ":" );
				methodCall = getToken( thisType, 3, ":" );
				break;
			}
		}

		// Check if model Exists
		if ( variables.injector.containsInstance( modelName ) ) {
			// Get Model object
			var oModel = variables.injector.getInstance( modelName );
			// Factories: TODO: Add arguments with 'ref()' parsing for argument references or 'dsl()'
			if ( len( methodCall ) ) {
				return invoke( oModel, methodCall );
			}
			return oModel;
		} else if ( variables.log.canDebug() ) {
			variables.log.debug(
				"getModelDSL() cannot find model object #modelName# using definition #arguments.definition.toString()#"
			);
		}
	}

	/**
	 * Get dependencies using the our provider pattern DSL
	 *
	 * @definition The dependency definition structure
	 * @targetObject The target object we are building the DSL dependency for. If empty, means we are just requesting building
	 */
	private any function getProviderDSL( required definition, targetObject = "" ){
		var thisType     = arguments.definition.dsl;
		var thisTypeLen  = listLen( thisType, ":" );
		var providerName = "";

		// DSL stages
		switch ( thisTypeLen ) {
			// provider default, get name of the provider from property
			case 1: {
				providerName = arguments.definition.name;
				break;
			}
			// provider:{name} stage
			case 2: {
				providerName = getToken( thisType, 2, ":" );
				break;
			}
			// multiple stages then most likely it is a full DSL being used
			default: {
				providerName = replaceNoCase( thisType, "provider:", "" );
			}
		}

		// Build provider arguments
		var args = {
			scopeRegistration : variables.injector.getScopeRegistration(),
			scopeStorage      : variables.injector.getScopeStorage(),
			targetObject      : arguments.targetObject
		};

		// Check if the passed in provider is an ID directly
		if ( variables.injector.containsInstance( providerName ) ) {
			args.name = providerName;
		}
		// Else try to tag it by FULL DSL
		else {
			args.dsl = providerName;
		}

		// Build provider and return it.
		return createObject( "component", "coldbox.system.ioc.Provider" ).init( argumentCollection = args );
	}

	/**
	 * Get dependencies using the mapped type
	 *
	 * @definition The dependency definition structure
	 * @targetObject The target object we are building the DSL dependency for. If empty, means we are just requesting building
	 */
	private any function getByTypeDSL( required definition, targetObject ){
		var injectType = arguments.definition.type;

		if ( variables.injector.containsInstance( injectType ) ) {
			return variables.injector.getInstance( injectType );
		}
	}

	/**
	 * Do our virtual inheritance magic
	 *
	 * @mapping The mapping to convert to
	 * @target The target object
	 * @targetMapping The target mapping
	 *
	 * @return The target object
	 */
	function toVirtualInheritance(
		required mapping,
		required target,
		required targetMapping
	){
		var excludedProperties = "$super,super,$wbaopmixed,$mixed,this,init";

		// Check if the base mapping has been discovered yet
		if ( NOT arguments.mapping.isDiscovered() ) {
			// process inspection of instance
			arguments.mapping.process( binder = variables.injector.getBinder(), injector = variables.injector );
		}
		// Build it out the base object and wire it
		var baseObject = variables.injector.buildInstance( arguments.mapping );
		variables.injector.autowire( target = baseObject, mapping = arguments.mapping );

		// Mix them up baby!
		variables.utility.getMixerUtil().start( arguments.target );
		variables.utility.getMixerUtil().start( baseObject );

		// Check if init already exists in target and base? If so, then inject it as $superInit
		if ( structKeyExists( arguments.target, "init" ) AND structKeyExists( baseObject, "init" ) ) {
			arguments.target.$superInit = baseObject.init;
		}

		// Mix in public methods and public properties
		for ( var key in baseObject ) {
			// If target has overridden method, then don't override it with mixin, simulated inheritance
			if ( NOT structKeyExists( arguments.target, key ) AND NOT listFindNoCase( excludedProperties, key ) ) {
				// inject method in both variables and this scope to simulate public access
				arguments.target.injectMixin( key, baseObject[ key ] );
			}
		}

		// Prepare for private property/method Injections
		var targetVariables   = arguments.target.getVariablesMixin();
		var generateAccessors = false;
		if (
			arguments.mapping.getObjectMetadata().keyExists( "accessors" ) and arguments.mapping.getObjectMetadata().accessors
		) {
			generateAccessors = true;
		}
		var baseProperties = {};

		// Process baseProperties lookup map
		if ( arguments.mapping.getObjectMetadata().keyExists( "properties" ) ) {
			arguments.mapping
				.getObjectMetadata()
				.properties
				.each( function( item ){
					baseProperties[ item.name ] = true;
				} );
		}

		// Commenting out for now, as I believe this causes double initializations of objects
		// Copy init only if the base object has it and the child doesn't.
		// if ( !structKeyExists( arguments.target, "init" ) AND structKeyExists( baseObject, "init" ) ) {
		//	arguments.target.injectMixin( "init", baseObject.init );
		// }

		// local reference to arguments to use in closures below
		var args = arguments;
		baseObject
			.getVariablesMixin()
			// filter out overrides
			.filter( function( key, value ){
				// If it's a function and not excluded and not overriden, then inject it
				if (
					isCustomFunction( arguments.value ) AND
					!listFindNoCase( excludedProperties, arguments.key ) AND
					!targetVariables.keyExists( arguments.key )
				) {
					return true;
				}

				// Check for just data now
				return ( !listFindNoCase( excludedProperties, arguments.key ) );
			} )
			.each( function( propertyName, propertyValue ){
				// inject the property/method now
				if ( !isNull( arguments.propertyValue ) ) {
					args.target.injectPropertyMixin( propertyName, propertyValue );
				}
				// Do we need to do automatic generic getter/setters
				if ( generateAccessors and baseProperties.keyExists( propertyName ) ) {
					if ( !structKeyExists( args.target, "get#propertyName#" ) ) {
						args.target.injectMixin( "get" & propertyName, variables.genericGetter );
					}

					if ( !structKeyExists( args.target, "set#propertyName#" ) ) {
						args.target.injectMixin( "set" & propertyName, variables.genericSetter );
					}
				}
			} );

		// Mix in virtual super class
		arguments.target.$super = baseObject;

		return arguments.target;
	}

	/**
	 * Generic setter for Virtual Inheritance
	 */
	private function genericSetter(){
		var propName          = getFunctionCalledName().replaceNoCase( "set", "" );
		variables[ propName ] = arguments[ 1 ];
		return this;
	}

	/**
	 * Generic getter for Virtual Inheritance
	 */
	private function genericGetter(){
		var propName = getFunctionCalledName().replaceNoCase( "get", "" );
		return variables[ propName ];
	}

}
