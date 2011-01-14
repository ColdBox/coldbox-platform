<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This is LogBox, an enterprise logger. Please remember to persist this factory once it has been created.
	You can create as many instances of LogBox as you like. Just remember that you
	need to register loggers in it.  It can be one or 1000, it all depends on you.
	
	By default, LogBox will log any warnings pertaining to itself in the CF logs
	according to its name.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="This is LogBox, an enterprise logger. Please remember to persist this factory once it has been created.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		// The log levels enum as a public property
		this.logLevels = createObject("component","coldbox.system.logging.LogLevels");
		
		// private instance scope
		instance = structnew();
		// LogBox Unique ID
		instance.logboxID = createObject('java','java.lang.System').identityHashCode(this);	
		// Appenders
		instance.appenderRegistry = structnew();
		// Loggers
		instance.loggerRegistry = structnew();
		// Category Appenders
		instance.categoryAppenders = "";	
		// Version
		instance.version = "1.6";	 
		// Configuration object
		instance.config = "";
		// ColdBox Application Link
		instance.coldbox = "";	
	</cfscript>
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="LogBox" hint="Constructor" output="false" >
		<cfargument name="config"  type="coldbox.system.logging.config.LogBoxConfig" required="true" hint="The LogBoxConfig object to use to configure this instance of LogBox"/>
		<cfargument name="coldbox" type="any" required="false" default="" hint="A coldbox application that this instance of logbox can be linked to."/>
		<cfscript>
			// Check if linking ColdBox
			if( isObject(arguments.coldbox) ){ instance.coldbox = arguments.coldbox; }
			
			// Configure LogBox
			configure(arguments.config);
			
			// Return LogBox
			return this;
		</cfscript>
	</cffunction>
	
	<!--- configure --->
	<cffunction name="configure" output="false" access="public" returntype="void" hint="Configure logbox for operation. You can also re-configure LogBox programmatically. Basically we register all appenders here and all categories">
		<cfargument name="config" type="any" required="true" hint="The LogBoxConfig object to use to configure this instance of LogBox: coldbox.system.logging.config.LogBoxConfig" colddoc:generic="coldbox.system.logging.config.LogBoxConfig"/>
		<cfscript>
			var appenders 	= "";
			var key 		= "";
			var oRoot 		= "";
			var rootConfig 	= "";
			var args 		= structnew();
		</cfscript>
		
		<cflock name="#instance.logboxID#.logBox.config" type="exclusive" timeout="30">
			<cfscript>
			// Store config object
			instance.config = arguments.config;
			// Validate configuration
			instance.config.validate();
			
			// Reset Registries
			instance.appenderRegistry = structnew();
			instance.loggerRegistry = structnew();
			
			//Get appender definitions
			appenders = instance.config.getAllAppenders();
						
			// Register All Appenders configured
			for( key in appenders ){
				registerAppender(argumentCollection=appenders[key]);
			}
			
			// Get Root def
			rootConfig = instance.config.getRoot();
			// Create Root Logger
			args.category = "ROOT";
			args.levelMin = rootConfig.levelMin;
			args.levelMax = rootConfig.levelMax;
			args.appenders = getAppendersMap(rootConfig.appenders);
			oRoot = createObject("component","coldbox.system.logging.Logger").init(argumentCollection=args);
			
			//Save in Registry
			instance.loggerRegistry = structnew();
			instance.loggerRegistry["ROOT"] = oRoot;
		</cfscript>
		</cflock>
	</cffunction>
	
	<!--- Get Version --->
	<cffunction name="getVersion" access="public" returntype="any" output="false" hint="Get the LogBox version string.">
		<cfreturn instance.Version>
	</cffunction>
	
	<!--- Get the config object --->
	<cffunction name="getConfig" access="public" returntype="any" output="false" hint="Get this LogBox's configuration object." colddoc:generic="coldbox.system.logging.config.LogBoxConfig">
		<cfreturn instance.config>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- getRootLogger --->
	<cffunction name="getRootLogger" output="false" access="public" returntype="any" hint="Get the root logger" colddoc:generic="coldbox.system.logging.Logger">
		<cfreturn instance.loggerRegistry["ROOT"]>
	</cffunction>

	<!--- getLogger --->
	<cffunction name="getLogger" output="false" access="public" returntype="any" hint="Get a logger object configured with a category name and appenders. If not configured, then it reverts to the root logger defined for this instance of LogBox" colddoc:generic="coldbox.system.logging.Logger">
		<cfargument name="category" type="any" required="true" hint="The category name to use in this logger or pass in the target object will log from and we will inspect the object and use its metadata name."/>
		<cfscript>
			var args = structnew();
			var categoryConfig = "";
			var oLogger = "";
			var root = instance.loggerRegistry["ROOT"];
			
			// is category object?
			if( isObject(arguments.category) ){ arguments.category = getMetadata(arguments.category).name; }
			
			//trim cat, just in case
			arguments.category = trim(arguments.category);
			
			//Is logger by category name created already?
			if( structKeyExists(instance.loggerRegistry,arguments.category) ){
				return instance.loggerRegistry[arguments.category];
			}
			//Do we have a category definition, so we can build it?
			if( instance.config.categoryExists(arguments.category) ){
				categoryConfig = instance.config.getCategory(arguments.category);
				// Setup creation arguments
				args.category = categoryConfig.name;
				args.levelMin = categoryConfig.levelMin;
				args.levelMax = categoryConfig.levelMax;
				args.appenders = getAppendersMap(categoryConfig.appenders);
			}
			else{
				// Setup new category name
				args.category = arguments.category;
				// Do Category Inheritance? or else just return the root logger.
				root = locateCategoryParentLogger(arguments.category);
				// Setup the category levels according to parent found.
				args.levelMin = root.getLevelMin();
				args.levelMax = root.getLevelMax();
			}					
		</cfscript>

		<!--- Create New Logger --->
		<cflock name="#instance.logboxID#.logBox.logger.#arguments.category#" type="exclusive" throwontimeout="true" timeout="30">
			<cfscript>
				if( NOT structKeyExists(instance.loggerRegistry,arguments.category) ){
					// Create logger	
					oLogger = createObject("component","coldbox.system.logging.Logger").init(argumentCollection=args);
					// Inject Root Logger
					oLogger.setRootLogger(root);
					// Store it
					instance.loggerRegistry[arguments.category] = oLogger;
				}
			</cfscript>
		</cflock>
		
		<cfreturn instance.loggerRegistry[arguments.category]>
	</cffunction>
	
	<!--- getCurrentLoggers --->
	<cffunction name="getCurrentLoggers" output="false" access="public" returntype="any" hint="Get the list of currently instantiated loggers.">
		<cfreturn structKeyList(instance.loggerRegistry)>
	</cffunction>
	
	<!--- getCurrentAppenders --->
	<cffunction name="getCurrentAppenders" output="false" access="public" returntype="any" hint="Get the list of currently registered appenders.">
		<cfreturn structKeyList(instance.appenderRegistry)>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- locateCategoryParentLogger --->
	<cffunction name="locateCategoryParentLogger" output="false" access="private" returntype="any" hint="Get a parent logger according to category convention inheritance.  If not found, it returns the root logger.">
		<cfargument name="category" required="true" hint="The category name to investigate for parents."/>
		<cfscript>
			// Get parent category name shortened by one.
			var parentCategory = "";
			
			// category len check
			if( len(arguments.category) ){
				parentCategory = listDeleteAt(arguments.category, listLen(arguments.category,"."), ".");
			}
			
			// Check if parent Category is empty
			if( len(parentCategory) EQ 0 ){
				// Just return the root logger, nothing found.
				return instance.loggerRegistry["ROOT"];
			}			
			// Does it exist already in the instantiated loggers?
			if( structKeyExists(instance.loggerRegistry,parentCategory) ){
				return instance.loggerRegistry[parentCategory];
			}
			// Do we need to create it, lazy loading?
			if( instance.config.categoryExists(parentCategory) ){
				return getLogger(parentCategory);	
			}
			// Else, it was not located, recurse
			return locateCategoryParentLogger(parentCategory);			
		</cfscript>
	</cffunction>
	
	<!--- registerAppender --->
	<cffunction name="registerAppender" output="false" access="private" returntype="any" hint="Register a new appender object in the appender registry.">
		<!--- ************************************************************* --->
		<cfargument name="name" 		required="true"  hint="A unique name for the appender to register. Only unique names can be registered per instance."/>
		<cfargument name="class" 		required="true"  hint="The appender's class to register. We will create, init it and register it for you."/>
		<cfargument name="properties" 	required="false" default="#structnew()#" hint="The structure of properties to configure this appender with." colddoc:generic="struct"/>
		<cfargument name="layout" 		required="false" default="" hint="The layout class to use in this appender for custom message rendering."/>
		<cfargument name="levelMin"  	required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN" colddoc:generic="numeric"/>
		<cfargument name="levelMax"  	required="false" default="4" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN" colddoc:generic="numeric"/>
		<!--- ************************************************************* --->
		<cfset var appenders = instance.appenderRegistry>
		<cfset var oAppender = "">
		
		<!--- Verify Registration --->
		<cfif NOT structKeyExists(appenders,arguments.name)>
			<cflock name="#instance.logboxID#.registerappender.#name#" type="exclusive" timeout="15">
				<cfscript>
					if( NOT structKeyExists(appenders,arguments.name) ){
						// Create appender
						oAppender = createObject("component",arguments.class).init(argumentCollection=arguments);
						// Is running within ColdBox
						if( isObject(instance.coldbox) ){ oAppender.setColdbox(instance.coldbox); }
						// run registration event
						oAppender.onRegistration();
						// set initialized
						oAppender.setInitialized(true);
						// Store it
						appenders[arguments.name] = oAppender;
					}
				</cfscript>
			</cflock>
		</cfif>
	</cffunction>
	
	<!--- getAppendersMap --->
	<cffunction name="getAppendersMap" output="false" access="private" returntype="any" hint="Get a map of appenders by list. Usually called to get a category of appenders." colddoc:generic="struct">
		<cfargument name="appenders" required="true" hint="The list of appenders to get"/>
		<cfscript>
			var x =1;
			var appendersMap = structnew();
			
			// Go over appender's list and configure it
			for(x=1; x lte listlen(arguments.appenders); x=x+1){
				thisAppender = listGetAt(arguments.appenders,x);
				appendersMap[thisAppender] = instance.appenderRegistry[thisAppender];	
			}
			
			return appendersMap;
		</cfscript>
	</cffunction>
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="any" hint="Create and return a util object" colddoc:generic="coldbox.system.core.util.Util">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

</cfcomponent>