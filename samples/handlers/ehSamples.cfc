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
	<cffunction name="onAppInit" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset getPlugin("i18n").setfwLocale(getSetting("DefaultLocale"))>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="onRequestStart" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="dspHome" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection()>
		<!--- Get Log File contents --->
		<cftry>
			<cfset rc.LogFileContents = getPlugin("fileUtilities").readFile(getPlugin("logger").getlogFullPath())>
			<cfcatch type="any">
				<cfset rc.LogFileContents = cfcatch.Detail & cfcatch.message>
			</cfcatch>
		</cftry>
		
		<cfset Event.setView("home")>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="doChangeLocale" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- Change Locale --->
		<cfset getPlugin("i18n").setfwLocale(Event.getValue("locale"))>
		<cfset runEvent("ehSamples.dspHome")>
		<!--- or you can also use, runEvent("ehSamples.dspHome")  
		--->
	</cffunction>

	<!--- ************************************************************* --->

</cfcomponent>