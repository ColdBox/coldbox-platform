<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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
			setController(arguments.controller);
			// Setup the Event Handler Cache Dictionary
			setHandlerCacheDictionary(CreateObject("component","coldbox.system.core.collections.BaseDictionary").init('Handlersmetadata'));
			// Setup the Event Cache Dictionary
			setEventCacheDictionary(CreateObject("component","coldbox.system.core.collections.BaseDictionary").init('EventCache'));

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERNAL COLDBOX EVENTS ------------------------------------------->

	<!--- onConfigurationLoad --->
    <cffunction name="onConfigurationLoad" output="false" access="public" returntype="void" hint="Called by loader service when configuration file loads">
    	<cfscript>
			instance.logger = getController().getLogBox().getLogger(this);
    		// execute the handler registrations after configurations loaded
			registerHandlers();
    	</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get a new handler Instance --->
	<cffunction name="newHandler" access="public" returntype="any" hint="Create a New Handler Instance" output="false" >
		<cfargument name="invocationPath" type="string" required="true" hint="The handler invocation path"/>
		<cfscript>
			//Create Handler
			var oHandler 	= CreateObject("component", invocationPath );
			var iData 		= structnew();

			// Check family if it is handler inheritance or simple CFC?
			if( NOT isFamilyType("handler",oHandler) ){
				convertToColdBox( "handler", oHandler );
				// Init super
				oHandler.$super.init( controller );
				// Check if doing cbInit()
				if( structKeyExists(oHandler, "$cbInit") ){ oHandler.$cbInit( controller ); }
			}

			// init the handler for usage
			oHandler.init( controller );

			// Fill-up Intercepted metadata
			iData.handlerPath 	= invocationPath;
			iData.oHandler 		= oHandler;

			// Fire Interception
			controller.getInterceptorService().processState("afterHandlerCreation",iData);

			//return handler
			return oHandler;
		</cfscript>
	</cffunction>

	<!--- Get a validated handler instance, using a handlerBean --->
	<cffunction name="getHandler" output="false" access="public" returntype="any" hint="Returns a valid event handler object ready for execution">
		<!--- ************************************************************* --->
		<cfargument name="ehBean" 			type="any" required="true" hint="The event handler bean to use: coldbox.system.beans.EventHandlerBean"/>
		<cfargument name="RequestContext"   type="any" required="true" hint="The request context"/>
		<!--- ************************************************************* --->
		<cfscript>
			var oEventHandler = "";
			var oRequestContext = arguments.RequestContext;
			var cacheKey = getColdboxOCM().HANDLER_CACHEKEY_PREFIX & arguments.ehBean.getRunnable();
			var eventCacheKey = "";
			var eventCachingData = structnew();
			var oEventURLFacade = getController().getColdboxOCM("template").getEventURLFacade();
			var handlerDictionaryEntry = "";
			var eventDictionaryEntry = "";
			var onInvalidEvent = controller.getSetting("onInvalidEvent");
			var refLocal = structnew();

			/* ::::::::::::::::::::::::::::::::::::::::: HANDLERS CACHING :::::::::::::::::::::::::::::::::::::::::::: */
			// Are we caching handlers?
			if ( controller.getSetting("HandlerCaching") ){
				// Lookup handler in Cache
				refLocal.oEventHandler = getColdboxOCM().get(cacheKey);

				// Verify if not found, then create it and cache it
				if( NOT structKeyExists(refLocal, "oEventHandler") OR NOT isObject(refLocal.oEventHandler) ){
					// Create a new handler
					oEventHandler = newHandler(arguments.ehBean.getRunnable());
					// Save its metadata For event Caching and Aspects
					saveHandlermetadata(oEventHandler,cacheKey);
					// Get dictionary entry for operations, it is now guaranteed
					handlerDictionaryEntry = getHandlerCacheDictionary().getKey(cacheKey);
					// Do we Cache this handler
					if ( handlerDictionaryEntry.cacheable ){
						getColdboxOCM().set(cacheKey,oEventHandler,handlerDictionaryEntry.timeout,handlerDictionaryEntry.lastAccessTimeout);
					}
				}//end of caching strategy
				else{
					oEventHandler = refLocal.oEventHandler;
				}
			}
			else{
				// Create Runnable Object
				oEventHandler = newHandler(arguments.ehBean.getRunnable());
				// Save its metadata For event Caching and Aspects to work
				saveHandlermetadata(oEventHandler,cacheKey,true);
			}

			/* ::::::::::::::::::::::::::::::::::::::::: EVENT METHOD TESTING :::::::::::::::::::::::::::::::::::::::::::: */

			// Does requested method/action of execution exist in handler?
			if ( NOT oEventHandler._actionExists(arguments.ehBean.getMethod()) ){

				// Check if the handler has an onMissingAction() method, virtual Events
				if( oEventHandler._actionExists("onMissingAction") ){
					// Override the method of execution
					arguments.ehBean.setMissingAction(arguments.ehBean.getMethod());
					// Let's go execute our missing action
					return oEventHandler;
				}
				
				// Test for Implicit View Dispatch
				if( isViewDispatch(arguments.ehBean.getFullEvent(),arguments.ehBean) ){
					return oEventHandler;
				}

				// Invalid Event procedures
				invalidEvent(arguments.ehBean.getFullEvent(), arguments.ehBean);

				// If we get here, then the invalid event kicked in and exists, else an exception is thrown
				return getHandler(arguments.ehBean,oRequestContext);

			}//method check finalized.

			/* ::::::::::::::::::::::::::::::::::::::::: EVENT CACHING :::::::::::::::::::::::::::::::::::::::::::: */

			// Event Caching Routines, if using caching and we are executing the main event
			if ( controller.getSetting("EventCaching") and ehBean.getFullEvent() eq oRequestContext.getCurrentEvent() ){

				// Save Event Caching metadata
				saveEventCachingMetadata(eventUDF=oEventHandler[ehBean.getMethod()],
										 cacheKey=ehBean.getFullEvent(),
										 cacheKeySuffix=oEventHandler.EVENT_CACHE_SUFFIX);

				// get dictionary entry for operations, it is now guaranteed
				eventDictionaryEntry = getEventCacheDictionary().getKey(ehBean.getFullEvent());

				// Do we need to cache this event's output after it executes??
				if ( eventDictionaryEntry.cacheable ){
					// Create caching data structure according to MD.
					structAppend(eventCachingData,eventDictionaryEntry,true);

					// Create the Cache Key to save
					eventCachingData.cacheKey = oEventURLFacade.buildEventKey(keySuffix=eventCachingData.suffix,
																		      targetEvent=ehBean.getFullEvent(),
																		      targetContext=oRequestContext);


					// Event is cacheable and we need to flag it so the Renderer caches it
					oRequestContext.setEventCacheableEntry(eventCachingData);

				}//end if md says that this event is cacheable

			}//end if event caching.

			//return the tested and validated event handler
			return oEventHandler;
		</cfscript>
	</cffunction>

	<!--- Default Event Check --->
	<cffunction name="defaultEventCheck" access="public" returntype="void" hint="Do a default Event check on the incoming event" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event"   type="any"  required="true"  hint="The created event context to test." >
		<!--- ************************************************************* --->
		<cfscript>
			var handlersList 			= controller.getSetting("RegisteredHandlers");
			var handlersExternalList 	= controller.getSetting("RegisteredExternalHandlers");
			var currentEvent 			= arguments.event.getCurrentEvent();
			var module 					= "";
			var modulesConfig 			= controller.getSetting("modules");

			// Module Check?
			if( find(":",currentEvent) ){
				module = listFirst(currentEvent,":");
				if( structKeyExists(modulesConfig,module) AND listFindNoCase(modulesConfig[module].registeredHandlers,reReplaceNoCase(currentEvent,"^([^:.]*):","")) ){
					// Append the default event action
					currentEvent = currentEvent & "." & controller.getSetting('EventAction',1);
					// Save it as the current Event
					event.setValue(controller.getSetting("EventName"),currentEvent);
				}
				return;
			}

			// Do a Default Action Test First, if default action desired.
			if( listFindNoCase(handlersList, currentEvent) OR listFindNoCase(handlersExternalList, currentEvent) ){
				// Append the default event action
				currentEvent = currentEvent & "." & controller.getSetting('EventAction',1);
				// Save it as the current Event
				event.setValue(controller.getSetting("EventName"),currentEvent);
			}
		</cfscript>
	</cffunction>

	<!--- Get a Registered Handler Bean --->
	<cffunction name="getRegisteredHandler" access="public" hint="I parse the incoming event string into an event handler bean that is used for executions." returntype="coldbox.system.beans.EventHandlerBean"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event"   type="any"  required="true"  hint="The full event string to check and get." >
		<!--- ************************************************************* --->
		<cfscript>
		var handlerIndex 			= 0;
		var handlerReceived 		= "";
		var methodReceived 			= "";
		var handlersList 			= controller.getSetting("RegisteredHandlers");
		var handlersExternalList 	= controller.getSetting("RegisteredExternalHandlers");
		var HandlerBean 			= CreateObject("component","coldbox.system.beans.EventHandlerBean").init(controller.getSetting("HandlersInvocationPath"));
		var moduleReceived			= "";
		var moduleSettings 			= controller.getSetting("modules");


		// Rip the handler and method
		handlerReceived = listLast(reReplace(arguments.event,"\.[^.]*$",""),":");
		methodReceived = listLast(arguments.event,".");

		// Verify if this is a module call
		if( find(":", arguments.event) ){
			moduleReceived = listFirst(arguments.event,":");
			// Does this module exist?
			if( structKeyExists(moduleSettings,moduleReceived) ){
				// Verify handler in module handlers
				handlerIndex = listFindNoCase(moduleSettings[moduleReceived].registeredHandlers,handlerReceived);
				if( handlerIndex ){
					HandlerBean.setInvocationPath(moduleSettings[moduleReceived].handlerInvocationPath);
					handlerBean.setHandler(listgetAt(moduleSettings[moduleReceived].registeredHandlers,handlerIndex));
					handlerBean.setMethod(methodReceived);
					handlerBean.setModule(moduleReceived);
					return handlerBean;
				}
			}
			// log it.
			controller.getPlugin("Logger").error("Invalid Module Event Called: #arguments.event#. The module: #moduleReceived# is not valid. Valid Modules are: #structKeyList(moduleSettings)#");
		}
		else{
			// Try to do list localization in the registry for full event string.
			handlerIndex = listFindNoCase(handlersList, HandlerReceived);
			// Check for conventions location
			if ( handlerIndex ){
				HandlerBean.setHandler(listgetAt(handlersList,handlerIndex));
				HandlerBean.setMethod(MethodReceived);
				return HandlerBean;
			}

			// Check for external location
			handlerIndex = listFindNoCase(handlersExternalList, HandlerReceived);
			if( handlerIndex ){
				HandlerBean.setInvocationPath(controller.getSetting("HandlersExternalLocation"));
				HandlerBean.setHandler(listgetAt(handlersExternalList,handlerIndex));
				HandlerBean.setMethod(MethodReceived);
				return HandlerBean;
			}
		} //end else
		
		// Do View Dispatch Check Procedures
		if( isViewDispatch(arguments.event,handlerBean) ){
			return handlerBean;
		}

		// Run invalid event procedures, handler not found
		invalidEvent(arguments.event,handlerBean);

		// onInvalidEvent detected, so just return the overriden bean
		return handlerBean;
		</cfscript>
	</cffunction>
	
	<!--- isViewDispatch --->
    <cffunction name="isViewDispatch" output="false" access="public" returntype="any" hint="Check if the incoming event has a matching implicit view dispatch available">
    	<cfargument name="event"  type="any"	required="true" hint="The event string"/>
		<cfargument name="ehBean" type="any" 	required="true" hint="The event handler bean"/>
		<cfscript>
    		// Cleanup for modules
			var cEvent     		= reReplaceNoCase(arguments.event,"^([^:.]*):","");
			var renderer 		= controller.getPlugin("Renderer");
			var targetView		= "";
			var targetModule	= getToken(arguments.event,1,":");
			
			// Cleanup of . to / for lookups 
			cEvent = lcase(replace(cEvent,".","/","all"));
			
			// module?
			if( find(":", arguments.event) and structKeyExists(controller.getSetting("modules"), targetModule ) ){
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
		<cfargument name="ehBean" type="any" 	required="true" hint="The event handler bean"/>
		<cfscript>
			var onInvalidEvent = controller.getSetting("onInvalidEvent");

			// Invalid Event Detected, log it in the Application log, not a coldbox log but an app log
			controller.getPlugin("Logger").error("Invalid Event detected: #arguments.event#. Path info: #cgi.path_info# , query string: #cgi.query_string#");

			// If onInvalidEvent is registered, use it
			if ( len(trim(onInvalidEvent)) ){

				// Test for invalid Event Error
				if ( compareNoCase(onInvalidEvent,arguments.event) eq 0 ){
					getUtil().throwit(message="The onInvalid event is also invalid",
									  detail="The onInvalidEvent setting is also invalid: #onInvalidEvent#. Please check your settings",
									  type="HandlerService.onInValidEventSettingException");
				}

				// Store Invalid Event in PRC
				controller.getRequestService().getContext().setValue("invalidevent",arguments.event,true);

				// Override Event
				arguments.ehBean.setHandler(reReplace(onInvalidEvent,"\.[^.]*$",""));
				arguments.ehBean.setMethod(listLast(onInvalidEvent,"."));

				return;
			}

			// Throw Exception
			getUtil().throwit(message="The event: #arguments.event# is not valid registered event.",type="HandlerService.EventHandlerNotRegisteredException");
		</cfscript>
	</cffunction>


	<!--- Handler Registration System --->
	<cffunction name="registerHandlers" access="public" returntype="void" hint="I register your application's event handlers" output="false">
		<cfscript>
		var HandlersPath = controller.getSetting("HandlersPath");
		var HandlersExternalLocationPath = controller.getSetting("HandlersExternalLocationPath");
		var HandlerArray = Arraynew(1);
		var HandlersExternalArray = ArrayNew(1);

		/* ::::::::::::::::::::::::::::::::::::::::: HANDLERS BY CONVENTION :::::::::::::::::::::::::::::::::::::::::::: */

		//Get recursive Array listing
		HandlerArray = getHandlerListing(HandlersPath);

		//Set registered Handlers
		controller.setSetting(name="RegisteredHandlers",value=arrayToList(HandlerArray));

		/* ::::::::::::::::::::::::::::::::::::::::: EXTERNAL HANDLERS :::::::::::::::::::::::::::::::::::::::::::: */

		if( len(HandlersExternalLocationPath) ){

			//Check for Handlers Directory Location
			if ( not directoryExists(HandlersExternalLocationPath) ){
				getUtil().throwit("The external handlers directory: #HandlersExternalLocationPath# does not exist please check your application structure.","","HandlerService.HandlersDirectoryNotFoundException");
			}

			//Get recursive Array listing
			HandlersExternalArray = getHandlerListing(HandlersExternalLocationPath);
		}

		//Verify it
		if ( ArrayLen(HandlerArray) eq 0 AND ArrayLen(HandlersExternalArray) eq 0){
			getUtil().throwit("No handlers were found in: #HandlersPath# or in #HandlersExternalLocationPath#. So I have no clue how you are going to run this application.","","HandlerService.NoHandlersFoundException");
		}

		//Set registered External Handlers
		controller.setSetting(name="RegisteredExternalHandlers",value=arrayToList(HandlersExternalArray));
		</cfscript>
	</cffunction>

	<!--- Clear All Dictioanries --->
	<cffunction name="clearDictionaries" access="public" returntype="void" hint="Clear the internal cache dictionaries" output="false" >
		<cfscript>
			getHandlerCacheDictionary().clearAll();
			getEventCacheDictionary().clearAll();
		</cfscript>
	</cffunction>

<!------------------------------------------- ACCESSOR/MUTATORS ------------------------------------------->

	<!--- Handler Cache Dictionary --->
	<cffunction name="getHandlerCacheDictionary" access="public" returntype="coldbox.system.core.collections.BaseDictionary" output="false">
		<cfreturn instance.HandlerCacheDictionary>
	</cffunction>
	<cffunction name="setHandlerCacheDictionary" access="public" returntype="void" output="false">
		<cfargument name="HandlerCacheDictionary" type="coldbox.system.core.collections.BaseDictionary" required="true">
		<cfset instance.HandlerCacheDictionary = arguments.HandlerCacheDictionary>
	</cffunction>

	<!--- Event Cache Dictionary --->
	<cffunction name="getEventCacheDictionary" access="public" returntype="coldbox.system.core.collections.BaseDictionary" output="false">
		<cfreturn instance.EventCacheDictionary>
	</cffunction>
	<cffunction name="setEventCacheDictionary" access="public" returntype="void" output="false">
		<cfargument name="EventCacheDictionary" type="coldbox.system.core.collections.BaseDictionary" required="true">
		<cfset instance.EventCacheDictionary = arguments.EventCacheDictionary>
	</cffunction>

	<cffunction name="getEventMetadataEntry" access="public" returntype="struct" hint="Get an event string's metadata entry" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="targetEvent" required="true" type="any" hint="The target event">
		<!--- ************************************************************* --->
		<cfscript>
			var entry = getEventCacheDictionary().getKey(arguments.targetEvent);

			if( isSimpleValue(entry) ){
				return getNewMDEntry();
			}
			else{
				return entry;
			}
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
				cleanHandler = getUtil().ripExtension(cleanhandler);

				//Add data to array
				ArrayAppend(fileArray,cleanHandler);
			}

			return fileArray;
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Get a new MD cache entry structure --->
	<cffunction name="getNewMDEntry" access="public" returntype="struct" hint="Get a new metadata entry structure" output="false" >
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

		<cfif not getEventCacheDictionary().keyExists(arguments.cacheKey)>
			<cflock name="handlerservice.eventcachingmd.#arguments.cacheKey#" type="exclusive" throwontimeout="true" timeout="10">
			<cfscript>
			// Determine if we have md for the event to execute in the md dictionary, else set it
			if ( not getEventCacheDictionary().keyExists(arguments.cacheKey) ){
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
				getEventCacheDictionary().setKey(cacheKey,mdEntry);
			}//end of md cache dictionary.
			</cfscript>
			</cflock>
		</cfif>
	</cffunction>

	<!--- Save Handler metadata --->
	<cffunction name="saveHandlerMetadata" access="private" returntype="void" hint="Save a handler's persistence metadata in the dictionary" output="false">
		<!--- ************************************************************* --->
		<cfargument name="targetHandler" type="any" 	required="true" hint="The handler target" />
		<cfargument name="cacheKey"      type="any" 	required="true" hint="The handler cache key" />
		<cfargument name="force" 		 type="boolean" required="true" default="false" hint="Force the md lookup. Most likely used when controller caching is off"/>
		<!--- ************************************************************* --->
		<cfset var metadata = 0>
		<cfset var mdEntry  = 0>

		<!--- Check if md already in our data dictionary --->
		<cfif NOT getHandlerCacheDictionary().keyExists(arguments.cacheKey) OR arguments.force>
			<cfset metadata = getmetadata(arguments.targetHandler)>
			<cflock name="handlerservice.handlermd.#metadata.name#" type="exclusive" throwontimeout="true" timeout="10">
			<cfscript>
			// Determine if we have md and cacheable, else set it
			if ( NOT getHandlerCacheDictionary().keyExists(arguments.cacheKey) OR arguments.force){

				// Get Default MD Entry
				mdEntry = getNewMDEntry();

				// By Default, handlers with no cache flag are set to true
				if ( NOT structKeyExists(metadata,"cache") or NOT isBoolean(metadata["cache"]) ){
					metadata.cache = true;
				}

				// Cache Entries for timeout and last access timeout
				if ( metadata.cache ){
					mdEntry.cacheable = true;
					if ( structKeyExists(metadata,"cachetimeout") ){
						mdEntry.timeout = metadata["cachetimeout"];
					}
					if ( structKeyExists(metadata, "cacheLastAccessTimeout") ){
						mdEntry.lastAccessTimeout = metadata["cacheLastAccessTimeout"];
					}
				} // end we cached.

				// Test for singleton parameters
				if( structKeyExists(metadata,"singleton") ){
					mdEntry.cacheable = true;
					mdEntry.timeout   = 0;
				}


				//TODO: Add function md entries here too. Maybe create a handlerMD object that can store
				// Persistence, event caching and more. Then we can use that easily for next requests.

				// Set Entry in dictionary
				getHandlerCacheDictionary().setKey(arguments.cacheKey,mdEntry);
			}
			</cfscript>
			</cflock>
		</cfif>
	</cffunction>

</cfcomponent>