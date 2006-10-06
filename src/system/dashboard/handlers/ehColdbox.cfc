<!---
Author			:	Luis Majano
Create Date		:	September 19, 2005
Update Date		:	September 25, 2006
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

	<cffunction name="onAppStart" access="public" returntype="void">
		<cfset var MyService = getSetting("AppMapping") & ".model.dbservice">
		<cfset application.dbservice = CreateObject("component",MyService).init()>
		<cfset application.isBD = server.ColdFusion.ProductName neq "Coldfusion Server">
	</cffunction>
	
	<!--- ************************************************************* --->

	<cffunction name="onRequestStart" access="public" returntype="void">
		<!--- Authorization --->
		<cfif (not isDefined("session.authorized") or session.authorized eq false) and
			  getValue("event") neq "ehColdbox.doLogin">
			<cfset overrideEvent("ehColdbox.dspLogin")>
		</cfif>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehLogout = "ehColdbox.doLogout">
	</cffunction>

	<!--- ************************************************************* --->
	<!--- LOGIN SECTION													--->
	<!--- ************************************************************* --->
	
	<cffunction name="dspLogin" access="public" returntype="void">
		<!--- EVENT HANDLERS: --->
		<cfset rc.xehLogin = "ehColdbox.doLogin">
		<!--- Set the View --->
		<cfset setView("vwLogin")>
	</cffunction>
	
	<cffunction name="doLogin" access="public" returntype="void">
		<!--- Do Login --->
		<cfif len(trim(getValue("password",""))) eq 0>
			<cfset getPlugin("messagebox").setMessage("error", "Please fill out the password field.")>
			<cfset setNextEvent()>
		</cfif>
		<cfif application.dbservice.get("settings").validatePassword(getvalue("password"))>
			<!--- Validate user --->
			<cfset session.authorized = true>
			<cfset setNextEvent()>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("error", "The password you entered is not correct. Please try again.")>
			<cfset setNextEvent()>
		</cfif>
	</cffunction>
	
	<cffunction name="doLogout" access="public" returntype="void">
		<cfset session.authorized = false>
		<cfset SetNextEvent("ehColdbox.dspLogin")>
	</cffunction>
	
	<!--- ************************************************************* --->
	<!--- FRAMESET SECTION												--->
	<!--- ************************************************************* --->
	
	<cffunction name="dspFrameset" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehHome = "ehColdbox.dspHome">
		<cfset rc.xehHeader = "ehColdbox.dspHeader">
		<!--- Set the View --->
		<cfset setView("vwFrameset",true)>
	</cffunction>
	
	<cffunction name="dspHome" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSystemInfo = "ehColdbox.dspSystemInfo">
		<cfset rc.xehResources = "ehColdbox.dspOnlineResources">
		<cfset rc.xehCFCDocs = "ehColdbox.dspCFCDocs">
		<!--- Set the Rollovers --->
		<cfset rc.qRollovers = filterQuery(application.dbservice.get("settings").getRollovers(),"pagesection","home")>
		
		<!--- Set the View --->
		<cfset setView("vwHome")>
	</cffunction>
	
	<cffunction name="dspHeader" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehHome = "ehColdbox.dspHome">
		<cfset rc.xehSettings = "ehColdbox.dspSettings">
		<cfset rc.xehTools = "ehColdbox.dspTools">
		<cfset rc.xehUpdate = "ehColdbox.dspUpdateSection">
		<cfset rc.xehBugs = "ehColdbox.dspBugs">
		<!--- Set the View --->
		<cfset setView("tags/header")>
	</cffunction>
	
	<!--- ************************************************************* --->
	<!--- HOME SECTION 													--->
	<!--- ************************************************************* --->
	
	<cffunction name="dspSystemInfo" access="public" returntype="void">
		<!--- Check if install folder exists --->
		<cfset rc.InstallFolderExits = directoryExists(ExpandPath("/coldbox/install"))>
		<!--- Check if the samples folder exists --->
		<cfset rc.SampleFolderExists = directoryExists(ExpandPath("/coldbox/samples"))>
		<!--- Set the View --->
		<cfset setView("home/vwSystemInfo")>
	</cffunction>
	
	<cffunction name="dspOnlineResources" access="public" returntype="void">
		<!--- Set the View --->
		<cfset setView("home/vwOnlineResources")>
	</cffunction>
	
	<cffunction name="dspCFCDocs" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehCFCDocs = "ehColdbox.dspCFCDocs">
		<cfset rc.cfcViewer = getPlugin("cfcViewer")>
		<cfset paramValue("show", "")>
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
		<cfset setView("home/vwCFCDocs")>
	</cffunction>

	<!--- ************************************************************* --->
	<!--- SETTINGS SECTION 												--->
	<!--- ************************************************************* --->
	
	<cffunction name="dspSettings" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSettings = "ehColdbox.dspGeneralSettings">
		<cfset rc.xehLogSettings = "ehColdbox.dspLogSettings">
		<cfset rc.xehEncodingSettings = "ehColdbox.dspEncodingSettings">
		<cfset rc.xehPassword = "ehColdbox.dspChangePassword">
		<cfset rc.xehProxy = "ehColdbox.dspProxySettings">
		<!--- Set the Rollovers For This Section --->
		<cfset rc.qRollovers = filterQuery(application.dbservice.get("settings").getRollovers(),"pagesection","settings")>
		<!--- Set the View --->
		<cfset setView("vwSettings")>
	</cffunction>
	
	<cffunction name="dspGeneralSettings" access="public" returntype="void">
		<cfset rc.fwSettings = application.dbservice.get("fwsettings").getSettings()>
		<!--- Set the View --->
		<cfset setView("settings/vwSettings")>
	</cffunction>
	
	<cffunction name="dspLogSettings" access="public" returntype="void">
		<cfset var fwSettings = application.dbservice.get("fwsettings").getSettings()>
		<cfset rc.LogFileEncoding = fwSettings["LogFileEncoding"]>
		<cfset rc.AvailableLogFileEncodings = fwSettings["AvailableLogFileEncodings"]>
		<cfset rc.LogFileBufferSize = fwSettings["LogFileBufferSize"]>
		<cfset rc.LogFileMaxSize = fwSettings["LogFileMaxSize"]>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehColdbox.doSaveLogFileSettings">
		<!--- Set the View --->
		<cfset setView("settings/vwLogFileSettings")>
	</cffunction>
	
	<cffunction name="doSaveLogFileSettings" access="public" returntype="void">
		<cfset var fwSettings = application.dbservice.get("fwsettings").getSettings()>
		<cfset var errors = false>
		<!--- Validate blanks --->
		<cfif len(trim(rc.LogFileEncoding)) eq 0 or len(trim(rc.LogFileBufferSize)) eq 0 or len(trim(rc.LogFileMaxSize)) eq 0>
			<cfset getPlugin("messagebox").setMessage("error","Please make sure you fill out all the values.")>
			<cfset errors = true>
		</cfif>
		<!--- Validate Buffer --->
		<cfif not isNumeric(rc.LogFileBufferSize) or rc.LogFileBufferSize gt 64000 or rc.LogFileBufferSize lt 8000>
			<cfset getPlugin("messagebox").setMessage("error","The Log File Buffer Size you sent in is not numeric or you choose a number not betwee 8000-64000 bytes. Please try again")>
			<cfset errors = true>
		</cfif>
		<!--- ValidateMax Size ---->
		<cfif not isNumeric(rc.LogFileMaxSize)>
			<cfset getPlugin("messagebox").setMessage("error","The Log File Max Size you sent in is not numeric. Please try again")>
			<cfset errors = true>
		</cfif>
		<!--- Check for Errors --->
		<cfif not errors>
			<!--- Update the settings --->
			<cfset application.dbservice.get("fwsettings").saveLogFileSettings(rc.LogFileEncoding,rc.LogFileBufferSize,rc.LogFileMaxSize)>
			<cfset getPlugin("messagebox").setMessage("info","Settings have been updated successfully. Please remember to reinitialize the framework on your applications for the changes to take effect.")>
			<!--- Relocate --->
			<cfset setNextEvent("ehColdbox.dspLogSettings","fwreinit=1")>
		<cfelse>
			<!--- Relocate --->
			<cfset setNextEvent("ehColdbox.dspLogSettings")>
		</cfif>
	</cffunction>
	
	<cffunction name="dspEncodingSettings" access="public" returntype="void">
		<cfset var fwSettings = application.dbservice.get("fwsettings").getSettings()>
		<cfset rc.AvailableCFCharacterSets = fwSettings["AvailableCFCharacterSets"]>
		<cfset rc.DefaultFileCharacterSet = fwSettings["DefaultFileCharacterSet"]>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehColdbox.doSaveEncodingSettings">
		<!--- Set the View --->
		<cfset setView("settings/vwFileEncodingSettings")>
	</cffunction>
	
	<cffunction name="doSaveEncodingSettings" access="public" returntype="void">
		<cfset var fwSettings = application.dbservice.get("fwsettings").getSettings()>
		<cfset var setCharacterSet = fwSettings["DefaultFileCharacterSet"]>
		<!--- Check for changes --->
		<cfif comparenocase(setCharacterSet, rc.DefaultFileCharacterSet ) neq 0>
			<!--- Update the settings --->
			<cfset application.dbservice.get("fwsettings").saveEncodingSettings(rc.DefaultFileCharacterSet)>
			<cfset getPlugin("messagebox").setMessage("info","Settings have been updated successfully. Please remember to reinitialize the framework on your applications for the changes to take effect.")>
			<!--- Relocate --->
			<cfset setNextEvent("ehColdbox.dspEncodingSettings","fwreinit=1")>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("warning","You did not select a new character set. No settings were saved.")>
			<!--- Relocate --->
			<cfset setNextEvent("ehColdbox.dspEncodingSettings")>
		</cfif>
	</cffunction>
	
	<cffunction name="dspChangePassword" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehColdbox.doChangePassword">
		<!--- Set the View --->
		<cfset setView("settings/vwPassword")>
	</cffunction>
	
	<cffunction name="doChangePassword" access="public" returntype="void">
		<cfset var errors = false>
		<cfset var rtnStruct = "">
		<!--- Validate Passwords --->
		<cfif len(trim(rc.oldpassword)) eq 0 or len(trim(rc.newpassword)) eq 0 or len(trim(rc.newpassword2)) eq 0>
			<cfset getPlugin("messagebox").setMessage("error", "Please fill out all the necessary fields.")>
		<cfelse>
			<!--- Save the new password --->
			<cfset rtnStruct = application.dbservice.get("settings").changePassword(rc.oldpassword,rc.newpassword,rc.newpassword2)>
			<!--- Validate --->
			<cfif not rtnStruct.results>
				<cfset getPlugin("messagebox").setMessage("error", "#rtnStruct.message#")>
			<cfelse>
				<cfset getPlugin("messagebox").setMessage("info", "Your new password has been updated successfully.")>
			</cfif>
		</cfif>		
		<!--- Move to new event --->
		<cfset setnextEvent("ehColdbox.dspChangePassword")>
	</cffunction>
	
	<cffunction name="dspProxySettings" access="public" returntype="void">
		<cfset var settings = application.dbservice.get("settings").getSettings()>
		<cfset rc.proxyflag = settings["proxyflag"]>
		<cfset rc.proxyserver = settings["proxyserver"]>
		<cfset rc.proxyuser = settings["proxyuser"]>
		<cfset rc.proxypassword = settings["proxypassword"]>
		<cfset rc.proxyport = settings["proxyport"]>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehColdbox.doChangeProxySettings">
		<!--- Set the View --->
		<cfset setView("settings/vwProxySettings")>
	</cffunction>
	
	<cffunction name="doChangeProxySettings" access="public" returntype="void">
		<cfset var errors = false>
		<cfset var rtnStruct = "">
		<!--- Validate Passwords --->
		<cfif len(trim(rc.proxyport)) neq 0 and not isnumeric(rc.proxyport)>
			<cfset getPlugin("messagebox").setMessage("error", "The proxy port you filled out was not numeric. Please try again.")>
		<cfelse>
			<!--- Save the proxy settings --->
			<cfset application.dbservice.get("settings").changeProxySettings(rc.proxyflag,rc.proxyserver,rc.proxyuser, rc.proxypassword, rc.proxyport)>
			<cfset getPlugin("messagebox").setMessage("info", "Your proxy settings have been saved successfully.")>
		</cfif>		
		<!--- Move to new event --->
		<cfset setnextEvent("ehColdbox.dspProxySettings")>
	</cffunction>
	
	<!--- ************************************************************* --->
	<!--- TOOLS SECTION 												--->
	<!--- ************************************************************* --->
	
	<cffunction name="dspTools" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehAppBuilder = "ehAppBuilder.dspAppBuilder">
		<cfset rc.xehLogViewer = "ehLogViewer.dspLogViewer">
		<cfset rc.xehCFCGenerator = "ehGenerator.dspcfcGenerator">
		<!--- Set the Rollovers For This Section --->
		<cfset rc.qRollovers = filterQuery(application.dbservice.get("settings").getRollovers(),"pagesection","tools")>
		<!--- Set the View --->
		<cfset setView("vwTools")>
	</cffunction>
	
	<!--- ************************************************************* --->
	<!--- UPDATE SECTION 												--->
	<!--- ************************************************************* --->
	<cffunction name="dspUpdateSection" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehUpdater = "ehColdbox.dspUpdater">
		<!--- Set the Rollovers For This Section --->
		<cfset rc.qRollovers = filterQuery(application.dbservice.get("settings").getRollovers(),"pagesection","update")>
		<!--- Set the View --->
		<cfset setView("vwUpdate")>
	</cffunction>
	
	<cffunction name="dspUpdater" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehCheck = "ehColdbox.docheckForUpdates">
		<!--- Set the View --->
		<cfset setView("update/vwUpdater")>
	</cffunction>
	
	<cffunction name="docheckForUpdates" access="public" returntype="void">
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
				<cfset getPlugin("logger").logError("#errorString#",structnew(), updateResults.errorMessage)>
				<cfset getPlugin("messagebox").setMessage("error", errorString & updateResults.errorMessage)>
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
				<cfset getPlugin("logger").logError("#errorString#", cfcatch)>
				<cfset getPlugin("messagebox").setMessage("error","#errorString##cfcatch.Detail#<br><br>#cfcatch.Message#")>
			</cfcatch>
		</cftry>
		<!--- set next event --->
		<cfset setNextEvent("ehColdbox.dspHome")>
	</cffunction>
	
	<!--- ************************************************************* --->
	<!--- SUBMIT BUG	 												--->
	<!--- ************************************************************* --->
	<cffunction name="dspBugs" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSubmitBug = "ehColdbox.dspSubmitBug">
		<!--- Set the Rollovers For This Section --->
		<cfset rc.qRollovers = filterQuery(application.dbservice.get("settings").getRollovers(),"pagesection","bugs")>
		<!--- Set the View --->
		<cfset setView("vwBugs")>
	</cffunction>
	
	<cffunction name="dspSubmitBug" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehColdbox.doSubmitBug">
		<!--- Set the View --->
		<cfset setView("bugs/vwSubmitBugs")>
	</cffunction>
	
	<cffunction name="doSubmitBug" access="public" returntype="void">
		<cfset var mybugreport = "">
		<!--- Validate --->
		<cfif len(trim(rc.email)) eq 0 or len(trim(rc.bugreport)) eq 0 or len(trim(rc.name)) eq 0>
			<cfset getPlugin("messagebox").setMessage("warning", "Please fill out all the mandatory fields.")>
		<cfelse>
			<!--- Save the Report --->
			<cfsavecontent variable="mybugreport">
			<cfoutput>
			=========================================================
			_Bug Details_
			=========================================================
			Date: #dateFormat(now(),"mmmm dd, YYYY")#
			Time: #TimeFormat(now(), "long")#
			From: #rc.name#
			Bug Report:
			#rc.bugreport#
			=========================================================
			_ColdBox Details_
			=========================================================
			Version:    #getSetting("version", 1)#
			Codename:   #getSetting("codename",1)#
			Suffix:     #getSetting("suffix",1)#
			O.S:        #getPlugin("fileutilities").getOSName()#
			CF Engine:  #server.ColdFusion.ProductName#
			CF Version: #server.ColdFusion.ProductVersion#
			=========================================================
			</cfoutput>
			</cfsavecontent>
			<!--- Send the bug report --->
			<cfif len(trim(rc.mailserver)) eq 0>
				<cfmail to="bugs@coldboxframework.com" from="#rc.email#" subject="Bug Report" username="#rc.mailusername#" password="#mailpassword#">
				#mybugreport#
				</cfmail>
			<cfelse>
				<cfmail to="bugs@coldboxframework.com" from="#rc.email#" subject="Bug Report" server="#rc.mailserver#" username="#rc.mailusername#" password="#rc.mailpassword#">
				#mybugreport#
				</cfmail>
			</cfif>
			<cfset getPlugin("messagebox").setMessage("info", "You have successfully sent your bug report to the ColdBox bug email address.")>
			<!--- Save copy to show --->
			<cfset getPlugin("clientstorage").setvar("sentbugreport",mybugreport)>
		</cfif>
		<cfset setNextEvent("ehColdbox.dspSubmitBug")>		
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

		<cfset setValue("dirListing",dirListing)>
		<!--- grab if backup --->
		<cfif getValue("finished","") eq "ok">
			<cfset getPlugin("messagebox").setMessage("info","Your data has been backed up successfully. Please look below in your backups directory for the zip file.")>
		</cfif>
		<cfset setView("vwBackups")>
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

	
</cfcomponent>