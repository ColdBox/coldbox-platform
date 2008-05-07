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
			/* Setup the Event Handler Cache Dictionary */
			setDICacheDictionary(CreateObject("component","coldbox.system.util.baseDictionary").init('DIMetadata'));
			
			/* Get set properties */
			if( not propertyExists("debugMode") or not isBoolean(getProperty("debugMode")) ){
				setProperty("debugMode",false);
			}
			/* DI Complete Method */
			if(not propertyExists("completeDIMethodName")){
				setProperty("completeDIMethodName",'onDIComplete');
			}
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
			var INTERCEPTOR_CACHEKEY_PREFIX = getController().getInterceptorService().INTERCEPTOR_CACHEKEY_PREFIX;
			var x = 1;
			
			/* Setup the targettype */
			arguments.targetType = "interceptor";
			
			/* Loop over the Interceptor Array, to begin autowiring */
			for (; x lte arrayLen(interceptorConfig.interceptors); x=x+1){
				
				/* Get the cache path */
				arguments.interceptData.interceptorPath = INTERCEPTOR_CACHEKEY_PREFIX & interceptorConfig.interceptors[x].class;
				
				/* Exclude yourself */
				if( not findnocase("coldbox.system.interceptors.autowire",interceptorConfig.interceptors[x].class) ){
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
		<cflock type="exclusive" name="cboxautowire_handler_#interceptData.handlerPath#" timeout="30">
			<cfset arguments.targetType = "handler">
			<cfset processAutowire(argumentCollection=arguments)>		
		</cflock>
	</cffunction>
		
	<!--- After Plugin Creation --->
	<cffunction name="afterPluginCreation" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted data = [pluginPath (The path of the plugin), custom (Flag if the plugin is custom or not), oPlugin (The actual plugin object)]">
		<!--- ************************************************************* --->
		<cflock type="exclusive" name="cboxautowire_plugin_#interceptData.pluginPath#" timeout="30">
			<cfset arguments.targetType = "plugin">
			<cfset processAutowire(argumentCollection=arguments)>		
		</cflock>
	</cffunction>
	
<!------------------------------------------- PRIVATE METHDOS ------------------------------------------->
	
	<!--- After Plugin Creation --->
	<cffunction name="processAutowire" access="private" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted data = [pluginPath (The path of the plugin), custom (Flag if the plugin is custom or not), oPlugin (The actual plugin object)]">
		<cfargument name="targetType" 	 required="true" type="string" hint="Either plugin or handler">
		<!--- ************************************************************* --->
		<cfscript>
			/* Targets */
			var targetCacheKey = "";
			var targetObject = "";
			
			/* Dependencies */
			var thisDependency = "";
			var thisScope = "";
			
			/* Metadata entry structures */
			var MetaData = "";
			var mdEntry = "";
			var targetDIEntry = "";
			var dependenciesLength = 0;
			var x = 1;
			var tmpBean = "";
			
			/* Determine targets by type */
			if ( targetType eq "plugin" ){
				targetObject = interceptData.oPlugin;
				targetCacheKey = interceptData.custom & "_" & interceptData.pluginPath;
			}
			else if( targetType eq "handler"){
				targetObject = interceptData.oHandler;
				targetCacheKey = interceptData.handlerPath;
			}
			else if( targetType eq "interceptor" ){
				targetObject = interceptData.oInterceptor;
				targetCacheKey = interceptData.interceptorPath;
			}
			
			/* Do we have the incoming target object's data in the cache? */
			if ( not getDICacheDictionary().keyExists(targetCacheKey) ){
				/* Get Object MetaData */
				MetaData = getMetaData(targetObject);
				/* Get Empty Default MD Entry */
				mdEntry = getNewMDEntry();
										
				/* By Default, objects are NOT autowired*/
				if ( not structKeyExists(MetaData,"autowire") or not isBoolean(MetaData["autowire"]) ){
					MetaData.autowire = false;
					mdEntry.autowire = false;
				}
				/* Lookup Dependencies if using autowire */
				if ( MetaData["autowire"] ){
					/* Set md entry to true for autowiring */
					mdEntry.autowire = true;
					/* Recurse for dependencies here, in order to build them. */
					mdEntry.dependencies = parseMetadata(MetaData,mdEntry.dependencies);
				}
				
				/* Set Entry in dictionary */
				getDICacheDictionary().setKey(targetCacheKey,mdEntry);
			}
			
			/* We are now assured that the DI cache has data. */
			targetDIEntry = getDICacheDictionary().getKey(targetCacheKey);
			/* Do we Inject Dependencies, are we AutoWiring */
			if ( targetDIEntry.autowire ){
				/* Dependencies Length */
				dependenciesLength = arrayLen(targetDIEntry.dependencies);
				/* Let's inject our mixins */
				getPlugin("methodInjector").start(targetObject);
				
				/* Loop over dependencies and inject. */
				for(x=1; x lte dependenciesLength;x=x+1){
					
					/* Defaults */
					thisDependency = targetDIEntry.dependencies[x];
					thisScope = "";
					
					/* Check for property and scopes */
					if( listlen(thisDependency) gt 1 ){
						thisDependency = listFirst(targetDIEntry.dependencies[x]);
						thisScope = listLast(targetDIEntry.dependencies[x]);
					}
					
					/* Verify that bean exists in the IOC container. */
					if( getPlugin("ioc").getIOCFactory().containsBean(thisDependency) ){
						
						/* Inject dependency */
						injectBean(targetBean=targetObject,
								   beanName=thisDependency,
								   beanObject=getPlugin("ioc").getBean(thisDependency),
								   scope=thisScope);
						
						/* Debug Mode Check */
						if( getProperty("debugMode") ){
							getPlugin("logger").logEntry("information","Bean: #thisDependency#,Scope: #thisScope# --> injected into #targetCacheKey#.");
						}
					}
					else if( getProperty("debugMode") ){
						getPlugin("logger").logEntry("warning","Bean: #thisDependency#,Scope: #thisScope# --> not found in factory");
					}
					
				}//end for loop of dependencies.
				
				/* Process After ID Complete */
				processAfterCompleteDI(targetObject);
				
				/* Let's cleanup our mixins */
				getPlugin("methodInjector").stop(targetObject);
				
			}//if autowiring			
		</cfscript>
	</cffunction>
	
	<!--- Get an object's dependencies via metadata --->
	<cffunction name="parseMetadata" returntype="array" access="private" output="false" hint="I get a components dependencies via searching for 'setters'">
		<!--- ************************************************************* --->
		<cfargument name="metadata" 		required="true" type="any" 		hint="The recursive metadata">
		<cfargument name="dependencies" 	required="true" type="array" 	hint="The dependencies">
		<!--- ************************************************************* --->
		<cfscript>
			var x = 1;
			var md = arguments.metadata;
			var cbox_reserved_functions = "setSetting,setDebugMode,setNextEvent,setNextRoute,setController,settingExists";
			
			/* Look For cfProperties */
			if( structKeyExists(md,"properties") and ArrayLen(md.properties) gt 0){
				for(x=1; x lte ArrayLen(md.properties); x=x+1 ){
					
					/* Check if type is ioc */
					if( structKeyExists(md.properties[x],"type") and md.properties[x].type eq "ioc" ){
						/* Scope Check */
						if( not structKeyExists(md.properties[x],"scope") ){
							md.properties[x].scope = "variables";
						}		
						/* Add Property Dependency */
						ArrayAppend( arguments.dependencies, md.properties[x].name & "," & md.properties[x].scope );
					}
					
				}//end for loop		
			}//end if properties found.
			
			/* Look for cfFunctions */		
			if( structKeyExists(md, "functions") ){
				for(x=1; x lte ArrayLen(md.functions); x=x+1 ){
					/* Verify we have a setter */
					if( left(md.functions[x].name,3) eq "set" and not listFindNoCase(cbox_reserved_functions,md.functions[x].name) ){
						/* Found Setter, append property Name */
						ArrayAppend(arguments.dependencies,Right(md.functions[x].name, Len(md.functions[x].name)-3));
					
					}//end if setter found.
				}//end loop of functions
			}//end if functions found
			
			/* Start Registering inheritances */
			if ( structKeyExists(md, "extends") and 
				 ( md.extends.name neq "coldbox.system.plugin" or
				   md.extends.name neq "coldbox.system.eventhandler" or
				   md.extends.name neq "coldbox.system.interceptor" )
			){
				/* Recursive lookup */
				arguments.dependencies = parseMetadata(md.extends,dependencies);
			}
			
			/* return the dependencies found */
			return arguments.dependencies;
		</cfscript>	
	</cffunction>
	
	<!--- Inject Bean --->
	<cffunction name="injectBean" access="private" returntype="void" output="false" hint="Inject a bean with dependencies via setters or property injections">
		<!--- ************************************************************* --->
		<cfargument name="targetBean"  	 type="any" 	required="true" hint="The bean that will be injected with dependencies" />
		<cfargument name="beanName"  	 type="string" 	required="true" hint="The name of the property to inject"/>
		<cfargument name="beanObject" 	 type="any" 	required="true" hint="The bean object to inject." />
		<cfargument name="scope" 		 type="string"  required="true" hint="The scope to inject a property into.">
		<!--- ************************************************************* --->
		<cfscript>
			var argCollection = structnew();
			argCollection[arguments.beanName] = arguments.beanObject;
		</cfscript>
		
		<!--- Property or Setter --->
		<cfif len(arguments.scope) eq 0>
			
			<!--- Call our mixin invoker --->
			<cfinvoke component="#arguments.targetBean#" method="invokerMixin">
				<cfinvokeargument name="method"  		value="set#arguments.beanName#">
				<cfinvokeargument name="argCollection"  value="#argCollection#">
			</cfinvoke>	
			
		<cfelse>
			
			<!--- Call our property injector mixin --->
			<cfinvoke component="#arguments.targetBean#" method="injectPropertyMixin">
				<cfinvokeargument name="propertyName"  	value="#arguments.beanName#">
				<cfinvokeargument name="propertyValue"  value="#arguments.beanObject#">
				<cfinvokeargument name="scope"			value="#arguments.scope#">
			</cfinvoke>	
			
		</cfif>			
	</cffunction>
	
	<!--- Process After DI Complete --->
	<cffunction name="processAfterCompleteDI" hint="see if we have a method to call after DI, and if so, call it" access="private" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="targetObject" hint="the target object to call on" type="any" required="Yes">
		<!--- ************************************************************* --->
		<cfset var meta = 0 />
		<!--- Check if method exists --->
		<cfif StructKeyExists(arguments.targetObject, getProperty('CompleteDIMethodName'))>
			<!--- Call our mixin invoker --->
			<cfinvoke component="#arguments.targetObject#" method="invokerMixin">
				<cfinvokeargument name="method"  		value="#getProperty('CompleteDIMethodName')#">
			</cfinvoke>
		</cfif>
	</cffunction>
	
	<!--- Get a new MD cache entry structure --->
	<cffunction name="getNewMDEntry" access="private" returntype="struct" hint="Get a new metadata entry structure" output="false" >
		<cfscript>
			var mdEntry = structNew();
			
			mdEntry.autowire = false;
			mdEntry.dependencies = Arraynew(1);
			
			return mdEntry;
		</cfscript>
	</cffunction>
	
	<!--- Get Set DI CACHE Dictionary --->
	<cffunction name="getDICacheDictionary" access="private" output="false" returntype="coldbox.system.util.baseDictionary" hint="Get DICacheDictionary">
		<cfreturn instance.DICacheDictionary/>
	</cffunction>
	<cffunction name="setDICacheDictionary" access="private" output="false" returntype="void" hint="Set DICacheDictionary">
		<cfargument name="DICacheDictionary" type="coldbox.system.util.baseDictionary" required="true"/>
		<cfset instance.DICacheDictionary = arguments.DICacheDictionary/>
	</cffunction>

</cfcomponent>