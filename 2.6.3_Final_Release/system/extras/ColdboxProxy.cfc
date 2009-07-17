<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This component is the coldbox remote proxy used for model operation.
	This will convert the framework into a model framework rather than a 
	HTML MVC framework.	
----------------------------------------------------------------------->
<cfcomponent name="ColdboxProxy" output="false" hint="This component is the coldbox remote proxy used for model operation." >
	
<!------------------------------------------- PUBLIC ------------------------------------------->	

	<!--- process a remote call --->
	<cffunction name="process" output="false" access="remote" returntype="any" hint="Process a remote call into ColdBox's event model and return data/objects back. If no results where found, this method returns null/void">
		<!--- There are no arguments defined as they come in as a collection of arguments. --->
		<cfset var cbController = "">
		<cfset var event = "">
		<cfset var refLocal = structnew()>
		<cfsetting showdebugoutput="false">
		<cfsetting enablecfoutputonly="true">
		<cfscript>
			
			/* Get ColdBox Controller */
			cbController = getController();
			
			try{
				/* Trace the incoming arguments. */
				tracer('Process: Incoming arguments',arguments);
				
				/* Create the request context */
				Event = cbController.getRequestService().requestCapture();
				
				/* Test Event Name */
				if( not structKeyExists(arguments, "#event.getEventName()#") ){
					getUtil().throwit("Event not detected","The #event.geteventName()# variable does not exist in the arguments.");
				}
				
				//Append the arguments to the collection
				Event.collectionAppend(arguments,true);
				//Set that this is a proxy request.
				Event.setProxyRequest();
				
				//Execute the app start handler if not fired already
				if ( cbController.getSetting("ApplicationStartHandler") neq "" and (not cbController.getAppStartHandlerFired()) ){
					cbController.runEvent(cbController.getSetting("ApplicationStartHandler"),true);
					cbController.setAppStartHandlerFired(true);
				}
				
				//Execute a pre process interception.
				cbController.getInterceptorService().processState("preProcess");
				
				//Request Start Handler if defined
				if ( cbController.getSetting("RequestStartHandler") neq "" ){
					cbController.runEvent(cbController.getSetting("RequestStartHandler"),true);
				}
					
				//Execute the Event
				refLocal.results = cbController.runEvent(default=true);
				
				//Request END Handler if defined
				if ( cbController.getSetting("RequestEndHandler") neq "" ){
					cbController.runEvent(cbController.getSetting("RequestEndHandler"),true);
				}
				
				//Execute the post process interceptor
				cbController.getInterceptorService().processState("postProcess");
				
				/* Request Profilers */
				pushTimers();
			}
			catch(Any e){
				/* Log Exception */
				handleException(e);
				/* Rethrow it */
				getUtil().rethrowit(e);
			}
				
			/* Determine what to return via the setting */
			if ( cbController.getSetting("ProxyReturnCollection") ){
				/* Return request collection */
				return Event.getCollection();
			}
			else{
				/* Check for Marshalling */
				refLocal.marshalData = Event.getRenderData();
				if ( not structisEmpty(refLocal.marshalData) ){
					/* Marshal Data */
					refLocal.results = getPlugin("Utilities").marshallData(argumentCollection=refLocal.marshalData);
					/* Set Return Format according to Marshalling Type if not incoming */
					if( not structKeyExists(arguments, "returnFormat") ){
						arguments.returnFormat = refLocal.marshalData.type;
					}
				}
				
				/* Return results from handler only if found, else method will produce a null result */
				if( structKeyExists(refLocal,"results") ){
					/* Trace the results */
					tracer('Process: Outgoing Results',refLocal.results);
					/* Return The results */
					return refLocal.results;
				}
				else{
					/* Trace the results */
					tracer('No outgoing results found in the local scope.');
				}				
			}
		</cfscript>		
	</cffunction>
	
	<!--- process an interception --->
	<cffunction name="announceInterception" output="false" access="remote" returntype="boolean" hint="Process a remote interception.">
		<!--- ************************************************************* --->
		<cfargument name="state" 			type="string" 	required="true" hint="The intercept state"/>
		<cfargument name="interceptData"    type="any" 	    required="false" default="" hint="This method will take the contents and embedded into a structure"/>
		<!--- ************************************************************* --->
		<cfscript>
			var cbController = "";
			var interceptionStructure = structnew();
			
			/* Get ColdBox Controller */
			cbController = getController();
			
			/* emded contents */
			interceptionStructure.interceptData = arguments.interceptData;
			
			/* Trace the incoming arguments */
			tracer('AnnounceInterception: incoming arguments',arguments);
					
			/* Intercept */
			try{
				cbController.getInterceptorService().processState(arguments.state,interceptionStructure);
			}
			catch(Any e){
				/* Handle Exception */
				handleException(e);				
				/* Rethrow it */
				getUtil().rethrowit(e);
			}
			
			/* Request Profilers */
			pushTimers();
			
			/* Return */
			return true;
		</cfscript>
	</cffunction>
		
<!------------------------------------------- PRIVATE ------------------------------------------->	
	
	<!--- handleException --->
	<cffunction name="handleException" output="false" access="private" returntype="void" hint="Handle a ColdBox request Exception">
		<cfargument name="exceptionObject" type="any" required="true" hint="The exception object"/>
		<cfscript>
			var cbController = "";
			var interceptData = structnew();
			
			/* Get ColdBox Controller */
			cbController = getController();
			
			/* Intercept Exception */
			interceptData = structnew();
			interceptData.exception = arguments.exceptionObject;
			cbController.getInterceptorService().processState("onException",interceptData);
			
			/* Log Exception */
			cbController.getExceptionService().ExceptionHandler(arguments.exceptionObject,"coldboxproxy","ColdBox Proxy Exception");
			
			/* Request Profilers */
			pushTimers();
		</cfscript>
	</cffunction>
	
	<!--- Trace messages to the tracer panel --->
	<cffunction name="tracer" access="private" returntype="void" hint="Trace messages to the tracer panel, will only trace if in debug mode." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="message"    type="string" required="Yes" hint="Message to Send" >
		<cfargument name="ExtraInfo"  required="No" default="" type="any" hint="Extra Information to dump on the trace">
		<!--- ************************************************************* --->
		<cfscript>
			var cbController = getController();
			
			if( cbController.getDebuggerService().getDebugMode() ){
				cbController.getPlugin("logger").tracer(argumentCollection=arguments);
			}
		</cfscript>
	</cffunction>
	
	<!--- Push Timers --->
	<cffunction name="pushTimers" access="private" returntype="void" hint="Push timers into debugging stack" output="false" >
		<cfscript>
			var cbController = getController();
			var dService = cbController.getDebuggerService();
			
			/* Only push if in debug mode. */
			if( cbController.getDebuggerService().getDebugMode() ){
				/* Request Profilers */
				if ( dService.getDebuggerConfigBean().getPersistentRequestProfiler() and structKeyExists(request,"debugTimers") ){
					/* Push timers */
					dService.pushProfiler(request.DebugTimers);
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- verifyColdBox --->
	<cffunction name="verifyColdBox" output="false" access="private" returntype="boolean" hint="Verify the coldbox app">
		<cfscript>
			//Verify the coldbox app is ok, else throw
			if ( not structKeyExists(application,"cbController") ){
				getUtil().throwit("ColdBox Controller Not Found", "The coldbox main controller has not been initialized");
			}
			else{
				return true;
			}
		</cfscript>
	</cffunction>
	
	<!--- Get the ColdBox Controller. --->
	<cffunction name="getController" output="false" access="private" returntype="any" hint="Get the controller from application scope.">
		<cfscript>
			/* Verify ColdBox */
			verifyColdBox();
			/* Return it. */
			return application.cbController;
		</cfscript>
	</cffunction>
	
	<!--- Facade: Get a plugin --->
	<cffunction name="getPlugin" access="private" returntype="any" hint="Plugin factory, returns a new or cached instance of a plugin." output="false">
		<!--- ************************************************************* --->
		<cfargument name="plugin" 		type="string"  hint="The Plugin object's name to instantiate" >
		<cfargument name="customPlugin" type="boolean" required="false" default="false" hint="Used internally to create custom plugins.">
		<cfargument name="newInstance"  type="boolean" required="false" default="false" hint="If true, it will create and return a new plugin. No caching or persistance.">
		<!--- ************************************************************* --->
		<cfreturn getController().getPlugin(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Interceptor Facade --->
	<cffunction name="getInterceptor" access="private" output="false" returntype="any" hint="Get an interceptor">
		<!--- ************************************************************* --->
		<cfargument name="interceptorClass" required="true" type="string" hint="The qualified class of the itnerceptor to retrieve">
		<!--- ************************************************************* --->
		<cfreturn getController().getInterceptorService().getInterceptor(arguments.interceptorClass)>
	</cffunction>
	
	<!--- Facade: Get the IOC Plugin. --->
	<cffunction name="getIoCFactory" output="false" access="private" returntype="any" hint="Gets the IOC Factory in usage: coldspring or lightwire">
		<cfreturn getController().getPlugin("ioc").getIoCFactory()>
	</cffunction>
	
	<!--- Facade: Get the an ioc bean --->
	<cffunction name="getBean" output="false" access="private" returntype="any" hint="Get a bean from the ioc plugin.">
		<cfargument name="beanName" type="string" required="true" hint="The bean name to get."/>
		<cfreturn getController().getPlugin("ioc").getBean(arguments.beanName)>
	</cffunction>
	
	<!--- Get Model --->
	<cffunction name="getModel" access="private" returntype="any" hint="Create or retrieve model objects by convention" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 				required="true"  type="string" hint="The name of the model to retrieve">
		<cfargument name="useSetterInjection" 	required="false" type="boolean" default="false"	hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence.">
		<cfargument name="onDICompleteUDF" 		required="false" type="string"	default="onDIComplete" hint="After Dependencies are injected, this method will look for this UDF and call it if it exists. The default value is onDIComplete">
		<cfargument name="debugMode" 			required="false" type="boolean" default="false" hint="Debugging Mode or not">
		<!--- ************************************************************* --->
		<cfreturn getController().getPlugin("beanFactory").getModel(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Facade: Get COldBox OCM --->
	<cffunction name="getColdboxOCM" access="private" output="false" returntype="any" hint="Get ColdboxOCM: coldbox.system.cache.CacheManager">
		<cfreturn getController().getColdboxOCM()/>
	</cffunction>
	
	<!--- Bootstrapper LoadColdBox --->
	<cffunction name="loadColdbox" access="private" output="false" returntype="void" hint="Load a coldbox application, and place the coldbox controller in application scope for usage. If the application is already running, then it will not re-do it, unless you specify the reload argument or the application expired.">
		<!--- ************************************************************* --->
		<cfargument name="appRootPath" 		type="string"  required="true" hint="The absolute location of the root of the coldbox application. This is usually where the Application.cfc is and where the conventions are read from."/>
		<cfargument name="configLocation" 	type="string"  required="false" default="" 		hint="The absolute location of the config file to override, if not passed, it will try to locate it by convention."/>
		<cfargument name="reloadApp" 		type="boolean" required="false" default="false" hint="Flag to reload the application or not"/>
		<!--- ************************************************************* --->
		<cfset var cbController = "">
		<cfset var appHash = hash(getBaseTemplatePath())>
		
		<!--- Reload Checks --->
		<cfif not structKeyExists(application,"cbController") or not application.cbController.getColdboxInitiated() or arguments.reloadApp>
			<cflock type="exclusive" name="#appHash#" timeout="30" throwontimeout="true">
				<cfscript>
				if ( not structkeyExists(application,"cbController") or not application.cbController.getColdboxInitiated() or arguments.reloadApp ){
					/* Cleanup, Just in Case */
					if( structKeyExists(application,"cbController") ){
						structDelete(application,"cbController");
					}
					/* Load it Up baby!! */
					cbController = CreateObject("component", "coldbox.system.controller").init( appRootPath );
					/* Put in Scope */
					application.cbController = cbController;
					/* Setup Calls */
					cbController.getLoaderService().setupCalls(arguments.configLocation);					
				}				
				</cfscript>
			</cflock>
		</cfif>		
		
		<!--- Application Startup. --->
		<cfif cbController.getSetting("ApplicationStartHandler") neq "" and (not cbController.getAppStartHandlerFired())>
			<cfset cbController.runEvent(cbController.getSetting("ApplicationStartHandler"),true)>
			<cfset cbController.setAppStartHandlerFired(true)>
		</cfif>
	</cffunction>
	
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.util.Util" hint="Create and return a util object">
		<cfreturn CreateObject("component","coldbox.system.util.Util")/>
	</cffunction>
	
</cfcomponent>