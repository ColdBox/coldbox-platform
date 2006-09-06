<!-----------------------------------------------------------------------
Author 	 :	Oscar Arevalo
Date     :	February 13, 2006
Description :
	General handler for my ColdboxReader application.

Modification History:
feb/13/2006 - Oscar Arevalo
	-Created the template.
aug/20/2006 - Luis Majano
	- Modified for 1.1.0
----------------------------------------------------------------------->
<cfcomponent name="ehGeneral" extends="coldbox.system.eventhandler">

	<cffunction name="init" access="public" returntype="ehGeneral" output="false">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>

	<cffunction name="onRequestStart" access="public" returntype="void" output="false">
		<!--- Session param --->
		<cfparam name="session.userID" 		default="">
		<cfparam name="session.username" 	default="">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSearch = "ehFeed.doSearchByTerm">
	</cffunction>

	<cffunction name="onException" access="public" returntype="void" output="false">
		<!--- My own Exception Handler --->
		<!--- Log error --->
		<cfset var exceptionBean = getValue("ExceptionBean")>
		<!--- Do per Type Validations, example here --->
		<cfif exceptionBean.getType eq "Framework.plugins.settings.EventSyntaxInvalidException">
			<cfset getPlugin("messagebox").setMessage("warning", "No page found with that syntax.")>
			<!--- Relocate to default event --->
			<cfset setNextEvent()>
		<cfelse>
			<cfset getPlugin("logger").logErrorWithBean(exceptionBean)>
		</cfif>
	</cffunction>

	<cffunction name="dspStart" access="public" returntype="void" output="false">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehReader = "ehGeneral.dspReader">
		<cfset setView("vwMain")>
	</cffunction>

	<cffunction name="dspReader" access="public" returntype="void" output="false">
		<cfset var obj = createObject("component","#getSetting("AppMapping")#.components.feed")>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehViewFeed = "ehFeed.dspViewFeed">
		<cfset rc.xehShowTags = "ehFeed.dspAllTags">
		<cfset rc.xehShowInfo = "ehGeneral.dspInfo">
		<cfset rc.xehAccountActions = "ehUser.dspAccountActions">
		<!--- Get Feeds --->
		<cfset rc.qryFeeds = obj.getAllFeeds()>
		<cfquery name="rc.qryTopFeeds" dbtype="query" maxrows="5">
			SELECT *
				FROM rc.qryFeeds
				ORDER BY Views DESC
		</cfquery>
		<cfset setView("vwReader")>
	</cffunction>

	<cffunction name="dspInfo" access="public" returntype="void" output="false">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehLogin = "ehUser.dspLogin">
		<cfset rc.xehSignup = "ehUser.dspSignUp">
		<cfset setView("vwInfo")>
	</cffunction>


</cfcomponent>