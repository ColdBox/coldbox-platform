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
		instance.loggerRegistry = "";		 	
	</cfscript>
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="LogBox" hint="Constructor" output="false" >
		<cfargument name="logBoxConfig" type="coldbox.system.logging.config.LogBoxConfig" required="false" hint="If passed, this LogBox instance will be configured with this configuration object."/>
		<cfscript>
			var Collections = createObject("java", "java.util.Collections");
			
			// Prepare Logger Object Registry
			instance.loggerRegistry = Collections.synchronizedMap(CreateObject("java","java.util.LinkedHashMap").init(3));
			
			// Check if using configuration object
			if( structKeyExists(arguments,"logBoxConfig") ){
				registerConfig(arguments.logBoxConfig);
			}
			
			/* Return Factory */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- getHash --->
	<cffunction name="getHash" output="false" access="public" returntype="string" hint="Get this logger's unique ID">
		<cfreturn instance._hash>
	</cffunction>
		
	<!--- Get the Logger Registry --->
	<cffunction name="getLoggers" access="public" returntype="struct" output="false" hint="Get the map of registered loggers.">
		<cfreturn instance.loggerRegistry>
	</cffunction>
	
	<!--- clearLoggers --->
	<cffunction name="clearLoggers" output="false" access="public" returntype="void" hint="Clear all loggers registered">
		<cfset structClear(getLoggers())>
	</cffunction>
		
	<!--- hasLoggers --->
	<cffunction name="hasLoggers" output="false" access="public" returntype="boolean" hint="Checks to see if we have registered any loggers yet">
		<cfreturn NOT getLoggers().isEmpty()>
	</cffunction>
	
	<!--- loggerExists --->
	<cffunction name="loggerExists" output="false" access="public" returntype="boolean" hint="Checks to see if a specified logger exists by name.">
		<cfargument name="name" type="string" required="true" hint="The name of the logger to check if it is registered"/>
		<cfreturn structKeyExists(getLoggers(), arguments.name)>
	</cffunction>
	
	<!--- getLogger --->
	<cffunction name="getLogger" output="false" access="public" returntype="any" hint="Get a specific logger registered with LogBox by name. Else it returns an empty struct.">
		<cfargument name="name" type="string" required="true" hint="The name of the logger to check if it is registered"/>
		<cfscript>
			if( loggerExists(arguments.name) ){
				return structFind(getLoggers(), arguments.name);
			}
			else{
				return structnew();
			}
		</cfscript>
	</cffunction>
	
	<!--- register --->
	<cffunction name="registerConfig" output="false" access="public" returntype="void" hint="Registers all the loggers in a LogBoxConfig object">
		<!--- ************************************************************* --->
		<cfargument name="logBoxConfig" type="coldbox.system.logging.config.LogBoxConfig" required="true"/>
		<!--- ************************************************************* --->
		<cfscript>
			var loggersArray = arguments.logBoxConfig.getLoggers();
			var x =1;
			
			for(x=1; x lte arrayLen(loggersArray); x=x+1){
				// Register configurations.
				registerNew(argumentCollection=loggersArray[x]);	
			}
		</cfscript>
	</cffunction>
	
	<!--- register --->
	<cffunction name="register" output="false" access="public" returntype="void" hint="Register a new or already instantiated logger object.">
		<!--- ************************************************************* --->
		<cfargument name="logger" 		type="coldbox.system.logging.AbstractLogger" required="false" hint="The logger object you would like to register with this instance of Log Box."/>
		<!--- ************************************************************* --->
		<cfset var name = "">
		<!--- Verify Name --->
		<cfif NOT len(arguments.logger.getName())>
			<cfthrow message="Logger does not have a name, please instantiate the logger with a unique name."
					 type="LogBox.InvalidLoggerNameException">
		<cfelse>
			<cfset name = arguments.logger.getName()>
		</cfif>
		<!--- Verify Registration --->
		<cfif NOT loggerExists(name)>
			<cflock name="#getHash()#.#name#" type="exclusive" throwontimeout="true" timeout="30">
				<cfscript>
					if( NOT loggerExists(name) ){
						// Store Logger
						getLoggers().put(name, arguments.logger)
						// run registration event
						arguments.logger.onRegistration();
						// set initialized
						arguments.logger.setInitialized(true);
					}
				</cfscript>
			</cflock>
		<cfelse>
			<cflog type="warning" file="LogBox" text="LogBoxID: #getHash()# - Cannot register logger #name# as it is already registered. Skipping.">
		</cfif>		
	</cffunction>
	
	<!--- create --->
	<cffunction name="registerNew" output="false" access="public" returntype="any" hint="Register a new logger with this instance of LogBox and returns it to you if you like.">
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true"  hint="A unique name for the logger to register. Only unique names can be registered per instance."/>
		<cfargument name="class" 		type="string"  required="true"  hint="The logger's class to register. We will create, init it and register it for you."/>
		<cfargument name="level" 		type="numeric" required="false" default="-1" hint="The default log level for this logger. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="The structure of properties to configure this logger with."/>
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
	<cffunction name="unRegister" output="false" access="public" returntype="boolean" hint="Unregister a logger from LogBox. True if successful or false otherwise.">
		<cfargument name="name" type="string" required="true" hint="The name of the logger to unregister"/>
		<cfset var logger = "">
		<cfif loggerExists(arguments.name)>
			<cfscript>
				// Get logger
				logger = getLogger(arguments.name);
				// Run un-registration event
				logger.onUnRegistration();
				// Unregister it
				getLoggers().remove(arguments.name);				
				return true;
			</cfscript>
		<cfelse>
			<cflog type="warning" file="#getName()#" text="Cannot UnRegister logger #arguments.name# as it does not exist in the current registered loggers.">
			<cfreturn false>
		</cfif>
	</cffunction>

<!------------------------------------------- FACADE Methods ------------------------------------------->

	<!--- Debug --->
	<cffunction name="debug" access="public" output="false" returntype="void" hint="I log a debug message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="yes" hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="no" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfset arguments.severity = this.logLevels.DEBUG>
		<cfset writeEntry(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Info --->
	<cffunction name="info" access="public" output="false" returntype="void" hint="I log an information message.">
		<!--- ************************************************************* --->
		<cfargument name="message"   type="string" required="yes" hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="no" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfset arguments.severity = this.logLevels.INFO>
		<cfset writeEntry(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Trace --->
	<cffunction name="trace" access="public" output="false" returntype="void" hint="I log a trace message.">
		<!--- ************************************************************* --->
		<cfargument name="message"   type="string" required="yes" hint="The message to trace.">
		<cfargument name="extraInfo" type="any"    required="no" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfset arguments.severity = this.logLevels.TRACE>
		<cfset writeEntry(argumentCollection=arguments)>
	</cffunction>
	
	<!--- warn --->
	<cffunction name="warn" access="public" output="false" returntype="void" hint="I log a warning message.">
		<!--- ************************************************************* --->
		<cfargument name="message"   type="string" required="yes" hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="no" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfset arguments.severity = this.logLevels.WARN>
		<cfset writeEntry(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Error --->
	<cffunction name="error" access="public" output="false" returntype="void" hint="I log an error message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="yes" hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="no" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfset arguments.severity = this.logLevels.ERROR>
		<cfset writeEntry(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Fatal --->
	<cffunction name="fatal" access="public" output="false" returntype="void" hint="I log a fatal message.">
		<!--- ************************************************************* --->
		<cfargument name="message"   type="string"  required="yes" hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="no" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfset arguments.severity = this.logLevels.FATAL>
		<cfset writeEntry(argumentCollection=arguments)>
	</cffunction>
		
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- logMessage --->
	<cffunction name="logMessage" output="false" access="private" returntype="void" hint="Write an entry into the loggers registered with this LogBox instance.">
		<cfargument name="message" 	 type="string"  required="true"   hint="The message to log.">
		<cfargument name="severity"  type="numeric" required="true"   hint="The severity level to log.">
		<cfargument name="extraInfo" type="any"     required="no" default="" hint="Extra information to send to the loggers.">
		<cfscript>
			// Loop over loggers
			var loggers = getLoggers();
			var key = "";
			var thisLogger = "";
			
			// If message empty, just exit
			arguments.message = trim(arguments.message);
			if( NOT len(arguments.message) ){ return; }
						
			// Delegate Calls
			for(key in loggers){
				thisLogger = loggers[key];
				thisLogger.writeDelegate(argumentCollection=arguments);
			}
		</cfscript>	
	</cffunction>

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.util.Util")/>
	</cffunction>

</cfcomponent>