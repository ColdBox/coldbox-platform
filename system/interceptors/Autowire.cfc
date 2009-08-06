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
<cfcomponent hint="This is an autowire interceptor"
			 output="false"
			 extends="coldbox.system.Interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="configure" access="public" returntype="void" output="false" >
		<cfscript>
			// Get set properties
			if( not propertyExists("debugMode") or not isBoolean(getProperty("debugMode")) ){
				setProperty("debugMode",false);
			}
			// DI Complete Method
			if(not propertyExists("completeDIMethodName")){
				setProperty("completeDIMethodName",'onDIComplete');
			}
			// enableSetterInjection
			if(NOT propertyExists("enableSetterInjection") OR
			   NOT isBoolean(getProperty('enableSetterInjection')) ){
				setProperty("enableSetterInjection",'false');
			}		
			// Annotation Check
			if( NOT propertyExists("annotationCheck") or NOT isBoolean(getProperty("annotationCheck")) ){
				setProperty("annotationCheck",false);
			}
			
			// Create our BeanFactory plugin, we do this here, because we need it not to execute an endless loop
			instance.beanFactory = getPlugin("BeanFactory");	
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<!--- After Aspects Load --->
	<cffunction name="afterAspectsLoad" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="any" hint="The event object.">
		<cfargument name="interceptData" required="true" type="any" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
		<cfscript>
			var interceptorConfig = getSetting("InterceptorConfig");
			var x = 1;
			
			// Loop over the Interceptor Array, to begin autowiring
			for (; x lte arrayLen(interceptorConfig.interceptors); x=x+1){
				
				// Exclude yourself
				if( not findnocase("coldbox.system.interceptors.Autowire",interceptorConfig.interceptors[x].class) ){
					// No locking necessary here, since the after aspects load is executed in thread safe conditions
					// Autowire it
					processAutowire(getInterceptor(interceptorConfig.interceptors[x].name,true));
				}
				
			}
		</cfscript>
	</cffunction>
	
	<!--- After Handler Creation --->
	<cffunction name="afterHandlerCreation" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="any" hint="The event object.">
		<cfargument name="interceptData" required="true" type="any" hint="A structure containing intercepted data = [handlerPath (The path of the handler), oHandler (The actual handler object)]">
		<!--- ************************************************************* --->
		<cflock type="exclusive" name="cboxautowire_handler_#arguments.interceptData.handlerPath#" timeout="30" throwontimeout="true">
			<cfset processAutowire(arguments.interceptData.oHandler)>		
		</cflock>		
	</cffunction>
		
	<!--- After Plugin Creation --->
	<cffunction name="afterPluginCreation" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="any" hint="The event object.">
		<cfargument name="interceptData" required="true" type="any" hint="A structure containing intercepted data = [pluginPath (The path of the plugin), custom (Flag if the plugin is custom or not), oPlugin (The actual plugin object)]">
		<!--- ************************************************************* --->
		<cfif( not findnocase("coldbox.system.plugins",arguments.interceptData.custom & "_" & arguments.interceptData.pluginPath) )>
			<cflock type="exclusive" name="cboxautowire_plugin_#arguments.interceptData.pluginPath#" timeout="30" throwontimeout="true">
				<cfset processAutowire(arguments.interceptData.oPlugin)>		
			</cflock>
		</cfif>		
	</cffunction>
	
	<!--- After Plugin Creation --->
	<cffunction name="processAutowire" access="public" returntype="void" output="false" hint="Process autowiring using a targetype and data.">
		<!--- ************************************************************* --->
		<cfargument name="target" type="any" required="true" hint="The target object to autowire" >
		<!--- ************************************************************* --->
		<cfscript>
			try{
				// Process Autowire
				instance.beanFactory.autowire(target=arguments.target,
											  useSetterInjection=getProperty('enableSetterInjection'),
											  annotationCheck=getProperty("annotationCheck"),
											  onDICompleteUDF=getProperty('completeDIMethodName'),
											  debugMode=getProperty('debugMode'));
			}
			catch(Any e){
				getPlugin("logger").error("Error autowiring #getmetadata(arguments.target).name#. #e.message# #e.detail#");
				$throw(message="Error autowiring #getmetadata(arguments.target).name#. #e.message# #e.detail#",detail="#e.stacktrace#",type="Autowire.AutowireException");
			}
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE METHDOS ------------------------------------------->
	


</cfcomponent>