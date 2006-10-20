<!---
Author			:	Luis Majano
Create Date		:	September 19, 2006
Update Date		:	September 25, 2006
Description		:

This is the app Builder handler.

--->
<cfcomponent name="ehAppbuilder" extends="coldbox.system.eventhandler">

	<!--- ************************************************************* --->

	<cffunction name="dspAppBuilder" access="public" returntype="void">
		<!--- EXIT HANDLERS --->
		<cfset rc.xehFileBrowser = "ehFileBrowser.dspBrowser">
		<cfset rc.xehGenerate = "ehAppbuilder.generateApplication">
		<!--- Get Locales --->
		<cfset rc.Locales = getPlugin("i18n").getLocales()>
		<!--- Set the View --->
		<cfset setView("tools/vwAppBuilder")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="generateApplication" access="public" returntype="void">
		<cfset var generatorResults = "">
		<!--- param the necessary values --->
		<cfset paramValue("onapplicationstart_cb", "false")>
		<cfset paramValue("onrequeststart_cb", "false")>
		<cfset paramValue("onrequestend_cb", "false")>
		<cfset paramValue("onexception_cb", "false")>
		
		<!--- Start application Generation --->
		<cfset generatorResults = application.dbservice.get("appGeneratorService").generate(getCollection())>
		<!--- Check for Errors --->
		<cfif generatorResults.error >
			<cfset getPlugin("messagebox").setMessage("error", "An error ocurred during generation")>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("info", "Your application has been successfully generated.")>
		</cfif>
		
		<!--- Set the View --->
		<cfset setView("tools/vwAppBuilder")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
</cfcomponent>