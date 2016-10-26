<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
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
		// Setup Default Namespace Key for controller locations
		setCOLDBOX_APP_KEY("cbController");

		// Remote proxies are created by the CFML engine without calling init(),
		// so autowire in here in the pseduo constructor
		selfAutowire();
	</cfscript>

	<!--- selfAutowire --->
    <cffunction name="selfAutowire" output="false" access="private" hint="Autowire the proxy on creation. This references the super class only, we use cgi information to get the actual proxy component path.">
		<cfscript>
			var script_name = cgi.script_name;
			// Only process this logic if hitting a remote proxy CFC directly and if ColdBox exists. 
			if( len( script_name ) < 5 || right( script_name, 4 ) != '.cfc' || !verifyColdBox( throwOnNotExist=false ) ) {
				return;
			}

			// Find the path of the proxy component being called
			var componentpath = replaceNoCase(mid( script_name, 2, len( script_name ) -5 ),'/','.');
			var injector = getWirebox();
			var binder = injector.getBinder();
			var mapping = '';

			// Prevent recursive object creation in Railo/Lucee
			if( !structKeyExists( request, 'proxyAutowire' ) ){
				request.proxyAutowire = true;

				// If a mapping for this proxy doesn't exist, create it.
				if( !binder.mappingExists( componentpath ) ) {
					// First one only, please
					lock name="ColdBoxProxy.createMapping.#hash( componentpath )#" type="exclusive" timeout="20" {
						// Double check
						if( !binder.mappingExists( componentpath ) ) {

							// Get its metadata
							var md = getUtil().getInheritedMetaData( componentpath );

							// register new mapping instance
							injector.registerNewInstance( componentpath, componentpath );
							// get Mapping created
							mapping = binder.getMapping( componentpath );
							// process it with the correct metadata
							mapping.process( binder=binder, injector=injector, metadata=md );

						}

					} // End lock
				} // End outer exists check

				// Guaranteed to exist now
				mapping = binder.getMapping( componentpath );

				// Autowire ourself based on the mapping
				getWirebox().autowire(target=this, mapping=mapping, annotationCheck=true);
			}
		</cfscript>

    </cffunction>

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

			// Load Module CF Mappings
			cbController.getModuleService().loadMappings();
			// Create the request context
			event = cbController.getRequestService().requestCapture();

			// Test event Name in the arguemnts.
			if( not structKeyExists( arguments, event.getEventName() ) ){
				throw( 
					message="Event not detected",
					detail="The #event.geteventName()# variable does not exist in the arguments.",
					type="ColdBoxProxy.NoEventDetected" 
				);
			}

			//Append the arguments to the collection
			event.collectionAppend( arguments, true );
			//Set that this is a proxy request.
			event.setProxyRequest();

			//Execute a pre process interception.
			cbController.getInterceptorService().processState( "preProcess" );

			//Request Start Handler if defined
			if ( cbController.getSetting( "RequestStartHandler" ) neq "" ){
				cbController.runEvent(cbController.getSetting( "RequestStartHandler" ),true);
			}

			//Execute the Event if not demarcated to not execute
			if( NOT event.isNoExecution() ){
				refLocal.results = cbController.runEvent( default=true );
			}

			//Request END Handler if defined
			if ( cbController.getSetting( "RequestEndHandler" ) neq "" ){
				cbController.runEvent( cbController.getSetting( "RequestEndHandler" ), true );
			}

			//Execute the post process interceptor
			cbController.getInterceptorService().processState(" postProcess" );
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
				refLocal.results = cbController.getDataMarshaller().marshallData( argumentCollection=refLocal.marshalData );

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

				// Return The results
				return refLocal.results;
			}
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
		<cfreturn true>
	</cffunction>

	<!--- handleException --->
	<cffunction name="handleException" output="false" access="private" returntype="void" hint="Handle a ColdBox Proxy Exception">
		<cfargument name="exceptionObject" type="any" required="true" hint="The exception object"/>
		<cfscript>
			var cbController = "";
			var interceptData = { exception = arguments.exceptionObject };
			// Locate ColdBox Controller
			cbController = getController();
			// Intercept Exception
			cbController.getInterceptorService().processState( "onException", interceptData );
			// Log Exception
			cbController.getLogBox()
				.getLogger( this )
				.error( "ColdBox Proxy Exception: #arguments.exceptionObject.message# #arguments.exceptionObject.detail#", arguments.exceptionObject );
		</cfscript>
	</cffunction>

	<!--- verifyColdBox --->
	<cffunction name="verifyColdBox" output="false" access="private" returntype="boolean" hint="Verify the coldbox app">
		<cfargument name="throwOnNotExist" default="true">
		<cfscript>
			
			//Verify the coldbox app is ok, else throw
			if ( not structKeyExists(application,COLDBOX_APP_KEY) ){
				if( arguments.throwOnNotExist ) {
					throw( message="ColdBox Controller Not Found", 
						   detail="The coldbox main controller has not been initialized",
						   type="ColdBoxProxy.ControllerIllegalState");
				} else {
					return false;
				}
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
	<cffunction name="getPlugin" access="private" returntype="any" hint="DEPRECATED: Plugin factory, returns a new or cached instance of a plugin." output="false">
		<cfthrow message="This method has been deprecated, please use getInstance() instead">
	</cffunction>

	<!--- Facade: Get a "my" plugin --->
	<cffunction name="getMyPlugin" access="private" returntype="any" hint="DEPRECATED: Plugin factory, returns a new or cached instance of a plugin." output="false">
		<cfthrow message="This method has been deprecated, please use getInstance() instead">
	</cffunction>

	<!--- Interceptor Facade --->
	<cffunction name="getInterceptor" access="private" output="false" returntype="any" hint="Get an interceptor">
		<!--- ************************************************************* --->
		<cfargument name="interceptorName" 	required="false" type="string" hint="The name of the interceptor to search for"/>
		<cfargument name="deepSearch" 		required="false" type="boolean" default="false" hint="By default we search the cache for the interceptor reference. If true, we search all the registered interceptor states for a match."/>
		<!--- ************************************************************* --->
		<cfreturn getController().getInterceptorService().getInterceptor(argumentCollection=arguments)>
	</cffunction>

	<!--- Get Model --->
	<cffunction name="getModel" access="private" returntype="any" hint="Create or retrieve model objects by convention" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 			required="false" 	hint="The mapping name or CFC instance path to try to build up"/>
		<cfargument name="dsl"				required="false" 	hint="The dsl string to use to retrieve the instance model object, mutually exclusive with 'name'"/>
		<cfargument name="initArguments" 	required="false" 	default="#structnew()#" hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<!--- ************************************************************* --->
		<cfreturn getWireBox().getInstance(argumentCollection=arguments)>
	</cffunction>

	<!--- Get a CacheBox Cache --->
	<cffunction name="getCache" access="private" output="false" returntype="any" hint="Get a CacheBox Cache Provider" colddoc:generic="coldbox.system.cache.IColdboxApplicationCache">
		<cfargument name="cacheName" type="string" required="false" default="default" hint="The cache name to retrieve"/>
		<cfreturn getController().getCache( arguments.cacheName )/>
	</cffunction>

	<!--- Bootstrapper LoadColdBox --->
	<cffunction name="loadColdbox" access="private" output="false" returntype="void" hint="Load a coldbox application, and place the coldbox controller in application scope for usage. If the application is already running, then it will not re-do it, unless you specify the reload argument or the application expired.">
		<!--- ************************************************************* --->
		<cfargument name="appMapping" 		type="string"  required="true" hint="The absolute location of the root of the coldbox application. This is usually where the Application.cfc is and where the conventions are read from."/>
		<cfargument name="configLocation" 	type="string"  required="false" default="" 		hint="The absolute location of the config file to override, if not passed, it will try to locate it by convention."/>
		<cfargument name="reloadApp" 		type="boolean" required="false" default="false" hint="Flag to reload the application or not"/>
		<cfargument name="appKey" 			type="string" 	required="true" default="#COLDBOX_APP_KEY#" hint="The application key name to use, defaults to 'cbController'"/>
		<!--- ************************************************************* --->
		<cfset var cbController = "">
		<cfset var appHash = hash( getBaseTemplatePath() )>

		<!--- Reload Checks --->
		<cfif not structKeyExists( application, arguments.appKey ) or not application[ arguments.appKey ].getColdboxInitiated() or arguments.reloadApp>
			<cflock type="exclusive" name="#appHash#" timeout="30" throwontimeout="true">
				<cfscript>
				if ( not structkeyExists( application, arguments.appKey ) OR NOT
					 application[ arguments.appKey ].getColdboxInitiated() OR
					 arguments.reloadApp ){
					// Cleanup, Just in Case
					structDelete( application, arguments.appKey );
					// Load it Up baby!!
					cbController = CreateObject( "component", "coldbox.system.web.Controller" ).init( expandPath(arguments.appMapping), arguments.appKey );
					// Put in Scope
					application[ arguments.appKey ] = cbController;
					// Setup Calls
					cbController.getLoaderService().loadApplication( arguments.configLocation, arguments.appMapping );
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