<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I am a config bean. I hold all the configuration file and framework info.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="configBean" hint="I model an application's configuration." output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cfscript>
		variables.instance = structnew();
	</cfscript>
	
<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->
	
	<cffunction name="init" access="public" output="false" hint="I build a new datasource bean." returntype="any">
	    <!--- ************************************************************* --->
	    <cfargument name="datasourceStruct" 	type="struct" required="false" default="#structnew()#" hint="The structure holding the name,dbtype,username,and password variables." >
	    <!--- ************************************************************* --->
	    <cfif not structisEmpty(arguments.datasourceStruct)>
		    <cfset setInstance(arguments.datasourceStruct)>
	    </cfif>
	    <cfreturn this >
	</cffunction>
	
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
	
</cfcomponent>