<!---
Author			:	Luis Majano
Create Date		:	September 19, 2005
Update Date		:	September 25, 2006
Description		:

Informative handler.

--->
<cfcomponent name="ehInfo" extends="coldbox.system.eventhandler" output="false">
	
	<!--- ************************************************************* --->
	<!--- HOME SECTION 													--->
	<!--- ************************************************************* --->
	
	<cffunction name="dspSystemInfo" access="public" returntype="void" output="false">   
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- Check if install folder exists --->
		<cfset rc.InstallFolderExits = directoryExists(ExpandPath("/coldbox/install"))>
		<!--- Check if the samples folder exists --->
		<cfset rc.SampleFolderExists = directoryExists(ExpandPath("/coldbox/samples"))>
		<!--- Set the View --->
		<cfset Context.setView("home/vwSystemInfo")>
	</cffunction>
	
	<cffunction name="dspOnlineResources" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<!--- Set the View --->
		<cfset Context.setView("home/vwOnlineResources")>
	</cffunction>
	
	<cffunction name="dspCFCDocs" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehCFCDocs = "ehInfo.dspCFCDocs">
		<cfset rc.cfcViewer = getPlugin("cfcViewer")>
		<cfset Context.paramValue("show", "")>
		<cfif rc.show eq "plugins">
			<cfset rc.cfcViewer.setup("/coldbox/system/plugins","coldbox/system/plugins")>
		<cfelseif rc.show eq "beans">
			<cfset rc.cfcViewer.setup("/coldbox/system/beans","coldbox/system/beans")>
		<cfelseif rc.show eq "util">
			<cfset rc.cfcViewer.setup("/coldbox/system/util","coldbox/system/util")>
		<cfelse>
			<cfset rc.cfcViewer.setup("/coldbox/system/","coldbox/system/")>
		</cfif>		
		<!--- Set the View --->
		<cfset Context.setView("home/vwCFCDocs")>
	</cffunction>
	
</cfcomponent>