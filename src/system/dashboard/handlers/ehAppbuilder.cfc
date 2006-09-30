<!---
Author			:	Luis Majano
Create Date		:	September 19, 2006
Update Date		:	September 25, 2006
Description		:

This is the app Builder handler.

--->
<cfcomponent name="ehAppbuilder" extends="coldbox.system.eventhandler">

	<!--- ************************************************************* --->

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfset super.Init()>
		<cfreturn this>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="dspAppBuilder" access="public" returntype="void">
		<!--- Get Locales --->
		<cfset rc.Locales = getPlugin("i18n").getLocales()>
		<!--- Set the View --->
		<cfset setView("tools/vwAppBuilder")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	
	
</cfcomponent>