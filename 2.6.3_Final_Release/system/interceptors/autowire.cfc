<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	01/15/2008
Description :
	This interceptor is used to autowire plugins, handlers and interceptors.
	Plugins and handlers are autowired after creation. Intreceptors will always
	be autowired after the aspects load. This is to give chance for all the correct
	application aspects to be in place.
	
----------------------------------------------------------------------->
<cfcomponent name="autowire"
			 hint="This is an autowire interceptor"
			 output="false"
			 extends="coldbox.system.interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		<cfscript>
			/* Get set properties */
			if( not propertyExists("debugMode") or not isBoolean(getProperty("debugMode")) ){
				setProperty("debugMode",false);
			}
			/* DI Complete Method */
			if(not propertyExists("completeDIMethodName")){
				setProperty("completeDIMethodName",'onDIComplete');
			}
			/* enableSetterInjection */
			if(not propertyExists("enableSetterInjection")){
				setProperty("enableSetterInjection",'true');
			}		
			
			/* Create our beanFactory plugin, we do this here, because we need it not to execute an endless loop */
			instance.beanFactory = getPlugin("beanFactory");	
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<!--- After Aspects Load --->
	<cffunction name="afterAspectsLoad" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
		<cfscript>
			var interceptorConfig = getController().getSetting("InterceptorConfig");
			var INTERCEPTOR_CACHEKEY_PREFIX = getColdboxOCM().INTERCEPTOR_CACHEKEY_PREFIX;
			var x = 1;
			
			/* Setup the targettype */
			arguments.targetType = "interceptor";
			
			/* Loop over the Interceptor Array, to begin autowiring */
			for (; x lte arrayLen(interceptorConfig.interceptors); x=x+1){
				
				/* Get the cache path */
				arguments.interceptData.interceptorPath = INTERCEPTOR_CACHEKEY_PREFIX & interceptorConfig.interceptors[x].class;
				
				/* Exclude yourself */
				if( not findnocase("coldbox.system.interceptors.autowire",interceptorConfig.interceptors[x].class) ){
					
					/* No locking necessary here, since the after aspects load is executed in thread safe conditions */
					
					/* Try to get the interceptor Object. */
					arguments.interceptData.oInterceptor = getColdboxOCM().get(arguments.interceptData.interceptorPath);
					/* Autowire it */
					processAutowire(argumentCollection=arguments);
				}
				
			}//end declared interceptor loop
		</cfscript>
	</cffunction>
	
	<!--- After Handler Creation --->
	<cffunction name="afterHandlerCreation" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted data = [handlerPath (The path of the handler), oHandler (The actual handler object)]">
		<!--- ************************************************************* --->
		<cfset arguments.targetType = "handler">
			
		<cflock type="exclusive" name="cboxautowire_handler_#interceptData.handlerPath#" timeout="30" throwontimeout="true">
			<cfset processAutowire(argumentCollection=arguments)>		
		</cflock>		
	</cffunction>
		
	<!--- After Plugin Creation --->
	<cffunction name="afterPluginCreation" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted data = [pluginPath (The path of the plugin), custom (Flag if the plugin is custom or not), oPlugin (The actual plugin object)]">
		<!--- ************************************************************* --->
		<cfset arguments.targetType = "plugin">
			
		<cflock type="exclusive" name="cboxautowire_plugin_#interceptData.pluginPath#" timeout="30" throwontimeout="true">
			<cfset processAutowire(argumentCollection=arguments)>		
		</cflock>		
	</cffunction>
	
	<!--- After Plugin Creation --->
	<cffunction name="processAutowire" access="public" returntype="void" output="false" hint="Process autowiring using a targetype and data.">
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted data = [pluginPath (The path of the plugin), custom (Flag if the plugin is custom or not), oPlugin (The actual plugin object)]">
		<cfargument name="targetType" 	 required="true" type="string" hint="Either plugin or handler or interceptor">
		<!--- ************************************************************* --->
		<cfscript>
			/* Targets */
			var targetPath = "";
			var targetObject = "";
			
			/* Determine targets by type */
			if ( targetType eq "plugin" ){
				targetObject = interceptData.oPlugin;
				targetPath = interceptData.custom & "_" & interceptData.pluginPath;
			}
			else if( targetType eq "handler"){
				targetObject = interceptData.oHandler;
				targetPath = interceptData.handlerPath;
			}
			else if( targetType eq "interceptor" ){
				targetObject = interceptData.oInterceptor;
				targetPath = interceptData.interceptorPath;
			}
			
			/* Exclude the core plugins from autowires */
			if( not findnocase("coldbox.system.plugins",targetPath) ){
				/* Process Autowire */
				instance.beanFactory.autowire(target=targetObject,
											  useSetterInjection=getProperty('enableSetterInjection'),
											  annotationCheck=true,
											  onDICompleteUDF=getProperty('completeDIMethodName'),
											  debugMode=getProperty('debugMode'));
			}	
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE METHDOS ------------------------------------------->
	


</cfcomponent>