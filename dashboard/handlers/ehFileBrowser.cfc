<!---
Author			:	Luis Majano
Create Date		:	September 19, 2006
Update Date		:	September 25, 2006
Description		:

This is the File Browser Handler

--->
<cfcomponent name="ehFileBrowser" extends="coldbox.system.eventhandler">

	<!--- ************************************************************* --->

	<cffunction name="dspBrowser" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehBrowser = "ehFileBrowser.dspBrowser">
		<cfset rc.xehNewFolder = "ehFileBrowser.doNewFolder">
		
		<cfif valueExists("callbackItem")>
			<cfset session.callBackItem = Event.getValue("callbackItem")>
		<cfelseif not structKeyExists(session, "callBackItem")>
			<cfdump var="You need a callBackItem in order to use the browser chooser">
			<cfaborT>
		</cfif>
		
		<!--- Test for dir param,else set to / --->
		<cfset Event.paramValue("dir","/")>
		<cfif Event.getValue("dir") eq "">
			<cfset Event.setValue("dir","/")>
		</cfif>
		<!--- Init Options --->
		<cfif Event.getValue("dir") eq "/">
			<cfset rc.currentRoot = "/">
			<cfset session.oldRoot = "/">
			<cfset session.currentRoot = "/">
		<cfelse>
			<cfset rc.currentRoot = Event.getValue("dir")>
			<cfset session.oldRoot = listdeleteAt(rc.currentRoot, listlen(rc.currentRoot,"/"), "/")>
			<cfif session.oldRoot eq "">
				<cfset session.oldRoot = "/">
			</cfif>
			<cfset session.currentRoot = rc.currentRoot>
		</cfif>
		
		<cfdirectory action="list" directory="#expandPath(rc.currentRoot)#" name="rc.qryDir" sort="asc">
		<cfset rc.qryDir = sortQuery(rc.qryDir,"Type,Name")>
		
		<cfset Event.setView("tags/serverbrowser")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="doNewFolder" access="public" returntype="void">
		<cfset var newDir = "">
		<!--- Check for incoming params --->
		<cfif len(trim(Event.getValue("newFolder",""))) eq 0>
			<cfset getPlugin("messagebox").setMessage("warning", "Please enter a valid folder name.")>
		<cfelse>
		    <cfset newDir = Event.getValue("dir") & "/" & Event.getValue("NewFolder")>
			<cfdirectory action="create" directory="#ExpandPath(newDir)#">
			<cfset getPlugin("messagebox").setMessage("info", "Folder Created Successfully")>
		</cfif>
		
		<!--- Set the next event --->
		<cfset setNextEvent("ehFileBrowser.dspBrowser","dir=#Event.getValue("dir")#")>
	</cffunction>
	
	<!--- ************************************************************* --->
</cfcomponent>