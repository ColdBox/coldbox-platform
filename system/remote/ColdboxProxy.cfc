<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This component is the coldbox remote proxy used for model operation.
	This will convert the framework into a model framework rather than a
	HTML MVC framework.
----------------------------------------------------------------------->
<cfcomponent name="ColdboxProxy" output="false" hint="This component is the coldbox remote proxy used for remote operations." >

	<cfscript>
		// Setup Namespace Key for controller locations
		setCOLDBOX_APP_KEY("cbController");
	</cfscript>

	<!--- getRemotingUtil --->
    <cffunction name="getRemotingUtil" output="false" access="private" returntype="coldbox.system.remote.RemotingUtil" hint="Get a reference to the ColdBox Remoting utility class.">
		<cfreturn createObject("component","coldbox.system.remote.RemotingUtil")>
    </cffunction>

	<!--- process a remote call --->
	<cffunction name="process" output="false" access="private" returntype="any" hint="Process a remote call into ColdBox's event model and return data/objects back. If no results where found, this method returns null/void">
		<!--- There are no arguments defined as they come in as a collection of arguments. --->
		<cfset var cbController = "">
		<cfset var event = "">
		<cfset var refLocal = structnew()>
		<cfset var interceptData = structnew()>
		<cfsetting showdebugoutput="false">

		<cftry>
			<cfscript>
			// Locate ColdBox Controller
			cbController = getController();

			// Trace the incoming arguments for debuggers
			tracer('Process: Incoming arguments',arguments);

			// Create the request context
			event = cbController.getRequestService().requestCapture();

			// Test event Name in the arguemnts.
			if( not structKeyExists(arguments,event.getEventName()) ){
				getUtil().throwit("Event not detected","The #event.geteventName()# variable does not exist in the arguments.");
			}

			//Append the arguments to the collection
			event.collectionAppend(arguments,true);
			//Set that this is a proxy request.
			event.setProxyRequest();

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

			// Request Profilers for debuggers.
			pushTimers();
			</cfscript>

			<cfcatch>
				<cfset handleException(cfcatch)>
				<cfrethrow>
			</cfcatch>
		</cftry>

		<cfscript>
			// Determine what to return via the setting for proxy calls, no preProxyReturn because we can just listen to the collection
			if ( cbController.getSetting("ProxyReturnCollection") ){
				// Return request collection
				return event.getCollection();
			}

			// Check for Marshalling
			refLocal.marshalData = event.getRenderData();
			if ( not structisEmpty(refLocal.marshalData) ){
				// Marshal Data
				refLocal.results = getPlugin("Utilities").marshallData(argumentCollection=refLocal.marshalData);

				// Set Return Format according to Marshalling Type if not incoming
				if( not structKeyExists(arguments, "returnFormat") ){
					arguments.returnFormat = refLocal.marshalData.type;
				}
			}

			// Return results from handler only if found, else method will produce a null result
			if( structKeyExists(refLocal,"results") ){
				// prepare packet by reference, so changes can take effect if modified in interceptions.
				interceptData.proxyResults = refLocal;

				// preProxyResults interception call
				cbController.getInterceptorService().processState("preProxyResults",interceptData);

				// Trace the results for debuggers
				tracer('Process: Outgoing Results',refLocal.results);

				// Return The results
				return refLocal.results;
			}

			// Trace that no results where found, returns void or null
			tracer('No outgoing results found in the local scope.');
		</cfscript>
	</cffunction>

	<!--- process an interception --->
	<cffunction name="announceInterception" output="false" access="private" returntype="boolean" hint="Process a remote interception">
		<!--- ************************************************************* --->
		<cfargument name="state" 			type="string" 	required="true"  hint="The intercept state"/>
		<cfargument name="interceptData"    type="any" 	    required="false" hint="This intercept data structure to announce with"/>
		<!--- ************************************************************* --->

		<cfset var cbController = getController()>
		<cftry>
			<cfif NOT structKeyExists(arguments,"interceptData")><cfset arguments.interceptData = structnew()></cfif>
			<cfset cbController.getInterceptorService().processState(arguments.state,arguments.interceptData)>
			<cfcatch>
				<cfset handleException(cfcatch)>
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfset pushTimers()>
		<cfreturn true>
	</cffunction>

	<!--- handleException --->
	<cffunction name="handleException" output="false" access="private" returntype="void" hint="Handle a ColdBox request Exception">
		<cfargument name="exceptionObject" type="any" required="true" hint="The exception object"/>
		<cfscript>
			var cbController = "";
			var interceptData = structnew();

			// Locate ColdBox Controller
			cbController = getController();

			// Intercept Exception
			interceptData.exception = arguments.exceptionObject;
			cbController.getInterceptorService().processState("onException",interceptData);

			// Log Exception
			cbController.getExceptionService().ExceptionHandler(arguments.exceptionObject,"ColdboxProxy","ColdBox Proxy Exception");

			// Request Profilers
			pushTimers();
		</cfscript>
	</cffunction>

	<!--- Trace messages to the tracer panel --->
	<cffunction name="tracer" access="private" returntype="void" hint="Trace messages to the tracer panel, will only trace if in debug mode." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="message"    type="string" required="true" hint="Message to Send" >
		<cfargument name="extraInfo"  required="false" default="" type="any" hint="Extra Information to dump on the trace">
		<!--- ************************************************************* --->
		<cfscript>
			var cbController = getController();

			if( cbController.getDebuggerService().getDebugMode() ){
				cbController.getDebuggerService().pushTracer(argumentCollection=arguments);
			}
		</cfscript>
	</cffunction>

	<!--- Push Timers --->
	<cffunction name="pushTimers" access="private" returntype="void" hint="Push timers into debugging stack" output="false" >
		<cfscript>
			getController().getDebuggerService().recordProfiler();
		</cfscript>
	</cffunction>

	<!--- verifyColdBox --->
	<cffunction name="verifyColdBox" output="false" access="private" returntype="boolean" hint="Verify the coldbox app">
		<cfscript>
			//Verify the coldbox app is ok, else throw
			if ( not structKeyExists(application,COLDBOX_APP_KEY) ){
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
			// Verify ColdBox
			verifyColdBox();

			return application[COLDBOX_APP_KEY];
		</cfscript>
	</cffunction>

	<!--- Get the cachebox instance --->
	<cffunction name="getCacheBox" output="false" access="private" returntype="any" hint="Get the CacheBox reference." colddoc:generic="coldbox.system.cache.CacheFactory">
		<cfreturn getController().getCacheBox()>
	</cffunction>

	<!--- getWireBox --->
	<cffunction name="getWireBox" output="false" access="private" returntype="any" hint="Get the WireBox Injector reference of this application.">
		<cfreturn getController().getWireBox()>
	</cffunction>

	<!--- getInstance --->
    <cffunction name="getInstance" output="false" access="private" returntype="any" hint="Locates, Creates, Injects and Configures an object model instance">
    	<cfargument name="name" 			required="true" 	hint="The mapping name or CFC instance path to try to build up"/>
		<cfargument name="dsl"				required="false" 	hint="The dsl string to use to retrieve the instance model object, mutually exclusive with 'name'"/>
		<cfargument name="initArguments" 	required="false" 	hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfreturn getWireBox().getInstance(argumentCollection=arguments)>
	</cffunction>

	<!--- Get the LogBox. --->
	<cffunction name="getLogBox" output="false" access="private" returntype="any" hint="Get the LogBox reference of this application.">
		<cfreturn getController().getLogBox()>
	</cffunction>

	<!--- Get the app's root Logger --->
	<cffunction name="getRootLogger" output="false" access="private" returntype="coldbox.system.logging.Logger" hint="Get the root logger reference.">
		<cfreturn getLogBox().getRootLogger()>
	</cffunction>

	<!--- Get a logger --->
	<cffunction name="getLogger" output="false" access="private" returntype="coldbox.system.logging.Logger" hint="Get a named logger reference.">
		<cfargument name="category" type="any" required="true" hint="The category name to use in this logger or pass in the target object will log from and we will inspect the object and use its metadata name."/>
		<cfreturn getLogBox().getLogger(arguments.category)>
	</cffunction>

	<!--- Facade: Get a plugin --->
	<cffunction name="getPlugin" access="private" returntype="any" hint="Plugin factory, returns a new or cached instance of a plugin." output="false">
		<!--- ************************************************************* --->
		<cfargument name="plugin" 		type="any"  hint="The Plugin object's name to instantiate" >
		<cfargument name="customPlugin" type="boolean"  required="false" default="false" hint="Used internally to create custom plugins.">
		<cfargument name="newInstance"  type="boolean"  required="false" default="false" hint="If true, it will create and return a new plugin. No caching or persistance.">
		<cfargument name="module" 		type="any" 	    required="false" default="" hint="The module to retrieve the plugin from"/>
		<cfargument name="init" 		type="boolean"  required="false" default="true" hint="Auto init() the plugin upon construction"/>
		<!--- ************************************************************* --->
		<cfreturn getController().getPlugin(argumentCollection=arguments)>
	</cffunction>

	<!--- Interceptor Facade --->
	<cffunction name="getInterceptor" access="private" output="false" returntype="any" hint="Get an interceptor">
		<!--- ************************************************************* --->
		<cfargument name="interceptorName" 	required="false" type="string" hint="The name of the interceptor to search for"/>
		<cfargument name="deepSearch" 		required="false" type="boolean" default="false" hint="By default we search the cache for the interceptor reference. If true, we search all the registered interceptor states for a match."/>
		<!--- ************************************************************* --->
		<cfreturn getController().getInterceptorService().getInterceptor(argumentCollection=arguments)>
	</cffunction>

	<!--- Facade: Get the IOC Plugin. --->
	<cffunction name="getIoCFactory" output="false" access="private" returntype="any" hint="Gets the IOC Factory in usage: coldspring or lightwire">
		<cfreturn getController().getPlugin("IOC").getIoCFactory()>
	</cffunction>

	<!--- Facade: Get the an ioc bean --->
	<cffunction name="getBean" output="false" access="private" returntype="any" hint="Get a bean from the ioc plugin.">
		<cfargument name="beanName" type="string" required="true" hint="The bean name to get."/>
		<cfreturn getController().getPlugin("IOC").getBean(arguments.beanName)>
	</cffunction>

	<!--- Get Model --->
	<cffunction name="getModel" access="private" returntype="any" hint="Create or retrieve model objects by convention" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 				required="false" type="any" default="" hint="The name of the model to retrieve">
		<cfargument name="useSetterInjection" 	required="false" type="any" hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence. Boolean" colddoc:generic="Boolean">
		<cfargument name="onDICompleteUDF" 		required="false" type="any"	hint="After Dependencies are injected, this method will look for this UDF and call it if it exists. The default value is onDIComplete">
		<cfargument name="stopRecursion"		required="false" type="any"  hint="A comma-delimmited list of stoprecursion classpaths.">
		<cfargument name="dsl"					required="false" type="any"  hint="The dsl string to use to retrieve the domain object"/>
		<cfargument name="executeInit"			required="false" type="any" default="true" hint="Whether to execute the init() constructor or not.  Defaults to execute, Boolean" colddoc:generic="Boolean"/>
		<cfargument name="initArguments" 		required="false" 	hint="The constructor structure of arguments to passthrough when initializing the instance. Only available for WireBox integration" colddoc:generic="struct"/>
		<!--- ************************************************************* --->
		<cfreturn getController().getPlugin("BeanFactory").getModel(argumentCollection=arguments)>
	</cffunction>

	<!--- Facade: Get COldBox OCM --->
	<cffunction name="getColdboxOCM" access="private" output="false" returntype="any" hint="Get ColdboxOCM: coldbox.system.cache.CacheManager or new CacheBox providers" colddoc:generic="coldbox.system.cache.IColdboxApplicationCache">
		<cfargument name="cacheName" type="string" required="false" default="default" hint="The cache name to retrieve"/>
		<cfreturn getController().getColdboxOCM(arguments.cacheName)/>
	</cffunction>

	<!--- Bootstrapper LoadColdBox --->
	<cffunction name="loadColdbox" access="private" output="false" returntype="void" hint="Load a coldbox application, and place the coldbox controller in application scope for usage. If the application is already running, then it will not re-do it, unless you specify the reload argument or the application expired.">
		<!--- ************************************************************* --->
		<cfargument name="appMapping" 		type="string"  required="true" hint="The absolute location of the root of the coldbox application. This is usually where the Application.cfc is and where the conventions are read from."/>
		<cfargument name="configLocation" 	type="string"  required="false" default="" 		hint="The absolute location of the config file to override, if not passed, it will try to locate it by convention."/>
		<cfargument name="reloadApp" 		type="boolean" required="false" default="false" hint="Flag to reload the application or not"/>
		<!--- ************************************************************* --->
		<cfset var cbController = "">
		<cfset var appHash = hash(getBaseTemplatePath())>

		<!--- Reload Checks --->
		<cfif not structKeyExists(application,COLDBOX_APP_KEY) or not application[COLDBOX_APP_KEY].getColdboxInitiated() or arguments.reloadApp>
			<cflock type="exclusive" name="#appHash#" timeout="30" throwontimeout="true">
				<cfscript>
				if ( not structkeyExists(application,COLDBOX_APP_KEY) OR NOT
					 application[COLDBOX_APP_KEY].getColdboxInitiated() OR
					 arguments.reloadApp ){
					// Cleanup, Just in Case
					if( structKeyExists(application,COLDBOX_APP_KEY) ){
						structDelete(application,COLDBOX_APP_KEY);
					}
					// Load it Up baby!!
					cbController = CreateObject("component", "coldbox.system.web.Controller").init( expandPath(arguments.appMapping) );
					// Put in Scope
					application[COLDBOX_APP_KEY] = cbController;
					// Setup Calls
					cbController.getLoaderService().loadApplication(arguments.configLocation,arguments.appMapping);
				}
				</cfscript>
			</cflock>
		</cfif>
	</cffunction>

	<!--- Get Simple Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn CreateObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

	<!--- setter COLDBOX_APP_KEY --->
	<cffunction name="setCOLDBOX_APP_KEY" access="private" returntype="void" output="false" hint="Override the name of the coldbox application key used.">
		<cfargument name="COLDBOX_APP_KEY" type="string" required="true">
		<cfset variables.COLDBOX_APP_KEY = arguments.COLDBOX_APP_KEY>
	</cffunction>

</cfcomponent>