<!---
Author			:	Luis Majano
Create Date		:	September 19, 2005
Update Date		:	September 25, 2006
Description		:

This is the updater handler

--->
<cfcomponent name="ehUpdater" extends="coldbox.system.eventhandler">

	<!--- ************************************************************* --->
	<!--- UPDATE SECTION 												--->
	<!--- ************************************************************* --->
	<cffunction name="dspUpdateSection" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehUpdater = "ehUpdater.dspUpdater">
		<!--- Set the Rollovers For This Section --->
		<cfset rc.qRollovers = filterQuery(application.dbservice.get("settings").getRollovers(),"pagesection","update")>
		<!--- Set the View --->
		<cfset Event.setView("vwUpdate")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="dspUpdater" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehCheck = "ehUpdater.docheckForUpdates">
		<!--- Get distribution URL's --->
		<cfset rc.qURLS = application.dbservice.get("settings").getDistributionUrls()>
		<!--- Set the View --->
		<cfset Event.setView("update/vwUpdater")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="docheckForUpdates" access="public" returntype="void">
		<cfset var errorString = "Error retrieving update information from the ColdBox distribution site. Below you can see some diagnostic information.<br><br>">
		<cfset var updateWS = "">
		<cfset var updateResults = "">
		<!--- Param Site--->
		<cfset Event.paramValue("distribution_site", "")>
		<cftry>
			<!--- Check for URL --->
			<cfif Event.getValue("distribution_site") eq "">
				<cfset getPlugin("messagebox").setMessage("warning", "The distribution site to query seems to be invalid. Please check again")>
				<cfset setnextEvent("ehUpdater.dspUpdater")>
			</cfif>
			<!--- Get a WS Object --->
			<cfset updateWS = CreateObject("webservice",Event.getValue("distribution_site"))>
			<!--- Check for Updates --->
			<cfset updateResults = updateWS.getUpdateInfo('#getSetting("Version",1)#',"#getSetting("Version")#")>
			<!--- CHeck for WS Errors --->
			<cfif updateResults.error>
				<cfset getPlugin("logger").logError(errorString,structnew(),updateResults.errorMessage)>
				<cfset getPlugin("messagebox").setMessage("error", errorString & updateResults.errorMessage)>
			<cfelse>
				<!--- Save Update Results --->
				<cfset getPlugin("clientstorage").setVar("updateResults", updateResults)>
				<!--- set next event --->
				<cfset setNextEvent("ehUpdater.dspUpdaterResults")>
			</cfif>
			<!--- Catch --->
			<cfcatch type="any">
				<cfset getPlugin("logger").logError(errorString, cfcatch)>
				<cfset getPlugin("messagebox").setMessage("error","#errorString##cfcatch.Detail#<br><br>#cfcatch.Message#")>
			</cfcatch>
		</cftry>
		<cfset setnextEvent("ehUpdater.dspUpdater")>
	</cffunction>

	<!--- ************************************************************* --->
		
	<cffunction name="dspUpdaterResults" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehdoUpdate = "ehUpdater.doGetUpdate">
		<cfset rc.UpdateResults = getPlugin("clientstorage").getVar("updateResults")>
		<!--- Set the View --->
		<cfset Event.setView("update/vwUpdaterResults")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="doGetUpdate" access="public" returntype="void">
		<cfscript>
		//init variables 
		var updateResults = getPlugin("clientStorage").getVar("updateResults");
		var dashboardSettings = application.dbservice.get("settings").getSettings();
		var frameworkSettings = getSettingStructure(true);
		var applicationSettings = getSettingStructure();
		
		//param type
		Event.paramValue("updatetype", "");
		
		//type Check
		if ( rc.updatetype eq ""){
			getPlugin("messagebox").setMessage("error", "Invalid update type detected: #rc.updatetype#");
			setNextEvent("ehUpdater.dspUpdateSection");
			return;
		}
		
		//Call the Updater service with data.
		try{
			application.dbService.autoupdate(rc.updatetype,dashboardSettings,frameworkSettings,applicationSettings,updateResults);
		}
		catch(Any e){
			dump(e);abort();
			getPlugin("logger").logError("The update service failed.", e);
			getPlugin("messagebox").setMessage("error", "Error executing the update service: #e.detail# #e.message#");
			setNextEvent("ehUpdater.dspUpdateSection");
		}
		</cfscript>
		
		
		<cfaborT>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="doInstall" access="public" returntype="void">
		<cfset var UpdateTempDir = expandPath(getSetting("UpdateTempDir") )>
		<cfif directoryExists(UpdateTempDir)>
			<!--- Remove Temp Install Dir --->
			<cfdirectory action="delete" directory="#UpdateTempDir#" recurse="yes">
		</cfif>
		<cfset getPlugin("messagebox").setMessage("info","Your ColdBox installation has been updated successfully!")>
		<cfset setNextEvent("ehColdbox.dspLogin")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="doRollback" access="public" returntype="void">
		<cfset var UpdateTempDir = expandPath(getSetting("UpdateTempDir") )>
		<cfif directoryExists(UpdateTempDir)>
			<!--- Remove Temp Install Dir --->
			<cfdirectory action="delete" directory="#UpdateTempDir#" recurse="yes">
		</cfif>
		<cfset getPlugin("messagebox").setMessage("error","There was an error while updating your system. Please look at the error below:<br><br>#URLDecode(Event.getValue("installerror"))#")>
		<cfset setNextEvent("ehColdbox.dspHome")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	
	
	
	
	<cffunction name="dspBackups" access="public" returntype="void">
		<cfset var dirListing = "">
		<cfset checkBackupDir()>
		<!--- Read Directory --->
		<cfdirectory action="list"
					 directory="#expandPath(getSetting("BackupsPath"))#"
					 name="dirListing"
					 recurse="yes"
					 sort="asc"  >

		<cfset Event.setValue("dirListing",dirListing)>
		<!--- grab if backup --->
		<cfif Event.getValue("finished","") eq "ok">
			<cfset getPlugin("messagebox").setMessage("info","Your data has been backed up successfully. Please look below in your backups directory for the zip file.")>
		</cfif>
		<cfset Event.setView("vwBackups")>
	</cffunction>
	
	<cffunction name="doRemoveFile" access="public" returntype="void">
		<!--- Get File info to remove --->
		<cfset var Filename = Event.getValue("filename")>
		<cfset var FilePath = Event.getValue("filepath")>
		<cftry>
			<!--- Remove File --->
			<cffile action="delete"
					file="#filepath##getSetting('OSFileSeparator',1)##filename#">
			<!--- Set Message --->
			<cfset getPlugin("messagebox").setMessage("info", "The file: <strong>#filename#</strong> was deleted successfully")>
			<cfset setNextEvent("ehColdbox.dspBackups")>
			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("error", "Error removing file: #cfcatch.detail# #cfcatch.message#")>
				<cfset setNextEvent("ehColdbox.dspBackups")>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="doDeliverFile" access="public" returntype="void">
		<cfset var DeliverFile = replace(urlDecode(Event.getValue("backupfile")),"{sep}",getSetting("OSFileSeparator",1))>
		<cfset var Filename = GetFileFromPath(DeliverFile)>
		<cfset var mime = "">
		<!--- Determine type --->
		<cfif findnocase("xml",Filename)>
			<cfset mime = "application/xml">
		<cfelseif findnocase("zip",Filename)>
			<cfset mime = "application/zip">
		<cfelse>
			<cfset mime = "application/unknown">
		</cfif>
		<CFHEADER NAME="content-disposition" VALUE="inline; filename=#Filename#">
		<cfcontent file="#DeliverFile#" reset="yes" type="#mime#">
	</cffunction>
	
	
	<cffunction name="doColdboxBackup" access="public" returntype="void">
		<!--- Package Settings --->
		<cfset var SetupSettings = Structnew()>
		<cfset var wddxpacket = "">
		<cfset SetupSettings.InstallationType = "backup">
		<cfset SetupSettings.BackupsPath= expandPath(getSetting("BackupsPath"))>
		<cfset SetupSettings.BackupDirectoryPath = getSetting("FrameworkPath",1)>
		<cfset SetupSettings.FrameworkPath = getSetting("FrameworkPath",1)>
		<cfset SetupSettings.FrameworkVersion = getSetting("Version",1)>
		<cfset SetupSettings.FrameworkBackupName = dateformat(now(),"Mmm.dd.yy") & "-" & timeFormat(now(),"HHmm") & "_system_" & getSetting("Version",1) & "_backup.zip">
		<cfwddx action="cfml2wddx" input="#SetupSettings#" output="wddxpacket">
		<!--- RElocate to installer --->
		<cflocation url="installer/installer.cfm?setuppacket=#wddxpacket#" addtoken="no">
	</cffunction>
	
	
	
	
</cfcomponent>