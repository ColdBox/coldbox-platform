<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I am a config bean. I hold all the configuration file and framework info.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="configBean"
			 hint="I hold a coldbox configuration file data."
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" hint="constructor" returntype="coldbox.system.beans.configBean">
	    <!--- ************************************************************* --->
	    <cfargument name="configStruct" type="struct" required="false" default="#structnew()#" >
	    <!--- ************************************************************* --->
		<cfscript>
		variables.configStruct = structnew();
		setconfigStruct(arguments.configStruct);
		return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

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
			<cfreturn Evaluate("configStruct.#arguments.key#")>
		<cfelse>
			<cfthrow message="Key not found in configStruct">
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setKey" access="public" returntype="void" output="false">
		<cfargument name="key"   type="string" required="true">
		<cfargument name="value" type="any" required="true">
		<cfscript>
		"configStruct.#arguments.key#" = arguments.value;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="keyExists" access="public" returntype="any" output="false">
		<cfargument name="key" type="string" required="true">
		<cfreturn isDefined("configStruct.#arguments.key#")>
	</cffunction>

	<!--- ************************************************************* --->

</cfcomponent>