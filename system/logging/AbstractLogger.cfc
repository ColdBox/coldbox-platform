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
<cfcomponent name="AbstractLogger" hint="This is the abstract interface component for Loggers" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		instance = structnew();
	</cfscript>
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="AbstractLogger" hint="Constructor" output="false" >
		<cfargument name="name"  type="string" required="true" hint="The logger identification name">
		<cfscript>
			/* Create the identification name */
			instance.name = arguments.name;
			/* Unique Instance ID for the object. */
			instance._hash = hash(createUUID()&instance.name);
			/* Flag denoting if the logger is inited or not */
			instance.isLoggerInitialized = false;
			/* The log levels map */
			instance.logLevels = structnew();
			/* The current set logging level */
			instance.logLevel = 0;		
			/* Logger Configuration Properties */
			instance.properties = structnew();
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- Init Log Location --->
	<cffunction name="initLogLocation" access="public" hint="Initialize the logger, runs after init()" output="false" returntype="void">
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get/Set Logger Name --->
	<cffunction name="getname" access="public" output="false" returntype="string" hint="Get name">
		<cfreturn instance.name/>
	</cffunction>
	<cffunction name="setname" access="public" output="false" returntype="void" hint="Set name">
		<cfargument name="name" type="string" required="true"/>
		<cfset instance.name = arguments.name/>
	</cffunction>
	
	<!--- Initied flag --->
	<cffunction name="isLoggerInitialized" access="public" returntype="boolean" output="false" hint="Checks if the logger's internal variables are initialized.">
		<cfreturn instance.isLoggerInitialized>
	</cffunction>
	<cffunction name="setisLoggerInitialized" access="public" returntype="void" output="false" hint="Set's the logger's internal variables flag to initalized.">
		<cfargument name="isLoggerInitialized" type="boolean" required="true">
		<cfset instance.isLoggerInitialized = arguments.isLoggerInitialized>
	</cffunction>
	
	<!--- Get Log Levels --->
	<cffunction name="getlogLevels" access="public" output="false" returntype="struct" hint="Get the logLevels as a structure map. Keys = Log Level Names, Values = Numerical Representation of Log Level">
		<cfreturn instance.logLevels/>
	</cffunction>
	
	<!--- Get/Set the Log Level --->
	<cffunction name="getlogLevel" access="public" output="false" returntype="numeric" hint="Get the current logLevel">
		<cfreturn instance.logLevel/>
	</cffunction>
	<cffunction name="setlogLevel" access="public" output="false" returntype="void" hint="Set the logger's logLevel">
		<cfargument name="logLevel" type="numeric" required="true"/>
		<cfset instance.logLevel = arguments.logLevel/>
	</cffunction>
	
	<!--- Debug --->
	<cffunction name="debug" access="public" output="false" returntype="void" hint="I log a debug message.">
		<!--- ************************************************************* --->
		<cfargument name="Message" type="string" required="yes" hint="The message to log.">
		<cfargument name="ExtraInfo" type="string" required="no" default="" hint="Extra information to append.">
		<!--- ************************************************************* --->
	</cffunction>
	
	<!--- Info --->
	<cffunction name="info" access="public" output="false" returntype="void" hint="I log an information message.">
		<!--- ************************************************************* --->
		<cfargument name="Message" type="string" required="yes" hint="The message to log.">
		<cfargument name="ExtraInfo" type="string" required="no" default="" hint="Extra information to append.">
		<!--- ************************************************************* --->
	</cffunction>
	
	<!--- Trace --->
	<cffunction name="trace" access="public" output="false" returntype="void" hint="I log a trace message.">
		<!--- ************************************************************* --->
		<cfargument name="Message" type="string" required="yes" hint="The message to trace.">
		<cfargument name="ExtraInfo" type="string" required="no" default="" hint="Extra information to append.">
		<!--- ************************************************************* --->
	</cffunction>
	
	<!--- warn --->
	<cffunction name="warn" access="public" output="false" returntype="void" hint="I log a warning message.">
		<!--- ************************************************************* --->
		<cfargument name="Message" type="string" required="yes" hint="The message to log.">
		<cfargument name="ExtraInfo" type="string" required="no" default="" hint="Extra information to append.">
		<!--- ************************************************************* --->
	</cffunction>
	
	<!--- Error --->
	<cffunction name="error" access="public" output="false" returntype="void" hint="I log an error message.">
		<!--- ************************************************************* --->
		<cfargument name="Message" type="string" required="yes" hint="The message to log.">
		<cfargument name="ExtraInfo" type="string" required="no" default="" hint="Extra information to append.">
		<!--- ************************************************************* --->
	</cffunction>
	
	<!--- Fatal --->
	<cffunction name="fatal" access="public" output="false" returntype="void" hint="I log a fatal message.">
		<!--- ************************************************************* --->
		<cfargument name="Message" type="string" required="yes" hint="The message to log.">
		<cfargument name="ExtraInfo" type="string" required="no" default="" hint="Extra information to append.">
		<!--- ************************************************************* --->
	</cffunction>
	
	<!--- Log An Entry --->
	<cffunction name="logEntry" access="public" hint="Log a message" output="false" returntype="void">
		<!--- ************************************************************* --->
		<cfargument name="Severity" 		type="string" 	required="yes" hint="The severity level to log">
		<cfargument name="Message" 			type="string"  	required="yes" hint="The message to log.">
		<cfargument name="ExtraInfo"		type="string"   required="no"  default="" hint="Extra information to append.">
		<!--- ************************************************************* --->
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

	

</cfcomponent>