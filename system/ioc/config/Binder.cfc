/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This is the WireBox configuration Binder.  You use it to configure an injector instance.
 * This binder will hold all your object mappings and injector settings.
 */
component accessors="true" {

	/**
	 * The current mapping pointer for DSL configurations
	 */
	property name="currentMapping" type="array";

	/**
	 * The configuration properties/settings for the app context or the injector context (standalone)
	 */
	property name="properties" type="struct";

	/**
	 * The injector reference this binder is bound to
	 */
	property name="injector";

	/**
	 * The ColdBox reference this binder is bound to, this can be null
	 */
	property name="coldbox";

	/**
	 * Main WireBox configuration structure
	 */
	property name="wirebox" type="struct";

	/**
	 * Main CacheBox configuration structure
	 */
	property name="cachebox" type="struct";

	/**
	 * The configuration CFC for this binder
	 */
	property name="config";

	/**
	 * The shortcut application mapping string
	 */
	property name="appMapping";

	/**
	 * The LogBox config file
	 */
	property name="logBoxConfig";

	/**
	 * The Listeners
	 */
	property name="listeners" type="array";

	/**
	 * The scope registration config
	 */
	property name="scopeRegistration" type="struct";

	/**
	 * The custom DSL namespaces
	 */
	property name="customDSL" type="struct";

	/**
	 * The custom scopes
	 */
	property name="customScopes" type="struct";

	/**
	 * The scan locations for this binder
	 */
	property name="scanLocations" type="struct";

	/**
	 * The collection of mappings
	 */
	property name="mappings" type="struct";

	/**
	 * The aspects binded to mappings
	 */
	property name="aspectBindings" type="array";

	/**
	 * The parent injector reference
	 */
	property name="oParentInjector";

	/**
	 * The stop recursions for the binder
	 */
	property name="aStopRecursions" type="array";

	/**
	 * The metadata cache for this binder
	 */
	property name="metadataCache";

	/**
	 * Boolean indicator if on startup all mappings will be processed for metadata inspections or
	 * lazy loaded. We default to lazy load due to performance.
	 */
	property name="autoProcessMappings" type="boolean";

	/**
	 * The configuration DEFAULTS struct
	 */
	property
		name  ="DEFAULTS"
		setter="false"
		type  ="struct";

	/**
	 * --------------------------------------------------
	 * Binder Public References
	 * --------------------------------------------------
	 * One day move as static references
	 */

	// Binder Marker
	this.$wbBinder = true;

	// Available WireBox public scopes
	this.SCOPES = new coldbox.system.ioc.Scopes();
	// Available WireBox public types
	this.TYPES  = new coldbox.system.ioc.Types();

	// WireBox Operational Defaults
	variables.DEFAULTS = {
		// LogBox Default Config
		logBoxConfig      : "coldbox.system.ioc.config.LogBox",
		// Scope Registration
		scopeRegistration : { enabled : true, scope : "application", key : "wireBox" },
		// CacheBox Integration Defaults
		cacheBox          : {
			enabled        : false,
			configFile     : "",
			cacheFactory   : "",
			classNamespace : "coldbox.system.cache"
		},
		// Auto process mappings on startup
		// We lazy process all mappings until requested
		autoProcessMappings : false
	};

	// Startup the configuration
	reset();

	/**
	 * Constructor
	 *
	 * @injector   The injector this binder is bound to
	 * @config     The WireBox Injector Data Configuration CFC instance or instantiation path to it. Leave blank if using this configuration object programmatically
	 * @properties A structure of binding properties to passthrough to the Binder Configuration CFC
	 */
	function init(
		required injector,
		config,
		struct properties = {}
	){
		// Setup incoming properties
		variables.properties = arguments.properties;
		// Setup Injector this binder is bound to.
		variables.injector   = arguments.injector;
		// ColdBox Context binding if any?
		variables.coldbox    = variables.injector.getColdBox();
		// is coldbox linked
		if ( isObject( variables.coldbox ) ) {
			variables.appMapping = variables.coldbox.getSetting( "AppMapping" );
		}

		// If Config CFC sent and a path, then create the data CFC
		if ( !isNull( arguments.config ) and isSimpleValue( arguments.config ) ) {
			arguments.config = createObject( "component", arguments.config );
		}

		// If sent and a data CFC variables
		if ( !isNull( arguments.config ) and isObject( arguments.config ) ) {
			// Decorate our data CFC
			arguments.config.getPropertyMixin = variables.injector.getUtility().getMixerUtil().getPropertyMixin;
			// Execute the configuration
			arguments.config.configure( this );
			// Load the raw data DSL
			loadDataDSL( arguments.config.getPropertyMixin( "wireBox", "variables", {} ) );
		}

		return this;
	}

	/**
	 * The main configuration method that must be overridden by a specific WireBox Binder configuration object
	 */
	function configure(){
		// Implemented by concrete classes
	}

	/**
	 * Reset the configuration back to the original binder defaults
	 */
	Binder function reset(){
		// Contains the mappings currently being affected by the DSL.
		variables.currentMapping      = [];
		// Main wirebox structure
		variables.wirebox             = {};
		// logBox File
		variables.logBoxConfig        = variables.DEFAULTS.logBoxConfig;
		// CacheBox integration
		variables.cacheBox            = variables.DEFAULTS.cacheBox;
		// Scope Registration
		variables.scopeRegistration   = variables.DEFAULTS.scopeRegistration;
		// Custom DSL namespaces
		variables.customDSL           = {};
		// Custom Storage Scopes
		variables.customScopes        = {};
		// Package Scan Locations
		variables.scanLocations       = structNew( "ordered" );
		// Parent Injector Mapping
		variables.oParentInjector     = "";
		// Stop Recursion classes
		variables.aStopRecursions     = [];
		// Listeners
		variables.listeners           = [];
		// Object Mappings
		variables.mappings            = {};
		// Aspect Bindings
		variables.aspectBindings      = [];
		// Binding Properties
		variables.properties          = {};
		// Metadata cache
		variables.metadataCache       = "";
		// Auto Process Mappings
		variables.autoProcessMappings = variables.DEFAULTS.autoProcessMappings;

		return this;
	}

	/**
	 * --------------------------------------------------
	 * Binder Property Binding Methods
	 * --------------------------------------------------
	 */

	/**
	 * Get a binded property. If not found it will try to return the default value passed, else it returns an exception
	 *
	 * @name         The name of the property to get
	 * @defaultValue The default value if property is not found
	 *
	 * @return Property value
	 *
	 * @throws PropertyNotFoundException - If the property is not found and no default sent
	 */
	function getProperty( required name, defaultValue ){
		// Prop Check
		if ( structKeyExists( variables.properties, arguments.name ) ) {
			return variables.properties[ arguments.name ];
		}

		// TODO: remove by v7
		// Deprecated Check
		if ( !isNull( arguments.default ) ) {
			return arguments.default;
		}

		// Default Value
		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}

		// Throw exception
		throw(
			message = "The property requested #arguments.name# was not found",
			detail  = "Properties defined are #structKeyList( variables.properties )#",
			type    = "PropertyNotFoundException"
		);
	}

	/**
	 * Create a new binding property
	 *
	 * @name  The name of the property to set
	 * @value The value of the property
	 */
	Binder function setProperty( required name, required value ){
		variables.properties[ arguments.name ] = arguments.value;
		return this;
	}

	/**
	 * Verify if a property exists
	 *
	 * @name The name of the property to verify
	 */
	Boolean function propertyExists( required name ){
		return structKeyExists( variables.properties, arguments.name );
	}

	/**
	 * Get the stop recursions: Different method to comply with previous API
	 * TODO: Change in v7 to break compat.
	 */
	function getStopRecursions(){
		return variables.aStopRecursions;
	}

	/**
	 * Get the parent injector: Different method to comply with previous API
	 * TODO: Change in v7 to break compat.
	 */
	function getParentInjector(){
		return variables.oParentInjector;
	}

	/**
	 * --------------------------------------------------
	 * Binder Mapping Methods
	 * --------------------------------------------------
	 */

	/**
	 * Get a specific object mapping
	 *
	 * @name The name of the mapping
	 *
	 * @return coldbox.system.ioc.config.Mapping
	 *
	 * @throws MappingNotFoundException - If the named mapping has not been registered
	 */
	Mapping function getMapping( required name ){
		if ( structKeyExists( variables.mappings, arguments.name ) ) {
			return variables.mappings[ arguments.name ];
		}

		throw(
			message = "Mapping #arguments.name# has not been registered",
			detail  = "Registered mappings are: #structKeyList( variables.mappings )#",
			type    = "MappingNotFoundException"
		);
	}

	/**
	 * Set a mapping object into the mappings map
	 *
	 * @name    The name of the mapping
	 * @mapping The mapping object to register
	 */
	Binder function setMapping( required name, required mapping ){
		variables.mappings[ arguments.name ] = arguments.mapping;
		return this;
	}

	/**
	 * Destroys a registered mapping by name
	 *
	 * @name The name of the mapping
	 *
	 * @return A boolean indicator if the mapping was removed or not
	 */
	boolean function unMap( required name ){
		return structDelete( variables.mappings, arguments.name );
	}

	/**
	 * Verifies if a mapping exists in this binder or not
	 *
	 * @name The name of the mapping
	 */
	boolean function mappingExists( required name ){
		return structKeyExists( variables.mappings, arguments.name );
	}

	/**
	 * --------------------------------------------------
	 * Binder Mapping DSL methods
	 * --------------------------------------------------
	 */

	/**
	 * Directly map to a path by using the last part of the path as the alias.
	 * This is equivalent to map('MyService').to('model.MyService').
	 * Only use if the name of the alias is the same as the last part of the path.
	 *
	 * @path      The class path to the object to map
	 * @namespace Provide namespace to merge it in
	 * @prepend   Where to attach the namespace, at the beginning of the name or end of the name. Defaults to end of name
	 * @force     Forces the registration of the mapping in case it already exists
	 */
	function mapPath(
		required path,
		namespace       = "",
		boolean prepend = false,
		boolean force   = false
	){
		var cName = listLast( arguments.path, "." );

		if ( arguments.prepend ) {
			cName = arguments.namespace & cName;
		} else {
			cName = cName & arguments.namespace;
		}

		// directly map to a path
		return map( cName, arguments.force ).to( arguments.path );
	}

	/**
	 * Maps an entire instantiation path directory, please note that the unique name of each file will be used and also processed for alias inspection
	 *
	 * @packagePath The instantiation packagePath to map
	 * @include     An include regex that if matches will only include CFCs that match this case insensitive regex
	 * @exclude     An exclude regex that if matches will exclude CFCs that match this case insensitive regex
	 * @influence   The influence closure or UDF that will receive the currently working mapping so you can influence it during the iterations
	 * @filter      The filter closure or UDF that will receive the path of the CFC to process and returns TRUE to continue processing or FALSE to skip processing
	 * @namespace   Provide namespace to merge it in
	 * @prepend     Where to attach the namespace, at the beginning of the name or end of the name. Defaults to end of name
	 * @process     If true, all mappings discovered will be automatically processed for metadata and inspections.  Default is false, everything lazy loads
	 *
	 * @throws DirectoryNotFoundException - If the requested package path does not exist.
	 */
	Binder function mapDirectory(
		required packagePath,
		include = "",
		exclude = "",
		influence,
		filter,
		namespace       = "",
		boolean prepend = false,
		boolean process = false
	){
		// check directory exists
		var targetDirectory = expandPath( "/#replace( arguments.packagePath, ".", "/", "all" )#" );
		if ( NOT directoryExists( targetDirectory ) ) {
			throw(
				message = "Directory does not exist",
				detail  = "Directory: #targetDirectory#",
				type    = "DirectoryNotFoundException"
			);
		}

		// These checks must be performed safely here so we can be explicit abut the scopes
		// All refernces to influence and filter inside the closures cannot be scoped or they will find the wrong arguments
		var hasInfluence = !isNull( arguments.influence );
		var hasFilter    = !isNull( arguments.filter );

		// Clear out any current mappings
		variables.currentMapping = [];

		// Scan + Process Objects
		directoryList(
			targetDirectory, // path
			true, // recurse
			"path", // list info
			"*.cfc" // filter
		)
			// Skip hidden files/dirs and also paths not in the include/exclude lists
			.filter( function( thisPath ){
				// Skip hidden dirs (like .Appledouble)
				if ( left( arguments.thisPath, 1 ) EQ "." ) {
					return false;
				}
				// If any of the following are true, then process it, else skip it
				return (
					// We have an include list and the path matches
					( len( include ) AND reFindNoCase( include, arguments.thisPath ) )
					OR
					// We have an exclude list and the path doesn't match
					( len( exclude ) AND NOT reFindNoCase( exclude, arguments.thisPath ) )
					// We have a closure filter, we ask the filter
					OR
					( hasFilter AND filter( arguments.thisPath ) )
					OR
					// No include, no exclude and no filter
					( NOT len( include ) AND NOT len( exclude ) AND !hasFilter )
				);
			} )
			// Transform the path to something usable for object creation
			// leading slash, append package path, remove .cfc and /\ with . notation
			.map( function( thisPath ){
				// Remove root directory from path to get relative path
				arguments.thisPath = replaceNoCase( arguments.thisPath, targetDirectory, "" );
				// Process rest of manips
				return reReplace(
					reReplace( packagePath, "^/", "" ) & replaceNoCase( arguments.thisPath, ".cfc", "" ),
					"(/|\\)",
					".",
					"all"
				);
			} )
			// Process the path
			.each( function( thisPath ){
				// Backup the current array of mappings
				var tmpCurrentMapping = variables.currentMapping;

				// Map the path
				mapPath(
					path     : arguments.thisPath,
					namespace: namespace,
					prepend  : prepend,
					force    : true
				);

				// Are we influencing?
				if ( hasInfluence ) {
					influence(
						this,
						arguments.thisPath,
						variables.currentMapping[ 1 ]
					);
				}

				/**
				 * Do this right away so aliases are picked up before this mapping potentially gets overwritten
				 * This is necessary for multiple CFCs with the same name in different folders, but with unique aliases
				 * TODO: Move to async
				 */
				if ( process ) {
					variables.currentMapping[ 1 ].process( binder = this, injector = variables.injector );
				}

				// Merge the full array of mappings back together
				arrayAppend( tmpCurrentMapping, variables.currentMapping[ 1 ] );
				variables.currentMapping = tmpCurrentMapping;
			} );

		return this;
	}

	/**
	 * Auto process a mapping once defined, this is usually done if there are critical annotations that must be read upon startup, else avoid it and let them lazy load
	 */
	Binder function process(){
		variables.mappings.each( function( thisMapping ){
			arguments.thisMapping.process( binder: this, injector: variables.injector );
		} );
		return this;
	}

	/**
	 * Create a mapping to an object
	 *
	 * @alias A single alias or a list or an array of aliases for this mapping. Remember an object can be referred by many names
	 * @force Forces the registration of the mapping in case it already exists
	 */
	Binder function map( required alias, boolean force = false ){
		// Clear out any current mappings
		variables.currentMapping = [];

		// unflatten list
		if ( isSimpleValue( arguments.alias ) ) {
			arguments.alias = listToArray( arguments.alias );
		}

		// first entry
		var name = arguments.alias[ 1 ];

		// check if mapping exists, if so, just use and return.
		if ( structKeyExists( variables.mappings, name ) and !arguments.force ) {
			arrayAppend( variables.currentMapping, variables.mappings[ name ] );
			return this;
		}

		// generate the mapping for the first name passed
		variables.mappings[ name ] = new coldbox.system.ioc.config.Mapping( name );

		// set as the current mapping
		arrayAppend( variables.currentMapping, variables.mappings[ name ] );

		// Set aliases, scopes and types
		variables.mappings[ name ].setAlias( arguments.alias ).setType( this.TYPES.CFC );

		// Loop and create alias references
		for ( var x = 2; x lte arrayLen( arguments.alias ); x++ ) {
			variables.mappings[ arguments.alias[ x ] ] = variables.mappings[ name ];
		}

		return this;
	}

	/**
	 * Create a mapping to an object overwriting any existing registration.
	 *
	 * @alias A single alias or a list or an array of aliases for this mapping. Remember an object can be referred by many names
	 */
	Binder function forceMap( required alias ){
		arguments.force = true;
		return map( argumentCollection = arguments );
	}

	/**
	 * Map to a destination CFC class path.
	 *
	 * @path The class path to the object to map
	 */
	Binder function to( required path ){
		for ( var mapping in variables.currentMapping ) {
			mapping.setPath( arguments.path ).setType( this.TYPES.CFC );
		}
		return this;
	}

	/**
	 * this method lets you use an abstract or parent mapping as a template for other like objects
	 *
	 * @alias The parent class to copy dependencies and definitions from
	 */
	Binder function parent( required alias ){
		// copy parent class's memento instance, exclude alias, name and path
		for ( var mapping in variables.currentMapping ) {
			mapping.processMemento( getMapping( arguments.alias ).getMemento(), "alias,name" );
		}
		return this;
	}

	/**
	 * Map an alias to a factory and its executing method
	 *
	 * @factory The mapping factory reference name
	 * @method  The method to execute
	 */
	Binder function toFactoryMethod( required factory, required method ){
		for ( var mapping in variables.currentMapping ) {
			mapping
				.setType( this.TYPES.FACTORY )
				.setPath( arguments.factory )
				.setMethod( arguments.method );
		}
		return this;
	}

	/**
	 * Map a method argument to a factory method
	 *
	 * @name     The name of the method argument (Not used for: JAVA,WEBSERVICE)
	 * @ref      The reference mapping id this method argument maps to
	 * @dsl      The construction dsl this argument references. If used, the name value must be used.
	 * @value    The explicit value of the method argument, if passed.
	 * @javaCast The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments
	 * @required If the argument is required or not, by default we assume required DI arguments
	 * @type     The type of the argument
	 */
	Binder function methodArg(
		name,
		ref,
		dsl,
		value,
		javaCast,
		required required=true,
		type             = "any"
	){
		for ( var mapping in variables.currentMapping ) {
			mapping.addDIMethodArgument( argumentCollection = arguments );
		}
		return this;
	}

	/**
	 * Map to a java destination class path
	 *
	 * @path The class path to the object to map
	 */
	Binder function toJava( required path ){
		for ( var mapping in variables.currentMapping ) {
			mapping.setPath( arguments.path ).setType( this.TYPES.JAVA );
		}
		return this;
	}

	/**
	 * Map to a webservice destination class path
	 *
	 * @path The webservice path to the object to map
	 */
	Binder function toWebservice( required path ){
		for ( var mapping in variables.currentMapping ) {
			mapping.setPath( arguments.path ).setType( this.TYPES.WEBSERVICE );
		}
		return this;
	}

	/**
	 * Map to an rss destination
	 *
	 * @path The rss path to the object to map
	 */
	Binder function toRSS( required path ){
		for ( var mapping in variables.currentMapping ) {
			mapping.setPath( arguments.path ).setType( this.TYPES.RSS );
		}
		return this;
	}

	/**
	 * Map to a dsl that will be used to create the mapped object
	 *
	 * @dsl The dsl to the object to map
	 */
	Binder function toDSL( required dsl ){
		for ( var mapping in variables.currentMapping ) {
			mapping.setDSL( arguments.dsl ).setType( this.TYPES.DSL );
		}
		return this;
	}

	/**
	 * Map to a provider object that must implement coldbox.system.ioc.IProvider or a closure or UDF
	 *
	 * @provider The provider to map to
	 */
	Binder function toProvider( required provider ){
		for ( var mapping in variables.currentMapping ) {
			mapping.setPath( arguments.provider ).setType( this.TYPES.PROVIDER );
		}
		return this;
	}

	/**
	 * Map to a constant value
	 *
	 * @value The value to bind to
	 */
	Binder function toValue( required value ){
		for ( var mapping in variables.currentMapping ) {
			mapping.setValue( arguments.value ).setType( this.TYPES.CONSTANT );
		}
		return this;
	}

	/**
	 * You can choose what method will be treated as the constructor. By default the value is 'init', so don't call this method if that is the case
	 *
	 * @constructor The constructor method to use for the mapped object
	 */
	Binder function constructor( required constructor ){
		for ( var mapping in variables.currentMapping ) {
			mapping.setConstructor( arguments.constructor );
		}
		return this;
	}

	/**
	 * Positional or named value arguments to use when initializing the mapping. (CFC-only)
	 */
	Binder function initWith(){
		for ( var thisArg in arguments ) {
			for ( var mapping in variables.currentMapping ) {
				mapping.addDIConstructorArgument( name = thisArg, value = arguments[ thisArg ] );
			}
		}
		return this;
	}

	/**
	 * If you call this method on an object mapping, the object's constructor will not be called. By default all constructors are called
	 */
	Binder function noInit(){
		for ( var mapping in variables.currentMapping ) {
			mapping.setAutoInit( false );
		}
		return this;
	}

	/**
	 * Tells WireBox to do a virtual inheritance mixin of the target and this passed mapping
	 *
	 * @mapping The mapping name of CFC to create the virtual inheritance from
	 */
	Binder function virtualInheritance( required mapping ){
		for ( var thisMapping in variables.currentMapping ) {
			thisMapping.setVirtualInheritance( arguments.mapping );
		}
		return this;
	}

	/**
	 * If this method is called, the mapped object will be created once the injector starts up. Basically, not lazy loaded
	 */
	Binder function asEagerInit(){
		for ( var mapping in variables.currentMapping ) {
			mapping.setEagerInit( true );
		}
		return this;
	}

	/**
	 * If you call this method on an object mapping, the object will NOT be inspected for injection/wiring metadata, it will use ONLY whatever you define in the mapping
	 */
	Binder function noAutowire(){
		for ( var mapping in variables.currentMapping ) {
			mapping.setAutowire( false );
		}
		return this;
	}

	/**
	 * Used to set the current working mapping name in place for the mapping DSL. An exception is thrown if the mapping does not exist yet.
	 *
	 * @alias The name of the mapping to set as the current working mapping
	 *
	 * @throws InvalidMappingStateException - If the alias has not been registered yet
	 */
	Binder function with( required alias ){
		// Check if it has been registered yet
		if ( mappingExists( arguments.alias ) ) {
			variables.currentMapping = [ variables.mappings[ arguments.alias ] ];
			return this;
		}
		throw(
			message = "The mapping '#arguments.alias#' has not been registered yet",
			type    = "InvalidMappingStateException"
		);
	}

	/**
	 * Map a constructor argument to a mapping
	 *
	 * @name     The name of the constructor argument (Not used for: JAVA,WEBSERVICE)
	 * @ref      The reference mapping id this constructor argument maps to
	 * @dsl      The construction dsl this argument references. If used, the name value must be used.
	 * @value    The explicit value of the constructor argument, if passed.
	 * @javaCast The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments
	 * @required If the argument is required or not, by default we assume required DI arguments
	 * @type     The type of the argument
	 */
	Binder function initArg(
		name,
		ref,
		dsl,
		value,
		javaCast,
		required required=true,
		type             = "any"
	){
		for ( var mapping in variables.currentMapping ) {
			mapping.addDIConstructorArgument( argumentCollection = arguments );
		}
		return this;
	}

	/**
	 * Map setter injection
	 *
	 * @name     The name of the setter to inject
	 * @ref      The reference mapping id this setter maps to
	 * @dsl      The construction dsl this setter references. If used, the name value must be used.
	 * @value    The explicit value of the setter, if passed.
	 * @javaCast The type of javaCast() to use on the value of the value. Only used if using dsl or ref arguments
	 * @argName  The name of the argument to use, if not passed, we default it to the setter name
	 */
	Binder function setter(
		required name,
		ref,
		dsl,
		value,
		javaCast,
		argName
	){
		for ( var mapping in variables.currentMapping ) {
			mapping.addDISetter( argumentCollection = arguments );
		}
		return this;
	}

	/**
	 * Map property injection
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
	Binder function property(
		required name,
		ref,
		dsl,
		value,
		javaCast,
		scope            = "variables",
		required required=true,
		type             = "any"
	){
		for ( var mapping in variables.currentMapping ) {
			mapping.addDIProperty( argumentCollection = arguments );
		}
		return this;
	}

	/**
	 * The methods to execute once DI completes on the mapping
	 *
	 * @methods A list or an array of methods to execute once the mapping is created, inited and DI has happened.
	 */
	Binder function onDIComplete( required methods ){
		// inflate list
		if ( isSimpleValue( arguments.methods ) ) {
			arguments.methods = listToArray( arguments.methods );
		}
		// store list
		for ( var mapping in variables.currentMapping ) {
			mapping.setOnDIComplete( arguments.methods );
		}
		return this;
	}

	/**
	 * Add a new provider method mapping
	 *
	 * @method  The provided method to override or inject as a provider
	 * @mapping The mapping to provide via the selected method
	 */
	Binder function providerMethod( required method, required mapping ){
		for ( var thisMapping in variables.currentMapping ) {
			thisMapping.addProviderMethod( argumentCollection = arguments );
		}
		return this;
	}

	/**
	 * Map an object into a specific persistence scope
	 *
	 * @scope The scope to map to, use a valid WireBox Scope by using binder.SCOPES.* or a custom scope
	 *
	 * @throws InvalidScopeMapping - Trying to register into an invalid scope
	 */
	Binder function into( required scope ){
		// check if invalid scope
		if (
			NOT this.SCOPES.isValidScope( arguments.scope ) AND NOT structKeyExists(
				variables.customScopes,
				arguments.scope
			)
		) {
			throw(
				message = "Invalid WireBox Scope: '#arguments.scope#'",
				detail  = "Please make sure you are using a valid scope, valid scopes are: #arrayToList( this.SCOPES.getValidScopes() )# AND custom scopes: #structKeyList( variables.customScopes )#",
				type    = "Binder.InvalidScopeMapping"
			);
		}
		for ( var mapping in variables.currentMapping ) {
			mapping.setScope( arguments.scope );
		}
		return this;
	}

	/**
	 * Map as a singleton, shortcut to using 'in( this.SCOPES.SINGLETON )'
	 */
	Binder function asSingleton(){
		return this.into( this.SCOPES.SINGLETON );
	}

	/**
	 * Tells persistence scopes to build, wire, and do onDIComplete() on objects in an isolated lock. This will disallow circular references unless object providers are used.  By default all object's constructors are the only thread safe areas
	 */
	Binder function threadSafe(){
		for ( var mapping in variables.currentMapping ) {
			mapping.setThreadSafe( true );
		}
		return this;
	}

	/**
	 * This is the default wiring of objects that allow circular dependencies.  By default all object's constructors are the only thread safe areas
	 */
	Binder function notThreadSafe(){
		for ( var mapping in variables.currentMapping ) {
			mapping.setThreadSafe( false );
		}
		return this;
	}

	/**
	 * This is a closure that will be able to influence the creation of the instance
	 *
	 * @influenceClosure The closure to use for influencing constructions
	 */
	Binder function withInfluence( required influenceClosure ){
		for ( var mapping in variables.currentMapping ) {
			mapping.setInfluenceClosure( arguments.influenceClosure );
		}
		return this;
	}

	/**
	 * Adds a structure of metadata to be stored with the mapping for later retrieval by the developer in events, manually or builders
	 *
	 * @data The data structure to store with the mapping
	 */
	Binder function extraAttributes( required struct data ){
		for ( var mapping in variables.currentMapping ) {
			mapping.setExtraAttributes( arguments.data );
		}
		return this;
	}

	/**
	 * Adds one, a list or an array of UDF templates to mixin to a CFC
	 *
	 * @mixins The udf include location(s) to mixin at runtime
	 */
	Binder function mixins( required mixins ){
		if ( isSimpleValue( arguments.mixins ) ) {
			arguments.mixins = listToArray( arguments.mixins );
		}
		for ( var mapping in variables.currentMapping ) {
			mapping.setMixins( arguments.mixins );
		}
		return this;
	}

	/**
	 * Link a parent injector to this configuration binder
	 *
	 * @injector A parent injector to link
	 */
	Binder function parentInjector( required injector ){
		variables.oParentInjector = arguments.injector;
		return this;
	}

	/**
	 * Configure the stop recursion classes
	 *
	 * @classes A list or array of classes to use so the injector can stop when looking for dependencies in inheritance chains
	 */
	Binder function stopRecursions( required classes ){
		// inflate incoming locations
		if ( isSimpleValue( arguments.classes ) ) {
			arguments.classes = listToArray( arguments.classes );
		}
		// Save them
		variables.aStopRecursions = arguments.classes;

		return this;
	}

	/**
	 * Use to define injector scope registration
	 *
	 * @enabled Enable registration or not (defaults=false) Boolean
	 * @scope   The scope to register on, defaults to application scope
	 * @key     The key to use in the scope, defaults to wireBox
	 */
	Binder function scopeRegistration(
		boolean enabled = variables.DEFAULTS.scopeRegistration.enabled,
		scope           = variables.DEFAULTS.scopeRegistration.scope,
		key             = variables.DEFAULTS.scopeRegistration.key
	){
		structAppend( variables.scopeRegistration, arguments, true );
		return this;
	}

	/**
	 * Register one or more package scan locations for CFC lookups
	 *
	 * @locations A list or array of locations to add to package scanning.e.g.: ['coldbox','com.myapp','transfer']
	 */
	Binder function scanLocations( required locations ){
		// inflate incoming locations
		if ( isSimpleValue( arguments.locations ) ) {
			arguments.locations = listToArray( arguments.locations );
		}
		// Process locations
		arguments.locations
			.filter( function( thisLocation ){
				return (
					!structKeyExists( variables.scanLocations, arguments.thisLocation )
					AND
					len( arguments.thisLocation )
				);
			} )
			.each( function( thisLocation ){
				// Process creation path & Absolute Path
				variables.scanLocations[ thisLocation ] = expandPath(
					"/" & replace( thisLocation, ".", "/", "all" ) & "/"
				);
			} );

		return this;
	}

	/**
	 * Try to remove all the scan locations passed in
	 *
	 * @locations Locations to remove from the lookup. A list or array of locations
	 */
	function removeScanLocations( required locations ){
		// inflate incoming locations
		if ( isSimpleValue( arguments.locations ) ) {
			arguments.locations = listToArray( arguments.locations );
		}

		// Loop and remove
		arguments.locations.each( function( thisLocation ){
			structDelete( variables.scanLocations, thisLocation );
		} );
	}

	/**
	 * Configure CacheBox operations
	 *
	 * @configFile     The configuration file to use for loading CacheBox if creating it
	 * @cacheFactory   The CacheBox cache factory instance to link WireBox to
	 * @enabled        Enable or Disable CacheBox Integration, if you call this method then enabled is set to true as most likely you are trying to enable it
	 * @classNamespace The package namespace to use for creating or connecting to CacheBox. Defaults to: coldbox.system.cache
	 */
	Binder function cachebox(
		configFile      = "",
		cacheFactory    = "",
		boolean enabled = true,
		classNamespace  = variables.DEFAULTS.cachebox.classNamespace
	){
		structAppend( variables.cacheBox, arguments, true );
		return this;
	}

	/**
	 * Alias to get cachebox configuration
	 *
	 * @deprecated Remove by v7: use getCacheBox() instead
	 */
	struct function getCacheBoxConfig(){
		return variables.cachebox;
	}

	/**
	 * Map an object into CacheBox
	 *
	 * @key               You can override the key it will use for storing in cache. By default it uses the name of the mapping
	 * @timeout           Object Timeout, else defaults to whatever the default is in the chosen cache
	 * @lastAccessTimeout Object Timeout, else defaults to whatever the default is in the chosen cache
	 * @provider          Uses the 'default' cache provider by default
	 */
	Binder function inCacheBox(
		key               = "",
		timeout           = "",
		lastAccessTimeout = "",
		provider          = "default"
	){
		for ( var mapping in variables.currentMapping ) {
			// if key not passed, build a mapping name
			if ( NOT len( arguments.key ) ) {
				if ( len( mapping.getPath() ) ) {
					arguments.key = "wirebox-#mapping.getPath()#";
				} else {
					arguments.key = "wirebox-#mapping.getName()#";
				}
			}
			// store the mapping info.
			mapping.setScope( this.SCOPES.CACHEBOX ).setCacheProperties( argumentCollection = arguments );
		}

		return this;
	}

	/**
	 * Register a new custom dsl namespace
	 *
	 * @namespace The namespace you would like to register
	 * @path      The instantiation path to the CFC that implements this scope, it must have an init() method and implement: coldbox.system.ioc.dsl.IDSLBuilder
	 */
	Binder function mapDSL( required namespace, required path ){
		variables.customDSL[ arguments.namespace ] = arguments.path;
		return this;
	}

	/**
	 * Register a new WireBox custom scope
	 *
	 * @annotation The unique scope name to register. This translates to an annotation value on CFCs
	 * @path       The path to the CFC that implements this scope, it must have an init() method and implement: coldbox.system.ioc.scopes.IScope
	 */
	Binder function mapScope( required annotation, required path ){
		variables.customScopes[ arguments.annotation ] = arguments.path;
		return this;
	}

	/**
	 * Set the logBox Configuration to use
	 *
	 * @config The logbox configuration struct
	 */
	Binder function logBoxConfig( required config ){
		variables.logBoxConfig = arguments.config;
		return this;
	}

	/**
	 * Load a data configuration CFCs data DSL into this configuration
	 *
	 * @rawDSL The data configuration DSL structure to load, else look internally
	 */
	Binder function loadDataDSL( struct rawDSL ){
		var wireBoxDSL = variables.wirebox;

		// Coldbox Context Attached
		if ( isObject( variables.coldbox ) ) {
			// create scan location for model convention as the first one.
			this.scanLocations( variables.coldbox.getSetting( "ModelsInvocationPath" ) );
		}

		// Incoming raw DSL or use locally?
		if ( !isNull( arguments.rawDSL ) ) {
			wireBoxDSL = arguments.rawDSL;
		}

		// Register LogBox Configuration
		if ( structKeyExists( wireBoxDSL, "logBoxConfig" ) ) {
			variables.logBoxConfig = wireBoxDSL.logBoxConfig;
		}

		// Register Parent Injector
		if ( structKeyExists( wireBoxDSL, "parentInjector" ) ) {
			variables.oParentInjector = wireBoxDSL.parentInjector;
		}

		// Register Server Scope Registration
		if ( structKeyExists( wireBoxDSL, "scopeRegistration" ) ) {
			this.scopeRegistration( argumentCollection = wireBoxDSL.scopeRegistration );
		}

		// Register CacheBox
		if ( structKeyExists( wireBoxDSL, "cacheBox" ) ) {
			this.cacheBox( argumentCollection = wireBoxDSL.cacheBox );
		}

		// Register metadataCache
		if ( structKeyExists( wireBoxDSL, "metadataCache" ) ) {
			variables.metadataCache = wireBoxDSL.metadataCache;
		}

		// Register Custom DSL
		if ( structKeyExists( wireBoxDSL, "customDSL" ) ) {
			structAppend(
				variables.customDSL,
				wireBoxDSL.customDSL,
				true
			);
		}

		// Register Custom Scopes
		if ( structKeyExists( wireBoxDSL, "customScopes" ) ) {
			structAppend(
				variables.customScopes,
				wireBoxDSL.customScopes,
				true
			);
		}

		// Append Register Scan Locations
		if ( structKeyExists( wireBoxDSL, "scanLocations" ) ) {
			this.scanLocations( wireBoxDSL.scanLocations );
		}

		// Append Register Stop Recursions
		if ( structKeyExists( wireBoxDSL, "stopRecursions" ) ) {
			this.stopRecursions( wireBoxDSL.stopRecursions );
		}

		// Register listeners
		if ( structKeyExists( wireBoxDSL, "listeners" ) ) {
			for ( var thisListener in wireboxDSL.listeners ) {
				this.listener( argumentCollection = thisListener );
			}
		}

		// Register Mappings
		if ( structKeyExists( wireBoxDSL, "mappings" ) ) {
			// iterate and register
			for ( var key in wireboxDSL.mappings ) {
				// create mapping & process its data memento
				map( key );
				variables.mappings[ key ].processMemento( wireBoxDSL.mappings[ key ] );
			}
		}

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
	 * Discover all eager inits in the Binder and build them.
	 */
	Binder function processEagerInits(){
		variables.mappings
			.filter( function( key, thisMapping ){
				return ( arguments.thisMapping.isEagerInit() );
			} )
			.each( function( key, thisMapping ){
				variables.injector.getInstance( arguments.thisMapping.getName() );
			} );

		return this;
	}

	/**
	 * Process all registered mappings, called by injector when ready to start serving requests
	 * Processing means that we will iterate over all NON discovered mappings and call each
	 * mapping's `process()` method so all metadata can be read and registered.
	 */
	Binder function processMappings(){
		var mappingError = "";

		variables.mappings
			.filter( function( key, thisMapping ){
				return ( !arguments.thisMapping.isDiscovered() );
			} )
			.each( function( key, thisMapping ){
				try {
					// process the metadata
					arguments.thisMapping.process( binder = this, injector = variables.injector );
				} catch ( any e ) {
					// Remove bad mapping
					variables.mappings.delete( key );
					mappingError = e;
				}
			} );

		// Verify exceptions
		if ( !isSimpleValue( mappingError ) ) {
			throw( object = mappingError );
		}

		return this;
	}

	/**
	 * Add a new listener configuration
	 *
	 * @class      The class of the listener
	 * @properties The structure of properties for the listener
	 * @name       The name of the listener
	 * @register   If true, registers the listener right away
	 */
	Binder function listener(
		required class,
		struct properties = {},
		name              = "",
		boolean register  = false
	){
		// Name check?
		if ( NOT len( arguments.name ) ) {
			arguments.name = listLast( arguments.class, "." );
		}

		// add listener
		arrayAppend( variables.listeners, arguments );

		if ( arguments.register ) {
			getInjector().registerListener( arguments );
		}

		return this;
	}

	/**
	 * --------------------------------------------------
	 * AOP Mapping Methods
	 * --------------------------------------------------
	 */

	/**
	 * Map a new aspect
	 *
	 * @aspect      The name or aliases of the aspect
	 * @autoBinding Allow autobinding of this aspect or not? Defaults to true
	 */
	Binder function mapAspect( required aspect, boolean autoBinding = true ){
		// map the aspect
		map( arguments.aspect ).asEagerInit().asSingleton();

		// register the aspect
		for ( var mapping in variables.currentMapping ) {
			mapping.setAspect( true ).setAspectAutoBinding( arguments.autoBinding );
		}

		return this;
	}

	/**
	 * Create a new matcher class for usage in class or method matching
	 *
	 * @return coldbox.system.aop.Matcher
	 */
	function match(){
		return new coldbox.system.aop.Matcher();
	}

	/**
	 * Bind a aspects to classes and methods
	 *
	 * @classes The class matcher that will be affected with this aspect binding
	 * @methods The method matcher that will be affected with this aspect binding
	 * @aspects The name or list of names or array of names of aspects to apply to the classes and method matchers
	 */
	Binder function bindAspect(
		required classes,
		required methods,
		required aspects
	){
		// cleanup aspect
		if ( isSimpleValue( arguments.aspects ) ) {
			arguments.aspects = listToArray( arguments.aspects );
		}
		// register it
		arrayAppend( variables.aspectBindings, arguments );

		return this;
	}

}
