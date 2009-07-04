<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
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
<cfcomponent name="LogBox" output="false" hint="This is LogBox, an enterprise logger. Please remember to persist this factory once it has been created.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		// The log levels enum as a public property
		this.logLevels = createObject("component","coldbox.system.logging.LogLevels");
	
		// private instance scope
		instance = structnew();
		// LogBox Unique ID */
		instance._hash = hash(createUUID());	
		// Appenders
		instance.appenderRegistry = "";
		// Category Appenders
		instance.categoryAppenders = "";	
		// Version
		instance.version = "1.0";	 
		// Configuration object
		instance.config = "";	
	</cfscript>
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="LogBox" hint="Constructor" output="false" >
		<cfargument name="logBoxConfig" type="coldbox.system.logging.config.LogBoxConfig" required="true" hint="The LogBoxConfig object to use to configure this instance of LogBox"/>
		<cfscript>
			var Collections = createObject("java", "java.util.Collections");
			
			// Prepare Appender Object Registries
			instance.appenderRegistry = Collections.synchronizedMap(CreateObject("java","java.util.LinkedHashMap").init(3));
			instance.categoryAppenders = structnew();
			
			// Store config object
			instance.config = arguments.logBoxConfig;
			
			// Configure LogBox
			configure(instance.config);
			
			// Return LogBox
			return this;
		</cfscript>
	</cffunction>
	
	<!--- configure --->
	<cffunction name="configure" output="false" access="public." returntype="void" hint="Configure logbox for operation. You can also re-configure LogBox programmatically. Basically we register all appenders here and all categories">
		<cfargument name="logBoxConfig" type="coldbox.system.logging.config.LogBoxConfig" required="true" hint="The LogBoxConfig object to use to configure this instance of LogBox"/>
		<cfscript>
			var config = arguments.logBoxConfig;
			var appenders = config.getAppenders();
			var key = "";
			var categories = config.getCategories();
		</cfscript>
		
		<cflock name="#instance._hash#.logbox.config" type="exclusive" timeout="30" throwontimeout="true">
		<cfscript>
			// Register All Appenders configured
			for( key in appenders ){
				registerNew(argumentCollection=appenders[key]);
			}
			// Clean just in case
			key = "";
			// Register All Category Appenders defined in the configuration object.
			for( key in categories ){
				instance.categoryAppenders[key] = getAppendersMap(categories[key].appenders);
			}
		</cfscript>
		</cflock>
	</cffunction>
	
	<!--- Get Version --->
	<cffunction name="getVersion" access="public" returntype="string" output="false" hint="Get the LogBox version string.">
		<cfreturn instance.Version>
	</cffunction>
	
	<!--- Get the config object --->
	<cffunction name="getConfig" access="public" returntype="coldbox.system.logging.config.LogBoxConfig" output="false" hint="Get this LogBox's configuration object.">
		<cfreturn instance.config>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
		
	<!--- clearAppenders --->
	<cffunction name="clearAppenders" output="false" access="public" returntype="void" hint="Clear all appenders registered">
		<cfset structClear(getAppenders())>
	</cffunction>
	
	<!--- removeAppender --->
	<cffunction name="removeAppender" output="false" access="public" returntype="boolean" hint="Remove an appender if it exists. Else returns false.">
		<cfargument name="name" type="string" required="true" hint="The appender's name"/>
		<cfscript>
			if( appenderExists(arguments.name) ){
				getAppenders().remove(ucase(arguments.name));
				return true;
			}
			return false;
		</cfscript>
	</cffunction>
		
	<!--- hasAppenders --->
	<cffunction name="hasAppenders" output="false" access="public" returntype="boolean" hint="Checks to see if we have registered any appenders yet">
		<cfreturn NOT getAppenders().isEmpty()>
	</cffunction>
	
	<!--- Get the appender Registry --->
	<cffunction name="getAppenders" access="public" returntype="struct" output="false" hint="Get the map of registered appenders.">
		<cfreturn instance.appenderRegistry>
	</cffunction>
	
	<!--- Get the category Appenders Registry --->
	<cffunction name="getCategoryAppenders" access="public" returntype="struct" output="false" hint="Get the map of registered category appenders.">
		<cfreturn instance.categoryAppenders>
	</cffunction>
	
	<!--- getAppender --->
	<cffunction name="getAppender" output="false" access="public" returntype="any" hint="Get a named appender">
		<cfargument name="name" type="string" required="true" hint="The appender's name"/>
		<cfscript>
			if( appenderExists(arguments.name) ){
				return structFind(getAppenders(),ucase(arguments.name));
			}
			else{
				getutil().throwit(message="Appender #arguments.name# does not exist.",detail="The appenders registered are #structKeyList(getAppenders())#",type="LogBox.AppenderNotFound");
			}
		</cfscript>
	</cffunction>
	
	<!--- appenderExists --->
	<cffunction name="appenderExists" output="false" access="public" returntype="boolean" hint="Checks to see if a specified appender exists by name.">
		<cfargument name="name" type="string" required="true" hint="The name of the appender to check if it is registered"/>
		<cfreturn structKeyExists(getAppenders(), ucase(arguments.name))>
	</cffunction>
	
	<!--- register --->
	<cffunction name="register" output="false" access="public" returntype="void" hint="Register a new or already instantiated appender object.">
		<!--- ************************************************************* --->
		<cfargument name="appender" 	type="coldbox.system.logging.AbstractAppender" required="false" hint="The appender object you would like to register with this instance of Log Box."/>
		<!--- ************************************************************* --->
		<cfset var name = "">
		
		<!--- Verify the appender's Name --->
		<cfif NOT len(arguments.appender.getName())>
			<cfthrow message="Appender does not have a name, please instantiate the appender with a unique name."
					 type="LogBox.InvalidAppenderNameException">
		<cfelse>
			<cfset name = arguments.appender.getName()>
		</cfif>
		
		<!--- Verify Registration --->
		<cfif NOT appenderExists(name)>
			<cflock name="#instance._hash#.registerappender.#name#" type="exclusive" throwontimeout="true" timeout="30">
				<cfscript>
					if( NOT appenderExists(name) ){
						// Store Logger
						getAppenders().put(name, arguments.appender)
						// run registration event
						arguments.appender.onRegistration();
						// set initialized
						arguments.appender.setInitialized(true);
					}
				</cfscript>
			</cflock>
		<cfelse>
			<cflog type="warning" file="LogBox" text="LogBoxID: #instance._hash# - Cannot register appender #name# as it is already registered. Skipping.">
		</cfif>		
	</cffunction>
	
	<!--- create --->
	<cffunction name="registerNew" output="false" access="public" returntype="any" hint="Register a new appender with this instance of LogBox and returns it to you if you like.">
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true"  hint="A unique name for the appender to register. Only unique names can be registered per instance."/>
		<cfargument name="class" 		type="string"  required="true"  hint="The appender's class to register. We will create, init it and register it for you."/>
		<cfargument name="levelMin" 	type="numeric" required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="levelMax" 	type="numeric" required="false" default="5" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="The structure of properties to configure this appender with."/>
		<!--- ************************************************************* --->
		<cfscript>
			// Create new appender object
			var appender = createObject("component",arguments.class).init(argumentCollection=arguments);
			
			// Register it
			register(appender);
			
			return appender;
		</cfscript>		
	</cffunction>
	
	<!--- unRegister --->
	<cffunction name="unRegister" output="false" access="public" returntype="boolean" hint="Unregister an appender from LogBox. True if successful or false otherwise.">
		<cfargument name="name" type="string" required="true" hint="The name of the appender to unregister"/>
		<cfset var appender = "">
		<cfset var allAppenders = getAppenders()>
		
		<cfif appenderExists(arguments.name)>
			<cfscript>
				// Get Appender
				appender = getAppender(arguments.name);			
				// Run un-registration event
				appender.onUnRegistration();
				// Unregister it
				removeAppender(arguments.name);	
							
				return true;
			</cfscript>
		<cfelse>
			<cflog type="warning" file="LogBox" text="Cannot UnRegister appender #arguments.name# as it does not exist in the current registered appenders.">
			<cfreturn false>
		</cfif>
	</cffunction>

	<!--- getLogger --->
	<cffunction name="getLogger" output="false" access="public" returntype="coldbox.system.logging.Logger" hint="Get a logger object configured with a category already.">
		<cfargument name="category" type="string" required="true" hint="The category name to use this logger with"/>
		<cfscript>
			var logger = createObject("component","coldbox.system.logging.Logger");
			var args = structnew();
			var config = getConfig();
			var categoryAppenders = getCategoryAppenders();
			var categoryConfig = "";	
					
			// Set category name in config
			args.category = arguments.category;
			
			// Verify if category exists to get appenders and data info.
			if( config.categoryExists(arguments.category) ){
				categoryConfig = config.getCategory(arguments.category);
				args.levelMin = categoryConfig.levelMin;
				args.levelMax = categoryConfig.levelMax;
				// Get Appenders from category storage map
				args.appenders = categoryAppenders[arguments.category];
			}
			
			// Dependencies
			logger.logLevels = this.logLevels;
			logger.logBox = this;
			
			// Init it
			return logger.init(argumentCollection=args);			
		</cfscript>
	</cffunction>

<!------------------------------------------- FACADE Methods ------------------------------------------->

	<!--- Debug --->
	<cffunction name="debug" access="public" output="false" returntype="void" hint="I log a debug message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category" type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfset arguments.severity = this.logLevels.DEBUG>
		<cfset logMessage(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Info --->
	<cffunction name="info" access="public" output="false" returntype="void" hint="I log an information message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfset arguments.severity = this.logLevels.INFO>
		<cfset logMessage(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Trace --->
	<cffunction name="trace" access="public" output="false" returntype="void" hint="I log a trace message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfset arguments.severity = this.logLevels.TRACE>
		<cfset logMessage(argumentCollection=arguments)>
	</cffunction>
	
	<!--- warn --->
	<cffunction name="warn" access="public" output="false" returntype="void" hint="I log a warning message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfset arguments.severity = this.logLevels.WARN>
		<cfset logMessage(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Error --->
	<cffunction name="error" access="public" output="false" returntype="void" hint="I log an error message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfset arguments.severity = this.logLevels.ERROR>
		<cfset logMessage(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Fatal --->
	<cffunction name="fatal" access="public" output="false" returntype="void" hint="I log a fatal message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfset arguments.severity = this.logLevels.FATAL>
		<cfset logMessage(argumentCollection=arguments)>
	</cffunction>
		
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- getAppendersMap --->
	<cffunction name="getAppendersMap" output="false" access="private" returntype="struct" hint="Get a map of appenders by list. Usually called to get a category of appenders.">
		<cfargument name="appenders" type="string" required="true" hint="The list of appenders to get"/>
		<cfscript>
			var x =1;
			var Collections = createObject("java", "java.util.Collections");
			var appendersMap = Collections.synchronizedMap(CreateObject("java","java.util.LinkedHashMap").init(listlen(arguments.appenders)));
			
			// Go over appender's list and configure it
			for(x=1; x lte listlen(arguments.appenders); x=x+1){
				thisAppender = ucase(listGetAt(arguments.appenders,x));
				appendersMap[thisAppender] = getAppender(thisAppender);	
			}
			
			return appendersMap;
		</cfscript>
	</cffunction>
	
	<!--- logMessage --->
	<cffunction name="logMessage" output="false" access="private" returntype="void" hint="Write an entry into the loggers registered with this LogBox instance.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string"  required="true"   hint="The message to log.">
		<cfargument name="severity"  type="numeric" required="true"   hint="The severity level to log.">
		<cfargument name="extraInfo" type="any"     required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfscript>
			// Loop over loggers
			var appenders = getAppenders();
			var key = "";
			var thisAppender = "";
			var logEvent = "";
			
			// Do we have appenders?
			if( NOT hasAppenders() ){ return; }
			
			// If message empty, just exit
			arguments.message = trim(arguments.message);
			if( NOT len(arguments.message) ){ return; }
			
			// Create Logging Event
			logEvent = createobject("component","coldbox.system.logging.LogEvent").init(argumentCollection=arguments);		
				
			// Delegate Calls
			for(key in appenders){
				// Get Appender
				thisAppender = appenders[key];
				// Log Check
				if( thisAppender.canLog(arguments.severity) ){
					// Log the message in the appender
					thisAppender.logMessage(logEvent);
				}
			}
		</cfscript>	
	</cffunction>

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.util.Util")/>
	</cffunction>

</cfcomponent>