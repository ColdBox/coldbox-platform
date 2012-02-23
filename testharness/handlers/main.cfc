<cfcomponent name="main" 
			 hint="main" 
			 output="false">

	<cffunction name="onApplicationStart" access="public" output="false" returntype="void">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext">
		<cfset getColdboxOCM().set("mysiteDSNBean",getDatasource("mysite"),0)>
		<cfset getPlugin("Logger").logEntry("information","AppStart Fired")>
		<!--- A-La-Carte loading --->
		<cfset controller.getModuleService().registerAndActivateModule(moduleName="ExternalTest",invocationPath="coldbox.testharness.extmodules")>
		
	</cffunction>
	
	<cffunction name="onSessionStart" access="public" output="false" returntype="void">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext">
		<cfscript>
		var logger = getPlugin("Logger");
		logger.logEntry("information","I am in the onSessionStart baby.");
		</cfscript>
	</cffunction>

	<cffunction name="onSessionEnd" access="public" output="false" returntype="void">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext">
		<cfscript>
		var logger = getPlugin("Logger");
		logger.logEntry("information","I am in the onSessionEnd baby.");
		</cfscript>
	</cffunction>
	
</cfcomponent>