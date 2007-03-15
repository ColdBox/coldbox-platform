<!---
Author			:	Luis Majano
Create Date		:	September 19, 2005
Update Date		:	September 25, 2006
Description		:

Bug handler

--->
<cfcomponent name="ehBugs" extends="coldbox.system.eventhandler">
	
	<!--- ************************************************************* --->
	<!--- SUBMIT BUG	 												--->
	<!--- ************************************************************* --->
	<cffunction name="dspBugs" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSubmitBug = "ehBugs.dspSubmitBug">
		<!--- Set the Rollovers For This Section --->
		<cfset rc.qRollovers = filterQuery(application.dbservice.get("settings").getRollovers(),"pagesection","bugs")>
		<!--- Set the View --->
		<cfset Event.setView("vwBugs")>
	</cffunction>
	
	<cffunction name="dspSubmitBug" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehBugs.doSubmitBug">
		<!--- Set the View --->
		<cfset Event.setView("bugs/vwSubmitBugs")>
	</cffunction>
	
	<cffunction name="doSubmitBug" access="public" returntype="void">
		<cfset var mybugreport = "">
		<!--- Validate --->
		<cfif len(trim(rc.email)) eq 0 or len(trim(rc.bugreport)) eq 0 or len(trim(rc.name)) eq 0>
			<cfset getPlugin("messagebox").setMessage("warning", "Please fill out all the mandatory fields.")>
		<cfelseif not getPlugin("fileUtilities").isEmail(rc.email) >
			<cfset getPlugin("messagebox").setMessage("warning","The email you entered is not a valid email address.")>
		<cfelse>
			<cftry>
				<!--- Send report --->
				<cfset mybugreport = application.dbservice.sendBugReport(getCollection(),getSettingStructure(true),getPlugin("fileutilities").getOSName())>
				<cfset getPlugin("messagebox").setMessage("info", "You have successfully sent your bug report to the ColdBox bug email address.")>
				<!--- Save copy to show --->
				<cfset getPlugin("clientstorage").setvar("sentbugreport",mybugreport)>
			
				<cfcatch type="any">
					<cfset getPlugin("logger").logError("Error sending bug report.", cfcatch)>
					<cfset getPlugin("messagebox").setMessage("error","An error ocurred while sending the bug report: #cfcatch.Detail# #cfcatch.message#")>
				</cfcatch>
			</cftry>
		</cfif>
		<cfset setNextEvent("ehBugs.dspSubmitBug")>		
	</cffunction>


</cfcomponent>