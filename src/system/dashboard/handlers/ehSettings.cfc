<!---
Author			:	Luis Majano
Create Date		:	September 19, 2005
Update Date		:	September 25, 2006
Description		:

This is the settings handler

--->
<cfcomponent name="ehSettings" extends="coldbox.system.eventhandler">

<!--- ************************************************************* --->
	<!--- SETTINGS SECTION 												--->
	<!--- ************************************************************* --->
	
	<cffunction name="dspSettings" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSettings = "ehSettings.dspGeneralSettings">
		<cfset rc.xehLogSettings = "ehSettings.dspLogSettings">
		<cfset rc.xehEncodingSettings = "ehSettings.dspEncodingSettings">
		<cfset rc.xehPassword = "ehSettings.dspChangePassword">
		<cfset rc.xehProxy = "ehSettings.dspProxySettings">
		<!--- Set the Rollovers For This Section --->
		<cfset rc.qRollovers = filterQuery(application.dbservice.get("settings").getRollovers(),"pagesection","settings")>
		<!--- Set the View --->
		<cfset Context.setView("vwSettings")>
	</cffunction>
	
	<cffunction name="dspGeneralSettings" access="public" returntype="void">
		<cfset rc.fwSettings = application.dbservice.get("fwsettings").getSettings()>
		<!--- Set the View --->
		<cfset Context.setView("settings/vwSettings")>
	</cffunction>
	
	<cffunction name="dspLogSettings" access="public" returntype="void">
		<cfset var fwSettings = application.dbservice.get("fwsettings").getSettings()>
		<cfset rc.LogFileEncoding = fwSettings["LogFileEncoding"]>
		<cfset rc.AvailableLogFileEncodings = fwSettings["AvailableLogFileEncodings"]>
		<cfset rc.LogFileBufferSize = fwSettings["LogFileBufferSize"]>
		<cfset rc.LogFileMaxSize = fwSettings["LogFileMaxSize"]>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehSettings.doSaveLogFileSettings">
		<!--- Set the View --->
		<cfset Context.setView("settings/vwLogFileSettings")>
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
			<cfset setNextEvent("ehSettings.dspLogSettings","fwreinit=1")>
		<cfelse>
			<!--- Relocate --->
			<cfset setNextEvent("ehSettings.dspLogSettings")>
		</cfif>
	</cffunction>
	
	<cffunction name="dspEncodingSettings" access="public" returntype="void">
		<cfset var fwSettings = application.dbservice.get("fwsettings").getSettings()>
		<cfset rc.AvailableCFCharacterSets = fwSettings["AvailableCFCharacterSets"]>
		<cfset rc.DefaultFileCharacterSet = fwSettings["DefaultFileCharacterSet"]>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehSettings.doSaveEncodingSettings">
		<!--- Set the View --->
		<cfset Context.setView("settings/vwFileEncodingSettings")>
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
			<cfset setNextEvent("ehSettings.dspEncodingSettings","fwreinit=1")>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("warning","You did not select a new character set. No settings were saved.")>
			<!--- Relocate --->
			<cfset setNextEvent("ehSettings.dspEncodingSettings")>
		</cfif>
	</cffunction>
	
	<cffunction name="dspChangePassword" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehSettings.doChangePassword">
		<!--- Set the View --->
		<cfset Context.setView("settings/vwPassword")>
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
		<cfset setnextEvent("ehSettings.dspChangePassword")>
	</cffunction>
	
	<cffunction name="dspProxySettings" access="public" returntype="void">
		<cfset var settings = application.dbservice.get("settings").getSettings()>
		<cfset rc.proxyflag = settings["proxyflag"]>
		<cfset rc.proxyserver = settings["proxyserver"]>
		<cfset rc.proxyuser = settings["proxyuser"]>
		<cfset rc.proxypassword = settings["proxypassword"]>
		<cfset rc.proxyport = settings["proxyport"]>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehSettings.doChangeProxySettings">
		<!--- Set the View --->
		<cfset Context.setView("settings/vwProxySettings")>
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
		<cfset setnextEvent("ehSettings.dspProxySettings")>
	</cffunction>
	

</cfcomponent>