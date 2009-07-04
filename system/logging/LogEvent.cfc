<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This resembles a logging event within log box.
----------------------------------------------------------------------->
<cfcomponent name="LogEvent" output="false" hint="Resembles a logging event.">

	<cfscript>
		instance = structnew();
		instance.category = "";
		instance.timestamp = now();
		instance.message = "";
		instance.severity = "";
		instance.extraInfo = "";
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
				instance[key] = arguments[key];
			}
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="getextraInfo" access="public" returntype="any" output="false">
		<cfreturn instance.extraInfo>
	</cffunction>
	<cffunction name="setextraInfo" access="public" returntype="void" output="false">
		<cfargument name="extraInfo" type="any" required="true">
		<cfset instance.extraInfo = arguments.extraInfo>
	</cffunction>
	
	<cffunction name="getcategory" access="public" returntype="string" output="false">
		<cfreturn instance.category>
	</cffunction>
	<cffunction name="setcategory" access="public" returntype="void" output="false">
		<cfargument name="category" type="string" required="true">
		<cfset instance.category = arguments.category>
	</cffunction>
	
	<cffunction name="gettimestamp" access="public" returntype="string" output="false">
		<cfreturn instance.timestamp>
	</cffunction>
	<cffunction name="settimestamp" access="public" returntype="void" output="false">
		<cfargument name="timestamp" type="string" required="true">
		<cfset instance.timestamp = arguments.timestamp>
	</cffunction>
	
	<cffunction name="getmessage" access="public" returntype="string" output="false">
		<cfreturn instance.message>
	</cffunction>
	<cffunction name="setmessage" access="public" returntype="void" output="false">
		<cfargument name="message" type="string" required="true">
		<cfset instance.message = arguments.message>
	</cffunction>
	
	<cffunction name="getseverity" access="public" returntype="numeric" output="false">
		<cfreturn instance.severity>
	</cffunction>
	<cffunction name="setseverity" access="public" returntype="void" output="false">
		<cfargument name="severity" type="numeric" required="true">
		<cfset instance.severity = arguments.severity>
	</cffunction>


</cfcomponent>