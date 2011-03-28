<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano
Description :
	This interceptor is used to autowire plugins, handlers and interceptors.
	Plugins and handlers are autowired after creation. Intreceptors will always
	be autowired after the aspects load. This is to give chance for all the correct
	application aspects to be in place.
	
----------------------------------------------------------------------->
<cfcomponent hint="This is an autowire interceptor" output="false" extends="coldbox.system.Interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- configure --->
	<cffunction name="configure" access="public" returntype="void" output="false" >
		<cfscript>
			
			// Prepare Autowire Settings
			
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
			
			// Enable Entity Injection
			if(NOT propertyExists("entityInjection") or NOT isBoolean(getProperty("entityInjection"))){
				setProperty("entityInjection",false);
			}
			// Entity Includes
			if(NOT propertyExists("entityInclude") ){
				setProperty("entityInclude",'');
			}
			// Entity Excludes
			if(NOT propertyExists("entityExclude") ){
				setProperty("entityExclude",'');
			}
			
			// Get bean factory
			beanFactory = getPlugin("BeanFactory");
			
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
			var x 				  = 1;
			
			// Loop over the Interceptor Array, to begin autowiring
			for (; x lte arrayLen(interceptorConfig.interceptors); x=x+1){
				// Exclude yourself
				if( not findnocase("coldbox.system.interceptors.Autowire",interceptorConfig.interceptors[x].class) ){
					// No locking necessary here, since the after aspects load is executed in thread safe conditions
					// Autowire it
					processAutowire(getInterceptor(interceptorConfig.interceptors[x].name,true),interceptorConfig.interceptors[x].class);
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
		<cfset processAutowire(arguments.interceptData.oHandler,arguments.interceptData.handlerPath)>		
	</cffunction>
		
	<!--- After Plugin Creation --->
	<cffunction name="afterPluginCreation" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="any" hint="The event object.">
		<cfargument name="interceptData" required="true" type="any" hint="A structure containing intercepted data = [pluginPath (The path of the plugin), custom (Flag if the plugin is custom or not), oPlugin (The actual plugin object)]">
		<!--- ************************************************************* --->
		<cfif( NOT findnocase("coldbox.system.plugins",arguments.interceptData.pluginPath) )>
			<cfset processAutowire(arguments.interceptData.oPlugin,arguments.interceptData.pluginPath)>
		</cfif>		
	</cffunction>
	
	<!--- After EntityNew --->
	<cffunction name="ORMPostNew" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="any" hint="The event object.">
		<cfargument name="interceptData" required="true" type="any" hint="A structure containing intercepted data = [entity=The created entity]">
		<!--- ************************************************************* --->
		<cfset processEntityInjection(argumentCollection=arguments)>
	</cffunction>
	
	<!--- ORMPostLoad --->
	<cffunction name="ORMPostLoad" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="any" hint="The event object.">
		<cfargument name="interceptData" required="true" type="any" hint="A structure containing intercepted data = [entity=The created entity]">
		<!--- ************************************************************* --->
		<cfset processEntityInjection(argumentCollection=arguments)>
	</cffunction>
	
	<!--- processAutowire --->
	<cffunction name="processAutowire" access="public" returntype="void" output="false" hint="Process autowiring using a targetype and data.">
		<!--- ************************************************************* --->
		<cfargument name="target" 	type="any" required="true" hint="The target object to autowire" >
		<cfargument name="targetID" type="any" required="true" hint="The target identifier to use for wiring"/>
		<!--- ************************************************************* --->
		<cfscript>
			try{
				// Process Autowire
				beanFactory.autowire(target=arguments.target,
									 useSetterInjection=getProperty('enableSetterInjection'),
									 annotationCheck=getProperty("annotationCheck"),
								     onDICompleteUDF=getProperty('completeDIMethodName'),
								     targetID=arguments.targetID);
			}
			catch(Any e){
				log.error("Error autowiring #getmetadata(arguments.target).name#. #e.message# #e.detail#");
				$throw(message="Error autowiring #getmetadata(arguments.target).name#. #e.message# #e.detail#",detail="#e.stacktrace#",type="Autowire.AutowireException");
			}
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE METHDOS ------------------------------------------->
	
	<cffunction name="processEntityInjection" access="private" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="any" hint="The event object.">
		<cfargument name="interceptData" required="true" type="any" hint="A structure containing intercepted data = [entity=The created entity]">
		<!--- ************************************************************* --->
		<cfscript>
			var entityName		= arguments.interceptData.entityName;
			var injectorInclude = getProperty("entityInclude");
			var injectorExclude = getProperty("entityExclude");
			
			// Enabled?
			if( NOT getProperty("entityInjection") ){
				return;
			}
			
			// Include,Exclude?
			if( (len(injectorInclude) AND listContainsNoCase(injectorInclude,entityName))
			    OR
				(len(injectorExclude) AND NOT listContainsNoCase(injectorExclude,entityName))
				OR 
				(NOT len(injectorInclude) AND NOT len(injectorExclude) ) ){
				
				// Process DI
				processAutowire(target=arguments.interceptData.entity,targetID="ORMEntity-#entityName#");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="getUtil" access="private" output="false" returntype="any" hint="Create and return a util object" colddoc:generic="coldbox.system.core.util.Util">
		<cfreturn CreateObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

</cfcomponent>