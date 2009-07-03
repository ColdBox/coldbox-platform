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
		// LoggersList
		instance.appenderRegistry = "";	
		// Version
		instance.version = "1.0";	 	
	</cfscript>
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="LogBox" hint="Constructor" output="false" >
		<cfargument name="logBoxConfig" type="coldbox.system.logging.config.LogBoxConfig" required="false" hint="If passed, this LogBox instance will be configured with this configuration object."/>
		<cfscript>
			var Collections = createObject("java", "java.util.Collections");
			
			// Prepare Logger Object Registry
			instance.appenderRegistry = Collections.synchronizedMap(CreateObject("java","java.util.LinkedHashMap").init(3));
			
			// Check if using configuration object
			if( structKeyExists(arguments,"logBoxConfig") ){
				registerConfig(arguments.logBoxConfig);
			}
			
			/* Return Factory */
			return this;
		</cfscript>
	</cffunction>
	
	<!--- Get Version --->
	<cffunction name="getVersion" access="public" returntype="string" output="false" hint="Get the LogBox version string.">
		<cfreturn instance.Version>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- getHash --->
	<cffunction name="getHash" output="false" access="public" returntype="string" hint="Get this Log Box's unique ID">
		<cfreturn instance._hash>
	</cffunction>
		
	<!--- clearAppenders --->
	<cffunction name="clearAppenders" output="false" access="public" returntype="void" hint="Clear all appenders registered">
		<cfset structClear(getAppenders())>
	</cffunction>
		
	<!--- hasAppenders --->
	<cffunction name="hasAppenders" output="false" access="public" returntype="boolean" hint="Checks to see if we have registered any appenders yet">
		<cfreturn NOT getAppenders().isEmpty()>
	</cffunction>
	
	<!--- appenderExists --->
	<cffunction name="appenderExists" output="false" access="public" returntype="boolean" hint="Checks to see if a specified appender exists by name.">
		<cfargument name="name" type="string" required="true" hint="The name of the appender to check if it is registered"/>
		<cfreturn structKeyExists(getAppenders(), arguments.name)>
	</cffunction>

	<!--- register --->
	<cffunction name="registerConfig" output="false" access="public" returntype="void" hint="Registers all the appenders in a LogBoxConfig object">
		<!--- ************************************************************* --->
		<cfargument name="logBoxConfig" type="coldbox.system.logging.config.LogBoxConfig" required="true"/>
		<!--- ************************************************************* --->
		<cfscript>
			var appendersArray = arguments.logBoxConfig.getAppenders();
			var x =1;
			
			for(x=1; x lte arrayLen(appendersArray); x=x+1){
				// Register configurations.
				registerNew(argumentCollection=appendersArray[x]);	
			}
		</cfscript>
	</cffunction>
	
	<!--- register --->
	<cffunction name="register" output="false" access="public" returntype="void" hint="Register a new or already instantiated appender object.">
		<!--- ************************************************************* --->
		<cfargument name="appender" 	type="coldbox.system.logging.AbstractAppender" required="false" hint="The appender object you would like to register with this instance of Log Box."/>
		<!--- ************************************************************* --->
		<cfset var name = "">
		<!--- Verify Name --->
		<cfif NOT len(arguments.appender.getName())>
			<cfthrow message="Appender does not have a name, please instantiate the appender with a unique name."
					 type="LogBox.InvalidAppenderNameException">
		<cfelse>
			<cfset name = arguments.appender.getName()>
		</cfif>
		<!--- Verify Registration --->
		<cfif NOT appenderExists(name)>
			<cflock name="#getHash()#.#name#" type="exclusive" throwontimeout="true" timeout="30">
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
			<cflog type="warning" file="LogBox" text="LogBoxID: #getHash()# - Cannot register appender #name# as it is already registered. Skipping.">
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
			// Create Logger?
			var target = createObject("component",arguments.class).init(argumentCollection=arguments);
			
			// Register it
			register(target);
			
			return target;
		</cfscript>		
	</cffunction>
	
	<!--- unRegister --->
	<cffunction name="unRegister" output="false" access="public" returntype="boolean" hint="Unregister an appender from LogBox. True if successful or false otherwise.">
		<cfargument name="name" type="string" required="true" hint="The name of the appender to unregister"/>
		<cfset var appender = "">
		<cfset var allAppenders = getAppenders()>
		
		<cfif appenderExists(arguments.name)>
			<cfscript>
				// Get logger
				appender = structFind(allAppenders, arguments.name);			
				// Run un-registration event
				appender.onUnRegistration();
				// Unregister it
				allAppenders.remove(arguments.name);	
							
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
			
			// Dependencies
			logger.logLevels = this.logLevels;
			logger.logBox = this;
			
			// Init it
			return logger.init(arguments.category);			
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
	
	<!--- Get the appender Registry --->
	<cffunction name="getAppenders" access="private" returntype="struct" output="false" hint="Get the map of registered loggers.">
		<cfreturn instance.appenderRegistry>
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
			
			// If message empty, just exit
			arguments.message = trim(arguments.message);
			if( NOT len(arguments.message) ){ return; }
			
			// Create Logging Event
			logEvent = createobject("component","coldbox.system.logging.LogEvent").init(argumentCollection=arguments);		
				
			// Delegate Calls
			for(key in appenders){
				// Get logger
				thisAppender = appenders[key];
				// Log Check
				if( thisAppender.canLog(arguments.severity) ){
					
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