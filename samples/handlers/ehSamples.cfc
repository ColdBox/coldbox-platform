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
<cfcomponent name="ehSamples" extends="coldbox.system.eventhandler" output="false">
	
	<!--- ************************************************************* --->
	<cffunction name="onAppInit" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="onRequestStart" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="dspHome" access="public" returntype="void" output="false" cache="true" cachetimeout="1">
		<cfargument name="Event" type="any">
		<cfset var rc = Event.getCollection()>
		<cfset Event.setView("home")>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="doChangeLocale" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<!--- Change Locale --->
		<cfset getPlugin("i18n").setfwLocale(Event.getValue("locale"))>
		
		<cfset setNextEvent('ehSamples.dspHome')>
	</cffunction>

	<!--- ************************************************************* --->

</cfcomponent>