<!---
Author			:	Luis Majano
Create Date		:	September 19, 2005
Update Date		:	June 19, 2006
Description		:

This is the main event handler for the ColdBox dashboard.

--->
<cfcomponent name="ehColdBox" extends="coldbox.system.eventhandler">

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfset super.Init()>
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="onAppStart" access="public" returntype="void">

	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="onRequestStart" access="public" returntype="void">
		<!--- Authorization --->
		<cfif (not isDefined("session.authorized") or
			  session.authorized eq false) and
			  getValue("password","not found") eq "not found">
			<cfset setValue("event", "ehColdbox.dspLogin")>
		</cfif>
		<!--- Logout --->
		<cfif getValue("logout",0) neq 0>
			<cfset setNextEvent("ehColdbox.doLogout")>
		</cfif>
		<!--- Web Service Refresh, if needed. --->
		<cfif getValue("refreshWS","") neq "">
			<cfset getPlugin("webservices").refreshWS("DistributionWS")>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspLogin" access="public" returntype="void">
		<!--- Set the View --->
		<cfset setView("vwLogin")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspHome" access="public" returntype="void">
		<!--- Set the View --->
		<cfset setView("vwHome")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspPassword" access="public" returntype="void">
		<!--- Set the View --->
		<cfset setView("vwPassword")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspConfigEditor" access="public" returntype="void">
		<cfset var fs = getSetting("OSFileSeparator",1)>
		<cfset var configFile = getSetting("ParentAppPath",true) & fs & "config" & fs & "config.xml.cfm">
		<!--- Read Config XML using plugin, this is mostly for cfscript --->
		<cfset var configXML = getPlugin("fileUtilities").readFile("#configFile#")>
		<cfset setValue("configXML", configXML)>
		<!--- Test for CFDOC --->
		<cfif getValue("cfdoc", false) eq false >
			<cfset setView("vwConfigEditor")>
		<cfelse>
			<cfset setValue("fpcontent", XMLFormat(configXML))>
			<cfset setValue("usePreTag", true)>
			<cfset setView("vwFPViewer")>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

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

		<cfset setValue("dirListing",dirListing)>
		<!--- grab if backup --->
		<cfif getValue("finished","") eq "ok">
			<cfset getPlugin("messagebox").setMessage("info","Your data has been backed up successfully. Please look below in your backups directory for the zip file.")>
		</cfif>
		<cfset setView("vwBackups")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspModifyLog" access="public" returntype="void">
		<cfset var logText = "">
		<!--- Read Modify Log --->
		<cffile action="read" file="#getSetting("ModifyLogLocation",true)#" variable="logtext">
		<cfset logText = replace(logtext, chr(13), "<br>", "all")>
		<cfset logText = replace(logtext, chr(9), "&nbsp;&nbsp;&nbsp;&nbsp;", "all")>
		<cfset setValue("logtext", logtext)>
		<!--- Test for CFDOC --->
		<cfif getValue("cfdoc", false) eq false >
			<cfset setView("vwModifyLog")>
		<cfelse>
			<cfset setValue("fpcontent", logtext)>
			<cfset setValue("usePreTag", false)>
			<cfset setView("vwFPViewer")>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspConfigHelp" access="public" returntype="void">
		<cfset setView("vwConfigHelp")>
		<!--- CFDoc Check --->
		<cfset cfdoc()>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspHandlersHelp" access="public" returntype="void">
		<cfset setView("vwHandlersHelp")>
		<!--- CFDoc Check --->
		<cfset cfdoc()>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspSettings" access="public" returntype="void">
		<cfset setView("vwSettings")>
		<!--- CFDoc Check --->
		<cfset cfdoc()>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspAPI" access="public" returntype="void">
		<!--- Code to Parse to System Directory --->
		<cfset var script = getDirectoryFromPath(cgi.SCRIPT_NAME)>
		<cfset var itemcount = listlen(script,"/")>
		<cfset var SystemPath = replace( listDeleteAt(script,itemcount,"/") & "/","/","","one")>
		<cfset var PluginPath = SystemPath & "plugins/">
		<cfset var cfcPath = "">
		<cfset var dirPath = "">
		<cfset var oCFCViewer = "">

		<!--- Determine type of cfc's to show --->
		<cfif getValue("type","") eq "plugins">
			<cfset cfcPath = PluginPath>
			<cfset dirPath = "../plugins/">
		<cfelseif getValue("type","") eq "system">
			<cfset cfcPath = SystemPath>
			<cfset dirPath = "../">
		</cfif>
		<!---Set paths --->
		<cfset setValue("cfcPath", cfcPath)>
		<cfset setValue("dirPath", dirPath)>

		<!--- Get cfcviewer Plugin --->
		<cfset oCFCViewer = getPlugin("cfcViewer")>
		<cfset oCFCViewer.setup(dirPath, cfcPath)>

		<!--- Place in req Collection --->
		<cfset setValue("oCFCViewer",oCFCViewer)>
		<cfset setValue("aCFC",oCFCViewer.getCFCs())>

		<!--- set the view --->
		<cfset setView("vwAPI")>
		<!--- CFDoc Check --->
		<cfset cfdoc()>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doLogin" access="public" returntype="void">
		<cfset var passHash = hash(getValue("password") )>
		<!--- Check for password --->
		<cfif passwordCheck(passHash)>
			<cfset session.authorized = true>
			<cfset setNextEvent("ehColdbox.dspHome")>
		<cfelse>
			<!--- Invalid --->
			<cfset getPlugin("messagebox").setMessage("warning","The password you entered is incorrect")>
			<cfset setNextEvent("ehColdbox.dspLogin")>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doCheckUpdates" access="public" returntype="void">
		<cfset var errorString = "Error retrieving update information from the ColdBox distribution site. Below you can see some diagnostic information.<br><br>">
		<cfset var updateWS = "">
		<cfset var updateResults = "">
		<cftry>
			<!--- Get a WS Object --->
			<cfset updateWS = getPlugin("webservices").getWSObj("DistributionWS")>
			<!--- Check for Updates --->
			<cfset updateResults = updateWS.getUpdateInfo('#getSetting("Version",1)#')>
			<!--- CHeck for WS Errors --->
			<cfif updateResults.error>
				<cfset getPlugin("messagebox").setMessage("error", "#errorString##updateResults.errorMessage#")>
			<cfelse>
				<!--- Test versions --->
				<cfif updateResults.AvailableUpdate>
					<cfset getPlugin("messagebox").setMessage("warning","There is a new version of ColdBox available.")>
				<cfelse>
					<cfset getPlugin("messagebox").setMessage("warning","You have the latest version of ColdBox installed.")>
				</cfif>
				<!--- Format Readme for display --->
				<cfset updateResults.updateStruct.ReadmeFile = replace(updateResults.updateStruct.ReadmeFile, chr(13), "<br>", "all")>
				<cfset updateResults.updateStruct.ReadmeFile = replace(updateResults.updateStruct.ReadmeFile, chr(9), "&nbsp;&nbsp;&nbsp;&nbsp;", "all")>
				<!--- Save Update Results --->
				<cfset getPlugin("clientstorage").setVar("updateResults", updateResults)>
			</cfif>
			<!--- Catch --->
			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("warning","#errorString##cfcatch.Detail#<br><br>#cfcatch.Message#")>
			</cfcatch>
		</cftry>
		<!--- set next event --->
		<cfset setNextEvent("ehColdbox.dspHome")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doLogout" access="public" returntype="void">
		<cfset session.authorized = false>
		<cfset SetNextEvent("ehColdbox.dspLogin")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doChangePassword" access="public" returntype="void">
		<cfset var errors = "">
		<!--- Validations --->
		<cfif trim(getValue("new_password")) eq "" or trim(getValue("current_password")) eq "" or trim(getValue("new_password2")) eq "">
			<cfset errors = "- Please enter all the fields.<br>">
		</cfif>
		<!--- pass matches --->
		<cfif compare(trim(getValue("new_password")), trim(getValue("new_password2"))) neq 0>
			<cfset errors = errors & "- The new password does not match the confirmation password. Try again.<br>">
		</cfif>
		<!--- Test for old Password --->
		<cfif not getPlugin("settings").passwordCheck(trim(hash(getValue("current_password"))))>
			<cfset errors = errors & "- The current password you entered is incorrect.<br>">
		</cfif>
		<cfif len(errors) neq 0>
			<cfset getPlugin("messagebox").setMessage("warning",errors)>
			<cfset setNextEvent("ehColdbox.dspPassword")>
		</cfif>

		<!--- Change Password --->
		<cfset getPlugin("settings").changePassword(trim(getValue("current_password")),trim(getValue("new_password")))>
		<cfset getPlugin("messagebox").setMessage("info","Your Dashboard password has been changed.")>
		<cfset setNextEvent("ehColdbox.dspPassword")>

	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doSaveConfig" access="public" returntype="void">
		<!--- Save Config XML --->
		<cfset var fileContents = toString(trim(getValue("xmlcontent")))>
		<cfset var fs = getSetting("OSFileSeparator",1)>
		<cfset var filename = "#getFileFromPath(getSetting("ConfigFileLocation",true))#">
		<cfset var source = getSetting("ParentAppPath",true) & fs & "config" & fs & "config.xml.cfm" >
		<cfset var destination = ExpandPath("#getSetting("BackupsPath")##fs#config_files#fs##dateformat(now(),"MMM.DD.YY")#-#timeformat(now(),"HH.MM")#_#filename#")>
		<cfset var validationResults = "">
		
		<!--- XML Verification --->
		<cfif not isXML(fileContents)>
			<cfset getPlugin("messagebox").setMessage("error", "The contents of the xml file are invalid. This is not a valid XML file. Please check your syntax. The file has been reverted to the original config.xml")>
			<cfset setNextEvent("ehColdbox.dspConfigEditor")>
		</cfif>

		<!--- Validation --->
		<cfset validationResults = XMLValidate(fileContents,getSetting("ConfigFileSchemaLocation",1))>

		<cfif not validationResults.status>
			<cfset getPlugin("messagebox").setMessage("error", "The contents of the xml file does not validate with the config schema file.  The file has been reverted to the original config.xml.")>
			<cfset setNextEvent("ehColdbox.dspConfigEditor")>
		</cfif>

		<!--- Check backups dir --->
		<cfset checkBackupDir()>
		<cftry>
			<!--- Save backup --->
			<cffile action="copy"
				    source="#source#"
					destination="#destination#"
					nameconflict="overwrite"
					mode="777">

			<!--- Save --->
			<cffile action="write"
					file="#source#"
					output="#fileContents#"
					nameconflict="overwrite"
					mode="777">

			<!--- Message --->
			<cfset getPlugin("messagebox").setMessage("info","The Config.xml file was saved successfully. A backup copy has been placed in the backups directory of the dashboard.")>
			<cfset setNextEvent("ehColdbox.dspConfigEditor")>
			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("error", "Error Saving File: #cfcatch.detail# #cfcatch.message#")>
				<cfset setNextEvent("ehColdbox.dspConfigEditor")>
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doRemoveFile" access="public" returntype="void">
		<!--- Get File info to remove --->
		<cfset var Filename = getValue("filename")>
		<cfset var FilePath = getValue("filepath")>
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
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doDeliverFile" access="public" returntype="void">
		<cfset var DeliverFile = replace(urlDecode(getValue("backupfile")),"{sep}",getSetting("OSFileSeparator",1))>
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
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
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
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doAppBackup" access="public" returntype="void">
		<!--- Package Settings --->
		<cfset var SetupSettings = Structnew()>
		<cfset var wddxpacket = "">
		<cfset SetupSettings.InstallationType = "backup">
		<cfset SetupSettings.BackupsPath= expandPath(getSetting("BackupsPath"))>
		<cfset SetupSettings.BackupDirectoryPath = getSetting("ParentAppPath",1)>
		<cfset SetupSettings.FrameworkPath = getSetting("FrameworkPath",1)>
		<cfset SetupSettings.FrameworkVersion = getSetting("Version",1)>
		<cfset SetupSettings.FrameworkBackupName = dateformat(now(),"Mmm.dd.yy") & "-" & timeFormat(now(),"HHmm") & "_app_backup.zip">
		<cfwddx action="cfml2wddx" input="#SetupSettings#" output="wddxpacket">
		<!--- RElocate to installer --->
		<cflocation url="installer/installer.cfm?setuppacket=#wddxpacket#" addtoken="no">
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doGetUpdate" access="public" returntype="void">
		<!--- Set Setup Variables Structure For Installer. --->
		<cfset var SetupSettings = Structnew()>
		<cfset var wddxpacket = "">
		<cfset var fs = getSetting("OSFileSeparator",1)>
		<cfset var installfiles = "">
		<cfset SetupSettings.InstallationType = "update">
		<cfset SetupSettings.FrameworkUpdateFileURL = getValue("updateFile")>
		<cfset SetupSettings.FrameworkUpdateFileSize = getValue("FileSize")>
		<cfset SetupSettings.FrameworkNewVersion = getValue("version")>
		<cfset SetupSettings.FrameworkVersion = getSetting("Version",1)>
		<cfset SetupSettings.FrameworkUpdateFileName = "coldbox_#SetupSettings.FrameworkNewVersion#.zip">
		<cfset SetupSettings.FrameworkBackupName = dateformat(now(),"Mmm.dd.yy") & "-" & timeFormat(now(),"HHmm") & "_system_" & SetupSettings.FrameworkVersion & "_backup.zip">
		<cfset SetupSettings.FrameworkPath = getSetting("FrameworkPath",1)>
		<cfset SetupSettings.UpdateTempDir = expandPath(getSetting("UpdateTempDir") )>
		<cfset SetupSettings.BackupsPath = SetupSettings.UpdateTempDir & fs & "system" & fs & "admin" & fs & "backups">
		<cfset SetupSettings.BackupDirectoryPath = getSetting("FrameworkPath",1)>
		<cfset SetupSettings.installerDir = expandPath("installer")>
		<cfset SetupSettings.PasswordFilePath = expandPath("config/.coldbox")>
		<cfset SetupSettings.PasswordFileDestination = SetupSettings.updateTempDir & fs & "system" & fs & "admin" & fs & "config">
		<cfset SetupSettings.ParentPath = getSetting("ParentAppPath",1)>
		<cfwddx action="cfml2wddx" input="#SetupSettings#" output="wddxpacket">
		<!--- Move Installer and run --->
		<cftry>
			<!--- Create Install Directory, if it doesn't exist --->
			<cfif not directoryExists(SetupSettings.updateTempDir)>
				<cfdirectory action="create" directory="#SetupSettings.updateTempDir#" mode="777">
			</cfif>

			<!--- Move installer Files to install dir --->
			<cfdirectory action="list" directory="#SetupSettings.installerDir#" name="installfiles">
			<cfloop query="installfiles">
				<cffile action="copy"
						source="#SetupSettings.installerDir##fs##installfiles.name#"
						destination="#SetupSettings.UpdateTempDir##fs##installfiles.name#">
			</cfloop>

			<!--- Start Installler --->
			<cflocation url="#getSetting("UpdateTempDir")#/installer.cfm?setuppacket=#wddxpacket#" addtoken="no">

			<cfcatch type="any">
				<!--- Check for Dir --->
				<cfif directoryExists(SetupSettings.updateTempDir)>
					<cfdirectory action="delete" recurse="true" directory="#setupSettings.updateTempDir#">
				</cfif>
				<!--- Message --->
				<cfset getPlugin("messagebox").setMessage("error","Error initiating installer. Please see the diagnostics message below:<br><br>#cfcatch.Detail#<br>#cfcatch.Message#")>
				<cfset setNextEvent("ehColdbox.dspHome")>
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- ************************************************************* --->

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

	<!--- ************************************************************* --->
	<cffunction name="doRollback" access="public" returntype="void">
		<cfset var UpdateTempDir = expandPath(getSetting("UpdateTempDir") )>
		<cfif directoryExists(UpdateTempDir)>
			<!--- Remove Temp Install Dir --->
			<cfdirectory action="delete" directory="#UpdateTempDir#" recurse="yes">
		</cfif>
		<cfset getPlugin("messagebox").setMessage("error","There was an error while updating your system. Please look at the error below:<br><br>#URLDecode(getValue("installerror"))#")>
		<cfset setNextEvent("ehColdbox.dspHome")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doChangeLocale" access="public" returntype="void">
		<!--- Change Locale --->
		<cfset getPlugin("i18n").setfwLocale(getValue("locale"))>
		<cfset dspHome()>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<!--- UTILITY METHODS												   --->
	<!--- ************************************************************* --->
	<cffunction  name="checkBackupDir" access="private" returntype="void" hint="Check the backups dir">
		<cfset var fs = getSetting("OSFileSeparator",1)>
		<!--- Directory Check --->
		<cfif not directoryExists( expandPath(getSetting("backupsPath")) )>
			<cfdirectory action="create" directory="#expandPath(getSetting("BackupsPath"))#" mode="777">
		</cfif>
		<!--- Config Directories Check --->
		<cfif not directoryExists( expandPath(getSetting("backupsPath") & "#fs#config_files") )>
			<cfdirectory action="create" directory="#expandPath(getSetting("BackupsPath") & "#fs#config_files")#" mode="777">
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction  name="cfdoc" access="private" returntype="void" hint="Change the layout to cfdoc">
		<cfif getValue("cfdoctype","") neq "">
			<cfset setLayout("Layout.cfdoc")>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="getPassword" access="private" hint="Gets the current dashboard password or creates one if necessary." returntype="any" output="false">
		<cfset var pass = "coldbox=9702D637FA3229EAFFC5A58FF7E06B6C">
		<cfset var passContent = "">
		<cfset var passfile = "#getSetting("FrameworkPath",1)##getSetting("OSFileSeparator",1)#admin#getSetting("OSFileSeparator",1)#config#getSetting("OSFileSeparator",1)#.coldbox">

		<!--- Check if file .coldbox exists --->
		<cfif fileExists( passfile )>
			<cffile action="read" file="#passfile#" variable="passContent">
			<!--- Veriy pass on File is Correct. --->
			<cfif not refindNocase("^coldbox=.*", passContent)>
				<cffile action="write" file="#passFile#" output="#pass#">
				<cfset passContent = pass>
			</cfif>
			<cfreturn getToken(passContent, 2,"=")>
		<cfelse>
			<!--- Create New File with Password --->
			<cffile action="write" file="#passfile#" output="#pass#">
			<cfset passContent = pass>
			<!--- Return password hash--->
			<cfreturn getToken(passContent, 2,"=")>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="passwordCheck" access="public" hint="Checks wether the passed password is correct or not." returntype="boolean" output="false">
		<!--- ************************************************************* --->
		<cfargument name="passToCheck" required="yes" type="string" hint="The password to verify. Hashed already please.">
		<!--- ************************************************************* --->
		<cfif Compare(trim("#getPassword()#"),trim(arguments.passToCheck)) eq 0>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="changePassword" access="public" hint="Changes the dashboard password." returntype="boolean" output="false">
		<!--- ************************************************************* --->
		<cfargument name="currentPassword" 	required="yes" type="string">
		<cfargument name="newPassword" 		required="yes" type="string">
		<!--- ************************************************************* --->
		<cfset var newPass = "">
		<cfset var passfile = "#getSetting("FrameworkPath",1)##getSetting("OSFileSeparator",1)#admin#getSetting("OSFileSeparator",1)#config#getSetting("OSFileSeparator",1)#.coldbox">
		<cfif CompareNocase(getSetting("AppName"),getSetting("DashboardName",1)) eq 0>
			<cfif passwordCheck(hash(arguments.currentPassword))>
				<!--- Create New File with Password --->
				<cfset newPass = "coldbox=#hash(arguments.newPassword)#">
				<cffile action="write" file="#passFile#" output="#newPass#">
				<cfreturn true>
			<cfelse>
				<cfreturn false>
			</cfif>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->
</cfcomponent>