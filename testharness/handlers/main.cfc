<!-----------------------------------------------------------------------
Author 	 :	
Date     :	5/16/2009
Description : 			
 
		
Modification History:

AUTOWIRE DSL:
ioc	 Get the named ioc bean and inject it. Name comes from the cfproperty name or argument name
ocm	 Get the name key from the Coldbox cache and inject it. Name comes from the cfproperty name or argument name
model	 Get a model with the same name or alias as defined in the cfproperty name="{name}" attribute. Name comes from the cfproperty name or argument name
model:{name}	 Same as above but it will get the {name} model object from the DSL and inject it.
model:{name}:{method}	 Get the {name} model object, call the {method} and inject the results
webservice:{alias}	 Get a webservice object using an {alias} that matches in your coldbox.xml
coldbox	 Get the coldbox controller
coldbox:setting:{setting}	 Get the {setting} setting and inject it
coldbox:plugin:{plugin}	 Get the {plugin} plugin and inject it
coldbox:myPlugin:{MyPlugin}	 Get the {MyPlugin} custom plugin and inject it
coldbox:datasource:{alias}	 Get the datasource bean according to {alias}
coldbox:configBean	 get the config bean object and inject it
coldbox:mailsettingsbean	 get the mail settings bean and inject it
coldbox:loaderService	 get the loader service
coldbox:requestService	 get the request service
coldbox:debuggerService	 get the debugger service
coldbox:pluginService	 get the plugin service
coldbox:handlerService	 get the handler service
coldbox:interceptorService	 get the interceptor service
coldbox:cacheManager	 get the cache manager
----------------------------------------------------------------------->
<cfcomponent name="main" 
			 hint="main" 
			 extends="coldbox.system.eventhandler" 
			 output="false"
			 autowire="false">

	<cffunction name="onApplicationStart" access="public" output="false" returntype="void">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext">
		<cfset getColdboxOCM().set("mysiteDSNBean",getDatasource("mysite"),0)>
		<cfset getPlugin("Logger").logEntry("information","AppStart Fired")>
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