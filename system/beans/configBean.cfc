<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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

	<cffunction name="init" access="public" output="false" hint="constructor" returntype="configBean">
	    <!--- ************************************************************* --->
	    <cfargument name="configStruct" type="struct" required="false" default="#structnew()#" hint="A memento of name-value pairs to init">
	    <!--- ************************************************************* --->
		<cfscript>
			variables.configStruct = structnew();
			setconfigStruct(arguments.configStruct);
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get Config Struct --->
	<cffunction name="getConfigStruct" access="public" returntype="any" output="false" hint="Get the memento of name-value pairs">
		<cfreturn variables.configStruct>
	</cffunction>

	<!--- Set Config Struct --->
	<cffunction name="setconfigStruct" access="public" returntype="void" output="false" hint="Override the name-value pairs memento">
		<!--- ************************************************************* --->
		<cfargument name="configStruct" type="struct" required="true">
		<!--- ************************************************************* --->
		<cfset variables.configStruct = arguments.configStruct>
	</cffunction>

	<cffunction name="getKey" access="public" returntype="any" output="false" hin="Get a key from the structure of values. You can nest keys.">
		<!--- ************************************************************* --->
		<cfargument name="key"	 			type="string" required="true" hint="The named key to return.">
		<cfargument name="defaultValue" 	type="any" required="false" default="_NONE_" hint="A default value to return"/>
		<!--- ************************************************************* --->
		<cfif keyExists(arguments.key)>
			<cfreturn Evaluate("configStruct.#arguments.key#")>
		<cfelseif isSimpleValue(arguments.defaultValue) and arguments.defaultValue eq "_NONE_">
			<cfthrow message="Key not found in configStruct">
		<cfelse>
			<cfreturn arguments.defaultValue>
		</cfif>
	</cffunction>

	<cffunction name="setKey" access="public" returntype="void" output="false" hint="Set a new value in the structure">
		<!--- ************************************************************* --->
		<cfargument name="key"   type="string" 	required="true">
		<cfargument name="value" type="any" 	required="true">
		<!--- ************************************************************* --->
		<cfscript>
		"configStruct.#arguments.key#" = arguments.value;
		</cfscript>
	</cffunction>

	<cffunction name="keyExists" access="public" returntype="any" output="false" hint="Check if a key is in the structure.">
		<!--- ************************************************************* --->
		<cfargument name="key" type="string" required="true">
		<!--- ************************************************************* --->
		<cfreturn isDefined("configStruct.#arguments.key#")>
	</cffunction>

</cfcomponent>