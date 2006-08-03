<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :
	General handler for my hello application. Please remember to alter
	your extends base component using the Coldfusion Mapping.

	example:
		Mapping: fwsample
		Argument Type: fwsample.system.eventhandler
Modification History:
Sep/25/2005 - Luis Majano
	-Created the template.
----------------------------------------------------------------------->
<cfcomponent name="ehSamples" extends="system.eventhandler">

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="Any">
		<cfargument name="controller" required="yes" hint="The reference to the framework controller">
		<cfset super.init(arguments.controller)>
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="onRequestStart" access="public">
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="onRequestEnd" access="public">
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspHome" access="public" returntype="string">
		<!--- Set View --->
		<cfset setView("home")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doChangeLocale" access="public" returntype="void">
		<!--- Change Locale --->
		<cfset getPlugin("i18n").setfwLocale(getValue("locale"))>
		<cfset dspHome()>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>