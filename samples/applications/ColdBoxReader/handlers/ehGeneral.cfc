<!-----------------------------------------------------------------------
Author 	 :	Oscar Arevalo
Date     :	February 13, 2006
Description :
	General handler for my ColdboxReader application.

	example:
		Mapping: fwsample
		Argument Type: fwsample.system.eventhandler
Modification History:
feb/13/2006 - Oscar Arevalo
	-Created the template.
----------------------------------------------------------------------->
<cfcomponent name="ehGeneral" extends="coldboxSamples.system.eventhandler">

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="ehGeneral">
		<cfargument name="controller" required="yes" hint="The reference to the framework controller">
		<cfset super.init(arguments.controller)>
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="onRequestStart" access="public">
		<cfparam name="session.userid" default="">
		<cfif session.userid eq "">
			<cfset setNextEvent = "ehGeneral.dspStart">
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="onRequestEnd" access="public">
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspStart" access="public">
		<cfparam name="session.userid" default="">
		<cfset setView("vwMain")>
	</cffunction>
	<!--- ************************************************************* --->


	<cffunction name="dspReader" access="public">
		<cfset obj = createObject("component","#getSetting("AppCFMXMapping")#.components.feed")>
		<cfset setValue("qryFeeds",obj.getAllFeeds())>
		<cfset setView("vwReader")>
	</cffunction>
</cfcomponent>