<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/10/2007
Description :
	This is the main ColdBox handler service.
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.web.services.BaseService" hint="This is the main Coldbox Handler service" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="HandlerService" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			// Setup The Controller.
			variables.controller = arguments.controller;

			// Setup the Event Handler Cache Dictionary
			instance.handlerCacheDictionary = {};
			// Setup the Event Cache Dictionary
			instance.eventCacheDictionary = {};
			// Handler base class
			instance.HANDLER_BASE_CLASS = "coldbox.system.EventHandler";

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERNAL COLDBOX EVENTS ------------------------------------------->

	<!--- onConfigurationLoad --->
    <cffunction name="onConfigurationLoad" output="false" access="public" returntype="void" hint="Called by loader service when configuration file loads">
    	<cfscript>
			// local logger
			instance.log = getController().getLogBox().getLogger(this);

    		// execute the handler registrations after configurations loaded
			registerHandlers();

			// Configuration data and dependencies
			instance.registeredHandlers			= controller.getSetting("RegisteredHandlers");
			instance.registeredExternalHandlers = controller.getSetting("RegisteredExternalHandlers");
			instance.eventAction				= controller.getSetting("EventAction",1);
			instance.eventName					= controller.getSetting("EventName");
			instance.onInvalidEvent				= controller.getSetting("onInvalidEvent");
			instance.handlerCaching				= controller.getSetting("HandlerCaching");
			instance.eventCaching				= controller.getSetting("EventCaching");
			instance.handlersInvocationPath		= controller.getSetting("HandlersInvocationPath");
			instance.handlersExternalLocation	= controller.getSetting("HandlersExternalLocation");
			instance.templateCache				= controller.getCache( "template" );
			instance.modules					= controller.getSetting("modules");
			instance.interceptorService			= controller.getInterceptorService();
    	</cfscript>
    </cffunction>


<!------------------------------------------- EVENTS ------------------------------------------>

	<!--- afterInstanceAutowire --->
    <cffunction name="afterInstanceAutowire" output="false" access="public" returntype="void" hint="Called by wirebox once instances are autowired">
		<cfargument name="event" />
		<cfargument name="interceptData" />
    	<cfscript>
			var attribs = interceptData.mapping.getExtraAttributes();
			var iData 	= {};

			// listen to handlers only
			if( structKeyExists(attribs, "isHandler") ){
				// Fill-up Intercepted metadata
				iData.handlerPath 	= attribs.handlerPath;
				iData.oHandler 		= interceptData.target;

				// Fire Interception
				instance.interceptorService.processState("afterHandlerCreation",iData);
			}
		</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get a new handler Instance --->
	<cffunction name="newHandler" access="public" returntype="any" hint="Create a New Handler Instance" output="false" >
		<cfargument name="invocationPath" type="any" required="true" hint="The handler invocation path"/>
		<cfscript>
			var oHandler 	= "";
			var binder		= "";
			var attribs		= "";
			var wirebox		= controller.getWireBox();
			var mapping		= "";

			// Check if handler mapped?
			if( NOT wirebox.getBinder().mappingExists( invocationPath ) ){
				// lazy load checks for wirebox
				wireboxSetup();
				// extra attributes
				attribs = {
					handlerPath = invocationPath,
					isHandler	= true
				};
				// feed this handler to wirebox with virtual inheritance just in case, use registerNewInstance so its thread safe
				mapping = wirebox.registerNewInstance( name=invocationPath, instancePath=invocationPath )
					.setVirtualInheritance( "coldbox.system.EventHandler" )
					.addDIConstructorArgument( name="controller", value=controller )
					.setThreadSafe( true )
					.setScope( wirebox.getBinder().SCOPES.SINGLETON )
					.setCacheProperties( key="handlers-#invocationPath#" )
					.setExtraAttributes( attribs );
				// Are we caching or not handlers?
				if ( NOT instance.handlerCaching ){
					mapping.setScope( wirebox.getBinder().SCOPES.NOSCOPE );
				}
			}
			// retrieve, build and wire from wirebox
			oHandler = wirebox.getInstance( invocationPath );

			//return handler
			return oHandler;
		</cfscript>
	</cffunction>

	<!--- Get a validated handler instance, using a handlerBean --->
	<cffunction name="getHandler" output="false" access="public" returntype="any" hint="Returns a valid event handler object ready for execution">
		<!--- ************************************************************* --->
		<cfargument name="ehBean" 			type="any" required="true" hint="The event handler bean to use: coldbox.system.web.context.EventHandlerBean"/>
		<cfargument name="requestContext"   type="any" required="true" hint="The request context"/>
		<!--- ************************************************************* --->
		<cfscript>
			var oEventHandler = "";
			var oRequestContext = arguments.requestContext;
			var eventCachingData = structnew();
			var oEventURLFacade = instance.templateCache.getEventURLFacade();
			var eventDictionaryEntry = "";

			// Create Runnable Object
			oEventHandler = newHandler( arguments.ehBean.getRunnable() );

			/* ::::::::::::::::::::::::::::::::::::::::: EVENT METHOD TESTING :::::::::::::::::::::::::::::::::::::::::::: */

			// Does requested method/action of execution exist in handler?
			if ( NOT oEventHandler._actionExists(arguments.ehBean.getMethod()) ){

				// Check if the handler has an onMissingAction() method, virtual Events
				if( oEventHandler._actionExists("onMissingAction") ){
					// Override the method of execution
					arguments.ehBean.setMissingAction( arguments.ehBean.getMethod() );
					// Let's go execute our missing action
					return oEventHandler;
				}

				// Test for Implicit View Dispatch
				if( controller.getSetting(name="ImplicitViews") AND isViewDispatch(arguments.ehBean.getFullEvent(),arguments.ehBean) ){
					return oEventHandler;
				}

				// Invalid Event procedures
				invalidEvent(arguments.ehBean.getFullEvent(), arguments.ehBean);

				// If we get here, then the invalid event kicked in and exists, else an exception is thrown
				// Go retrieve the handler that will handle the invalid event so it can execute.
				return getHandler( getRegisteredHandler(arguments.ehBean.getFullEvent()), oRequestContext);
				//return getHandler(arguments.ehBean,oRequestContext);

			}//method check finalized.

			/* ::::::::::::::::::::::::::::::::::::::::: EVENT CACHING :::::::::::::::::::::::::::::::::::::::::::: */

			// Event Caching Routines, if using caching and we are executing the main event
			if ( instance.eventCaching and ehBean.getFullEvent() eq oRequestContext.getCurrentEvent() ){

				// Save Event Caching metadata
				saveEventCachingMetadata(eventUDF=oEventHandler[ehBean.getMethod()],
										 cacheKey=ehBean.getFullEvent(),
										 cacheKeySuffix=oEventHandler.EVENT_CACHE_SUFFIX);

				// get dictionary entry for operations, it is now guaranteed
				eventDictionaryEntry = instance.eventCacheDictionary[ ehBean.getFullEvent() ];

				// Do we need to cache this event's output after it executes??
				if ( eventDictionaryEntry.cacheable ){
					// Create caching data structure according to MD.
					structAppend(eventCachingData,eventDictionaryEntry,true);

					// Create the Cache Key to save
					eventCachingData.cacheKey = oEventURLFacade.buildEventKey(keySuffix=eventCachingData.suffix,
																		      targetEvent=ehBean.getFullEvent(),
																		      targetContext=oRequestContext);


					// Event is cacheable and we need to flag it so the Renderer caches it
					oRequestContext.setEventCacheableEntry( eventCachingData );

				}//end if md says that this event is cacheable

			}//end if event caching.

			//return the tested and validated event handler
			return oEventHandler;
		</cfscript>
	</cffunction>

	<!--- Default Event Check --->
	<cffunction name="defaultEventCheck" access="public" returntype="void" hint="Do a default Event check on the incoming event" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event"   type="any"  required="true"  hint="The created event context to test for the default event" >
		<!--- ************************************************************* --->
		<cfscript>
			var handlersList 			= instance.registeredHandlers;
			var handlersExternalList 	= instance.registeredExternalHandlers;
			var currentEvent 			= arguments.event.getCurrentEvent();
			var module 					= "";
			var modulesConfig 			= instance.modules;

			// Module Check?
			if( find(":",currentEvent) ){
				module = listFirst(currentEvent,":");
				if( structKeyExists(modulesConfig,module) AND listFindNoCase(modulesConfig[module].registeredHandlers,reReplaceNoCase(currentEvent,"^([^:.]*):","")) ){
					// Append the default event action
					currentEvent = currentEvent & "." & instance.eventAction;
					// Save it as the current Event
					event.setValue(instance.eventName,currentEvent);
				}
				return;
			}

			// Do a Default Action Test First, if default action desired.
			if( listFindNoCase(handlersList, currentEvent) OR listFindNoCase(handlersExternalList, currentEvent) ){
				// Append the default event action
				currentEvent = currentEvent & "." & instance.eventAction;
				// Save it as the current Event
				event.setValue(instance.eventName,currentEvent);
			}
		</cfscript>
	</cffunction>

	<!--- Get a Registered Handler Bean --->
	<cffunction name="getRegisteredHandler" access="public" hint="I parse the incoming event string into an event handler bean that is used for executions." returntype="coldbox.system.web.context.EventHandlerBean"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event"   type="any"  required="true"  hint="The full event string to check and get." >
		<!--- ************************************************************* --->
		<cfscript>
		var handlerIndex 			= 0;
		var handlerReceived 		= "";
		var methodReceived 			= "";
		var handlersList 			= instance.registeredHandlers;
		var handlersExternalList 	= instance.registeredExternalHandlers;
		var handlerBean 			= CreateObject("component","coldbox.system.web.context.EventHandlerBean").init(instance.handlersInvocationPath);
		var moduleReceived			= "";
		var moduleSettings 			= instance.modules;


		// Rip the handler and method
		handlerReceived = listLast(reReplace(arguments.event,"\.[^.]*$",""),":");
		methodReceived 	= listLast(arguments.event,".");

		// Verify if this is a module call
		if( find(":", arguments.event) ){
			moduleReceived = listFirst(arguments.event,":");
			// Does this module exist?
			if( structKeyExists(moduleSettings,moduleReceived) ){
				// Verify handler in module handlers
				handlerIndex = listFindNoCase(moduleSettings[moduleReceived].registeredHandlers,handlerReceived);
				if( handlerIndex ){
					return handlerBean
						.setInvocationPath(moduleSettings[moduleReceived].handlerInvocationPath)
						.setHandler(listgetAt(moduleSettings[moduleReceived].registeredHandlers,handlerIndex))
						.setMethod(methodReceived)
						.setModule(moduleReceived);
				}
			}
			// log it as application log
			instance.log.error( "Invalid Module Event Called: #arguments.event#. The module: #moduleReceived# is not valid. Valid Modules are: #structKeyList(moduleSettings)#" );
		}
		else{
			// Try to do list localization in the registry for full event string.
			handlerIndex = listFindNoCase(handlersList, HandlerReceived);
			// Check for conventions location
			if ( handlerIndex ){
				return HandlerBean
					.setHandler(listgetAt(handlersList,handlerIndex))
					.setMethod(MethodReceived);
			}

			// Check for external location
			handlerIndex = listFindNoCase(handlersExternalList, HandlerReceived);
			if( handlerIndex ){
				return HandlerBean
					.setInvocationPath(instance.handlersExternalLocation)
					.setHandler(listgetAt(handlersExternalList,handlerIndex))
					.setMethod(MethodReceived);
			}
		} //end else

		// Do View Dispatch Check Procedures
		if( isViewDispatch(arguments.event,handlerBean) ){
			return handlerBean;
		}

		// Run invalid event procedures, handler not found
		invalidEvent(arguments.event,handlerBean);

		// If we get here, then invalid event handler is active and we need to
		// return an event handler bean that matches it
		return getRegisteredHandler( handlerBean.getFullEvent() );
		</cfscript>
	</cffunction>

	<!--- isViewDispatch --->
    <cffunction name="isViewDispatch" output="false" access="public" returntype="any" hint="Check if the incoming event has a matching implicit view dispatch available">
    	<cfargument name="event"  type="any"	required="true" hint="The event string"/>
		<cfargument name="ehBean" type="any" 	required="true" hint="The event handler bean"/>
		<cfscript>
    		// Cleanup for modules
			var cEvent     		= reReplaceNoCase(arguments.event,"^([^:.]*):","");
			var renderer 		= controller.getRenderer();
			var targetView		= "";
			var targetModule	= getToken(arguments.event,1,":");

			// Cleanup of . to / for lookups
			cEvent = lcase(replace(cEvent,".","/","all"));

			// module?
			if( find(":", arguments.event) and structKeyExists(instance.modules, targetModule ) ){
				targetView = renderer.locateModuleView(cEvent,targetModule);
			}
			else{
				targetView = renderer.locateView(cEvent);
			}

			// Validate Target View
			if( fileExists( expandPath(targetView & ".cfm") ) ){
				arguments.ehBean.setViewDispatch(true);
				return true;
			}

			return false;
		</cfscript>
    </cffunction>

	<!--- invalidEvent --->
	<cffunction name="invalidEvent" output="false" access="private" returntype="void" hint="Invalid Event procedures. Throws EventHandlerNotRegisteredException">
		<cfargument name="event"  type="string" required="true" hint="The event that was found invalid"/>
		<cfargument name="ehBean" type="any" 	required="true" hint="The event handler bean" colddoc:generic="coldbox.system.web.context.EventHandlerBean"/>
		<cfscript>
			var iData			= structnew();

			// Announce invalid event with invalid event, ehBean and override flag.
			iData.invalidEvent 	= arguments.event;
			iData.ehBean 		= arguments.ehBean;
			iData.override 		= false;
			instance.interceptorService.processState( "onInvalidEvent", iData );

			//If the override was changed by the interceptors then they updated the ehBean of execution
			if( iData.override ){
				return;
			}

			// If onInvalidEvent is registered, use it
			if ( len(trim(instance.onInvalidEvent)) ){

				// Test for invalid Event Error
				if ( compareNoCase( instance.onInvalidEvent, arguments.event ) eq 0 ){
					throw( message="The onInvalid event is also invalid",
						   detail="The onInvalidEvent setting is also invalid: #instance.onInvalidEvent#. Please check your settings",
						   type="HandlerService.onInValidEventSettingException");
				}

				// Store Invalid Event in PRC
				controller.getRequestService().getContext().setValue("invalidevent",arguments.event,true);

				// Override Event With On Invalid Event
				arguments.ehBean.setHandler(reReplace(instance.onInvalidEvent,"\.[^.]*$",""))
					.setMethod(listLast(instance.onInvalidEvent,"."))
					.setModule('');
				// If module found in invalid event, set it for discovery
				if( find(":",instance.onInvalidEvent) ){ arguments.ehBean.setModule( getToken(instance.onInvalidEvent,1) ); }

				return;
			}

			// Invalid Event Detected, log it in the Application log, not a coldbox log but an app log
			instance.log.error( "Invalid Event detected: #arguments.event#. Path info: #cgi.path_info#, query string: #cgi.query_string#" );

			// Throw Exception
			throw( message="The event: #arguments.event# is not valid registered event.", type="HandlerService.EventHandlerNotRegisteredException" );
		</cfscript>
	</cffunction>

	<!--- Handler Registration System --->
	<cffunction name="registerHandlers" access="public" returntype="void" hint="I register your application's event handlers" output="false">
		<cfscript>
		var handlersPath = controller.getSetting( "handlersPath" );
		var handlersExternalLocationPath = controller.getSetting( "handlersExternalLocationPath" );
		var handlerArray = [];
		var handlersExternalArray = [];

		/* ::::::::::::::::::::::::::::::::::::::::: HANDLERS BY CONVENTION :::::::::::::::::::::::::::::::::::::::::::: */

		// Get recursive Array listing
		handlerArray = getHandlerListing( handlersPath );

		// Set registered Handlers
		controller.setSetting( name="registeredHandlers", value=arrayToList( handlerArray ) );

		/* ::::::::::::::::::::::::::::::::::::::::: EXTERNAL HANDLERS :::::::::::::::::::::::::::::::::::::::::::: */

		if( len( handlersExternalLocationPath ) ){

			// Check for handlers Directory Location
			if ( !directoryExists( handlersExternalLocationPath ) ){
				throw(
					message = "The external handlers directory: #HandlersExternalLocationPath# does not exist please check your application structure.",
					type 	= "HandlerService.HandlersDirectoryNotFoundException"
				);
			}

			// Get recursive Array listing
			handlersExternalArray = getHandlerListing( handlersExternalLocationPath );
		}

		// Set registered External Handlers
		controller.setSetting( name="registeredExternalHandlers", value=arrayToList( handlersExternalArray ) );
		</cfscript>
	</cffunction>

	<!--- Clear All Dictioanries --->
	<cffunction name="clearDictionaries" access="public" returntype="void" hint="Clear the internal cache dictionaries" output="false" >
		<cfscript>
			instance.eventCacheDictionary = {};
		</cfscript>
	</cffunction>

<!------------------------------------------- ACCESSOR/MUTATORS ------------------------------------------->

	<!--- Event Cache Dictionary --->
	<cffunction name="getEventCacheDictionary" access="public" returntype="struct" output="false">
		<cfreturn instance.eventCacheDictionary>
	</cffunction>

	<cffunction name="getEventMetadataEntry" access="public" returntype="any" hint="Get an event string's metadata entry: struct" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="targetEvent" required="true" type="any" hint="The target event">
		<!--- ************************************************************* --->
		<cfscript>
			if( NOT structKeyExists(instance.eventCacheDictionary, arguments.targetEvent) ){
				return getNewMDEntry();
			}

			return instance.eventCacheDictionary[ arguments.targetEvent ];
		</cfscript>
	</cffunction>

	<!--- Recursive Registration of Handler Directories --->
	<cffunction name="getHandlerListing" access="public" output="false" returntype="array" hint="Get an array of registered handlers">
		<!--- ************************************************************* --->
		<cfargument name="directory" 	type="string" required="true">
		<!--- ************************************************************* --->
		<cfset var files = "">
		<cfset var i = 1>
		<cfset var thisAbsolutePath = "">
		<cfset var cleanHandler = "">
		<cfset var fileArray = arrayNew(1)>

		<!--- List Handlers --->
		<cfdirectory action="list" recurse="true" name="files" directory="#arguments.directory#" filter="*.cfc"/>

		<cfscript>
			// Convert windows \ to java /
			arguments.directory = replace(arguments.directory,"\","/","all");

			// Iterate, clean and register
			for (i=1; i lte files.recordcount; i=i+1 ){

				thisAbsolutePath = replace(files.directory[i],"\","/","all") & "/";
				cleanHandler = replacenocase(thisAbsolutePath,arguments.directory,"","all") & files.name[i];

				// Clean OS separators to dot notation.
				cleanHandler = removeChars(replacenocase(cleanHandler,"/",".","all"),1,1);

				//Clean Extension
				cleanHandler = controller.getUtil().ripExtension(cleanhandler);

				//Add data to array
				ArrayAppend(fileArray,cleanHandler);
			}

			return fileArray;
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- wireboxSetup --->
    <cffunction name="wireboxSetup" output="false" access="private" returntype="any" hint="Verifies the setup for handler classes is online">
    	<cfscript>
			var wirebox = controller.getWireBox();
			// Check if handler mapped?
			if( NOT wirebox.getBinder().mappingExists( instance.HANDLER_BASE_CLASS ) ){
				// feed the base class
				wirebox.registerNewInstance( name=instance.HANDLER_BASE_CLASS, instancePath=instance.HANDLER_BASE_CLASS )
					.addDIConstructorArgument( name="controller", value=controller );
				// register ourselves to listen for autowirings
				instance.interceptorService.registerInterceptionPoint( "HandlerService", "afterInstanceAutowire", this );
			}
    	</cfscript>
    </cffunction>

	<!--- Get a new MD cache entry structure --->
	<cffunction name="getNewMDEntry" access="public" returntype="any" hint="Get a new metadata entry structure" output="false" >
		<cfscript>
			var mdEntry = structNew();

			mdEntry.cacheable 		  = false;
			mdEntry.timeout 		  = "";
			mdEntry.lastAccessTimeout = "";
			mdEntry.cacheKey  		  = "";
			mdEntry.suffix 			  = "";

			return mdEntry;
		</cfscript>
	</cffunction>

	<!--- Save Event Caching metadata --->
	<cffunction name="saveEventCachingmetadata" access="private" returntype="void" hint="Save a handler's event caching metadata in the dictionary" output="false">
		<!--- ************************************************************* --->
		<cfargument name="eventUDF" 		type="any" required="true" hint="The handler event UDF to inspect" />
		<cfargument name="cacheKey"     	type="any" required="true" hint="The event cache key" />
		<cfargument name="cacheKeySuffix"   type="any" required="true" hint="The event cache key suffix" />
		<!--- ************************************************************* --->
		<cfset var metadata = 0>
		<cfset var mdEntry  = 0>

		<cfif NOT structKeyExists( instance.eventCacheDictionary, arguments.cacheKey)>
			<cflock name="handlerservice.#getController().getAppHash()#.eventcachingmd.#arguments.cacheKey#" type="exclusive" throwontimeout="true" timeout="10">
			<cfscript>
			// Determine if we have md for the event to execute in the md dictionary, else set it
			if ( NOT structKeyExists( instance.eventCacheDictionary, arguments.cacheKey) ){
				// Get Method metadata
				metadata = getmetadata(arguments.eventUDF);
				// Get New Default MD Entry
				mdEntry = getNewMDEntry();

				// By Default, events with no cache flag are set to FALSE
				if ( not structKeyExists(metadata,"cache") or not isBoolean(metadata["cache"]) ){
					metadata.cache = false;
				}

				// Cache Entries for timeout and last access timeout
				if ( metadata.cache ){
					mdEntry.cacheable = true;
					// Event Timeout
					if ( structKeyExists(metadata,"cachetimeout") and metadata.cachetimeout neq 0 ){
						mdEntry.timeout = metadata["cachetimeout"];
					}
					// Last Access Timeout
					if ( structKeyExists(metadata, "cacheLastAccessTimeout") ){
						mdEntry.lastAccessTimeout = metadata["cacheLastAccessTimeout"];
					}
				} //end cache metadata is true

				// Handler Event Cache Key Suffix
				mdEntry.suffix = arguments.cacheKeySuffix;

				// Save md Entry in dictionary
				instance.eventCacheDictionary[ cacheKey ] = mdEntry;
			}//end of md cache dictionary.
			</cfscript>
			</cflock>
		</cfif>
	</cffunction>

</cfcomponent>