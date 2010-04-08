<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This resembles a logging event within log box.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="Resembles a logging event.">

	<cfscript>
		instance 			= structnew();
		instance.category 	= "";
		instance.timestamp	= now();
		instance.message 	= "";
		instance.severity 	= "";
		instance.extraInfo	= "";
	</cfscript>
	
	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor">
		<cfargument name="message" 	 type="string"  required="true"   hint="The message to log.">
		<cfargument name="severity"  type="numeric" required="true"   hint="The severity level to log.">
		<cfargument name="extraInfo" type="any"     required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
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
	
	<cffunction name="getExtraInfoAsString" access="public" returntype="string" output="false">
		<cfset var info = instance.extraInfo>
		<cfif NOT isSimpleValue(info)>
			<cfreturn info.toString()>
		<cfelse>
			<cfreturn info>
		</cfif>
	</cffunction>
	<cffunction name="getExtraInfo" access="public" returntype="any" output="false">
		<cfreturn instance.extraInfo>
	</cffunction>
	<cffunction name="setExtraInfo" access="public" returntype="void" output="false">
		<cfargument name="extraInfo" type="any" required="true">
		<cfset instance.extraInfo = arguments.extraInfo>
	</cffunction>
	
	<cffunction name="getCategory" access="public" returntype="string" output="false">
		<cfreturn instance.category>
	</cffunction>
	<cffunction name="setCategory" access="public" returntype="void" output="false">
		<cfargument name="category" type="string" required="true">
		<cfset instance.category = arguments.category>
	</cffunction>
	
	<cffunction name="getTimestamp" access="public" returntype="string" output="false">
		<cfreturn instance.timestamp>
	</cffunction>
	<cffunction name="setTimestamp" access="public" returntype="void" output="false">
		<cfargument name="timestamp" type="string" required="true">
		<cfset instance.timestamp = arguments.timestamp>
	</cffunction>
	
	<cffunction name="getMessage" access="public" returntype="string" output="false">
		<cfreturn instance.message>
	</cffunction>
	<cffunction name="setMessage" access="public" returntype="void" output="false">
		<cfargument name="message" type="string" required="true">
		<cfset instance.message = arguments.message>
	</cffunction>
	
	<cffunction name="getSeverity" access="public" returntype="numeric" output="false">
		<cfreturn instance.severity>
	</cffunction>
	<cffunction name="setSeverity" access="public" returntype="void" output="false">
		<cfargument name="severity" type="numeric" required="true">
		<cfset instance.severity = arguments.severity>
	</cffunction>

</cfcomponent>