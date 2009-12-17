<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/10/2007
Description :
	This is the main ColdBox handler service.
----------------------------------------------------------------------->
<cfcomponent name="HandlerService" extends="coldbox.system.services.BaseService" hint="This is the main Coldbox Handler service" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="HandlerService" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			// Setup The Controller.
			setController(arguments.controller);
			// Setup the Event Handler Cache Dictionary
			setHandlerCacheDictionary(CreateObject("component","coldbox.system.core.util.collections.BaseDictionary").init('Handlersmetadata'));
			// Setup the Event Cache Dictionary
			setEventCacheDictionary(CreateObject("component","coldbox.system.core.util.collections.BaseDictionary").init('EventCache'));
						
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- onConfigurationLoad --->
    <cffunction name="onConfigurationLoad" output="false" access="public" returntype="void" hint="Called by loader service when configuration file loads">
    	<cfscript>
			instance.log = getController().getLogBox().getLogger(this);
    		// execute the handler registrations after configurations loaded
			registerHandlers();			
    	</cfscript>
    </cffunction>
	
	<!--- Get a new handler Instance --->
	<cffunction name="newHandler" access="public" returntype="any" hint="Create a New Handler Instance" output="false" >
		<cfargument name="invocationPath" type="string" required="true" hint="The handler invocation path"/>
		<cfscript>
			//Create Handler
			var oHandler = CreateObject("component", invocationPath ).init( controller );
			var interceptmetadata = structnew();
			
			//Fill-up Intercepted metadata
			interceptmetadata.handlerPath = invocationPath;
			interceptmetadata.oHandler = oHandler;
			
			//Fire Interception
			controller.getInterceptorService().processState("afterHandlerCreation",interceptmetadata);
			
			//Return handler
			return oHandler;
		</cfscript>
	</cffunction>
	
	<!--- Get a validated handler instance, using a handlerBean --->
	<cffunction name="getHandler" output="false" access="public" returntype="any" hint="Returns a valid event handler object ready for execution">
		<!--- ************************************************************* --->
		<cfargument name="oEventHandlerBean" type="coldbox.system.beans.EventHandlerBean" required="true" hint="The event handler bean to use"/>
		<cfargument name="RequestContext"    type="any" required="true" hint="The request Context"/>
		<!--- ************************************************************* --->
		<cfscript>
			/* Get the validated event handler bean */
			var oEventHandler = "";
			/* Request context to check */
			var oRequestContext = arguments.RequestContext;
			/* Cache Keys */
			var cacheKey = getColdboxOCM().HANDLER_CACHEKEY_PREFIX & oEventHandlerBean.getRunnable();
			var eventCacheKey = "";
			/* Cache Util */
			var oEventURLFacade = getController().getColdboxOCM().getEventURLFacade();
			/* metadata entry structures */
			var handlerDictionaryEntry = "";
			var eventDictionaryEntry = "";
			
			/* ::::::::::::::::::::::::::::::::::::::::: HANDLERS CACHING :::::::::::::::::::::::::::::::::::::::::::: */
			/* Are we caching handlers? */
			if ( controller.getSetting("HandlerCaching") ){
				/* Lookup handler in Cache */
				oEventHandler = getColdboxOCM().get(cacheKey);
				/* Verify if not found, then create it and cache it */
				if( not isObject(oEventHandler) ){
					/* Create a new handler */
					oEventHandler = newHandler(oEventHandlerBean.getRunnable());
					/* Save its metadata For event Caching and Aspects */
					saveHandlermetadata(oEventHandler,cacheKey);					
					/* Get dictionary entry for operations, it is now guaranteed. */
					handlerDictionaryEntry = getHandlerCacheDictionary().getKey(cacheKey);
					/* Do we Cache this handler */
					if ( handlerDictionaryEntry.cacheable ){
						getColdboxOCM().set(cacheKey,oEventHandler,handlerDictionaryEntry.timeout,handlerDictionaryEntry.lastAccessTimeout);
					}
				}//end of caching strategy				
			}
			else{
				/* Create Runnable Object */
				oEventHandler = newHandler(oEventHandlerBean.getRunnable());
				/* Save its metadata For event Caching and Aspects */
				saveHandlermetadata(oEventHandler,cacheKey);					
			}
			
			/* ::::::::::::::::::::::::::::::::::::::::: EVENT METHOD TESTING :::::::::::::::::::::::::::::::::::::::::::: */
			
			/* Method Testing and Validation */
			if ( not oEventHandlerBean.getisPrivate() and not structKeyExists(oEventHandler,oEventHandlerBean.getMethod()) ){
				
				/* Check if the handler has an onMissingAction() method, virtual Events */
				if( structKeyExists(oEventHandler,"onMissingAction") ){
					oEventHandlerBean.setisMissingAction(true);
					oEventHandlerBean.setMissingAction(oEventHandlerBean.getMethod());
					/* Let's execute our missing action */
					return oEventHandler;
				}
				
				/* Invalid Event Detected, log it */
				controller.getPlugin("Logger").logEntry("error","Invalid Event detected: #oEventHandlerBean.getRunnable()#");
				
				// If onInvalidEvent is registered, use it
				if ( len(trim(controller.getSetting("onInvalidEvent"))) ){
					// Test for invalid Event Error
					if ( compareNoCase(controller.getSetting("onInvalidEvent"),oRequestContext.getCurrentEvent()) eq 0 ){
						getUtil().throwit(message="The onInvalid event is invalid",
										  detail="The onInvalidEvent setting is also invalid: #controller.getSetting('onInvalidEvent')#. Please check your settings",
										  type="HandlerService.onInValidEventSettingException");
					}
					//Place invalid event in request context.
					oRequestContext.setValue("invalidevent",oEventHandlerBean.getRunnable());
					
					// Relocate to Invalid Event, with collection persistance
					controller.setNextEvent(event=controller.getSetting("onInvalidEvent"),persist="invalidevent");
				}
				else{
					getUtil().throwit(message="An invalid event has been detected",
									  detail="An invalid event has been detected: [#oEventHandlerBean.getRunnable()#] The action requested: [#oEventHandlerBean.getMethod()#] does not exists in the specified handler.",
									  type="HandlerService.invalidEventException");
				}
			}//method check finalized.
			
			/* ::::::::::::::::::::::::::::::::::::::::: EVENT CACHING :::::::::::::::::::::::::::::::::::::::::::: */
		
			/* Event Caching Routines, if using caching and we are executing the main event */
			if ( controller.getSetting("EventCaching") and oEventHandlerBean.getFullEvent() eq oRequestContext.getCurrentEvent() ){
				
				/* Save Event Caching metadata */
				saveEventCachingmetadata(eventUDF=oEventHandler[oEventHandlerBean.getMethod()],
										 cacheKey=oEventHandlerBean.getFullEvent(),
										 cacheKeySuffix=oEventHandler.EVENT_CACHE_SUFFIX);
				/* get dictionary entry for operations, it is now guaranteed. */
				eventDictionaryEntry = getEventCacheDictionary().getKey(oEventHandlerBean.getFullEvent());
				/* Do we need to cache this event's output after it executes?? */
				if ( eventDictionaryEntry.cacheable ){
					/* Create the Cache Key to save */
					eventDictionaryEntry.cacheKey = oEventURLFacade.buildEventKey(keySuffix=eventDictionaryEntry.suffix,
																				  targetEvent=oEventHandlerBean.getFullEvent(),
																				  targetContext=oRequestContext);
					/* Event is cacheable and we need to flag it so the Renderer caches it. */
					oRequestContext.setEventCacheableEntry(eventDictionaryEntry);
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
			var handlerIndex = 0;
			var handlerExternalIndex = 0;
			var handlersList = controller.getSetting("RegisteredHandlers");
			var handlersExternalList = controller.getSetting("RegisteredExternalHandlers");
			var currentEvent = arguments.event.getCurrentEvent();
			
			// Verify our incoming event in our registration lists
			handlerIndex 		 = listFindNoCase(handlersList, currentEvent);
			handlerExternalIndex = listFindNoCase(handlersExternalList, currentEvent);
			
			// Do a Default Action Test First, if default action desired.
			if( handlerIndex OR handlerExternalIndex ){
				// Append the default event action
				currentEvent = currentEvent & "." & controller.getSetting('EventAction',1);
				// Save it as the current Event
				event.setValue(controller.getSetting("EventName"),currentEvent);
			}		
		</cfscript>
	</cffunction>
	
	<!--- Get a Registered Handler Bean --->
	<cffunction name="getRegisteredHandler" access="public" hint="I get a registered handler and method according to passed event from the registeredHandlers setting." returntype="coldbox.system.beans.EventHandlerBean"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event"   type="any"  		required="true"  hint="The full event string to check and get." >
		<!--- ************************************************************* --->
		<cfscript>
		var handlerIndex = 0;
		var handlerExternalIndex = 0;
		var HandlerReceived = "";
		var MethodReceived = "";
		var handlersList = controller.getSetting("RegisteredHandlers");
		var handlersExternalList = controller.getSetting("RegisteredExternalHandlers");
		var onInvalidEvent = controller.getSetting("onInvalidEvent");
		var HandlerBean = CreateObject("component","coldbox.system.beans.EventHandlerBean").init(controller.getSetting("HandlersInvocationPath"));
	
		// Rip the handler and method
		HandlerReceived = reReplace(event,"\.[^.]*$","");
		MethodReceived = listLast(event,".");
		
		// Try to do list localization in the registry for full event string.
		handlerIndex = listFindNoCase(handlersList, HandlerReceived);
		// Check for conventions location
		if ( handlerIndex ){
			HandlerBean.setHandler(listgetAt(handlersList,handlerIndex));
			HandlerBean.setMethod(MethodReceived);
			return HandlerBean;
		}
		
		// Check for external location
		handlerExternalIndex = listFindNoCase(handlersExternalList, HandlerReceived);
		if( handlerExternalIndex ){
			HandlerBean.setInvocationPath(controller.getSetting("HandlersExternalLocation"));
			HandlerBean.setHandler(listgetAt(handlersExternalList,handlerExternalIndex));
			HandlerBean.setMethod(MethodReceived);
			return HandlerBean;
		}
		
		// Invalid Event Detected
		controller.getPlugin("Logger").logEntry("error","Invalid Event detected: #event# ");
		
		// If onInvalidEvent is registered, use it
		if ( len(trim(onInvalidEvent)) ){
			// Test for invalid Event Error
			if ( compareNoCase(onInvalidEvent,event) eq 0 ){
				getUtil().throwit(message="The onInvalid event is also invalid",
								  detail="The onInvalidEvent setting is also invalid: #onInvalidEvent#. Please check your settings",
								  type="HandlerService.onInValidEventSettingException");
			}
			// Relocate to Invalid Event
			controller.setNextEvent(event=onInvalidEvent);
		}
		// Throw Exception
		getUtil().throwit(message="The event: #event# is not valid registered event.",type="HandlerService.EventHandlerNotRegisteredException");
		
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
		
		//Check for Handlers Directory Location
		if ( not directoryExists(HandlersPath) ){
			getUtil().throwit("The handlers directory: #handlerspath# does not exist please check your application structure or your Application Mapping.","","HandlerService.HandlersDirectoryNotFoundException");
		}
		
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
	<cffunction name="getHandlerCacheDictionary" access="public" returntype="coldbox.system.core.util.collections.BaseDictionary" output="false">
		<cfreturn instance.HandlerCacheDictionary>
	</cffunction>
	<cffunction name="setHandlerCacheDictionary" access="public" returntype="void" output="false">
		<cfargument name="HandlerCacheDictionary" type="coldbox.system.core.util.collections.BaseDictionary" required="true">
		<cfset instance.HandlerCacheDictionary = arguments.HandlerCacheDictionary>
	</cffunction>
	
	<!--- Event Cache Dictionary --->
	<cffunction name="getEventCacheDictionary" access="public" returntype="coldbox.system.core.util.collections.BaseDictionary" output="false">
		<cfreturn instance.EventCacheDictionary>
	</cffunction>
	<cffunction name="setEventCacheDictionary" access="public" returntype="void" output="false">
		<cfargument name="EventCacheDictionary" type="coldbox.system.core.util.collections.BaseDictionary" required="true">
		<cfset instance.EventCacheDictionary = arguments.EventCacheDictionary>
	</cffunction>
	
	<cffunction name="getEventmetadataEntry" access="public" returntype="struct" hint="Get an event string's metadata entry" output="false" >
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
			for (; i lte files.recordcount; i=i+1 ){
				
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
			
			mdEntry.cacheable = false;
			mdEntry.timeout = "";
			mdEntry.lastAccessTimeout = "";
			mdEntry.cacheKey = "";
			mdEntry.suffix = "";
			
			return mdEntry;
		</cfscript>
	</cffunction>
	
	<!--- Save Event Caching metadata --->
	<cffunction name="saveEventCachingmetadata" access="private" returntype="void" hint="Save a handler's event caching metadata in the dictionary">
		<!--- ************************************************************* --->
		<cfargument name="eventUDF" 		type="any" required="true" hint="The handler event UDF to inspect" />
		<cfargument name="cacheKey"     	type="any" required="true" hint="The event cache key" />
		<cfargument name="cacheKeySuffix"   type="any" required="true" hint="The event cache key suffix" />
		<!--- ************************************************************* --->
		<cfset var metadata = 0>
		<cfset var mdEntry = 0>
		
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
				if ( metadata["cache"] ){
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
				else{
					mdEntry.cacheable = false;
				}
				
				// Test for singleton parameters
				if( structKeyExists(metadata,"singleton") ){
					mdEntry.cacheable = true;
					mdEntry.timeout = 0;
				}
				
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
	<cffunction name="saveHandlermetadata" access="private" returntype="void" hint="Save a handler's metadata in the dictionary">
		<!--- ************************************************************* --->
		<cfargument name="targetHandler" type="any" required="true" hint="The handler target" />
		<cfargument name="cacheKey"      type="any" required="true" hint="The handler cache key" />
		<!--- ************************************************************* --->
		<cfset var metadata = 0>
		<cfset var mdEntry = 0>
		
		<cfif not getHandlerCacheDictionary().keyExists(arguments.cacheKey)>
			<cfset metadata = getmetadata(arguments.targetHandler)>
			<cflock name="handlerservice.handlermd.#metadata.name#" type="exclusive" throwontimeout="true" timeout="10">
			<cfscript>
			/* Determine if we have md and cacheable, else set it  */
			if ( not getHandlerCacheDictionary().keyExists(arguments.cacheKey) ){
				/* Get Default MD Entry */
				mdEntry = getNewMDEntry();
				/* By Default, handlers with no cache flag are set to true */
				if ( not structKeyExists(metadata,"cache") or not isBoolean(metadata["cache"]) ){
					metadata.cache = true;
				}
				/* Cache Entries for timeout and last access timeout */
				if ( metadata["cache"] ){
					mdEntry.cacheable = true;
					if ( structKeyExists(metadata,"cachetimeout") ){
						mdEntry.timeout = metadata["cachetimeout"];
					}
					if ( structKeyExists(metadata, "cacheLastAccessTimeout") ){
						mdEntry.lastAccessTimeout = metadata["cacheLastAccessTimeout"];
					}
				} // end we cached.
				else{
					mdEntry.cacheable = false;
				}
				
				/* Set Entry in dictionary */
				getHandlerCacheDictionary().setKey(arguments.cacheKey,mdEntry);
			}
			</cfscript>
			</cflock>
		</cfif>
	</cffunction>
	
</cfcomponent>