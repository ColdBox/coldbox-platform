<!---
Author			:	Luis Majano
Create Date		:	September 19, 2005
Update Date		:	September 25, 2006
Description		:

This is the settings handler

--->
<cfcomponent name="ehSettings" extends="coldbox.system.eventhandler" output="false">

<!--- ************************************************************* --->
	<!--- SETTINGS SECTION 												--->
	<!--- ************************************************************* --->

	<cffunction name="dspGateway" access="public" returntype="void" output="false">
		<cfargument name="event" type="any" required="true">
		<cfset var rc = event.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSettings = "ehSettings.dspOverview">
		<cfset rc.xehLogSettings = "ehSettings.dspLogSettings">
		<cfset rc.xehGeneralSettings = "ehSettings.dspGeneralSettings">
		<cfset rc.xehPassword = "ehSettings.dspChangePassword">
		<cfset rc.xehProxy = "ehSettings.dspProxySettings">
		<cfset rc.xehCacheSettings = "ehSettings.dspCachesettings">
		<!--- Set the Rollovers For This Section --->
		<cfset rc.qRollovers = getPlugin("queryHelper").filterQuery(rc.dbService.get("settings").getRollovers(),"pagesection","settings")>
		<!--- Set the View --->
		<cfset Event.setView("settings/gateway")>
	</cffunction>

	<cffunction name="dspOverview" access="public" returntype="void" output="false">
		<cfargument name="event" type="any" required="true">
		<cfset var rc = event.getCollection()>
		<cfset rc.fwSettings = rc.dbService.get("fwsettings").getSettings()>
		<!--- Help --->
		<cfset rc.help = renderView("settings/help/Overview")>
		<!--- Set the View --->
		<cfset Event.setView("settings/vwOverview")>
	</cffunction>

	<cffunction name="dspGeneralSettings" access="public" returntype="void" output="false">
		<cfargument name="event" type="any" required="true">
		<cfset var rc = event.getCollection()>
		<cfset var fwSettings = rc.dbservice.get("fwsettings").getSettings()>
		<!--- Get general Settings --->
		<cfset rc.AvailableCFCharacterSets = fwSettings["AvailableCFCharacterSets"]>
		<cfset rc.DefaultFileCharacterSet = fwSettings["DefaultFileCharacterSet"]>
		<cfset rc.ColdspringBeanFactory = fwSettings["ColdspringBeanFactory"]>
		<cfset rc.MessageBoxStorage = fwSettings["MessageBoxStorage"]>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehSettings.doSaveGeneralSettings">
		<!--- Help --->
		<cfset rc.help = renderView("settings/help/GeneralSettings")>
		<!--- Set the View --->
		<cfset Event.setView("settings/vwGeneralSettings")>
	</cffunction>

	<cffunction name="doSaveGeneralSettings" access="public" returntype="void" output="false">
		<cfargument name="event" type="any" required="true">
		<cfset var rc = event.getCollection()>
		<cfset var fwSettings = rc.dbservice.get("fwsettings").getSettings()>
		<cfset var setCharacterSet = fwSettings["DefaultFileCharacterSet"]>

		<!--- Validate Coldspring --->
		<cfif len(trim(ColdspringBeanFactory)) eq 0>
			<cfset getPlugin("messagebox").setMessage("error","Please enter the coldspring bean factory path.")>
			<cfset setNextEvent("ehSettings.dspGeneralSettings")>
		<cfelse>
			<!--- Update the settings --->
			<cfset rc.dbservice.get("fwsettings").saveGeneralSettings(rc.DefaultFileCharacterSet,rc.MessageBoxStorage,rc.ColdspringBeanFactory)>
			<cfset getPlugin("messagebox").setMessage("info","Settings have been updated successfully. Please remember to reinitialize the framework on your applications for the changes to take effect.")>
			<!--- Relocate --->
			<cfset setNextEvent("ehSettings.dspGeneralSettings","fwreinit=1")>
		</cfif>
	</cffunction>

	<cffunction name="dspLogSettings" access="public" returntype="void" output="false">
		<cfargument name="event" type="any" required="true">
		<cfset var rc = event.getCollection()>
		<cfset var fwSettings = rc.dbservice.get("fwsettings").getSettings()>
		<cfset rc.LogFileEncoding = fwSettings["LogFileEncoding"]>
		<cfset rc.AvailableLogFileEncodings = fwSettings["AvailableLogFileEncodings"]>
		<cfset rc.LogFileBufferSize = fwSettings["LogFileBufferSize"]>
		<cfset rc.LogFileMaxSize = fwSettings["LogFileMaxSize"]>
		<cfset rc.DefaultLogDirectory = fwSettings["DefaultLogDirectory"]>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehSettings.doSaveLogFileSettings">
		<!--- Help --->
		<cfset rc.help = renderView("settings/help/LogFileSettings")>
		<!--- Set the View --->
		<cfset Event.setView("settings/vwLogFileSettings")>
	</cffunction>

	<cffunction name="doSaveLogFileSettings" access="public" returntype="void" output="false">
		<cfargument name="event" type="any" required="true">
		<cfset var rc = event.getCollection()>
		<cfset var fwSettings = rc.dbservice.get("fwsettings").getSettings()>
		<cfset var errors = false>
		<!--- Validate blanks --->
		<cfif len(trim(rc.DefaultLogDirectory)) eq 0 or len(trim(rc.LogFileEncoding)) eq 0 or len(trim(rc.LogFileBufferSize)) eq 0 or len(trim(rc.LogFileMaxSize)) eq 0>
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
			<cfset rc.dbservice.get("fwsettings").saveLogFileSettings(rc.LogFileEncoding,rc.LogFileBufferSize,rc.LogFileMaxSize, rc.DefaultLogDirectory)>
			<cfset getPlugin("messagebox").setMessage("info","Settings have been updated successfully. Please remember to reinitialize the framework on your applications for the changes to take effect.")>
			<!--- Relocate --->
			<cfset setNextEvent("ehSettings.dspLogSettings","fwreinit=1")>
		<cfelse>
			<!--- Relocate --->
			<cfset setNextEvent("ehSettings.dspLogSettings")>
		</cfif>
	</cffunction>

	<cffunction name="dspChangePassword" access="public" returntype="void" output="false">
		<cfargument name="event" type="any" required="true">
		<cfset var rc = event.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehSettings.doChangePassword">
		<!--- Help --->
		<cfset rc.help = renderView("settings/help/Password")>
		<!--- Set the View --->
		<cfset Event.setView("settings/vwPassword")>
	</cffunction>

	<cffunction name="doChangePassword" access="public" returntype="void" output="false">
		<cfargument name="event" type="any" required="true">
		<cfset var rc = event.getCollection()>
		<cfset var errors = false>
		<cfset var rtnStruct = "">
		<!--- Validate Passwords --->
		<cfif len(trim(rc.oldpassword)) eq 0 or len(trim(rc.newpassword)) eq 0 or len(trim(rc.newpassword2)) eq 0>
			<cfset getPlugin("messagebox").setMessage("error", "Please fill out all the necessary fields.")>
		<cfelse>
			<!--- Save the new password --->
			<cfset rtnStruct = rc.dbservice.get("settings").changePassword(rc.oldpassword,rc.newpassword,rc.newpassword2)>
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

	<cffunction name="dspProxySettings" access="public" returntype="void" output="false">
		<cfargument name="event" type="any" required="true">
		<cfset var rc = event.getCollection()>
		<cfset var settings = rc.dbservice.get("settings").getSettings()>
		<cfset rc.proxyflag = settings["proxyflag"]>
		<cfset rc.proxyserver = settings["proxyserver"]>
		<cfset rc.proxyuser = settings["proxyuser"]>
		<cfset rc.proxypassword = settings["proxypassword"]>
		<cfset rc.proxyport = settings["proxyport"]>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehSettings.doChangeProxySettings">
		<!--- Help --->
		<cfset rc.help = renderView("settings/help/ProxySettings")>
		<!--- Set the View --->
		<cfset Event.setView("settings/vwProxySettings")>
	</cffunction>

	<cffunction name="doChangeProxySettings" access="public" returntype="void" output="false">
		<cfargument name="event" type="any" required="true">
		<cfset var rc = event.getCollection()>
		<cfset var errors = false>
		<cfset var rtnStruct = "">
		<!--- Validate Passwords --->
		<cfif len(trim(rc.proxyport)) neq 0 and not isnumeric(rc.proxyport)>
			<cfset getPlugin("messagebox").setMessage("error", "The proxy port you filled out was not numeric. Please try again.")>
		<cfelse>
			<!--- Save the proxy settings --->
			<cfset rc.dbservice.get("settings").changeProxySettings(rc.proxyflag,rc.proxyserver,rc.proxyuser, rc.proxypassword, rc.proxyport)>
			<cfset getPlugin("messagebox").setMessage("info", "Your proxy settings have been saved successfully.")>
		</cfif>
		<!--- Move to new event --->
		<cfset setnextEvent("ehSettings.dspProxySettings")>
	</cffunction>

	<cffunction name="dspCacheSettings" access="public" returntype="void" output="false">
		<cfargument name="event" type="any" required="true">
		<cfset var rc = event.getCollection()>
		<cfset var settings = rc.dbservice.get("fwsettings").getSettings()>
		<cfset rc.CacheObjectDefaultTimeout = settings["CacheObjectDefaultTimeout"]>
		<cfset rc.CacheObjectDefaultLastAccessTimeout = settings["CacheObjectDefaultLastAccessTimeout"]>
		<cfset rc.CacheReapFrequency = settings["CacheReapFrequency"]>
		<cfset rc.CacheMaxObjects = settings["CacheMaxObjects"]>
		<cfset rc.CacheFreeMemoryPercentageThreshold = settings["CacheFreeMemoryPercentageThreshold"]>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoSave = "ehSettings.doSaveCacheSettings">
		<!--- Help --->
		<cfset rc.help = renderView("settings/help/CachingSettings")>
		<!--- Set the View --->
		<cfset Event.setView("settings/vwCachingSettings")>

	</cffunction>

	<cffunction name="doSaveCacheSettings" access="public" returntype="void" output="false">
		<cfargument name="event" type="any" required="true">
		<cfset var rc = event.getCollection()>
		<cfset var fwSettings = rc.dbservice.get("fwsettings").getSettings()>
		<cfset var errors = false>
		<!--- Validate blanks --->
		<cfif len(trim(rc.CacheObjectDefaultTimeout)) eq 0 or
		      len(trim(rc.CacheObjectDefaultLastAccessTimeout)) eq 0 or
		      len(Trim(rc.CacheReapFrequency)) eq 0 or
		      len(trim(rc.CacheMaxObjects)) eq 0 or
		      len(trim(rc.CacheFreeMemoryPercentageThreshold)) eq 0>
			<cfset getPlugin("messagebox").setMessage("error","You cannot leave any empty configurations.")>
			<cfset setNextEvent("ehSettings.dspCacheSettings")>
		<cfelseif not isNumeric(rc.CacheObjectDefaultTimeout) or
				  not isNumeric(rc.CacheObjectDefaultLastAccessTimeout) or
				  not isNumeric(rc.CacheReapFrequency) or
				  not isNumeric(rc.CacheMaxObjects) or
				  not isNumeric(rc.CacheFreeMemoryPercentageThreshold)>
			<cfset getPlugin("messagebox").setMessage("error","Only numerical values are allowed.")>
			<cfset setNextEvent("ehSettings.dspCacheSettings")>
		<cfelse>
			<cfset rc.dbservice.get("fwsettings").saveCacheSettings(rc.CacheObjectDefaultTimeout,
																	rc.CacheObjectDefaultLastAccessTimeout,
																	rc.CacheReapFrequency,
																	rc.CacheMaxObjects,
																	rc.CacheFreeMemoryPercentageThreshold)>
			<cfset getPlugin("messagebox").setMessage("info","Settings have been updated successfully. Please remember to reinitialize the framework on your applications for the changes to take effect.")>
			<!--- Relocate --->
			<cfset setNextEvent("ehSettings.dspCacheSettings","fwreinit=1")>
		</cfif>
	</cffunction>

</cfcomponent>