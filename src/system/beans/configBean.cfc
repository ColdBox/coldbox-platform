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
<cfcomponent name="configBean" hint="I hole a coldbox configuration file data." output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cfscript>
		variables.configStruct = structnew();
	</cfscript>
	
<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->
	
	<cffunction name="init" access="public" output="false" hint="constructor" returntype="coldbox.system.beans.configBean">
	    <!--- ************************************************************* --->
	    <cfargument name="configStruct" type="struct" required="false" default="#structnew()#" >
	    <!--- ************************************************************* --->
		<cfset setconfigStruct(arguments.configStruct)>
	    <cfreturn this >
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getConfigStruct" access="public" returntype="any" output="false">
		<cfreturn variables.configStruct >
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setconfigStruct" access="public" returntype="void" output="false">
		<cfargument name="configStruct" type="struct" required="true">
		<cfset variables.configStruct = arguments.configStruct>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getKey" access="public" returntype="any" output="false">
		<cfargument name="key" type="string" required="true">
		<cfif keyExists(arguments.key)>
			<cfreturn Evaluate("variables.configStruct.#arguments.key#")>
		<cfelse>
			<cfthrow message="Key not found in configStruct">
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setKey" access="public" returntype="void" output="false">
		<cfargument name="key"   type="string" required="true">
		<cfargument name="value" type="any" required="true">
		<cfscript>
		"variables.configStruct.#arguments.key#" = arguments.value;
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="keyExists" access="public" returntype="any" output="false">
		<cfargument name="key" type="string" required="true">
		<cfreturn isDefined("variables.configStruct.#arguments.key#")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
</cfcomponent>