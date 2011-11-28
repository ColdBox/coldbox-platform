<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2009 Reactor Loader by Mark Drew and Railo Technologies
www.reactorframework.com | www.markdrew.co.uk | www.getrailo.com
********************************************************************************
Template : ReactorLoader.cfc
Author 	 : Mark Drew, Luis Majano
Date     : 2009-05-29
Description :
	
	This loader  is used to create Reactor and load it
	
---------------------------------------------------------------------->
<cfcomponent hint="Creates Reactor and caches it within ColdBox" 
			 output="false"
			 extends="coldbox.system.Interceptor">
<!---
	CONSTRUCTOR
--->	
	
	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
	<!---
		Property checks, since these need to be defined for Reactor to work
	--->
	<cfscript >
		/* Property Checks */
		if( not propertyExists('dsnAlias') ){
			$throw("No datasource alias passed",
				  "Please pass in the alias of the datasource to use. This is defined in your datasources in your configuration.",
				  "ReactorLoader.InvalidPropertyException");
		}
		if( not propertyExists('pathToConfigXml') ){
			$throw("No pathToConfigXML passed","Please pass in the location of the pathToConfigXml","ReactorLoader.InvalidPropertyException");
		}
		if( not propertyExists('project') ){
			$throw("No project name passed","Please pass in the name of the project to use","ReactorLoader.InvalidPropertyException");
		}
		if( not propertyExists('mapping') ){
			$throw("No mapping passed","Please pass in the mapping location","ReactorLoader.InvalidPropertyException");
		}
		if( not propertyExists('mode') ){
			$throw("No mode passed","Please pass in the mode to use","ReactorLoader.InvalidPropertyException");
		}
		
		/* Optional Properties */
		if( not propertyExists('ReactorCacheKey') ){
			setProperty('ReactorCacheKey',"Reactor");
		}
		if( not propertyExists('ReactorConfigClassPath') ){
			setProperty('ReactorConfigClassPath',"reactor.config.config");
		}
		if( not propertyExists('ReactorFactoryClassPath') ){
			setProperty('ReactorFactoryClassPath',"reactor.reactorFactory");
		}
	</cfscript>
	</cffunction>
	
	<cffunction name="afterConfigurationLoad" output="false" access="public" returntype="void" hint="Load Reactor after configuration has loaded">
		<!--- *********************************************************************** --->
		<cfargument name="event" 			required="true" type="any" hint="The event object: coldbox.system.web.context.RequestContext">
		<cfargument name="interceptData" 	required="true" type="struct" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
		<!--- *********************************************************************** --->
		<cfscript >
			var datasources = getSetting('Datasources');
			var reactorConfig = CreateObject("component", getProperty("ReactorConfigClassPath")).init(getProperty("pathToConfigXml")); 
			var reactor = CreateObject("component", getProperty("ReactorFactoryClassPath"));
			var dsnBean = "";
			
			// Check Datasource Alia
			if( not structKeyExists(datasources, getProperty('dsnAlias')) ){
				$throw("No datasource alias #getProperty('dsnAlias')# found.",
					  "Please pass in the alias of the datasource to use that exists in your datasources section of your config file.",
					  "ReactorLoader.DSNAliasNotFoundException");
			}
			// Get DSN Object
			dsnBean = getDatasource(getProperty('dsnAlias'));
			
			// Configure reactor
			reactorConfig.setDsn(dsnBean.getName());
			reactorConfig.setProject(getProperty("project"));
			reactorConfig.setType(dsnBean.getDBType());
			reactorConfig.setMapping(getProperty("mapping"));
			reactorConfig.setMode(getProperty("mode"));
			
			// Init Reactor
			reactor.init(reactorConfig);
			
			// Now cache it as a singleton
			getColdboxOCM().set(getProperty('ReactorCacheKey'), reactor,0);
			
			// Debug
			getPlugin("Logger").debug("Reactor loaded at #now()#");
		</cfscript>	
	</cffunction>
	
	
	
</cfcomponent>