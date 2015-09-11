<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This is a LogBox configuration object.  You can use it to configure
	a log box instance.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="This is a LogBox configuration object.  You can use it to configure a log box instance">

	<cfscript>
		// The log levels enum as a public property
		this.logLevels = createObject("component","coldbox.system.logging.LogLevels");
		// Utility object
		variables.utility  = createObject("component","coldbox.system.core.util.Util");

		// Instance private scope
		instance = structnew();
		
		// Startup the configuration
		reset();
	</cfscript>

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="LogBoxConfig" hint="Constructor">
		<cfargument name="CFCConfig" 		required="false" hint="The logBox Data Configuration CFC"/>
		<cfargument name="CFCConfigPath" 	required="false" hint="The logBox Data Configuration CFC path to use"/>
		<cfscript>
			var logBoxDSL = "";
			
			// Test and load via Data CFC Path
			if( structKeyExists(arguments, "CFCConfigPath") ){
				arguments.CFCConfig = createObject("component",arguments.CFCConfigPath);
			}
			
			// Test and load via Data CFC
			if( structKeyExists(arguments,"CFCConfig") and isObject(arguments.CFCConfig) ){
				// Decorate our data CFC
				arguments.CFCConfig.getPropertyMixin = variables.utility.getMixerUtil().getPropertyMixin;
				// Execute the configuration
				arguments.CFCConfig.configure();
				// Get Data
				logBoxDSL = arguments.CFCConfig.getPropertyMixin("logBox","variables",structnew());
				// Load the DSL
				loadDataDSL( logBoxDSL );
			}
			
			// Just return, most likely programmatic config
			return this;
		</cfscript>
	</cffunction>
	
	<!--- loadDataCFC --->
    <cffunction name="loadDataDSL" output="false" access="public" returntype="void" hint="Load a data configuration CFC data DSL">
    	<cfargument name="rawDSL" required="true" hint="The data configuration DSL structure" colddoc:generic="struct"/>
    	<cfscript>
			var logBoxDSL  = arguments.rawDSL;
			var key 		= "";
			
			// Are appenders defined?
			if( NOT structKeyExists( logBoxDSL, "appenders" ) ){
				throw("No appenders defined","Please define at least one appender","#getMetadata(this).name#.NoAppendersFound");
			}
			// Register Appenders
			for( key in logBoxDSL.appenders ){
				logBoxDSL.appenders[key].name = key;
				appender(argumentCollection=logBoxDSL.appenders[key]);
			}
			
			// Register Root Logger
			if( NOT structKeyExists( logBoxDSL, "root" ) ){
				throw("No Root Logger Defined","Please define the root logger","#getMetadata(this).name#.NoRootLoggerException");
			}
			root(argumentCollection=logBoxDSL.root);
			
			// Register Categories
			if( structKeyExists( logBoxDSL, "categories") ){
				for( key in logBoxDSL.categories ){
					logBoxDSL.categories[key].name = key;
					category(argumentCollection=logBoxDSL.categories[key]);
				}
			}
			
			// Register Level Categories
			if( structKeyExists( logBoxDSL, "debug" ) ){ 
				DEBUG(argumentCollection=variables.utility.arrayToStruct(logBoxDSL.debug) );
			}
			if( structKeyExists( logBoxDSL, "info" ) ){ 
				INFO(argumentCollection=variables.utility.arrayToStruct(logBoxDSL.info) );
			}
			if( structKeyExists( logBoxDSL, "warn" ) ){ 
				WARN(argumentCollection=variables.utility.arrayToStruct(logBoxDSL.warn) );
			}
			if( structKeyExists( logBoxDSL, "error" ) ){ 
				ERROR(argumentCollection=variables.utility.arrayToStruct(logBoxDSL.error) );
			}
			if( structKeyExists( logBoxDSL, "fatal" ) ){ 
				FATAL(argumentCollection=variables.utility.arrayToStruct(logBoxDSL.fatal) );
			}
			if( structKeyExists( logBoxDSL, "off" ) ){ 
				OFF(argumentCollection=variables.utility.arrayToStruct(logBoxDSL.off) );
			}			
		</cfscript>
    </cffunction>
	
	<!--- reset --->
	<cffunction name="reset" output="false" access="public" returntype="void" hint="Reset the configuration">
		<cfscript>
			// Register appenders
			instance.appenders = structnew();
			// Register categories
			instance.categories = structnew();
			// Register root logger
			instance.rootLogger = structnew();
		</cfscript>
	</cffunction>
	
	<!--- resetAppenders --->
    <cffunction name="resetAppenders" output="false" access="public" returntype="void" hint="Reset the appender configurations">
    	<cfset instance.appenders = structNew()>
    </cffunction>
	
	<!--- resetCategories --->
    <cffunction name="resetCategories" output="false" access="public" returntype="void" hint="Reset the set categories">
    	<cfset instance.categories = structnew()>
    </cffunction>
	
	<!--- resetRoot --->
    <cffunction name="resetRoot" output="false" access="public" returntype="void" hint="Reset the root logger">
    	<cfset instance.rootLogger = structnew()>
    </cffunction>
	
	<!--- Get Memento --->
	<cffunction name="getMemento" access="public" returntype="any" output="false" hint="Get the instance data" colddoc:generic="struct">
		<cfreturn instance>
	</cffunction>
	
	<!--- validate --->
	<cffunction name="validate" output="false" access="public" returntype="void" hint="Validates the configuration. If not valid, it will throw an appropriate exception.">
		<cfscript>
			var x=1;
			var key ="";
			
			// Are appenders defined
			if( structIsEmpty(instance.appenders) ){
				throw(message="Invalid Configuration. No appenders defined.",type="#getMetadata(this).name#.NoAppendersFound");
			}
			// Check root logger definition
			if( structIsEmpty(instance.rootLogger) ){
				throw(message="Invalid Configuration. No root logger defined.",type="#getMetadata(this).name#.RootLoggerNotFound");
			}
			
			// All root appenders?
			if( instance.rootLogger.appenders eq "*"){
				instance.rootLogger.appenders = structKeyList(getAllAppenders());
			}
			// Check root's appenders
			for(x=1; x lte listlen(instance.rootLogger.appenders); x=x+1){
				if( NOT structKeyExists(instance.appenders, listGetAt(instance.rootLogger.appenders,x)) ){
					throw(message="Invalid appender in Root Logger",
						   					 detail="The appender #listGetAt(instance.rootLogger.appenders,x)# has not been defined yet. Please define it first.",
						   					 type="#getMetadata(this).name#.AppenderNotFound");
				}
			}
			
			// Check all Category Appenders
			for(key in instance.categories){
				
				// Check * all appenders
				if( instance.categories[key].appenders eq "*"){
					instance.categories[key].appenders = structKeyList(getAllAppenders());
				}
				
				for(x=1; x lte listlen(instance.categories[key].appenders); x=x+1){
					if( NOT structKeyExists(instance.appenders, listGetAt(instance.categories[key].appenders,x)) ){
						throw(message="Invalid appender in Category: #key#",
							   					 detail="The appender #listGetAt(instance.categories[key].appenders,x)# has not been defined yet. Please define it first.",
							   					 type="#getMetadata(this).name#.AppenderNotFound");
					}
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- addAppender --->
	<cffunction name="appender" output="false" access="public" returntype="any" hint="Add an appender configuration.">
		<cfargument name="name" 		required="true"  hint="A unique name for the appender to register. Only unique names can be registered per instance."/>
		<cfargument name="class" 		required="true"  hint="The appender's class to register. We will create, init it and register it for you."/>
		<cfargument name="properties" 	required="false" default="#structnew()#" hint="The structure of properties to configure this appender with." colddoc:generic="struct"/>
		<cfargument name="layout" 		required="false" default="" hint="The layout class path to use in this appender for custom message rendering."/>
		<cfargument name="levelMin" 	required="false" default="0" hint="The default log level for the root logger, by default it is 0 (FATAL). Optional. ex: config.logLevels.WARN"/>
		<cfargument name="levelMax" 	required="false" default="4" hint="The default log level for the root logger, by default it is 4 (DEBUG). Optional. ex: config.logLevels.WARN"/>
		<cfscript>			
			// Convert Levels
			convertLevels(arguments);
			
			// Check levels
			levelChecks(arguments.levelMin, arguments.levelMax);
			
			// Register appender
			instance.appenders[arguments.name] = arguments;
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- Set the root logger information  --->
	<cffunction name="root" access="public" returntype="any" output="false" hint="Register the root logger in this configuration.">
		<cfargument name="levelMin" 	required="false" default="0" hint="The default log level for the root logger, by default it is 0 (FATAL). Optional. ex: config.logLevels.WARN"/>
		<cfargument name="levelMax" 	required="false" default="4" hint="The default log level for the root logger, by default it is 4 (DEBUG). Optional. ex: config.logLevels.WARN"/>
		<cfargument name="appenders" 	required="true"  hint="A list of appenders to configure the root logger with. Send a * to add all appenders"/>
		<cfscript>
			var x = 1;
			// Convert Levels
			convertLevels(arguments);
			
			// Check levels
			levelChecks(arguments.levelMin, arguments.levelMax);
			
			//Verify appender list
			if( NOT listLen(arguments.appenders) ){
				throw("Invalid Appenders","Please send in at least one appender for the root logger","#getMetadata(this).name#.InvalidAppenders");
			}

			// Add definition
			instance.rootLogger = arguments;
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- Get root logger --->
	<cffunction name="getRoot" access="public" returntype="any" output="false" hint="Get the root logger definition." colddoc:generic="struct">
		<cfreturn instance.rootLogger>
	</cffunction>
	
	<!--- addCategory --->
	<cffunction name="category" output="true" access="public" returntype="any" hint="Add a new category configuration with appender(s).  Appenders MUST be defined first, else this method will throw an exception">
		<cfargument name="name" 		required="true"  hint="A unique name for the appender to register. Only unique names can be registered per instance."/>
		<cfargument name="levelMin" 	required="false" default="0" hint="The default min log level for this category. Defaults to the lowest level 0 or FATAL"/>
		<cfargument name="levelMax" 	required="false" default="4" hint="The max default log level for this category. If not passed it defaults to the highest level possible"/>
		<cfargument name="appenders" 	required="false" default="*"  hint="A list of appender names to configure this category with. By default it uses all the registered appenders"/>
		<cfscript>
			// Convert Levels
			convertLevels(arguments);
			
			// Check levels
			levelChecks(arguments.levelMin, arguments.levelMax);
			
			// Add category registration
			instance.categories[arguments.name] = arguments;
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- getCategory --->
	<cffunction name="getCategory" output="false" access="public" returntype="any" hint="Get a specifed category definition" colddoc:generic="struct">
		<cfargument name="name" required="true" hint="The category to retrieve"/>
		<cfreturn instance.categories[arguments.name]>
	</cffunction>
	
	<!--- categoryExists --->
	<cffunction name="categoryExists" output="false" access="public" returntype="any" hint="Check if a category definition exists" colddoc:generic="boolean">
		<cfargument name="name" required="true" hint="The category to retrieve"/>
		<cfreturn structKeyExists(instance.categories, arguments.name)>
	</cffunction>
	
	<!--- getCategories --->
	<cffunction name="getAllCategories" output="false" access="public" returntype="any" hint="Get the configured categories" colddoc:generic="struct">
		<cfreturn instance.categories>
	</cffunction>
	
	<!--- getappenders --->
	<cffunction name="getAllAppenders" output="false" access="public" returntype="any" hint="Get all the configured appenders" colddoc:generic="struct">
		<cfreturn instance.appenders>
	</cffunction>
	
<!------------------------------------------- Facade methods for categoreis with levels only ------------------------------------------>
	
	<!--- DEBUG --->
	<cffunction name="DEBUG" output="false" access="public" returntype="any" hint="Add categories to the DEBUG level. Send each category as an argument.">
		<cfscript>
			var key = "";
			for(key in arguments){
				category(name=arguments[key],levelMax=this.logLevels.DEBUG);
			}
			return this;
		</cfscript>
	</cffunction>
	
	<!--- INFO --->
	<cffunction name="INFO" output="false" access="public" returntype="any" hint="Add categories to the INFO level. Send each category as an argument.">
		<cfscript>
			var key = "";
			for(key in arguments){
				category(name=arguments[key],levelMax=this.logLevels.INFO);
			}
			return this;
		</cfscript>
	</cffunction>
	
	<!--- WARN --->
	<cffunction name="WARN" output="false" access="public" returntype="any" hint="Add categories to the WARN level. Send each category as an argument.">
		<cfscript>
			var key = "";
			for(key in arguments){
				category(name=arguments[key],levelMax=this.logLevels.WARN);
			}
			return this;
		</cfscript>
	</cffunction>
	
	<!--- ERROR --->
	<cffunction name="ERROR" output="false" access="public" returntype="any" hint="Add categories to the ERROR level. Send each category as an argument.">
		<cfscript>
			var key = "";
			for(key in arguments){
				category(name=arguments[key],levelMax=this.logLevels.ERROR);
			}
			return this;
		</cfscript>
	</cffunction>
	
	<!--- FATAL --->
	<cffunction name="FATAL" output="false" access="public" returntype="any" hint="Add categories to the FATAL level. Send each category as an argument.">
		<cfscript>
			var key = "";
			for(key in arguments){
				category(name=arguments[key],levelMax=this.logLevels.FATAL);
			}
			return this;
		</cfscript>
	</cffunction>
	
	<!--- OFF --->
	<cffunction name="OFF" output="false" access="public" returntype="any" hint="Add categories to the OFF level. Send each category as an argument.">
		<cfscript>
			var key = "";
			for(key in arguments){
				category(name=arguments[key],levelMin=this.logLevels.OFF,levelMax=this.logLevels.OFF);
			}
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- convertLevels --->
    <cffunction name="convertLevels" output="false" access="private" returntype="any" hint="Convert levels from an incoming structure of data" colddoc:generic="struct">
    	<cfargument name="target" required="true" default="" hint="The structure to look for elements: LevelMin and LevelMax" colddoc:generic="struct"/>
		<cfscript>
			// Check levelMin
			if( structKeyExists(arguments.target, "levelMIN") and NOT isNumeric(arguments.target.levelMin)){
				arguments.target.levelMin = this.logLevels.lookupAsInt(arguments.target.levelMin);
			}
			// Check levelMax
			if( structKeyExists(arguments.target, "levelMax") and NOT isNumeric(arguments.target.levelMax)){
				arguments.target.levelMax = this.logLevels.lookupAsInt(arguments.target.levelMax);
			}
			
			// For chaining
			return arguments.target;
		</cfscript>
    </cffunction>

	<!--- levelChecks --->
	<cffunction name="levelChecks" output="false" access="private" returntype="void" hint="Level checks or throw">
		<cfargument name="levelMin" required="true"/>
		<cfargument name="levelMax" required="true"/>
		<cfif NOT this.logLevels.isLevelValid(arguments.levelMin)>
			<cfthrow message="LevelMin #arguments.levelMin# is not a valid level." type="LogBoxConfig.InvalidLevel">
		<cfelseif NOT this.logLevels.isLevelValid(arguments.levelMax)>
			<cfthrow message="LevelMin #arguments.levelMax# is not a valid level." type="LogBoxConfig.InvalidLevel">
		</cfif>
	</cffunction>
	
</cfcomponent>