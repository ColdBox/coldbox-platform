<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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
		
		// Instance private scope
		instance 		  = structnew();
		instance.utility  = createObject("component","coldbox.system.core.util.Util");
		
		// Startup the configuration
		reset();
	</cfscript>

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="LogBoxConfig" hint="Constructor">
		<cfargument name="XMLConfig" 		required="false" default="" hint="The xml configuration file to use instead of a programmatic approach"/>
		<cfargument name="CFCConfig" 		required="false" hint="The logBox Data Configuration CFC"/>
		<cfargument name="CFCConfigPath" 	required="false" hint="The logBox Data Configuration CFC path to use"/>
		<cfscript>
			var logBoxDSL = "";
			
			// Test and load via XML
			if( len(trim(arguments.XMLConfig)) ){
				parseAndLoad(xmlParse(arguments.XMLConfig));
			}
			
			// Test and load via Data CFC Path
			if( structKeyExists(arguments, "CFCConfigPath") ){
				arguments.CFCConfig = createObject("component",arguments.CFCConfigPath);
			}
			
			// Test and load via Data CFC
			if( structKeyExists(arguments,"CFCConfig") and isObject(arguments.CFCConfig) ){
				// Decorate our data CFC
				arguments.CFCConfig.getPropertyMixin = instance.utility.getMixerUtil().getPropertyMixin;
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
				instance.utility.throwit("No appenders defined","Please define at least one appender","#getMetadata(this).name#.NoAppendersFound");
			}
			// Register Appenders
			for( key in logBoxDSL.appenders ){
				logBoxDSL.appenders[key].name = key;
				appender(argumentCollection=logBoxDSL.appenders[key]);
			}
			
			// Register Root Logger
			if( NOT structKeyExists( logBoxDSL, "root" ) ){
				instance.utility.throwit("No Root Logger Defined","Please define the root logger","#getMetadata(this).name#.NoRootLoggerException");
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
				DEBUG(argumentCollection=instance.utility.arrayToStruct(logBoxDSL.debug) );
			}
			if( structKeyExists( logBoxDSL, "info" ) ){ 
				INFO(argumentCollection=instance.utility.arrayToStruct(logBoxDSL.info) );
			}
			if( structKeyExists( logBoxDSL, "warn" ) ){ 
				WARN(argumentCollection=instance.utility.arrayToStruct(logBoxDSL.warn) );
			}
			if( structKeyExists( logBoxDSL, "error" ) ){ 
				ERROR(argumentCollection=instance.utility.arrayToStruct(logBoxDSL.error) );
			}
			if( structKeyExists( logBoxDSL, "fatal" ) ){ 
				FATAL(argumentCollection=instance.utility.arrayToStruct(logBoxDSL.fatal) );
			}
			if( structKeyExists( logBoxDSL, "off" ) ){ 
				OFF(argumentCollection=instance.utility.arrayToStruct(logBoxDSL.off) );
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
				instance.utility.throwit(message="Invalid Configuration. No appenders defined.",type="#getMetadata(this).name#.NoAppendersFound");
			}
			// Check root logger definition
			if( structIsEmpty(instance.rootLogger) ){
				instance.utility.throwit(message="Invalid Configuration. No root logger defined.",type="#getMetadata(this).name#.RootLoggerNotFound");
			}
			
			// All root appenders?
			if( instance.rootLogger.appenders eq "*"){
				instance.rootLogger.appenders = structKeyList(getAllAppenders());
			}
			// Check root's appenders
			for(x=1; x lte listlen(instance.rootLogger.appenders); x=x+1){
				if( NOT structKeyExists(instance.appenders, listGetAt(instance.rootLogger.appenders,x)) ){
					instance.utility.throwit(message="Invalid appender in Root Logger",
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
						instance.utility.throwit(message="Invalid appender in Category: #key#",
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
				instance.utility.throwit("Invalid Appenders","Please send in at least one appender for the root logger","#getMetadata(this).name#.InvalidAppenders");
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

	<!--- parseAndLoad --->
	<cffunction name="parseAndLoad" output="false" access="public" returntype="void" hint="Parse and load a config xml object">
		<cfargument name="xmlDoc" required="true" hint="The xml document object to use for parsing."/>
		<cfscript>
			// Get All Appenders
			var xml = arguments.xmlDoc;
			var appendersXML = xmlSearch(xml,"//Appender");
			var rootXML = xmlSearch(xml,"//Root");
			var categoriesXML = xmlSearch(xml,"//Category");
			var args = structnew();
			var x =1;
			var y =1;
			
			//Register all appenders
			for(x=1; x lte arrayLen(appendersXML); x=x+1){
				args = structnew();
				args.properties = structnew();
				thisAppender = appendersXML[x];
				// Error
				if( NOT structKeyExists(thisAppender.XMLAttributes,"name") OR NOT 
				        structKeyExists(thisAppender.XMLAttributes,"class") ){
					instance.utility.throwit(message="An appender must have a name and class attribute",type="#getMetadata(this).name#.InvalidAppenderDefinition");
				}
				// Construct appender Properties
				args.name = trim(thisAppender.XMLAttributes.name);
				args.class = trim(thisAppender.XMLAttributes.class);
				
				//Appender layout?
				if( structKeyExists(thisAppender.XMLAttributes,"layout") ){
					args.layout = trim(thisAppender.XMLAttributes.layout);
				}
				//Appender Levels?
				if( structKeyExists(thisAppender.XMLAttributes,"levelMin") ){
					args.levelMin = trim(thisAppender.XMLAttributes.levelMin);
					// Numeric Check
					if( NOT isNumeric(args.levelMin) ){
						args.levelMin = this.logLevels.lookupAsInt(args.levelMin);
					}
				}
				if( structKeyExists(thisAppender.XMLAttributes,"levelMax") ){
					args.levelMax = trim(thisAppender.XMLAttributes.levelMax);
					// Numeric Check
					if( NOT isNumeric(args.levelMax) ){
						args.levelMax = this.logLevels.lookupAsInt(args.levelMax);
					}
				}
				
				// Check Properties Out
				for(y=1; y lte arrayLen(thisAppender.xmlChildren); y=y+1 ){
					args.properties[trim(thisAppender.xmlChildren[y].xmlAttributes.name)] = trim(thisAppender.xmlChildren[y].xmlText);
				}
				// Register appender
				appender(argumentCollection=args);
			}
			
			//Register Root Logger
			if( NOT arrayLen(rootXML) ){
				instance.utility.throwit(message="The root element cannot be found and it is mandatory",type="#getMetadata(this).name#.RootLoggerNotFound");
			}
			args = structnew();
			if( structKeyExists(rootXML[1].xmlAttributes,"levelMin") ){
				args.levelMin = trim(rootXML[1].xmlAttributes.levelMin);
				// Numeric Check
				if( NOT isNumeric(args.levelMin) ){
					args.levelMin = this.logLevels.lookupAsInt(args.levelMin);
				}
			}
			if( structKeyExists(rootXML[1].xmlAttributes,"levelMax") ){
				args.levelMax = trim(rootXML[1].xmlAttributes.levelMax);
				// Numeric Check
				if( NOT isNumeric(args.levelMax) ){
					args.levelMax = this.logLevels.lookupAsInt(args.levelMax);
				}
			}
			
			//Root Appenders
			if( structKeyExists(rootXML[1].xmlAttributes,"appenders") ){
				args.appenders = trim(rootXML[1].xmlAttributes.appenders);
			}
			else{
				args.appenders = "";
				for( x=1; x lte arrayLen(rootXML[1].xmlChildren); x=x+1){
					if( rootXML[1].xmlChildren[x].XMLName eq "Appender-ref" ){
						args.appenders = listAppend(args.appenders, trim(rootXML[1].xmlChildren[x].XMLAttributes.ref) );
					}
				}
			}
			root(argumentCollection=args);
			
			//Categories
			for( x=1; x lte arrayLen(categoriesXML); x=x+1){
				args = structnew();
				
				// Category Name
				if( NOT structKeyExists(categoriesXML[x].XMLAttributes,"name") ){
					instance.utility.throwit(message="A category definition must have a name attribute",type="#getMetadata(this).name#.InvalidCategoryDefinition");
				}
				args.name = trim(categoriesXML[x].XMLAttributes.name);
				
				// Level Min
				if( structKeyExists(categoriesXML[x].XMLAttributes,"levelMin") ){
					args.levelMin = trim(categoriesXML[x].XMLAttributes.levelMin);
					if( NOT isNumeric(args.levelMin) ){
						args.levelMin = this.logLevels.lookupAsInt(args.levelMin);
					}
				}
				
				// Level Max
				if( structKeyExists(categoriesXML[x].XMLAttributes,"levelMax") ){
					args.levelMax = trim(categoriesXML[x].XMLAttributes.levelMax);
					if( NOT isNumeric(args.levelMax) ){
						args.levelMax = this.logLevels.lookupAsInt(args.levelMax);
					}
				}
				
				//Category Appenders
				if( structKeyExists(categoriesXML[x].XMLAttributes,"appenders") ){
					args.appenders = trim(categoriesXML[x].XMLAttributes.appenders);
				}
				else{
					args.appenders = "";
					// Find xml appender references
					for( y=1; y lte arrayLen(categoriesXML[x].xmlChildren); y=y+1){
						if( categoriesXML[x].xmlChildren[y].XMLName eq "Appender-ref" ){
							args.appenders = listAppend(args.appenders, trim(categoriesXML[x].xmlChildren[y].XMLAttributes.ref) );
						}
					}
					// check if we have appenders else default to *
					if(NOT len(args.appenders) ){
						args.appenders = "*";
					}
				}
				// Register category
				category(argumentCollection=args);
			}
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