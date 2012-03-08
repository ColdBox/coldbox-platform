<!-----------------------------------------------------------------------
Template : ColdboxFactory.cfc
Author 	 : Luis Majano
Date     : 5/30/2007 6:10:56 PM
Description :
	This is a proxy factory to return ColdBox components and beans.
	You can set this up via Coldspring to return configured
	ConfigBeans, the ColdBox controller and ColdBox Plugins.
	
	<!-- ColdboxFactory -->
	<bean id="ColdboxFactory" class="coldbox.system.ioc.ColdboxFactory" />
	<bean id="ConfigBean" factory-bean="ColdboxFactory" factory-method="getConfigBean" />
	
	<bean id="loggerPlugin" factory-bean="ColdboxFactory" factory-method="getPlugin">
		<constructor-arg name="name">
			<value>logger</value>
		</constructor-arg>
		<constructor-arg name="customPlugin">
			<value>true|false</value>
		</constructor-arg>
	</bean>

Modification History:
5/30/2007 - Created Template
---------------------------------------------------------------------->
<cfcomponent name="ColdboxFactory" output="false" hint="Create Config Beans, Controller, Cache Manager and Plugins of the current running application">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- The beans paths --->
	<cfscript>
		variables.configBeanPath 		= "coldbox.system.core.collections.ConfigBean";
		variables.datasourceBeanPath 	= "coldbox.system.core.db.DatasourceBean";
		variables.mailsettingsBeanPath 	= "coldbox.system.core.mail.MailSettingsBean";
		variables.coldboxAppKey 		= "cbController";
	</cfscript>
	
	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="ColdboxFactory">
		<cfargument name="COLDBOX_APP_KEY" type="string" required="false" hint="The application key to use"/>
		
		<cfif structKeyExists(arguments,"COLDBOX_APP_KEY") AND
			  len(trim(arguments.COLDBOX_APP_KEY)) NEQ 0>
			<!--- Setup the coldbox app Key --->
			<cfset variables.coldboxAppKey = arugments.COLDBOX_APP_KEY>
		</cfif>
		
		<!--- Check App Config --->
		<cfif not structKeyExists(application,coldboxAppKey)>
			<cfthrow message="ColdBox controller does not exist as application.#variables.coldboxAppKey#" detail="The coldbox controller does not exist in application scope. Most likely the application has not been initialized.">
		</cfif>	
		
		<cfreturn this>
	</cffunction>
		
<!------------------------------------------- HELPERS ------------------------------------------->
	
	<!--- Get a config bean --->
	<cffunction name="getConfigBean" output="false" access="public" returntype="coldbox.system.core.collections.ConfigBean" hint="Returns an application's config bean: coldbox.system.core.collections.ConfigBean">
		<cfscript>
			return CreateObject("component",configBeanPath).init( getColdbox().getConfigSettings() );
		</cfscript>
	</cffunction>
	
	<!--- Get the coldbox controller --->
	<cffunction name="getColdbox" output="false" access="public" returntype="coldbox.system.web.Controller" hint="Get the coldbox controller reference: coldbox.system.web.Controller">
		<cfreturn application[coldboxAppKey]>
	</cffunction>
	
	<!--- Get the cachebox instance --->
	<cffunction name="getCacheBox" output="false" access="public" returntype="any" hint="Get the CacheBox reference." colddoc:generic="coldbox.system.cache.CacheFactory">
		<cfreturn getColdbox().getCacheBox()>
	</cffunction>
	
	<!--- Get the wirebox configured on this app --->
	<cffunction name="getWireBox" output="false" access="public" returntype="coldbox.system.ioc.Injector" hint="Get the WireBox Injector reference.">
		<cfreturn getColdbox().getWireBox()>
	</cffunction>
	
	<!--- Get a wirebox instance --->
	<cffunction name="getInstance" output="false" access="public" returntype="any" hint="Locates, Creates, Injects and Configures an object model instance">
    	<cfargument name="name" 			required="true" 	hint="The mapping name or CFC instance path to try to build up"/>
		<cfargument name="dsl"				required="false" 	hint="The dsl string to use to retrieve the instance model object, mutually exclusive with 'name'"/>
		<cfargument name="initArguments" 	required="false" 	hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfreturn getWireBox().getInstance(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Get the logbox configured on this app --->
	<cffunction name="getLogBox" output="false" access="public" returntype="coldbox.system.logging.LogBox" hint="Get the LogBox reference.">
		<cfreturn getColdbox().getLogBox()>
	</cffunction>
	
	<!--- Get the app's root Logger --->
	<cffunction name="getRootLogger" output="false" access="public" returntype="coldbox.system.logging.Logger" hint="Get the root logger reference.">
		<cfreturn getLogBox().getRootLogger()>
	</cffunction>
	
	<!--- Get a logger --->
	<cffunction name="getLogger" output="false" access="public" returntype="coldbox.system.logging.Logger" hint="Get a named logger reference.">
		<cfargument name="category" type="any" required="true" hint="The category name to use in this logger or pass in the target object will log from and we will inspect the object and use its metadata name."/>
		<cfreturn getLogBox().getLogger(arguments.category)>
	</cffunction>
	
	<!--- Get Context Facade --->
	<cffunction name="getRequestContext" access="public" returntype="coldbox.system.web.context.RequestContext" hint="Tries to retrieve the request context object" output="false" >
		<cfreturn getColdbox().getRequestService().getContext()>
	</cffunction>
	
	<!--- Get the Collection --->
	<cffunction name="getRequestCollection" access="public" returntype="struct" hint="Tries to retrieve the request collection" output="false" >
		<cfargument name="private" type="boolean" required="false" default="false" hint="Get the request collection or private request collection"/>
		<cfreturn getRequestContext().getCollection(private=arguments.private)>
	</cffunction>	
	
	<!--- Get the cache manager --->
	<cffunction name="getColdboxOCM" access="public" output="false" returntype="any" hint="Get ColdboxOCM: coldbox.system.cache.CacheManager or new CacheBox providers as coldbox.system.cache.IColdboxApplicationCache" colddoc:generic="coldbox.system.cache.IColdboxApplicationCache">
		<cfargument name="cacheName" type="string" required="false" default="default" hint="The cache name to retrieve"/>
		<cfreturn getColdbox().getColdboxOCM(arguments.cacheName)/>
	</cffunction>
	
	<!--- Get a plugin --->
	<cffunction name="getPlugin" access="Public" returntype="any" hint="Plugin factory, returns a new or cached instance of a plugin." output="false">
		<cfargument name="plugin" 		type="any"  hint="The Plugin object's name to instantiate" >
		<cfargument name="customPlugin" type="boolean"  required="false" default="false" hint="Used internally to create custom plugins.">
		<cfargument name="newInstance"  type="boolean"  required="false" default="false" hint="If true, it will create and return a new plugin. No caching or persistance.">
		<cfargument name="module" 		type="any" 	    required="false" default="" hint="The module to retrieve the plugin from"/>
		<cfargument name="init" 		type="boolean"  required="false" default="true" hint="Auto init() the plugin upon construction"/>
		<!--- ************************************************************* --->
		<cfreturn getColdbox().getPlugin(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Interceptor Facade --->
	<cffunction name="getInterceptor" access="public" output="false" returntype="any" hint="Get an interceptor">
		<!--- ************************************************************* --->
		<cfargument name="interceptorName" 	required="false" type="string" hint="The name of the interceptor to search for"/>
		<cfargument name="deepSearch" 		required="false" type="boolean" default="false" hint="By default we search the cache for the interceptor reference. If true, we search all the registered interceptor states for a match."/>
		<!--- ************************************************************* --->
		<cfreturn getColdbox().getInterceptorService().getInterceptor(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Get a datasource --->
	<cffunction name="getDatasource" access="public" output="false" returnType="coldbox.system.core.db.DatasourceBean" hint="I will return to you a datasourceBean according to the alias of the datasource you wish to get from the configstruct: coldbox.system.core.db.DatasourceBean">
		<!--- ************************************************************* --->
		<cfargument name="alias" type="string" hint="The alias of the datasource to get from the configstruct (alias property in the config file)">
		<!--- ************************************************************* --->
		<cfscript>
		var datasources = getColdbox().getSetting("Datasources");
		//Check for datasources structure
		if ( structIsEmpty(datasources) ){
			getUtil().throwit("There are no datasources defined for this application.","","ColdboxFactory.DatasourceStructureEmptyException");
		}
		//Try to get the correct datasource.
		if ( structKeyExists(datasources, arguments.alias) ){
			return CreateObject("component",datasourceBeanPath).init(datasources[arguments.alias]);
		}
		else{
			getUtil().throwit("The datasource: #arguments.alias# is not defined.","","ColdboxFactory.DatasourceNotFoundException");
		}
		</cfscript>
	</cffunction>
	
	<!--- Get a mail settings bean --->
	<cffunction name="getMailSettings" access="public" output="false" returnType="coldbox.system.core.mail.MailSettingsBean" hint="I will return to you a mailsettingsBean modeled after your mail settings in your config file.">
		<cfreturn createObject("component",mailsettingsBeanPath).init(argumentCollection=getColdbox().getSetting("mailSettings"))>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Get the util object --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn CreateObject("component","coldbox.system.core.util.Util")/>
	</cffunction>
	
</cfcomponent>