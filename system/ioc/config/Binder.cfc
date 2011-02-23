<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This is a WireBox configuration binder object.  You can use it to configure
	a WireBox injector instance using our WireBox Mapping DSL.
	This binder will hold all your object mappings, injector settings and more.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="This is a WireBox configuration binder object.  You can use it to configure a WireBox injector instance using our WireBox Mapping DSL">

	<cfscript>
		// Available WireBox public scopes
		this.SCOPES = createObject("component","coldbox.system.ioc.Scopes");
		// Available WireBox public types
		this.TYPES = createObject("component","coldbox.system.ioc.Types");
		// Internal Utility class
		utility  	= createObject("component","coldbox.system.core.util.Util");
		// Temp Mapping positional mover
		currentMapping = "";
		// Instance private scope
		instance = {};
		// WireBox Defaults
		DEFAULTS = {
			//LogBox Defaults
			logBoxConfig = "coldbox.system.ioc.config.LogBox",
			// Scope Defaults
			scopeRegistration = {
				enabled = false,
				scope = "application",
				key = "wireBox"
			},
			// CacheBox Integration Defaults
			cacheBox = {
				enabled = false,
				configFile = "",
				cacheFactory = "",
				classNamespace = "coldbox.system.cache"
			}
		};
		// Startup the configuration
		reset();
	</cfscript>
	
	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="Binder" hint="Constructor: You can pass a data CFC instance, data CFC path or nothing at all for purely programmatic configuration">
		<cfargument name="injector" 	required="true" 	hint="The Injector this binder is bound to" colddoc:generic="coldbox.system.ioc.Injector">
		<cfargument name="config" 		required="false" 	hint="The WireBox Injector Data Configuration CFC instance or instantiation path to it. Leave blank if using this configuration object programatically"/>
		<cfargument name="properties" 	required="false" 	default="#structNew()#" hint="A structure of binding properties to passthrough to the Binder Configuration CFC" colddoc:generic="struct">
		<cfscript>
			// Setup incoming properties
			instance.properties = arguments.properties;
			// Setup Injector this binder is bound to.
			instance.injector = arguments.injector;
			// ColdBox Context binding if any?
			instance.coldbox = instance.injector.getColdBox();
			// is coldbox linked
			if( isObject(instance.coldbox) ){
				variables.appMapping = instance.coldbox.getSetting("AppMapping");
			}
			
			// If sent and a path, then create the data CFC
			if( structKeyExists(arguments, "config") and isSimpleValue(arguments.config) ){
				arguments.config = createObject("component",arguments.config);
			}
			
			// If sent and a data CFC instance
			if( structKeyExists(arguments,"config") and isObject(arguments.config) ){
				// Decorate our data CFC
				arguments.config.getPropertyMixin = utility.getMixerUtil().getPropertyMixin;
				// Execute the configuration
				arguments.config.configure(this);
				// Load the raw data DSL
				loadDataDSL( arguments.config.getPropertyMixin("wireBox","variables",structnew()) );
			}
			
			return this;
		</cfscript>
	</cffunction>

	<!--- getInjector --->
    <cffunction name="getInjector" output="false" access="public" returntype="any" hint="Get the bounded injector for this binder" colddoc:generic="coldbox.system.ioc.Injector">
    	<cfreturn instance.injector>
    </cffunction>
	
	<!--- getColdBox --->
    <cffunction name="getColdBox" output="false" access="public" returntype="any" hint="Get the bounded ColdBox context for this binder, if any" colddoc:generic="coldbox.system.web.Controller">
    	<cfreturn instance.coldbox>
    </cffunction>
	
	<!--- getAppMapping --->
    <cffunction name="getAppMapping" output="false" access="public" returntype="any" hint="Get the ColdBox app mapping variable if context linked">
    	<cfreturn instance.coldbox.getSetting("AppMapping")>
    </cffunction>

	<!--- configure --->
    <cffunction name="configure" output="false" access="public" returntype="any" hint="The main configuration method that must be overriden by a specific WireBox Binder configuration object">
    	<!--- Usually implemented by concrete classes of this Binder --->
    </cffunction>

	<!--- reset --->
	<cffunction name="reset" output="false" access="public" returntype="void" hint="Reset the configuration back to the original binder defaults">
		<cfscript>
			// Main wirebox structure
			variables.wirebox = {};
			// logBox File
			instance.logBoxConfig = DEFAULTS.logBoxConfig;
			// CacheBox integration
			instance.cacheBox = DEFAULTS.cacheBox;
			// Listeners
			instance.listeners = [];
			// Scope Registration
			instance.scopeRegistration = DEFAULTS.scopeRegistration;
			// Custom DSL namespaces
			instance.customDSL = {};
			// Custom Storage Scopes
			instance.customScopes = {};
			// Package Scan Locations
			instance.scanLocations = createObject("java","java.util.LinkedHashMap").init(5);
			// Object Mappings
			instance.mappings = {};
			// Parent Injector Mapping
			instance.parentInjector = "";
			// Binding Properties
			instance.properties = {};
			// Stop Recursion classes
			instance.stopRecursions = [];
		</cfscript>
	</cffunction>

<!------------------------------------------- BINDING PROPERTIES ------------------------------------------>

	<!--- getProperties --->
    <cffunction name="getProperties" output="false" access="public" returntype="any" hint="Get the binded properties structure" colddoc:generic="struct">
    	<cfreturn instance.properties>
    </cffunction>
	
	<!--- setProperties --->
    <cffunction name="setProperties" output="false" access="public" returntype="any" hint="Set the binded properties structure">
    	<cfargument name="properties" required="true" colddoc:generic="struct"/>
		<cfset instance.properties = arguments.properties>
		<cfreturn this>
    </cffunction>
	
	<!--- getProperty --->
    <cffunction name="getProperty" output="false" access="public" returntype="any" hint="Get a binded property. If not found it will try to return the default value passed, else it returns an exception">
    	<cfargument name="name" 	required="true" hint="The name of the property"/>
		<cfargument name="default"	required="false" hint="A default value if property does not exist"/>
		<cfscript>
			if( propertyExists(arguments.name) ){
				return instance.properties[arguments.name];
			}
			if( structKeyExists(arguments,"default") ){
				return arguments.default;
			}
		</cfscript>
		<cfthrow message="The property requested #arguments.name# was not found"
				 detail="Properties defined are #structKeyList(instance.properties)#"
				 type="Binder.PropertyNotFoundException">
    </cffunction>
	
	<!--- setProperty --->
    <cffunction name="setProperty" output="false" access="public" returntype="void" hint="Create a new binding property">
    	<cfargument name="name" 	required="true" hint="The name of the property"/>
		<cfargument name="value" 	required="true" hint="The value of the property"/>
		<cfset instance.properties[arguments.name] = arguments.value>
    </cffunction>

	<!--- propertyExists --->
    <cffunction name="propertyExists" output="false" access="public" returntype="boolean" hint="Checks if a property exists">
    	<cfargument name="name" required="true" hint="The name of the property"/>
		<cfreturn structKeyExists(instance.properties, arguments.name)>
    </cffunction>

<!------------------------------------------- PARENT INJECTOR ------------------------------------------>
	
	<!--- getParentInjector --->
    <cffunction name="getParentInjector" output="false" access="public" returntype="any" hint="Get the parent injector reference this binder is linked to">
    	<cfreturn instance.parentInjector>
    </cffunction>
	
	<!--- parentInjector --->
    <cffunction name="parentInjector" output="false" access="public" returntype="any" hint="Link a parent injector to this configuration binder">
    	<cfargument name="injector" required="true" hint="A parent injector to configure link"/>
		<cfset instance.parentInjector = arguments.injector>
		<cfreturn this>
    </cffunction>

<!------------------------------------------- MAPPING METHODS ------------------------------------------>
	
	<!--- getMappings --->
    <cffunction name="getMappings" output="false" access="public" returntype="any" hint="Get all the registered object mappings structure" colddoc:generic="struct">
    	<cfreturn instance.mappings>
    </cffunction>
	
	<!--- getMapping --->
    <cffunction name="getMapping" output="false" access="public" returntype="any" hint="Get a specific object mapping: coldbox.system.ioc.config.Mapping" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfargument name="name" required="true" hint="The name of the mapping to retrieve"/>
    	
		<cfif NOT structKeyExists(instance.mappings, arguments.name)>
    		<cfthrow message="Mapping #arguments.name# has not been registered"
					 detail="Registered mappings are: #structKeyList(instance.mappings)#"
					 type="Binder.MappingNotFoundException" >
    	</cfif>
		
		<cfreturn instance.mappings[arguments.name]>
    </cffunction>

	<!--- mappingExists --->
    <cffunction name="mappingExists" output="false" access="public" returntype="any" hint="Check if an object mapping exists" colddoc:generic="Boolean">
    	<cfargument name="name" required="true" hint="The name of the mapping to verify"/>
    	<cfreturn structKeyExists(instance.mappings, arguments.name)>
    </cffunction>

<!------------------------------------------- MAPPING DSL ------------------------------------------>

	<!--- mapPath --->
    <cffunction name="mapPath" output="false" access="public" returntype="any" hint="Directly map to a path by using the last part of the path as the alias. This is equivalent to map('MyService').to('model.MyService'). Only use if the name of the alias is the same as the last part of the path.">
    	<cfargument name="path" required="true" hint="The class path to the object to map"/>
		<cfscript>
			// directly map to a path
			return map( listlast(arguments.path,".") ).to(arguments.path);
		</cfscript>
    </cffunction>
	
	<!--- mapDirectory --->
    <cffunction name="mapDirectory" output="false" access="public" returntype="any" hint="Maps an entire instantiation path directory, please note that the unique name of each file will be used and also processed for alias inspection">
    	<cfargument name="packagePath" required="true" hint="The instantiation packagePath to map"/>
		<cfscript>
			var directory 		= expandPath("/#replace(arguments.packagePath,".","/","all")#");
			var qObjects		= "";
			var thisTargetPath 	= "";
		</cfscript>
		
		<!--- check directory --->
		<cfif NOT directoryExists(directory)>
			<cfthrow message="Directory does not exist" detail="Directory: #directory#" type="Binder.DirectoryNotFoundException">
		</cfif>
		
		<!--- Get directory listing --->
		<cfdirectory action="list" directory="#directory#" filter="*.cfc" recurse="true" listinfo="name" name="qObjects">
		
		<!--- Loop and Register --->
		<cfloop query="qObjects">
			<!--- Remove .cfc and /\ with . notation--->
			<cfset thisTargetPath = arguments.packagePath & "." & reReplace( replaceNoCase(qObjects.name,".cfc","") ,"(/|\\)",".","all")>
			<!--- Map the Path --->
			<cfset mapPath( thisTargetPath )>
		</cfloop>
		
		<cfreturn this>
    </cffunction>
	
	<!--- map --->
    <cffunction name="map" output="false" access="public" returntype="any" hint="Create a mapping to an object">
    	<cfargument name="alias" required="true" hint="A single alias or a list or an array of aliases for this mapping. Remember an object can be refered by many names"/>
		<cfscript>
			// generate mapping entry for this dude.
			var name 	= "";
			var x		= 1;
			var cAlias	= "";
			
			// unflatten list
			if( isSimpleValue( arguments.alias ) ){ arguments.alias = listToArray(arguments.alias); }
			
			// first entry
			name = arguments.alias[1];
			
			// generate the mapping for the first name passed
			instance.mappings[ name ] = createObject("component","coldbox.system.ioc.config.Mapping").init( name );
			
			// set the current mapping
			currentMapping = instance.mappings[ name ];
			
			// Set aliases, scopes and types
			instance.mappings[ name ]
				.setAlias( arguments.alias )
				.setScope( this.SCOPES.NOSCOPE )
				.setType( this.TYPES.CFC );
			
			// Loop and create alias references
			for(x=2;x lte arrayLen(arguments.alias); x++){
				instance.mappings[ arguments.alias[x] ] = instance.mappings[ name ];
			}
			
			return this;
		</cfscript>    	
    </cffunction>
	
	<!--- to --->
    <cffunction name="to" output="false" access="public" returntype="any" hint="Map to a destination CFC class path.">
    	<cfargument name="path" required="true" hint="The class path to the object to map"/>
		<cfscript>
			currentMapping.setPath( arguments.path ).setType( this.TYPES.CFC );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- toFactoryMethod --->
    <cffunction name="toFactoryMethod" output="false" access="public" returntype="any" hint="Map to a factory and its executing method.">
    	<cfargument name="factory" 	required="true" hint="The mapping factory reference name"/>
		<cfargument name="method" 	required="true" hint="The method to execute"/>
		<cfscript>
			currentMapping.setType( this.TYPES.FACTORY ).setPath( arguments.factory ).setMethod( arguments.method );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- methodArg --->
    <cffunction name="methodArg" output="false" access="public" returntype="any" hint="Map a method argument to a factory method">
    	<cfargument name="name" 	required="false" hint="The name of the argument"/>
		<cfargument name="ref" 		required="false" hint="The reference mapping id this method argument maps to"/>
		<cfargument name="dsl" 		required="false" hint="The construction dsl this argument references. If used, the name value must be used."/>
		<cfargument name="value" 	required="false" hint="The value of the constructor argument, if passed."/>
    	<cfargument name="javaCast" required="false" hint="The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments"/>
    	<cfscript>
    		currentMapping.addDIMethodArgument(argumentCollection=arguments);
    		return this;
    	</cfscript>
    </cffunction>
	
	<!--- toJava --->
    <cffunction name="toJava" output="false" access="public" returntype="any" hint="Map to a java destination class path.">
    	<cfargument name="path" required="true" hint="The class path to the object to map"/>
		<cfscript>
			currentMapping.setPath( arguments.path ).setType( this.TYPES.JAVA );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- toWebservice --->
    <cffunction name="toWebservice" output="false" access="public" returntype="any" hint="Map to a webservice destination class path.">
    	<cfargument name="path" required="true" hint="The class path to the object to map"/>
		<cfscript>
    		currentMapping.setPath( arguments.path ).setType( this.TYPES.WEBSERVICE );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- toRSS --->
    <cffunction name="toRSS" output="false" access="public" returntype="any" hint="Map to a rss destination class path.">
    	<cfargument name="path" required="true" hint="The class path to the object to map"/>
		<cfscript>
    		currentMapping.setPath( arguments.path ).setType( this.TYPES.RSS );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- toDSL --->
    <cffunction name="toDSL" output="false" access="public" returntype="any" hint="Map to a dsl that will be used to create the mapped object">
    	<cfargument name="dsl" required="true" hint="The DSL string to use"/>
		<cfscript>
			currentMapping.setDSL( arguments.dsl ).setType( this.TYPES.DSL );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- toProvider --->
    <cffunction name="toProvider" output="false" access="public" returntype="any" hint="Map to a provider object that must implement coldbox.system.ioc.IProvider">
    	<cfargument name="provider" required="true" hint="The provider to map to"/>
		<cfscript>
			currentMapping.setPath( arguments.provider ).setType( this.TYPES.PROVIDER );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- toValue --->
    <cffunction name="toValue" output="false" access="public" returntype="any" hint="Map to a constant value">
    	<cfargument name="value" required="true" hint="The value to bind to"/>
		<cfscript>
			currentMapping.setValue( arguments.value ).setType( this.TYPES.CONSTANT );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- constructor --->
    <cffunction name="constructor" output="false" access="public" returntype="any" hint="You can choose what method will be treated as the constructor. By default the value is 'init', so don't call this method if that is the case.">
    	<cfargument name="constructor" required="true" hint="The constructor method to use for the mapped object"/>
   		<cfscript>
    		currentMapping.setConstructor( arguments.constructor );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- initWith --->
    <cffunction name="initWith" output="false" access="public" returntype="any" hint="Positional or named value arguments to use when initializing the mapping. (CFC-only)">
    	<cfscript>
    		var key = "";
    		for(key in arguments){
				currentMapping.addDIConstructorArgument(name=key,value=arguments[key]);
			}
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- noInit --->
    <cffunction name="noInit" output="false" access="public" returntype="any" hint="If you call this method on an object mapping, the object's constructor will not be called. By default all constructors are called.">
    	<cfscript>
    		currentMapping.setAutoInit( false );
			return this;
    	</cfscript>
    </cffunction>

	<!--- asEagerInit --->
    <cffunction name="asEagerInit" output="false" access="public" returntype="any" hint="If this method is called, the mapped object will be created once the injector starts up. Basically, not lazy loaded">
    	<cfscript>
    		currentMapping.setEagerInit( true );
			return this;
    	</cfscript>
    </cffunction>

	<!--- noAutowire --->
    <cffunction name="noAutowire" output="false" access="public" returntype="any" hint="If you call this method on an object mapping, the object will NOT be inspected for injection/wiring metadata, it will use ONLY whatever you define in the mapping.">
    	<cfscript>
    		currentMapping.setAutowire( false );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- with --->
    <cffunction name="with" output="false" access="public" returntype="any" hint="Used to set the current working mapping name in place for the maping DSL. An exception is thrown if the mapping does not exist yet.">
    	<cfargument name="alias" required="true" hint="The name of the maping to set as current for working with it via the mapping DSL"/>
		<cfscript>
			if( mappingExists(arguments.alias) ){
				currentMapping = instance.mappings[arguments.alias];
				return this;
			}
			utility.throwit(message="The mapping '#arguments.alias# has not been initialized yet.'",
							detail="Please use the map('#arguments.alias#') first to start working with a mapping",
							type="Binder.InvalidMappingStateException");
		</cfscript>
    </cffunction>
	
	<!--- initArg --->
    <cffunction name="initArg" output="false" access="public" returntype="any" hint="Map a constructor argument to a mapping">
    	<cfargument name="name" 	required="false" hint="The name of the constructor argument. NA: JAVA-WEBSERVICE"/>
		<cfargument name="ref" 		required="false" hint="The reference mapping id this constructor argument maps to"/>
		<cfargument name="dsl" 		required="false" hint="The construction dsl this argument references. If used, the name value must be used."/>
		<cfargument name="value" 	required="false" hint="The value of the constructor argument, if passed."/>
    	<cfargument name="javaCast" required="false" hint="The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments"/>
    	<cfscript>
    		currentMapping.addDIConstructorArgument(argumentCollection=arguments);
    		return this;
    	</cfscript>
    </cffunction>
	
	<!--- setter --->
    <cffunction name="setter" output="false" access="public" returntype="any" hint="Map a setter function to a mapping">
    	<cfargument name="name" 	required="true"  hint="The name of the setter method (without 'set')."/>
		<cfargument name="ref" 		required="false" hint="The reference mapping object this setter method will receive"/>
		<cfargument name="dsl" 		required="false" hint="The construction dsl this setter method will receive"/>
		<cfargument name="value" 	required="false" hint="The value to pass into the setter method."/>
    	<cfargument name="javaCast" required="false" hint="The type of javaCast() to use on the value. Only used if using dsl or ref arguments"/>
    	<cfscript>
    		currentMapping.addDISetter(argumentCollection=arguments);
    		return this;
    	</cfscript>
    </cffunction>
		
	<!--- property --->
    <cffunction name="property" output="false" access="public" returntype="any" hint="Map a cfproperty to a mapping">
    	<cfargument name="name" 	required="true"  hint="The name of the cfproperty to inject into"/>
		<cfargument name="ref" 		required="false" hint="The reference mapping id this property maps to"/>
		<cfargument name="dsl" 		required="false" hint="The construction dsl this property references. If used, the name value must be used."/>
		<cfargument name="value" 	required="false" hint="The value of the property, if passed."/>
    	<cfargument name="javaCast" required="false" hint="The type of javaCast() to use on the value of the property. Only used if using dsl or ref arguments"/>
    	<cfargument name="scope" 	required="false" default="variables" hint="The scope in the CFC to inject the property to. By default it will inject it to the variables scope"/>
    	<cfscript>
    		currentMapping.addDIProperty(argumentCollection=arguments);
    		return this;
    	</cfscript>
    </cffunction>
	
	<!--- onDIComplete --->
    <cffunction name="onDIComplete" output="false" access="public" returntype="any" hint="The methods to execute once DI completes on the mapping">
    	<cfargument name="methods" required="true" hint="A list or an array of methods to execute once the mapping is created, inited and DI has happened."/>
    	<cfscript>
    		//inflate list
			if( isSimpleValue(arguments.methods) ){ arguments.methods = listToArray(arguments.methods); }
			// store list
			currentMapping.setOnDIComplete( arguments.methods );
			return this;
		</cfscript>
    </cffunction>
	
	<!--- into --->
    <cffunction name="into" output="false" access="public" returntype="any" hint="Map an object into a specific persistence scope">
    	<cfargument name="scope" required="true" hint="The scope to map to, use a valid WireBox Scope by using binder.SCOPES.* or a custom scope" >
    	<cfscript>
    		// check if invalid scope
			if( NOT this.SCOPES.isValidScope(arguments.scope) AND NOT structKeyExists(instance.customScopes,arguments.scope) ){
				utility.throwit(message="Invalid WireBox Scope: '#arguments.scope#'",
								detail="Please make sure you are using a valid scope, valid scopes are: #arrayToList(this.SCOPES.getValidScopes())# AND custom scopes: #structKeyList(instance.customScopes)#",
								type="Binder.InvalidScopeMapping");
			}
			currentMapping.setScope( arguments.scope );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- singleton shortcut --->
    <cffunction name="asSingleton" output="false" access="public" returntype="any" hint="Map as a singleton, shortcut to using 'in( this.SCOPES.SINGLETON )'">
    	<cfscript>
    		return this.into( this.SCOPES.SINGLETON );
		</cfscript>
    </cffunction>

<!------------------------------------------- STOP RECURSIONS ------------------------------------------>

	<!--- getStopRecursions --->
    <cffunction name="getStopRecursions" output="false" access="public" returntype="any" hint="Get all the stop recursion classes array" colddoc:generic="Array">
    	<cfreturn instance.stopRecursions>
    </cffunction>
	
	<!--- stopRecursions --->
    <cffunction name="stopRecursions" output="false" access="public" returntype="any" hint="Configure the stop recursion classes">
    	<cfargument name="classes" required="true" hint="A list or array of classes to use so the injector can stop when looking for dependencies in inheritance chains"/>
   		<cfscript>
    		// inflate incoming locations
   			if( isSimpleValue(arguments.classes) ){ arguments.classes = listToArray(arguments.classes); }
			// Save them
			instance.stopRecursions = arguments.classes;
			
			return this;
		</cfscript>
    </cffunction>

<!------------------------------------------- SCOPE REGISTRATION ------------------------------------------>
	
	<!--- scopeRegistration --->
    <cffunction name="scopeRegistration" output="false" access="public" returntype="any" hint="Use to define injector scope registration">
    	<cfargument name="enabled" 	required="false" default="#DEFAULTS.scopeRegistration.enabled#" hint="Enable registration or not (defaults=false) Boolean" colddoc:generic="Boolean" />
		<cfargument name="scope" 	required="false" default="#DEFAULTS.scopeRegistration.scope#" hint="The scope to register on, defaults to application scope"/>
		<cfargument name="key" 		required="false" default="#DEFAULTS.scopeRegistration.key#" hint="The key to use in the scope, defaults to wireBox"/>
		<cfset structAppend( instance.scopeRegistration, arguments, true)>
		<cfreturn this>
    </cffunction>

	<!--- getScopeRegistration --->
    <cffunction name="getScopeRegistration" output="false" access="public" returntype="any" hint="Get the scope registration details structure" colddoc:generic="Struct">
    	<cfreturn instance.scopeRegistration>
    </cffunction>
				
<!------------------------------------------- SCAN LOCATIONS ------------------------------------------>
		
	<!--- getScanLocations --->
    <cffunction name="getScanLocations" output="false" access="public" returntype="any" hint="Get the linked map of package scan locations for CFCs" colddoc:generic="java.util.LinkedHashMap">
    	<cfreturn instance.scanLocations>
    </cffunction>
	
	<!--- scanLocations --->
    <cffunction name="scanLocations" output="false" access="public" returntype="any" hint="Register one or more package scan locations for CFC lookups">
    	<cfargument name="locations" required="true" hint="A list or array of locations to add to package scanning.e.g.: ['coldbox','com.myapp','transfer']"/>
   		<cfscript>
   			var x = 1;
			
   			// inflate incoming locations
   			if( isSimpleValue(arguments.locations) ){ arguments.locations = listToArray(arguments.locations); }
			
			// Prepare Locations
			for(x=1; x lte arrayLen(arguments.locations); x++){
				// Validate it is not registered already
				if ( NOT structKeyExists(instance.scanLocations, arguments.locations[x]) ){
					// Process creation path & Absolute Path
					instance.scanLocations[ arguments.locations[x] ] = expandPath( "/" & replace(arguments.locations[x],".","/","all") & "/" );
				}
			}
			
			return this;
		</cfscript>
    </cffunction>
	
	<!--- removeScanLocations --->
	<cffunction name="removeScanLocations" output="false" access="public" returntype="void" hint="Try to remove all the scan locations passed in">
		<cfargument name="locations" required="true" hint="Locations to remove from the lookup. A list or array of locations"/>
		<cfscript>
			var x = 1;
			
			// inflate incoming locations
   			if( isSimpleValue(arguments.locations) ){ arguments.locations = listToArray(arguments.locations); }
			
			// Loop and remove
			for(x=1;x lte arraylen(arguments.locations); x++ ){
				structDelete(instance.scanLocations, arguments.locations[x]);
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- CACHEBOX INTEGRATION ------------------------------------------>
		
	<!--- cacheBox --->
    <cffunction name="cacheBox" output="false" access="public" returntype="any" hint="Integrate with CacheBox">
    	<cfargument name="configFile" 		required="false" default="" hint="The configuration file to use for loading CacheBox if creating it."/>
		<cfargument name="cacheFactory" 	required="false" default="" hint="The CacheBox cache factory instance to link WireBox to"/>
		<cfargument name="enabled" 			required="false" default="true" hint="Enable or Disable CacheBox Integration, if you call this method then enabled is set to true as most likely you are trying to enable it" colddoc:generic="Boolean"/>
    	<cfargument name="classNamespace" 	required="false" default="#DEFAULTS.cachebox.classNamespace#" hint="The package namespace to use for creating or connecting to CacheBox. Defaults to: coldbox.system.cache"/>
		<cfset structAppend(instance.cacheBox, arguments, true)>
		<cfreturn this>
	</cffunction>
	
	<!--- getCacheBoxConfig --->
    <cffunction name="getCacheBoxConfig" output="false" access="public" returntype="any" hint="Get the CacheBox Configuration Integration structure" colddoc:generic="Struct">
    	<cfreturn instance.cacheBox>
    </cffunction>
	
	<!--- inCacheBox --->
    <cffunction name="inCacheBox" output="false" access="public" returntype="any" hint="Map an object into CacheBox">
    	<cfargument name="key" 					required="false" default="" hint="You can override the key it will use for storing in cache. By default it uses the name of the mapping."/>
    	<cfargument name="timeout" 				required="false" default="" hint="Object Timeout, else defaults to whatever the default is in the choosen cache"/>
		<cfargument name="lastAccessTimeout" 	required="false" default="" hint="Object Timeout, else defaults to whatever the default is in the choosen cache"/>
		<cfargument name="provider" 			required="false" default="default" hint="Uses the 'default' cache provider by default"/>
		<cfscript>
			// if key not passed, use the same mapping name
			if( NOT len(arguments.key) ){ arguments.key = currentMapping.getName(); }
			
			// store the mapping info.
			currentMapping.setScope( this.SCOPES.CACHEBOX ).setCacheProperties(argumentCollection=arguments);
			
			return this;
    	</cfscript>
    </cffunction>

<!------------------------------------------- MAP DSL ------------------------------------------>
	
	<!--- mapDSL --->
    <cffunction name="mapDSL" output="false" access="public" returntype="any" hint="Register a new custom dsl namespace">
    	<cfargument name="namespace" 	required="true" hint="The namespace you would like to register"/>
		<cfargument name="path" 		required="true" hint="The instantiation path to the CFC that implements this scope, it must have an init() method and implement: coldbox.system.ioc.dsl.IDSLBuilder"/>
		<cfset instance.customDSL[arguments.namespace] = arguments.path>
		<cfreturn this>
    </cffunction>
	
	<!--- getCustomDSL --->
    <cffunction name="getCustomDSL" output="false" access="public" returntype="any" hint="Get the custom dsl namespace registration structure" colddoc:generic="struct">
    	<cfreturn instance.customDSL>
    </cffunction>

<!------------------------------------------- MAP SCOPES ------------------------------------------>

	<!--- mapScope --->
    <cffunction name="mapScope" output="false" access="public" returntype="any" hint="Register a new WireBox custom scope">
    	<cfargument name="annotation"	required="true" hint="The unique scope name to register. This translates to an annotation value on CFCs"/>
    	<cfargument name="path" 		required="true" hint="The path to the CFC that implements this scope, it must have an init() method and implement: coldbox.system.ioc.scopes.IScope"/>
		<cfset instance.customScopes[arguments.annotation] = arguments.path>
		<cfreturn this>
	</cffunction>

	<!--- getCustomScopes --->
    <cffunction name="getCustomScopes" output="false" access="public" returntype="struct" hint="Get the registered custom scopes">
    	<cfreturn instance.customScopes>
    </cffunction>	

<!------------------------------------------- LOGBOX INTEGRATION ------------------------------------------>

	<!--- logBoxConfig --->
    <cffunction name="logBoxConfig" output="false" access="public" returntype="any" hint="Set the logBox Configuration to use">
    	<cfargument name="config" required="true" hint="The configuration file to use"/>
		<cfset instance.logBoxConfig = arguments.config>
		<cfreturn this>
    </cffunction>
	
	<!--- getLogBoxConfig --->
    <cffunction name="getLogBoxConfig" output="false" access="public" returntype="any" hint="Get the logBox Configuration file to use">
    	<cfreturn instance.logBoxConfig>
    </cffunction>

<!------------------------------------------- DSL METHODS ------------------------------------------>

	<!--- loadDataDSL --->
    <cffunction name="loadDataDSL" output="false" access="public" returntype="void" hint="Load a data configuration CFC data DSL">
    	<cfargument name="rawDSL" required="false" hint="The data configuration DSL structure to load, else look internally" colddoc:generic="struct"/>
    	<cfscript>
			var wireBoxDSL  = variables.wirebox;
			var key 		= "";
			
			// Coldbox Context Attached
			if( isObject(instance.coldbox) ){
				// create scan location for model convention as the first one.
				scanLocations( instance.coldbox.getSetting("ModelsInvocationPath") );
			}
			
			// Incoming raw DSL or use locally?
			if ( structKeyExists(arguments,"rawDSL") ){
				wireBoxDSL = arguments.rawDSL;
			}
			
			// Register LogBox Configuration
			if( structKeyExists( wireBoxDSL, "logBoxConfig") ){
				logBoxConfig(wireBoxDSL.logBoxConfig);
			}
			
			// Register Server Scope Registration
			if( structKeyExists( wireBoxDSL, "scopeRegistration") ){
				scopeRegistration(argumentCollection=wireBoxDSL.scopeRegistration);
			}
			
			// Register CacheBox
			if( structKeyExists( wireBoxDSL, "cacheBox") ){
				cacheBox(argumentCollection=wireBoxDSL.cacheBox);
			}
			
			// Register Custom DSL
			if( structKeyExists( wireBoxDSL, "customDSL") ){
				structAppend(instance.customDSL, wireBoxDSL.customDSL, true);
			}
			
			// Register Custom Scopes
			if( structKeyExists( wireBoxDSL, "customScopes") ){
				structAppend(instance.customScopes, wireBoxDSL.customScopes, true);
			}
			
			// Append Register Scan Locations
			if( structKeyExists( wireBoxDSL, "scanLocations") ){
				scanLocations( wireBoxDSL.scanLocations );
			}
			
			// Append Register Stop Recursions
			if( structKeyExists( wireBoxDSL, "stopRecursions") ){
				stopRecursions( wireBoxDSL.stopRecursions );
			}

			// Register listeners
			if( structKeyExists( wireBoxDSL, "listeners") ){
				for(key=1; key lte arrayLen(wireBoxDSL.listeners); key++ ){
					listener(argumentCollection=wireBoxDSL.listeners[key]);
				}
			}	
			
			// Register Mappings	
			if( structKeyExists( wireBoxDSL, "mappings") ){
				// iterate and register
				for(key in wireboxDSL.mappings){
					// create mapping & process its data memento
					map(key);
					instance.mappings[ key ].processMemento( wireBoxDSL.mappings[key] );
				}
			}
		</cfscript>
    </cffunction>
	
	<!--- getDefaults --->
    <cffunction name="getDefaults" output="false" access="public" returntype="any" hint="Get the default WireBox settings structure" colddoc:generic="Struct">
    	<cfreturn variables.DEFAULTS>
    </cffunction>
		
	<!--- Get Memento --->
	<cffunction name="getMemento" access="public" returntype="any" output="false" hint="Get the instance data structure" colddoc:generic="Struct">
		<cfreturn instance>
	</cffunction>
	
	<!--- getCurrentMapping --->
    <cffunction name="getCurrentMapping" output="false" access="public" returntype="any" hint="Get the current set mapping (UTILITY method)">
    	<cfreturn variables.currentMapping>
    </cffunction>
	
	<!--- processMappings --->
    <cffunction name="processMappings" output="false" access="public" returntype="any" hint="Process all registered mappings, called by injector when ready to start serving requests">
    	<cfscript>
			var key 			= "";
			var thisMapping 	= "";
			
			// iterate over declared mappings,process, announce, eager and the whole nine yards
			for(key in instance.mappings){
				thisMapping = instance.mappings[key];
				// has it been discovered yet?
				if( NOT thisMapping.isDiscovered() ){
					// process the metadata
					thisMapping.process(binder=this,injector=instance.injector);
					// is it eager?
					if( thisMapping.isEagerInit() ){
						instance.injector.getInstance( thisMapping.getName() );
					}
				}
			}
		</cfscript>
    </cffunction>

<!------------------------------------------- LISTENER METHODS ------------------------------------------>

	<!--- listener --->
	<cffunction name="listener" output="false" access="public" returntype="any" hint="Add a new listener configuration.">
		<cfargument name="class" 		required="true"  hint="The class of the listener"/>
		<cfargument name="properties" 	required="false" default="#structNew()#" hint="The structure of properties for the listner" colddoc:generic="Struct"/>
		<cfargument name="name" 		required="false" default=""  hint="The name of the listener"/>
		<cfscript>
			// Name check?
			if( NOT len(arguments.name) ){
				arguments.name = listLast(arguments.class,".");
			}
			// add listener
			arrayAppend(instance.listeners, arguments);
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- getListeners --->
	<cffunction name="getListeners" output="false" access="public" returntype="any" hint="Get the configured listeners array" colddoc:generic="Array">
		<cfreturn instance.listeners>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
</cfcomponent>