<cfcomponent displayName="Galleon" hint="Core CFC for the application. Main purpose is to handle settings.">

	<cffunction name="getSettings" access="public" returnType="struct" output="false"
				hint="Returns application settings as a structure.">
		
		<!--- load the settings from the ini file --->
		<cfset var settingsFile = replace(getDirectoryFromPath(getCurrentTemplatePath()),"\","/","all") & "/settings.ini.cfm">
		<cfset var iniData = getProfileSections(settingsFile)>
		<cfset var r = structNew()>
		<cfset var key = "">
		
		<cfloop index="key" list="#iniData.settings#">
			<cfset r[key] = getProfileString(settingsFile,"settings",key)>
		</cfloop>
		
		<cfreturn r>
		
	</cffunction>
	
</cfcomponent>