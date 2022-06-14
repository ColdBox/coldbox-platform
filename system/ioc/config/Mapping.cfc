/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * I model a WireBox object mapping in all of its glory and splendour to create the
 * object it represents
 */
component accessors="true" {

	/**
	 * Mapping Properties
	 */

	property name="name";
	property name="alias" type="array";
	property name="type";
	property name="value";
	property name="path";
	property name="method";
	property name="constructor";
	property name="autoWire";
	property name="autoInit" type="boolean";
	property name="eagerInit";
	property name="scope";
	property name="dsl";
	property name="cache" type="struct";
	property name="DIConstructorArguments";
	property name="DIProperties"      type="array";
	property name="DISetters"         type="array";
	property name="DIMethodArguments" type="array";
	property name="onDIComplete"      type="array";
	property name="discovered"        type="boolean";
	property name="objectMetadata"    type="struct";
	property name="providerMethods"   type="array";
	property name="aspect"            type="boolean";
	property name="aspectAutoBinding" type="boolean";
	property name="virtualInheritance";
	property name="extraAttributes" type="struct";
	property name="mixins"          type="array";
	property name="threadSafe";
	property name="influenceClosure";

	/**
	 * Constructor
	 *
	 * @name The mapping name
	 */
	function init( required name ){
		// Setup the mapping name
		variables.name        = arguments.name;
		// Setup the alias list for this mapping.
		variables.alias       = [];
		// Mapping Type
		variables.type        = "";
		// Mapping Value (If Any)
		variables.value       = "";
		// Mapped instantiation path or mapping
		variables.path        = "";
		// A factory method to execute on the mapping if this is a factory mapping
		variables.method      = "";
		// Mapped constructor
		variables.constructor = "init";
		// Discovery and wiring flag
		variables.autoWire    = "";
		// Auto init or not
		variables.autoInit    = true;
		// Lazy load the mapping or not
		variables.eagerInit   = "";
		// The storage or visibility scope of the mapping
		variables.scope       = "";
		// A construction dsl
		variables.dsl         = "";
		// Caching parameters
		variables.cache       = {
			provider          : "",
			key               : "",
			timeout           : "",
			lastAccessTimeout : ""
		};
		// Explicit Constructor arguments
		variables.DIConstructorArguments = [];
		// Explicit Properties
		variables.DIProperties           = [];
		// Explicit Setters
		variables.DISetters              = [];
		// Explicit method arguments
		variables.DIMethodArguments      = [];
		// Post Processors
		variables.onDIComplete           = [];
		// Flag used to distinguish between discovered and non-discovered mappings
		variables.discovered             = false;
		// original object's metadata
		variables.objectMetadata         = {};
		// discovered provider methods
		variables.providerMethods        = [];
		// AOP aspect
		variables.aspect                 = false;
		// aspectAutoBinding
		variables.aspectAutoBinding      = true;
		// Virtual Inheritance
		variables.virtualInheritance     = "";
		// Extra Attributes
		variables.extraAttributes        = {};
		// Mixins
		variables.mixins                 = [];
		// Thread safety on wiring
		variables.threadSafe             = "";
		// A closure that can influence the creation of the mapping
		variables.influenceClosure       = "";

		return this;
	}

	/**
	 * Get the mapping's memento structure
	 */
	struct function getMemento(){
		return variables.filter( function( k, v ){
			return ( !isCustomFunction( v ) );
		} );
	}

	/**
	 * Verify if the influence closure has been seeded.
	 */
	boolean function hasInfluenceClosure(){
		return !isSimpleValue( variables.influenceClosure );
	}

	/**
	 * Process a mapping memento. Basically takes in a struct of data to process the mapping's data with.
	 *
	 * @memento  The data memento to process
	 * @excludes List of memento keys to not process
	 */
	Mapping function processMemento( required memento, excludes = "" ){
		// if excludes is passed as an array, convert to list
		if ( isArray( arguments.excludes ) ) {
			arguments.excludes = arrayToList( arguments.excludes );
		}

		// append incoming memento data
		for ( var key in arguments.memento ) {
			// if current key is in excludes list, skip and continue to next loop
			if ( listFindNoCase( arguments.excludes, key ) ) {
				continue;
			}

			switch ( key ) {
				// process cache properties
				case "cache": {
					setCacheProperties( argumentCollection = arguments.memento.cache );
					break;
				}

				// process constructor args
				case "DIConstructorArguments": {
					for ( var x = 1; x lte arrayLen( arguments.memento.DIConstructorArguments ); x++ ) {
						addDIConstructorArgument(
							argumentCollection = arguments.memento.DIConstructorArguments[ x ]
						);
					}
					break;
				}

				// process properties
				case "DIProperties": {
					for ( var x = 1; x lte arrayLen( arguments.memento.DIProperties ); x++ ) {
						addDIProperty( argumentCollection = arguments.memento.DIProperties[ x ] );
					}
					break;
				}

				// process DISetters
				case "DISetters": {
					for ( var x = 1; x lte arrayLen( arguments.memento.DISetters ); x++ ) {
						addDISetter( argumentCollection = arguments.memento.DISetters[ x ] );
					}
					break;
				}

				// process DIMethodArguments
				case "DIMethodArguments": {
					for ( var x = 1; x lte arrayLen( arguments.memento.DIMethodArguments ); x++ ) {
						addDIMethodArgument( argumentCollection = arguments.memento.DIMethodArguments[ x ] );
					}
					break;
				}

				// process path
				case "path": {
					// Only override if it doesn't exist or empty
					if ( !len( variables.path ) ) {
						variables.path = arguments.memento[ "path" ];
					}
					break;
				}

				default: {
					variables[ key ] = arguments.memento[ key ];
					break;
				}
			}
			// end switch
		}

		return this;
	}

	/**
	 * Checks if the mapping needs virtual inheritance or not
	 */
	boolean function isVirtualInheritance(){
		return len( variables.virtualInheritance ) GT 0;
	}

	/**
	 * Flag describing if you are using autowire or not as Boolean
	 */
	boolean function isAutoWire(){
		return ( isBoolean( variables.autowire ) ? variables.autowire : false );
	}

	/**
	 * Flag describing if this mapping is an AOP aspect or not
	 */
	boolean function isAspect(){
		return ( isBoolean( variables.aspect ) ? variables.aspect : false );
	}

	/**
	 * Is this mapping an auto aspect binding
	 */
	boolean function isAspectAutoBinding(){
		return ( isBoolean( variables.aspectAutoBinding ) ? variables.aspectAutoBinding : false );
	}

	/**
	 * Using auto init or not
	 */
	boolean function isAutoInit(){
		return ( isBoolean( variables.autoInit ) ? variables.autoInit : false );
	}

	/**
	 * Does this mapping have a DSL construction element or not as Boolean
	 */
	boolean function isDSL(){
		return ( len( variables.dsl ) GT 0 );
	}

	/**
	 * Set the cache properties for this mapping
	 *
	 * @key               Cache key to use
	 * @timeout           Object Timeout
	 * @lastAccessTimeout Object Last Access Timeout
	 * @provider          The Cache Provider to use
	 */
	function setCacheProperties(
		required key,
		timeout           = "",
		lastAccessTimeout = "",
		provider          = "default"
	){
		structAppend( variables.cache, arguments, true );
		return this;
	}

	/**
	 * Get the cache properties struct
	 */
	struct function getCacheProperties(){
		return variables.cache;
	}

	/**
	 * Add a new constructor argument to this mapping
	 *
	 * @name     The name of the constructor argument (Not used for: JAVA,WEBSERVICE)
	 * @ref      The reference mapping id this constructor argument maps to
	 * @dsl      The construction dsl this argument references. If used, the name value must be used.
	 * @value    The explicit value of the constructor argument, if passed.
	 * @javaCast The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments
	 * @required If the argument is required or not, by default we assume required DI arguments
	 * @type     The type of the argument
	 */
	Mapping function addDIConstructorArgument(
		name,
		ref,
		dsl,
		value,
		javaCast,
		required required=true,
		type             = "any"
	){
		// check if already registered, if it is, just return
		for ( var x = 1; x lte arrayLen( variables.DIConstructorArguments ); x++ ) {
			if (
				structKeyExists( arguments, "name" ) AND
				structKeyExists( variables.DIConstructorArguments[ x ], "name" ) AND
				variables.DIConstructorArguments[ x ].name == arguments.name
			) {
				return this;
			}
		}

		// Register new constructor argument.
		var definition = getNewDIDefinition();
		structAppend( definition, arguments, true );
		arrayAppend( variables.DIConstructorArguments, definition );

		return this;
	}

	/**
	 * Add a new method argument to this mapping
	 *
	 * @name     The name of the method argument (Not used for: JAVA,WEBSERVICE)
	 * @ref      The reference mapping id this method argument maps to
	 * @dsl      The construction dsl this argument references. If used, the name value must be used.
	 * @value    The explicit value of the method argument, if passed.
	 * @javaCast The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments
	 * @required If the argument is required or not, by default we assume required DI arguments
	 * @type     The type of the argument
	 */
	Mapping function addDIMethodArgument(
		name,
		ref,
		dsl,
		value,
		javaCast,
		required required=true,
		type             = "any"
	){
		// check if already registered, if it is, just return
		for ( var x = 1; x lte arrayLen( variables.DIMethodArguments ); x++ ) {
			if (
				structKeyExists( variables.DIMethodArguments[ x ], "name" ) AND
				variables.DIMethodArguments[ x ].name == arguments.name
			) {
				return this;
			}
		}

		// Register new constructor argument.
		var definition = getNewDIDefinition();
		structAppend( definition, arguments, true );
		arrayAppend( variables.DIMethodArguments, definition );

		return this;
	}

	/**
	 * Add a new property di definition
	 *
	 * @name     The name of the property to inject
	 * @ref      The reference mapping id this property maps to
	 * @dsl      The construction dsl this property references. If used, the name value must be used.
	 * @value    The explicit value of the property, if passed.
	 * @javaCast The type of javaCast() to use on the value of the value. Only used if using dsl or ref arguments
	 * @scope    The scope in the CFC to inject the property to. By default it will inject it to the variables scope
	 * @required If the property is required or not, by default we assume required DI
	 * @type     The type of the property
	 */
	Mapping function addDIProperty(
		required name,
		ref,
		dsl,
		value,
		javaCast,
		scope            = "variables",
		required required=true,
		type             = "any"
	){
		// check if already registered, if it is, just return
		for ( var x = 1; x lte arrayLen( variables.DIProperties ); x++ ) {
			if ( variables.DIProperties[ x ].name eq arguments.name ) {
				return this;
			}
		}

		var definition = getNewDIDefinition();
		structAppend( definition, arguments, true );
		arrayAppend( variables.DIProperties, definition );

		return this;
	}

	/**
	 * Add a new DI Setter Definition
	 *
	 * @name     The name of the setter to inject
	 * @ref      The reference mapping id this setter maps to
	 * @dsl      The construction dsl this setter references. If used, the name value must be used.
	 * @value    The explicit value of the setter, if passed.
	 * @javaCast The type of javaCast() to use on the value of the value. Only used if using dsl or ref arguments
	 * @argName  The name of the argument to use, if not passed, we default it to the setter name
	 */
	Mapping function addDISetter(
		required name,
		ref,
		dsl,
		value,
		javaCast,
		argName
	){
		// check if already registered, if it is, just return
		for ( var x = 1; x lte arrayLen( variables.DISetters ); x++ ) {
			if ( variables.DISetters[ x ].name eq arguments.name ) {
				return this;
			}
		}

		// Get new definition
		var definition   = getNewDIDefinition();
		// Remove scope for setter injection
		definition.scope = "";
		// Verify argument name, if not default it to setter name
		if ( NOT structKeyExists( arguments, "argName" ) OR len( arguments.argName ) EQ 0 ) {
			arguments.argName = arguments.name;
		}
		// save incoming params
		structAppend( definition, arguments, true );
		// save new DI setter injection
		arrayAppend( variables.DISetters, definition );

		return this;
	}

	/**
	 * Checks if this mapping has already been processed or not
	 */
	boolean function isDiscovered(){
		return variables.discovered;
	}

	/**
	 * Is this mapping eager initialized or not as Boolean
	 */
	boolean function isEagerInit(){
		return ( isBoolean( variables.eagerInit ) ? variables.eagerInit : false );
	}

	/**
	 * Add a new provider method to this mapping
	 *
	 * @method  The provided method to override as a provider
	 * @mapping The mapping to provide via the selected method
	 */
	Mapping function addProviderMethod( required method, required mapping ){
		arrayAppend( variables.providerMethods, arguments );
		return this;
	}

	/**
	 * ---------------------------------------------------
	 * Processing Methods
	 * ---------------------------------------------------
	 */

	/**
	 * Process a mapping for metadata discovery and more
	 *
	 * @binder   The binder requesting the processing
	 * @injector The calling injector processing the mapping
	 * @metadata The metadata of an a-la-carte processing, use instead of retrieving again
	 *
	 * @return Mapping
	 */
	Mapping function process( required binder, required injector, metadata ){
		// Short circuit, if mapping already discovered, then just exit out.
		if ( variables.discovered ) {
			return this;
		}

		var md              = variables.objectMetadata;
		var eventManager    = arguments.injector.getEventManager();
		var cacheProperties = {};

		// Generate a lock token
		var lockToken = isSimpleValue( variables.path ) ? variables.path : variables.name;

		// Lock for discovery based on path location, only done once per mapping
		lock
			name          ="Mapping.#arguments.injector.getInjectorID()#.MetadataProcessing.#lockToken#"
			type          ="exclusive"
			timeout       ="20"
			throwOnTimeout="true" {
			// Race Condition Lock
			if ( variables.discovered ) {
				return this;
			}

			// announce inspection
			var iData = {
				mapping  : this,
				binder   : arguments.binder,
				injector : arguments.binder.getInjector()
			};
			eventManager.announce( "beforeInstanceInspection", iData );

			// Processing only done for CFC's,rest just mark and return
			if ( variables.type neq arguments.binder.TYPES.CFC ) {
				if ( !len( variables.scope ) ) {
					variables.scope = "noscope";
				}
				if ( !len( variables.autowire ) ) {
					variables.autowire = true;
				}
				if ( !len( variables.eagerInit ) ) {
					variables.eagerInit = false;
				}
				if ( !len( variables.threadSafe ) ) {
					variables.threadSafe = false;
				}
				// finished processing mark as discovered
				variables.discovered = true;
				// announce it
				eventManager.announce( "afterInstanceInspection", iData );
				return this;
			}

			// Get the metadata first, so we can start processing.
			if ( !isNull( arguments.metadata ) ) {
				md = arguments.metadata;
			} else {
				var produceMetadataUDF = function(){
					return injector.getUtility().getInheritedMetaData( variables.path, binder.getStopRecursions() );
				};

				// Are we caching metadata? or just using it
				if ( len( arguments.binder.getMetadataCache() ) ) {
					// Get from cache or produce on demand
					md = arguments.injector
						.getCacheBox()
						.getCache( arguments.binder.getMetadataCache() )
						.getOrSet( variables.path, produceMetadataUDF );
				} else {
					md = produceMetadataUDF();
				}
			}

			// Store Metadata
			variables.objectMetadata = md;

			// Process persistence if not set already by configuration as it takes precedence
			if ( !len( variables.scope ) ) {
				// Singleton Processing
				if ( structKeyExists( md, "singleton" ) ) {
					variables.scope = arguments.binder.SCOPES.SINGLETON;
				}
				// Registered Scope Processing
				if ( structKeyExists( md, "scope" ) ) {
					variables.scope = md.scope;
				}
				// CacheBox scope processing if cachebox annotation found, or cache annotation found
				if (
					structKeyExists( md, "cacheBox" ) OR (
						structKeyExists( md, "cache" ) AND isBoolean( md.cache ) AND md.cache
					)
				) {
					variables.scope = arguments.binder.SCOPES.CACHEBOX;
				}
				// check if scope found? If so, then set it to no scope.
				else if ( !len( variables.scope ) ) {
					variables.scope = "noscope";
				}
			}
			// end of persistence checks

			// Cachebox Persistence Processing
			if ( variables.scope EQ arguments.binder.SCOPES.CACHEBOX ) {
				// Check if we already have a key, maybe added via configuration
				if ( !len( variables.cache.key ) ) {
					variables.cache.key = "wirebox-#variables.name#";
				}
				// Check the default provider now to see if set by configuration
				if ( !len( variables.cache.provider ) ) {
					// default it first
					variables.cache.provider = "default";
					// Now check the annotations for the provider
					if ( structKeyExists( md, "cacheBox" ) AND len( md.cacheBox ) ) {
						variables.cache.provider = md.cacheBox;
					}
				}
				// Check if timeouts set by configuration or discovery
				if ( !len( variables.cache.timeout ) ) {
					// Discovery by annocations
					if ( structKeyExists( md, "cachetimeout" ) AND isNumeric( md.cacheTimeout ) ) {
						variables.cache.timeout = md.cacheTimeout;
					}
				}
				// Check if lastAccessTimeout set by configuration or discovery
				if ( !len( variables.cache.lastAccessTimeout ) ) {
					// Discovery by annocations
					if ( structKeyExists( md, "cacheLastAccessTimeout" ) AND isNumeric( md.cacheLastAccessTimeout ) ) {
						variables.cache.lastAccessTimeout = md.cacheLastAccessTimeout;
					}
				}
			}

			// Alias annotations if found, then append them as aliases.
			if ( structKeyExists( md, "alias" ) ) {
				var thisAliases = listToArray( md.alias );
				variables.alias.addAll( thisAliases );
				// register alias references on binder
				var mappings = arguments.binder.getMappings();
				for ( var x = 1; x lte arrayLen( thisAliases ); x++ ) {
					mappings[ thisAliases[ x ] ] = this;
				}
			}

			// eagerInit annotation only if not overridden
			if ( !len( variables.eagerInit ) ) {
				if ( structKeyExists( md, "eagerInit" ) ) {
					variables.eagerInit = true;
				} else {
					// defaults to lazy loading
					variables.eagerInit = false;
				}
			}

			// threadSafe wiring annotation
			if ( !len( variables.threadSafe ) ) {
				if ( structKeyExists( md, "threadSafe" ) AND NOT len( md.threadSafe ) ) {
					variables.threadSafe = true;
				} else if ( structKeyExists( md, "threadSafe" ) AND len( md.threadSafe ) AND isBoolean( md.threadSafe ) ) {
					variables.threadSafe = md.threadSafe;
				} else {
					// defaults to non thread safe wiring
					variables.threadSafe = false;
				}
			}

			// mixins annotation only if not overridden
			if ( NOT arrayLen( variables.mixins ) ) {
				if ( structKeyExists( md, "mixins" ) ) {
					variables.mixins = listToArray( md.mixins );
				}
			}

			// autowire only if not overridden
			if ( !len( variables.autowire ) ) {
				// Check if autowire annotation found or autowire already set
				if ( structKeyExists( md, "autowire" ) and isBoolean( md.autowire ) ) {
					variables.autoWire = md.autowire;
				} else {
					// default to true
					variables.autoWire = true;
				}
			}

			// look for parent metadata referring to an abstract parent (by alias) to copy
			// dependencies and definitions from
			if ( structKeyExists( md, "parent" ) and len( trim( md.parent ) ) ) {
				arguments.binder.parent( alias: md.parent );
			}

			// Only process if autowiring
			if ( variables.autoWire ) {
				// Process Methods, Constructors and Properties only if non autowire annotation check found on component.
				processDIMetadata( arguments.binder, md );
			}

			// AOP AutoBinding only if both @classMatcher and @methodMatcher exist
			if (
				isAspectAutoBinding() AND structKeyExists( md, "classMatcher" ) AND structKeyExists(
					md,
					"methodMatcher"
				)
			) {
				processAOPBinding( arguments.binder, md );
			}

			// finished processing mark as discovered
			variables.discovered = true;

			// announce it
			eventManager.announce( "afterInstanceInspection", iData );
		}
		// End lock

		return this;
	}

	/**
	 * ---------------------------------------------------
	 * Private Methods
	 * ---------------------------------------------------
	 */

	/**
	 * Process the AOP self binding aspects
	 *
	 * @binder   The binder requesting the processing
	 * @metadata The metadata to process
	 *
	 * @return Mapping
	 */
	private Mapping function processAOPBinding( required binder, required metadata ){
		var classes       = listFirst( arguments.metadata.classMatcher, ":" );
		var methods       = listFirst( arguments.metadata.methodMatcher, ":" );
		var classMatcher  = "";
		var methodMatcher = "";

		// determine class matching
		switch ( classes ) {
			case "any": {
				classMatcher = arguments.binder.match().any();
				break;
			}
			case "annotatedWith": {
				// annotation value?
				if ( listLen( arguments.metadata.classMatcher, ":" ) eq 3 ) {
					classMatcher = arguments.binder
						.match()
						.annotatedWith(
							getToken( arguments.metadata.classMatcher, 2, ":" ),
							getToken( arguments.metadata.classMatcher, 3, ":" )
						);
				}
				// No annotation value
				else {
					classMatcher = arguments.binder
						.match()
						.annotatedWith( getToken( arguments.metadata.classMatcher, 2, ":" ) );
				}
				break;
			}
			case "mappings": {
				classMatcher = arguments.binder
					.match()
					.mappings( getToken( arguments.metadata.classMatcher, 2, ":" ) );
				break;
			}
			case "instanceOf": {
				classMatcher = arguments.binder
					.match()
					.instanceOf( getToken( arguments.metadata.classMatcher, 2, ":" ) );
				break;
			}
			case "regex": {
				classMatcher = arguments.binder
					.match()
					.regex( getToken( arguments.metadata.classMatcher, 2, ":" ) );
				break;
			}
			default: {
				// throw, no matching matchers
				throw(
					message = "Invalid Class Matcher: #classes#",
					type    = "Mapping.InvalidAOPClassMatcher",
					detail  = "Valid matchers are 'any,annotatedWith:annotation,annotatedWith:annotation:value,mappings:XXX,instanceOf:XXX,regex:XXX'"
				);
			}
		}

		// determine method matching
		switch ( methods ) {
			case "any": {
				methodMatcher = arguments.binder.match().any();
				break;
			}
			case "annotatedWith": {
				// annotation value?
				if ( listLen( arguments.metadata.classMatcher, ":" ) eq 3 ) {
					methodMatcher = arguments.binder
						.match()
						.annotatedWith(
							getToken( arguments.metadata.methodMatcher, 2, ":" ),
							getToken( arguments.metadata.methodMatcher, 3, ":" )
						);
				}
				// No annotation value
				else {
					methodMatcher = arguments.binder
						.match()
						.annotatedWith( getToken( arguments.metadata.methodMatcher, 2, ":" ) );
				}
				break;
			}
			case "methods": {
				methodMatcher = arguments.binder
					.match()
					.methods( getToken( arguments.metadata.methodMatcher, 2, ":" ) );
				break;
			}
			case "instanceOf": {
				methodMatcher = arguments.binder
					.match()
					.instanceOf( getToken( arguments.metadata.methodMatcher, 2, ":" ) );
				break;
			}
			case "regex": {
				methodMatcher = arguments.binder
					.match()
					.regex( getToken( arguments.metadata.methodMatcher, 2, ":" ) );
				break;
			}
			default: {
				// throw, no matching matchers
				throw(
					message = "Invalid Method Matcher: #classes#",
					type    = "Mapping.InvalidAOPMethodMatcher",
					detail  = "Valid matchers are 'any,annotatedWith:annotation,annotatedWith:annotation:value,methods:XXX,instanceOf:XXX,regex:XXX'"
				);
			}
		}

		// Bind the Aspect to this Mapping
		arguments.binder.bindAspect( classMatcher, methodMatcher, getName() );

		return this;
	}

	/**
	 * Process methods/properties for dependency injection
	 *
	 * @binder       The binder requesting the processing
	 * @metadata     The metadata to process
	 * @dependencies The dependencies structure
	 *
	 * @return Mapping
	 */
	private Mapping function processDIMetadata(
		required binder,
		required metadata,
		dependencies = {}
	){
		// Shortcut
		var md = arguments.metadata;

		// Look For properties for annotation injections and register them with the mapping
		param md.properties = [];
		md.properties
			// Only process injectable properties
			.filter( function( thisProperty ){
				return structKeyExists( arguments.thisProperty, "inject" );
			} )
			// Process each property
			.each( function( thisProperty ){
				addDIProperty(
					name : arguments.thisProperty.name,
					dsl  : ( len( arguments.thisProperty.inject ) ? arguments.thisProperty.inject : "model" ),
					scope: (
						structKeyExists( arguments.thisProperty, "scope" ) ? arguments.thisProperty.scope : "variables"
					),
					required: (
						structKeyExists( arguments.thisProperty, "required" ) ? arguments.thisProperty.required : true
					),
					type: ( structKeyExists( arguments.thisProperty, "type" ) ? arguments.thisProperty.type : "any" )
				);
			} );

		// Look For functions for setter injections and more and register them with the mapping
		param md.functions = [];
		md.functions
			// Verify Processing or do we continue to next iteration for processing
			// This is to avoid overriding by parent trees in inheritance chains
			.filter( function( thisFunction ){
				return !structKeyExists( dependencies, thisFunction.name );
			} )
			.each( function( thisFunction ){
				// Constructor Processing if found
				if ( thisFunction.name eq variables.constructor ) {
					// Process parameters for constructor injection
					for ( var thisParam in thisFunction.parameters ) {
						// Check injection annotation, if not found then no injection
						if ( structKeyExists( thisParam, "inject" ) ) {
							// ADD Constructor argument
							addDIConstructorArgument(
								name    : thisParam.name,
								dsl     : ( len( thisParam.inject ) ? thisParam.inject : "model" ),
								required: ( structKeyExists( thisParam, "required" ) ? thisParam.required : false ),
								type    : ( structKeyExists( thisParam, "type" ) ? thisParam.type : "any" )
							);
						}
					}
					// add constructor to found list, so it is processed only once in recursions
					dependencies[ thisFunction.name ] = "constructor";
				}

				// Setter discovery, MUST be inject annotation marked to be processed.
				if ( left( thisFunction.name, 3 ) eq "set" AND structKeyExists( thisFunction, "inject" ) ) {
					// Add to setter to mappings and recursion lookup
					addDISetter(
						name: right( thisFunction.name, len( thisFunction.name ) - 3 ),
						dsl : ( len( thisFunction.inject ) ? thisFunction.inject : "model" )
					);
					dependencies[ thisFunction.name ] = "setter";
				}

				// Provider Methods Discovery
				if ( structKeyExists( thisFunction, "provider" ) AND len( thisFunction.provider ) ) {
					addProviderMethod( thisFunction.name, thisFunction.provider );
					dependencies[ thisFunction.name ] = "provider";
				}

				// onDIComplete Method Discovery
				if ( structKeyExists( thisFunction, "onDIComplete" ) ) {
					arrayAppend( variables.onDIComplete, thisFunction.name );
					dependencies[ thisFunction.name ] = "onDIComplete";
				}
			} ); // End function processing

		return this;
	}

	/**
	 * Get a new DI definition structure
	 */
	private struct function getNewDIDefinition(){
		return {
			"name"     : "",
			"value"    : javacast( "null", "" ),
			"dsl"      : javacast( "null", "" ),
			"scope"    : "variables",
			"javaCast" : javacast( "null", "" ),
			"ref"      : javacast( "null", "" ),
			"required" : false,
			"argName"  : "",
			"type"     : "any"
		};
	}

}
