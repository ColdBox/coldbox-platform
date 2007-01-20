<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I model a ColdBox Event Handler

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="eventhandlerBean" hint="I model a ColdBox event handler" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
	variables.instance = structnew();
	variables.instance.handler = "";
	variables.instance.method = "";
	</cfscript>
	

	<!--- ************************************************************* --->
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="eventhandler" type="any" required="true" hint="Eventh handler syntax string." />
		<cfset variables.instance.handler = getToken(arguments.eventhandler,1,".")>
		<cfset variables.instance.method = getToken(arguments.eventhandler,2,".")>
		<cfreturn this >
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- ************************************************************* --->
	
	<cffunction name="getInstance" access="public" returntype="any" output="false">
		<cfreturn variables.instance >
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setInstance" access="public" returntype="void" output="false">
		<cfargument name="instance" type="struct" required="true">
		<cfset variables.instance = arguments.instance>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getName" access="public" returntype="any" output="false">
		<cfreturn variables.instance.handler & "." & variables.instance.method>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getHandler" access="public" returntype="any" output="false">
		<cfreturn variables.instance.handler >
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getMethod" access="public" returntype="any" output="false">
		<cfreturn variables.instance.method >
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setHandler" access="public" returntype="void" output="false">
		<cfargument name="handler" type="any" required="true" />
		<cfset variables.instance.handler = arguments.handler >
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setMethod" access="public" returntype="void" output="false">
		<cfargument name="method" type="any" required="true" />
		<cfset variables.instance.method = arguments.method>
	</cffunction>
	
	<!--- ************************************************************* --->

</cfcomponent>