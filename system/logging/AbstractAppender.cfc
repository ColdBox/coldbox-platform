<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	This component is used as a base or interface for creating LogBox appenders
----------------------------------------------------------------------->
<cfcomponent hint="This is the abstract interface component for all LogBox Appenders" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		// The log levels enum as a public property
		this.logLevels = createObject("component","coldbox.system.logging.LogLevels");

		// private instance scope
		instance = structnew();
		// Appender Unique ID */
		instance._hash = createObject('java','java.lang.System').identityHashCode(this);
		// Appender Unique Name
		instance.name = "";
		// Flag denoting if the appender is inited or not. This will be set by LogBox upon succesful creation and registration.
		instance.initialized = false;
		// Appender Configuration Properties
		instance.properties = structnew();
		// Custom Renderer For Messages
		instance.customLayout = "";
		// Appender Logging Level defaults, which is wideeeee open!
		instance.levelMin = this.logLevels.FATAL;
		instance.levelMax = this.logLevels.DEBUG;
	</cfscript>

	<!--- Init --->
	<cffunction name="init" access="public" returntype="AbstractAppender" hint="Constructor called by a Concrete Appender" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 		required="true" hint="The unique name for this appender."/>
		<cfargument name="properties" 	required="false" default="#structnew()#" hint="A map of configuration properties for the appender" colddoc:generic="struct"/>
		<cfargument name="layout" 		required="false" default="" hint="The layout class to use in this appender for custom message rendering."/>
		<cfargument name="levelMin"  	required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN" colddoc:generic="numeric"/>
		<cfargument name="levelMax"  	required="false" default="4" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN" colddoc:generic="numeric"/>
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

			// Levels
			instance.levelMin = arguments.levelMin;
			instance.levelMax = arguments.levelMax;

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERNAL OBSERVERS ------------------------------------------>

	<cffunction name="onRegistration" access="public" hint="Runs after the appender has been created and registered. Implemented by Concrete appender" output="false" returntype="void">
	</cffunction>

	<cffunction name="onUnRegistration" access="public" hint="Runs before the appender is unregistered from LogBox. Implemented by Concrete appender" output="false" returntype="void">
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Level Min --->
	<cffunction name="getlevelMin" access="public" returntype="any" output="false" hint="Get the level min setting" colddoc:generic="numeric">
		<cfreturn instance.levelMin>
	</cffunction>
	<cffunction name="setLevelMin" access="public" output="false" returntype="void" hint="Set the appender's default levelMin">
		<cfargument name="levelMin" required="true"/>
		<cfscript>
			// Verify level
			if( this.logLevels.isLevelValid(arguments.levelMin) AND
			    arguments.levelMin lte getLevelMax() ){
				instance.levelMin = arguments.levelMin;
			}
			else{
				throw("Invalid Log Level","The log level #arguments.levelMin# is invalid or greater than the levelMax (#getLevelMax()#). Valid log levels are from 0 to 5","AbstractAppender.InvalidLogLevelException");
			}
		</cfscript>
	</cffunction>

	<!--- GetSet level Max --->
	<cffunction name="getlevelMax" access="public" returntype="any" output="false" hint="Get the level Max setting" colddoc:generic="numeric">
		<cfreturn instance.levelMax>
	</cffunction>
	<cffunction name="setLevelMax" access="public" output="false" returntype="void" hint="Set the appender's default levelMax">
		<cfargument name="levelMax" required="true"/>
		<cfscript>
			// Verify level
			if( this.logLevels.isLevelValid(arguments.levelMax) AND
			    arguments.levelMax gte getLevelMin() ){
				instance.levelMax = arguments.levelMax;
			}
			else{
				throw("Invalid Log Level","The log level #arguments.levelMax# is invalid or less than the levelMin (#getLevelMin()#). Valid log levels are from 0 to 5","AbstractAppender.InvalidLogLevelException");
			}
		</cfscript>
	</cffunction>

	<!--- ColdBox --->
	<cffunction name="getColdbox" access="public" returntype="any" output="false" hint="Get the ColdBox application controller LogBox is linked to. If not set, it will return an empty string.">
    	<cfreturn instance.coldbox>
    </cffunction>
    <cffunction name="setColdbox" access="public" returntype="void" output="false" hint="Set the ColdBox application link">
    	<cfargument name="coldbox" type="any" required="true">
    	<cfset instance.coldbox = arguments.coldbox>
    </cffunction>

	<!--- getCustomLayout --->
	<cffunction name="getCustomLayout" output="false" access="public" returntype="any" hint="Get the custom layout object">
		<cfreturn instance.customLayout>
	</cffunction>

	<!--- hasCustomLayout --->
	<cffunction name="hasCustomLayout" output="false" access="public" returntype="any" hint="Whether a custom layout has been set or not." colddoc:generic="Boolean">
		<cfreturn isObject(getCustomLayout())>
	</cffunction>

	<!--- severityToString --->
	<cffunction name="severityToString" output="false" access="public" returntype="any" hint="convert a severity to a string">
		<cfargument name="severity" required="true" hint="The numeric severity to convert" colddoc:generic="numeric"/>
		<cfreturn this.logLevels.lookup(arguments.severity)>
	</cffunction>

	<!--- getHash --->
	<cffunction name="getHash" output="false" access="public" returntype="any" hint="Get this appender's unique ID">
		<cfreturn instance._hash>
	</cffunction>

	<!--- Get the name --->
	<cffunction name="getName" access="public" returntype="any" output="false" hint="Get this appender's name">
		<cfreturn instance.name>
	</cffunction>

	<!--- Initied flag --->
	<cffunction name="isInitialized" access="public" returntype="any" output="false" hint="Checks if the appender's internal variables are initialized." colddoc:generic="Boolean">
		<cfreturn instance.initialized>
	</cffunction>
	<cffunction name="setInitialized" access="public" returntype="void" output="false" hint="Set's the appender's internal variables flag to initalized.">
		<cfargument name="initialized" required="true">
		<cfset instance.initialized = arguments.initialized>
	</cffunction>

	<!--- logMessage --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the appender. You must implement this method yourself.">
		<cfargument name="logEvent" type="coldbox.system.logging.LogEvent"   required="true"   hint="The logging event to log.">

		<cfthrow message="This appender '#getMetadata(this).name#' must implement the 'logMessage()' method."
				 type="AbstractAppender.NotImplementedException">
	</cffunction>

	<!--- canLog --->
	<cffunction name="canLog" output="false" access="public" returntype="any" hint="Checks wether a log can be made on this appender using a passed in level" colddoc:generic="Boolean">
		<cfargument name="level" required="true" hint="The level to check if it can be logged in this Appender" colddoc:generic="numeric"/>
		<cfscript>
			return (arguments.level GTE getLevelMin() AND arguments.level LTE getLevelMax() );
		</cfscript>
	</cffunction>

<!------------------------------------------- PROPERTY METHODS ------------------------------------------->

	<!--- getter for the properties structure --->
	<cffunction name="getProperties" access="public" output="false" returntype="any" hint="Get properties structure map" colddoc:generic="struct">
		<cfreturn instance.properties/>
	</cffunction>

	<!--- setter for the properties structure --->
	<cffunction name="setProperties" access="public" output="false" returntype="void" hint="Set the entire properties structure map">
		<cfargument name="properties" required="true" colddoc:generic="struct"/>
		<cfset instance.properties = arguments.properties/>
	</cffunction>

	<!--- get a property --->
	<cffunction name="getProperty" access="public" returntype="any" hint="Get a property, throws exception if not found." output="false" >
		<cfargument name="property" required="true" hint="The key of the property to return.">
		<cfreturn instance.properties[arguments.property]>
	</cffunction>

	<!--- set a property --->
	<cffunction name="setProperty" access="public" returntype="void" hint="Set a property" output="false" >
		<cfargument name="property" required="true" hint="The property name to set.">
		<cfargument name="value" 	required="true" hint="The value of the property.">
		<cfset instance.properties[arguments.property] = arguments.value>
	</cffunction>

	<!--- check for a property --->
	<cffunction name="propertyExists" access="public" returntype="any" hint="Checks wether a given property exists or not." output="false" colddoc:generic="Boolean">
		<cfargument name="property" required="true" hint="The property name">
		<cfreturn structKeyExists(instance.properties,arguments.property)>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="any" hint="Create and return a util object">
		<cfscript>
			if( structKeyExists(instance,"util") ){ return instance.util; }
			instance.util = createObject("component","coldbox.system.core.util.Util");
			return instance.util;
		</cfscript>
	</cffunction>

	<!--- $log --->
	<cffunction name="$log" output="false" access="private" returntype="void" hint="Log an internal message to the ColdFusion facilities.  Used when errors ocurrs or diagnostics">
		<cfargument name="severity" required="true" default="INFO" hint="The severity to use."/>
		<cfargument name="message" 	required="true" default="" hint="The message to log"/>
		<cflog type="#arguments.severity#" file="LogBox" text="#arguments.message#">
	</cffunction>

</cfcomponent>