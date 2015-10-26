<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	This resembles a logging event within LogBox
----------------------------------------------------------------------->
<cfcomponent output="false" hint="Resembles a logging event within logBox.">

	<cfscript>
		instance 			= structnew();
		instance.category 	= "";
		instance.timestamp	= now();
		instance.message 	= "";
		instance.severity 	= "";
		instance.extraInfo	= "";
		// converters
		instance.xmlConverter = createObject("component","coldbox.system.core.conversion.XMLConverter").init();
	</cfscript>
	
	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor">
		<cfargument name="message" 	 required="true"   hint="The message to log.">
		<cfargument name="severity"  required="true"   hint="The severity level to log." colddoc:generic="numeric">
		<cfargument name="extraInfo" required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<cfscript>
			var key = "";
			for(key in arguments){
				if( isSimpleValue(arguments[key]) ){
					arguments[key] = trim(arguments[key]);	
				}
				instance[key] = arguments[key];
			}
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="getExtraInfoAsString" access="public" returntype="any" output="false" hint="Get the extra info as a string representation">
		<cfscript>
			// Simple value, just return it
			if( isSimpleValue(instance.extraInfo) ){ return instance.extraInfo; }
			
			// Convention translation: $toString();
			if( isObject(instance.extraInfo) AND structKeyExists(instance.extraInfo,"$toString") ){ return instance.extraInfo.$toString(); }
		
			// Component XML conversion
			if( isObject(instance.extraInfo) ){
				return instance.xmlConverter.toXML( instance.extraInfo );
			}
			
			// Complex values, return serialized in json
			return serializeJSON( instance.extraInfo );			
		</cfscript>
	</cffunction>
	
	<cffunction name="getExtraInfo" access="public" returntype="any" output="false" hint="Get the extra info param">
		<cfreturn instance.extraInfo>
	</cffunction>
	<cffunction name="setExtraInfo" access="public" returntype="void" output="false" hint="Set the extra info param">
		<cfargument name="extraInfo" required="true">
		<cfset instance.extraInfo = arguments.extraInfo>
	</cffunction>
	
	<cffunction name="getCategory" access="public" returntype="any" output="false" hint="Get the category of this log">
		<cfreturn instance.category>
	</cffunction>
	<cffunction name="setCategory" access="public" returntype="void" output="false" hint="Set the category">
		<cfargument name="category" required="true">
		<cfset instance.category = arguments.category>
	</cffunction>
	
	<cffunction name="getTimestamp" access="public" returntype="any" output="false" hint="Get the timestamp">
		<cfreturn instance.timestamp>
	</cffunction>
	<cffunction name="setTimestamp" access="public" returntype="void" output="false" hint="Set the timestamp">
		<cfargument name="timestamp" required="true">
		<cfset instance.timestamp = arguments.timestamp>
	</cffunction>
	
	<cffunction name="getMessage" access="public" returntype="any" output="false" hint="Get the message to log">
		<cfreturn instance.message>
	</cffunction>
	<cffunction name="setMessage" access="public" returntype="void" output="false" hint="Set the message to log">
		<cfargument name="message" required="true">
		<cfset instance.message = arguments.message>
	</cffunction>
	
	<cffunction name="getSeverity" access="public" returntype="any" output="false" hint="Get the severity to log" colddoc:generic="numeric">
		<cfreturn instance.severity>
	</cffunction>
	<cffunction name="setSeverity" access="public" returntype="void" output="false" hint="Set the severity to log">
		<cfargument name="severity" required="true">
		<cfset instance.severity = arguments.severity>
	</cffunction>

</cfcomponent>