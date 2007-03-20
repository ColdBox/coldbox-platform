<cfcomponent output="false" displayname="fwsettings" hint="I am the Dashboard Framework Settings model.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- Constructor --->
	<cfset variables.instance = structnew()>
	<cfset variables.instance.settingsFilePath = ExpandPath("/coldbox/system/config/settings.xml")>
	<cfset variables.instance.qSettings = queryNew("")>
	<cfset variables.instance.xmlObj = "">
	
	<cffunction name="init" access="public" returntype="fwsettings" output="false">
		<cfset parseSettings()>
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<cffunction name="getSettings" access="public" returntype="query" output="false">
		<cfreturn instance.qSettings>
	</cffunction>
	
	<cffunction name="saveLogFileSettings" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="LogFileEncoding" 		required="true" type="string">
		<cfargument name="LogFileBufferSize" 	required="true" type="string">
		<cfargument name="LogFileMaxSize" 		required="true" type="string">
		<cfargument name="DefaultLogDirectory"  required="true" type="string">
		<!--- ************************************************************* --->
		<cfscript>
		var x = 1;
		var settingArray = instance.xmlObj.xmlRoot.settings.xmlChildren;
		for (x=1; x lte ArrayLen(settingArray); x=x+1){
			if ( Comparenocase(settingArray[x].xmlAttributes.name,"DefaultLogDirectory") eq 0){
				settingArray[x].xmlAttributes.value = trim(arguments.DefaultLogDirectory);
			}
			if ( Comparenocase(settingArray[x].xmlAttributes.name,"LogFileEncoding") eq 0){
				settingArray[x].xmlAttributes.value = trim(arguments.logFileEncoding);
			}
			if ( Comparenocase(settingArray[x].xmlAttributes.name,"LogFileBufferSize") eq 0){
				settingArray[x].xmlAttributes.value = trim(arguments.LogFileBufferSize);
			}
			if ( Comparenocase(settingArray[x].xmlAttributes.name,"LogFileMaxSize") eq 0){
				settingArray[x].xmlAttributes.value = trim(arguments.LogFileMaxSize);
			}
		}
		saveSettings();
		</cfscript>	
	</cffunction>
	
	<cffunction name="saveGeneralSettings" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="DefaultFileCharacterSet"		required="true" type="string">
		<cfargument name="MessageBoxStorage" 	        required="true" type="string">
		<cfargument name="ColdspringBeanFactory" 	    required="true" type="string">		
		<!--- ************************************************************* --->
		<cfscript>
		var x = 1;
		var settingArray = instance.xmlObj.xmlRoot.settings.xmlChildren;
		for (x=1; x lte ArrayLen(settingArray); x=x+1){
			if ( Comparenocase(settingArray[x].xmlAttributes.name,"DefaultFileCharacterSet") eq 0){
				settingArray[x].xmlAttributes.value = trim(arguments.DefaultFileCharacterSet);
			}
			if ( Comparenocase(settingArray[x].xmlAttributes.name,"MessageBoxStorage") eq 0){
				settingArray[x].xmlAttributes.value = trim(arguments.MessageBoxStorage);
			}
			if ( Comparenocase(settingArray[x].xmlAttributes.name,"ColdspringBeanFactory") eq 0){
				settingArray[x].xmlAttributes.value = trim(arguments.ColdspringBeanFactory);
			}
		}
		saveSettings();
		</cfscript>	
	</cffunction>
	
	<cffunction name="saveCacheSettings" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="CacheObjectDefaultTimeout"			required="true" type="string">
		<cfargument name="CacheObjectDefaultLastAccessTimeout" 	required="true" type="string">
		<cfargument name="CacheReapFrequency" 	    			required="true" type="string">
		<cfargument name="CacheMaxObjects" 	    				required="true" type="string">		
		<cfargument name="CacheFreeMemoryPercentageThreshold"	required="true" type="string">
		<!--- ************************************************************* --->
		<cfscript>
		var x = 1;
		var settingArray = instance.xmlObj.xmlRoot.settings.xmlChildren;
		for (x=1; x lte ArrayLen(settingArray); x=x+1){
			if ( Comparenocase(settingArray[x].xmlAttributes.name,"CacheObjectDefaultTimeout") eq 0){
				settingArray[x].xmlAttributes.value = trim(arguments.CacheObjectDefaultTimeout);
			}
			if ( Comparenocase(settingArray[x].xmlAttributes.name,"CacheObjectDefaultLastAccessTimeout") eq 0){
				settingArray[x].xmlAttributes.value = trim(arguments.CacheObjectDefaultLastAccessTimeout);
			}
			if ( Comparenocase(settingArray[x].xmlAttributes.name,"CacheReapFrequency") eq 0){
				settingArray[x].xmlAttributes.value = trim(arguments.CacheReapFrequency);
			}
			if ( Comparenocase(settingArray[x].xmlAttributes.name,"CacheMaxObjects") eq 0){
				settingArray[x].xmlAttributes.value = trim(arguments.CacheMaxObjects);
			}
			if ( Comparenocase(settingArray[x].xmlAttributes.name,"CacheFreeMemoryPercentageThreshold") eq 0){
				settingArray[x].xmlAttributes.value = trim(arguments.CacheFreeMemoryPercentageThreshold);
			}
		}
		saveSettings();
		</cfscript>	
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- ************************************************************* --->
		
	<cffunction name="parseSettings" access="private" returntype="void" output="false">
		<cfset var xmlString = "">
		<cfset var xmlSettings = ArrayNew(1)>
		<cfset var x = 1>
		<!--- Read File --->
		<cffile action="read" file="#instance.settingsFilePath#" variable="xmlString">
		<!--- Parse File --->
		<cfset instance.xmlObj = XMLParse(trim(xmlString))>
		<cfset xmlSettings = instance.xmlObj.xmlRoot.Settings.xmlChildren>
		
		<!--- Create Query --->
		<cfscript>
			QueryAddRow(instance.qSettings,1);
			for (x=1; x lte ArrayLen(xmlSettings); x=x+1){
				QueryAddColumn(instance.qSettings, trim(xmlSettings[x].xmlAttributes.name), "varchar" , ArrayNew(1));				
				QuerySetCell(instance.qSettings, trim(xmlSettings[x].xmlAttributes.name), trim(xmlSettings[x].xmlAttributes.value),1);
			}
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="saveSettings" access="private" returntype="void" output="false">
		<cflock type="exclusive" name="settingsfile_udpate" timeout="120">
			<cffile action="write" file="#instance.settingsFilePath#" output="#toString(instance.xmlObj)#">
		</cflock>
	</cffunction>
	
	<!--- ************************************************************* --->
	
</cfcomponent>