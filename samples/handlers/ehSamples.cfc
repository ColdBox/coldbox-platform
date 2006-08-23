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
<cfcomponent name="ehSamples" extends="coldbox.system.eventhandler">

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="Any" output="false">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="onAppInit" access="public" returntype="void" output="false">
		<cfset application.localeUtils = getPlugin("i18n").setfwLocale(getSetting("DefaultLocale"))>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="onRequestStart" access="public" returntype="void" output="false">
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="onRequestEnd" access="public" returntype="void" output="false">
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspHome" access="public" returntype="void" output="false">
		<cfset setView("home")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doChangeLocale" access="public" returntype="void" output="false">
		<!--- Change Locale --->
		<cfset application.localeUtils.setfwLocale(getValue("locale"))>
		<cfset dspHome()>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>