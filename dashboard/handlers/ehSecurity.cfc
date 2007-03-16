<!---
Author			:	Luis Majano
Create Date		:	March 10, 2007
Description		:

This is the security handler

--->
<cfcomponent name="ehSecurity" extends="coldbox.system.eventhandler" output="false">

	<!--- ************************************************************* --->
	<!--- LOGIN SECTION													--->
	<!--- ************************************************************* --->
	
	<cffunction name="dspLogin" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- EVENT HANDLERS: --->
		<cfset Event.getCollection().xehLogin = "ehSecurity.doLogin">
		<!--- Set the View --->
		<cfset Event.setView("vwLogin")>
	</cffunction>
	
	<cffunction name="doLogin" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- Do Login --->
		<cfif len(trim(Event.getValue("password",""))) eq 0>
			<cfset getPlugin("messagebox").setMessage("error", "Please fill out the password field.")>
			<cfset setNextEvent()>
		</cfif>
		<cfif getColdboxOCM().get("dbservice").get("settings").validatePassword(Event.getValue("password"))>
			<!--- Validate user --->
			<cfset getPlugin("sessionstorage").setVar("authorized",true)>
			<cfset setNextEvent()>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("error", "The password you entered is not correct. Please try again.")>
			<cfset setNextEvent()>
		</cfif>
	</cffunction>
	
	<cffunction name="doLogout" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset getPlugin("sessionstorage").deleteVar("authorized")>
		<cfset SetNextEvent("ehSecurity.dspLogin")>
	</cffunction>
		
</cfcomponent>