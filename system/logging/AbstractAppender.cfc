<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	This component is used as a base or interface for creating LogBox appenders
----------------------------------------------------------------------->
<cfcomponent name="AbstractAppender" hint="This is the abstract interface component for all LogBox Appenders" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		// The log levels enum as a public property
		this.logLevels = createObject("component","coldbox.system.logging.LogLevels");
		
		// private instance scope
		instance = structnew();
		// Appender Unique ID */
		instance._hash = hash(createUUID());
		// Appender Unique Name
		instance.name = "";
		// Flag denoting if the appender is inited or not. This will be set by LogBox upon succesful creation and registration.
		instance.initialized = false;
		// Appender Configuration Properties
		instance.properties = structnew();
		// Custom Renderer For Messages
		instance.customLayout = "";
	</cfscript>
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="AbstractAppender" hint="Constructor called by a Concrete Appender" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true" hint="The unique name for this appender."/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="A map of configuration properties for the appender"/>
		<cfargument name="layout" 		type="string"  required="true"  default="" hint="The layout class to use in this appender for custom message rendering."/>
		<!--- ************************************************************* --->
		<cfscript>
			// Appender's Name
			instance.name = REreplacenocase(arguments.name, "[^0-9a-z]","","ALL");
			
			// Set internal properties	
			instance.properties = arguments.properties;
			
			//Custom Layout?
			if( len(trim(arguments.layout)) ){
				instance.customLayout = createObject("component",arguments.layout).init(this);
			}
					
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- INTERNAL OBSERVERS ------------------------------------------>

	<cffunction name="onRegistration" access="public" hint="Runs after the appender has been created and registered. Implemented by Concrete appender" output="false" returntype="void">
	</cffunction>

	<cffunction name="onUnRegistration" access="public" hint="Runs before the appender is unregistered from LogBox. Implemented by Concrete appender" output="false" returntype="void">
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- getCustomLayout --->
	<cffunction name="getCustomLayout" output="false" access="public" returntype="any" hint="Get the custom layout object">
		<cfreturn instance.customLayout>
	</cffunction>
	
	<!--- hasCustomLayout --->
	<cffunction name="hasCustomLayout" output="false" access="public" returntype="Boolean" hint="Whether a custom layout has been set or not.">
		<cfreturn isObject(getCustomLayout())>
	</cffunction>
	
	<!--- severityToString --->
	<cffunction name="severityToString" output="false" access="public" returntype="string" hint="convert a severity to a string">
		<cfargument name="severity" type="numeric" required="true" hint="The severity to convert"/>
		<cfreturn this.logLevels.lookup(arguments.severity)>
	</cffunction>
	
	<!--- getHash --->
	<cffunction name="getHash" output="false" access="public" returntype="string" hint="Get this appender's unique ID">
		<cfreturn instance._hash>
	</cffunction>
	
	<!--- Get the name --->
	<cffunction name="getName" access="public" returntype="string" output="false" hint="Get this appender's name">
		<cfreturn ucase(instance.name)>
	</cffunction>
	
	<!--- Initied flag --->
	<cffunction name="isInitialized" access="public" returntype="boolean" output="false" hint="Checks if the appender's internal variables are initialized.">
		<cfreturn instance.initialized>
	</cffunction>
	<cffunction name="setInitialized" access="public" returntype="void" output="false" hint="Set's the appender's internal variables flag to initalized.">
		<cfargument name="initialized" type="boolean" required="true">
		<cfset instance.initialized = arguments.initialized>
	</cffunction>
		
	<!--- logMessage --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the appender. You must implement this method yourself.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="coldbox.system.logging.LogEvent"   required="true"   hint="The logging event to log.">
		<!--- ************************************************************* --->
		<cfthrow message="This appender '#getMetadata(this).name#' must implement the 'logMessage()' method."
				 type="AbstractAppender.NotImplementedException">
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
	
	<!--- $log --->
	<cffunction name="$log" output="false" access="public" returntype="void" hint="Log an internal message to the ColdFusion facilities.  Used when errors ocurrs or diagnostics">
		<cfargument name="severity" type="string" required="true" default="INFO" hint="The severity to use."/>
		<cfargument name="message" type="string" required="true" default="" hint="The message to log"/>
		<cflog type="#arguments.severity#" file="LogBox" text="#arguments.message#">
	</cffunction>

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