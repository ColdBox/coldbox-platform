<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	This component is used as a base or interface for creating ColdBox Loggers
----------------------------------------------------------------------->
<cfcomponent name="AbstractLogger" hint="This is the abstract interface component for all LogBox Loggers" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		// The log levels enum as a public property
		this.logLevels = createObject("component","coldbox.system.logging.LogLevels");
		
		// private instance scope
		instance = structnew();
		// Logger Unique ID */
		instance._hash = hash(createUUID());
		// Logger Unique Name
		instance.name = "";
		// Flag denoting if the logger is inited or not. This will be set by LogBox upon succesful creation and registration.
		instance.initialized = false;
		// The current set logging level. By default we go with the highest possible
		instance.logLevel = this.logLevels.TRACE;		
		// Logger Configuration Properties
		instance.properties = structnew();			
	</cfscript>
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="AbstractLogger" hint="Constructor called by a Concrete Logger" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true" hint="The unique name for this logger."/>
		<cfargument name="level" 		type="numeric" required="false" default="-1" hint="The default log level for this logger. If not passed, then it will use the highest logging level available."/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="A map of configuration properties for the logger"/>
		<!--- ************************************************************* --->
		<cfscript>
			// Logger's Name
			instance.name = REreplacenocase(arguments.name, "[^0-9a-z]","","ALL");
			
			// Set internal properties	
			instance.properties = arguments.properties;
			
			// Setup the default log level
			if( arguments.level gt -1 ){ 
				setLogLevel(arguments.level);
			}
					
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- INTERNAL OBSERVERS ------------------------------------------>

	
	<cffunction name="onRegistration" access="public" hint="Runs after the logger has been created and registered. Implemented by Concrete Logger" output="false" returntype="void">
	</cffunction>

	<cffunction name="onUnRegistration" access="public" hint="Runs before the logger is unregistered from LogBox. Implemented by Concrete Logger" output="false" returntype="void">
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- getHash --->
	<cffunction name="getHash" output="false" access="public" returntype="string" hint="Get this logger's unique ID">
		<cfreturn instance._hash>
	</cffunction>
	
	<!--- Get the name --->
	<cffunction name="getname" access="public" returntype="string" output="false" hint="Get this logger's name">
		<cfreturn instance.name>
	</cffunction>
	
	<!--- Initied flag --->
	<cffunction name="isLoggerInitialized" access="public" returntype="boolean" output="false" hint="Checks if the logger's internal variables are initialized.">
		<cfreturn instance.initialized>
	</cffunction>
	<cffunction name="setInitialized" access="public" returntype="void" output="false" hint="Set's the logger's internal variables flag to initalized.">
		<cfargument name="initialized" type="boolean" required="true">
		<cfset instance.initialized = arguments.initialized>
	</cffunction>
	
	<!--- Get/Set the Log Level --->
	<cffunction name="getlogLevel" access="public" output="false" returntype="numeric" hint="Get the current default logLevel">
		<cfreturn instance.logLevel/>
	</cffunction>
	<cffunction name="setlogLevel" access="public" output="false" returntype="void" hint="Set the logger's default logLevel">
		<cfargument name="logLevel" type="numeric" required="true"/>
		<cfscript>
			// Verify level
			if( arguments.logLevel gte this.logLevels.minLevel OR arguments.logLevel lte this.logLevels.maxLevel ){
				instance.logLevel = arguments.logLevel;
			}
			else{
				$throw("Invalid Log Level","The log level #arguments.logLevel# is invalid. Valid log levels are from 0 to 5","AbstractLogger.InvalidLogLevelException");
			}
		</cfscript>
	</cffunction>

	<!--- writeDelegate --->
	<cffunction name="writeDelegate" output="false" access="public" returntype="void" hint="Delegate a write call if the log level permits it. DO NOT OVERRIDE THIS METHOD IF POSSIBLE">
		<cfargument name="message" 	 type="string"  required="true"   hint="The message to log.">
		<cfargument name="severity"  type="numeric" required="true"   hint="The severity level to log.">
		<cfargument name="extraInfo" type="any"    required="no" default="" hint="Extra information to send to the loggers.">
		<cfscript>
			// Check log levels?
			if ( arguments.severity LTE getLogLevel() ){
				// Delegate to writeEntry method of concrete logger.
				logMessage(argumentCollection=arguments);
			}
		</cfscript>
	</cffunction>
	
	<!--- logMessage --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the logger. You must implement this method yourself.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string"   required="true"   hint="The message to log.">
		<cfargument name="severity"  type="numeric"  required="true"   hint="The severity level to log.">
		<cfargument name="extraInfo" type="any"      required="no" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfthrow message="This logger '#getMetadata(this).name#' must implement the 'logMessage()' method."
				 type="AbstractLogger.NotImplementedException">
	</cffunction>

<!------------------------------------------- PROPERTY METHODS ------------------------------------------->
	
	<!--- getter for the properties structure --->
	<cffunction name="getProperties" access="public" output="false" returntype="struct" hint="Get properties structure map">
		<cfreturn instance.properties/>
	</cffunction>
	
	<!--- setter for the properties structure --->
	<cffunction name="setProperties" access="public" output="false" returntype="void" hint="Set the entire properties structure map">
		<cfargument name="properties" type="struct" required="true"/>
		<cfset instance.properties = arguments.properties/>
	</cffunction>
	
	<!--- get a property --->
	<cffunction name="getProperty" access="public" returntype="any" hint="Get a property, throws exception if not found." output="false" >
		<cfargument name="property" required="true" type="string" hint="The key of the property to return.">
		<cfreturn instance.properties[arguments.property]>
	</cffunction>
	
	<!--- set a property --->
	<cffunction name="setProperty" access="public" returntype="void" hint="Set a property" output="false" >
		<cfargument name="property" required="true" type="string" 	hint="The property name to set.">
		<cfargument name="value" 	required="true" type="any" 		hint="The value of the property.">
		<cfset instance.properties[arguments.property] = arguments.value>
	</cffunction>
	
	<!--- check for a property --->
	<cffunction name="propertyExists" access="public" returntype="boolean" hint="Checks wether a given property exists or not." output="false" >
		<cfargument name="property" required="true" type="string" hint="The property name">
		<cfreturn structKeyExists(instance.properties,arguments.property)>		
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Throw Facade --->
	<cffunction name="$throw" access="private" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	
	<!--- Dump facade --->
	<cffunction name="$dump" access="private" hint="Facade for cfmx dump" returntype="void">
		<cfargument name="var" required="yes" type="any">
		<cfargument name="isAbort" type="boolean" default="false" required="false" hint="Abort also"/>
		<cfdump var="#var#">
		<cfif arguments.isAbort><cfabort></cfif>
	</cffunction>
	
	<!--- Rethrow Facade --->
	<cffunction name="$rethrowit" access="private" returntype="void" hint="Rethrow facade" output="false" >
		<cfargument name="throwObject" required="true" type="any" hint="The cfcatch object">
		<cfthrow object="#arguments.throwObject#">
	</cffunction>
	
	<!--- Abort Facade --->
	<cffunction name="$abort" access="private" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>

</cfcomponent>