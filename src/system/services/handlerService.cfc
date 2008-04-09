<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/10/2007
Description :
	This is the main ColdBox handler service.
----------------------------------------------------------------------->
<cfcomponent name="handlerService" extends="baseService" hint="This is the main Coldbox Handler service" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="handlerService" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			/* Setup The Controller. */
			setController(arguments.controller);
			/* Setup the Event Handler Cache Dictionary */
			setHandlerCacheDictionary(CreateObject("component","coldbox.system.util.baseDictionary").init('HandlersMetadata'));
			/* Setup the Event Cache Dictionary */
			setEventCacheDictionary(CreateObject("component","coldbox.system.util.baseDictionary").init('EventCache'));
			
			/* Setup the public event cache key prefix */
			this.EVENT_CACHEKEY_PREFIX = "cboxevent_event-";
			this.HANDLER_CACHEKEY_PREFIX = "cboxhandler_handler-";
			
			/* Return Service */			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get a new handler Instance --->
	<cffunction name="newHandler" access="public" returntype="any" hint="Create a New Handler Instance" output="false" >
		<cfargument name="invocationPath" type="string" required="true" hint="The handler invocation path"/>
		<cfscript>
			//Create Handler
			var oHandler = CreateObject("component", invocationPath ).init( controller );
			var interceptMetadata = structnew();
			
			//Fill-up Intercepted MetaData
			interceptMetadata.handlerPath = invocationPath;
			interceptMetadata.oHandler = oHandler;
			
			//Fire Interception
			getController().getInterceptorService().processState("afterHandlerCreation",interceptMetadata);
			
			//Return handler
			return oHandler;
		</cfscript>
	</cffunction>
	
	<!--- Get a validated handler instance, using a handlerBean --->
	<cffunction name="getHandler" output="false" access="public" returntype="any" hint="Returns a valid event handler object ready for execution">
		<!--- ************************************************************* --->
		<cfargument name="oEventHandlerBean" type="coldbox.system.beans.eventhandlerBean" required="true" hint="The event handler bean to use"/>
		<!--- ************************************************************* --->
		<cfscript>
			/* Get the validated event handler bean */
			var oEventHandler = "";
			/* Request context to check */
			var oRequestContext = controller.getRequestService().getContext();
			/* Cache Keys */
			var cacheKey = this.HANDLER_CACHEKEY_PREFIX & oEventHandlerBean.getRunnable();
			var eventCacheKey = "";
			/* Metadata entry structures */
			var MetaData = "";
			var mdEntry = "";
			var handlerDictionaryEntry = "";
			var eventDictionaryEntry = "";
			
			/* ::::::::::::::::::::::::::::::::::::::::: HANDLERS CACHING :::::::::::::::::::::::::::::::::::::::::::: */
		
			/* Are we caching handlers? */
			if ( controller.getSetting("HandlerCaching") ){
				
				/* Lookup in Cache */
				if ( controller.getColdboxOCM().lookup(cacheKey) ){
					oEventHandler = controller.getColdboxOCM().get(cacheKey);
				}
				else{
					/* Create a new handler */
					oEventHandler = newHandler(oEventHandlerBean.getRunnable());
					
					/* Determine if we have md and cacheable, else set it  */
					if ( not getHandlerCacheDictionary().keyExists(cacheKey) ){
						/* Get Object MetaData */
						MetaData = getMetaData(oEventHandler);
						/* Get Default MD Entry */
						mdEntry = getNewMDEntry();
												
						/* By Default, handlers with no cache flag are set to true */
						if ( not structKeyExists(MetaData,"cache") or not isBoolean(MetaData["cache"]) ){
							MetaData.cache = true;
						}
						/* Cache Entries for timeout and last access timeout */
						if ( MetaData["cache"] ){
							mdEntry.cacheable = true;
							if ( structKeyExists(MetaData,"cachetimeout") ){
								mdEntry.timeout = MetaData["cachetimeout"];
							}
							if ( structKeyExists(MetaData, "cacheLastAccessTimeout") ){
								mdEntry.lastAccessTimeout = MetaData["cacheLastAccessTimeout"];
							}
						} // end we cached.
						else{
							mdEntry.cacheable = false;
						}
						
						/* Set Entry in dictionary */
						getHandlerCacheDictionary().setKey(cacheKey,mdEntry);	
					}//end of md cache dictionary.
					
					/* Set dictionary entry for operations, it is now guaranteed. */
					handlerDictionaryEntry = getHandlerCacheDictionary().getKey(cacheKey);
					/* Do we Cache */
					if ( handlerDictionaryEntry.cacheable ){
						controller.getColdboxOCM().set(cacheKey,oEventHandler,handlerDictionaryEntry.timeout,handlerDictionaryEntry.lastAccessTimeout);
					}
				}//end of caching strategy
				
			}//end of if not caching handlers
			else{
				/* Create Runnable Object */
				oEventHandler = newHandler(oEventHandlerBean.getRunnable());
			}
			
			/* ::::::::::::::::::::::::::::::::::::::::: EVENT METHOD TESTING :::::::::::::::::::::::::::::::::::::::::::: */
			
			/* Method Testing and Validation */
			if ( not oEventHandlerBean.getisPrivate() and not structKeyExists(oEventHandler,oEventHandlerBean.getMethod()) ){
				getUtil().dumpit(getMetaData(oEventHandler).functions);getUtil().abortit();
				/* Invalid Event Detected, log it */
				controller.getPlugin("logger").logEntry("error","Invalid Event detected: #oEventHandlerBean.getRunnable()#");
				/* If onInvalidEvent is registered, use it */
				if ( controller.getSetting("onInvalidEvent") neq "" ){
					/* Test for invalid Event Error */
					if ( compareNoCase(controller.getSetting("onInvalidEvent"),oRequestContext.getCurrentEvent()) eq 0 ){
						getUtil().throwit(message="The onInvalid event is invalid",
										  detail="The onInvalidEvent setting is also invalid: #controller.getSetting('onInvalidEvent')#. Please check your settings",
										  type="Framework.onInValidEventSettingException");
					}
					//Place invalid event in request context.
					oRequestContext.setValue("invalidevent",oEventHandlerBean.getRunnable());
					/* Relocate to Invalid Event, with collection persistance */
					controller.setNextEvent(event=controller.getSetting("onInvalidEvent"),persist="invalidevent");
				}
				else{
					getUtil().throwit(message="An invalid event has been detected",
									  detail="An invalid event has been detected: #oEventHandlerBean.getRunnable()# This event does not exist in the specified handler.",
									  type="Framework.onInValidEventSettingException");
				}
			}//method check finalized.
			
			/* ::::::::::::::::::::::::::::::::::::::::: EVENT CACHING :::::::::::::::::::::::::::::::::::::::::::: */
		
			/* Event Caching Routines, if using caching and we are executing the main event */
			if ( controller.getSetting("EventCaching") and oEventHandlerBean.getFullEvent() eq oRequestContext.getCurrentEvent() ){
				
				/* Determine if we have md for the event to execute in the md dictionary, else set it  */
				if ( not getEventCacheDictionary().keyExists(oEventHandlerBean.getFullEvent()) ){
					/* Get Method MetaData */
					MetaData = getMetaData(oEventHandler[oEventHandlerBean.getMethod()]);
					/* Get New Default MD Entry */
					mdEntry = getNewMDEntry();
											
					/* By Default, events with no cache flag are set to FALSE */
					if ( not structKeyExists(MetaData,"cache") or not isBoolean(MetaData["cache"]) ){
						MetaData.cache = false;
					}
					/* Cache Entries for timeout and last access timeout */
					if ( MetaData["cache"] ){
						mdEntry.cacheable = true;
						/* Event Timeout */
						if ( structKeyExists(MetaData,"cachetimeout") and MetaData.cachetimeout neq 0 ){
							mdEntry.timeout = MetaData["cachetimeout"];
						}
						/* Last Access Timeout */
						if ( structKeyExists(MetaData, "cacheLastAccessTimeout") ){
							mdEntry.lastAccessTimeout = MetaData["cacheLastAccessTimeout"];
						}
					} //end cache metadata is true
					else{
						mdEntry.cacheable = false;
					}			
					
					/* Set md Entry in dictionary */
					getEventCacheDictionary().setKey(oEventHandlerBean.getFullEvent(),mdEntry);
					
				}//end of md cache dictionary.
				
				/* get dictionary entry for operations, it is now guaranteed. */
				eventDictionaryEntry = getEventCacheDictionary().getKey(oEventHandlerBean.getFullEvent());
				
				/* Do we need to cache this event?? */
				if ( eventDictionaryEntry.cacheable ){
					/* Save the cache key in md Entry */
					eventDictionaryEntry.cacheKey = this.EVENT_CACHEKEY_PREFIX & oEventHandlerBean.getFullEvent() & "-" & getController().getColdboxOCM().getEventURLFacade().getUniqueHash(oEventHandlerBean.getFullEvent()) ;
					/* Event is cacheable and we need to flag it so the renderer caches it. */
					oRequestContext.setEventCacheableEntry(eventDictionaryEntry);
				}//end if md says that this event is cacheable
			}//end if event caching.
					
			//return the tested and validated event handler
			return oEventHandler;
		</cfscript>
	</cffunction>
		
	<!--- Get a Registered Handler Bean --->
	<cffunction name="getRegisteredHandler" access="public" hint="I get a registered handler and method according to passed event from the registeredHandlers setting." returntype="coldbox.system.beans.eventhandlerBean"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event"   type="any"  		required="true"  hint="The event to check and get." >
		<cfargument name="noThrow" type="any" 		required="false" default="false" hint="No error throwing, used by request service."/>
		<!--- ************************************************************* --->
		<cfscript>
		var handlerIndex = 0;
		var handlerExternalIndex = 0;
		var HandlerReceived = "";
		var MethodReceived = "";
		var handlersList = controller.getSetting("RegisteredHandlers");
		var handlersExternalList = controller.getSetting("RegisteredExternalHandlers");
		var onInvalidEvent = controller.getSetting("onInvalidEvent");
		var HandlerBean = CreateObject("component","coldbox.system.beans.eventhandlerBean").init(controller.getSetting("HandlersInvocationPath"));
	
		//Rip the handler and method.
		HandlerReceived = reReplace(event,"\.[^.]*$","");
		MethodReceived = listLast(event,".");

		//Try to do list localization in the registry
		handlerIndex = listFindNoCase(handlersList, HandlerReceived);
		handlerExternalIndex = listFindNoCase(handlersExternalList, HandlerReceived);
		
		//Check for conventions location
		if ( handlerIndex ){
			HandlerBean.setHandler(listgetAt(handlersList,handlerIndex));
			HandlerBean.setMethod(MethodReceived);
		}
		//Check for external location
		else if( handlerExternalIndex ){
			HandlerBean.setInvocationPath(controller.getSetting("HandlersExternalLocation"));
			HandlerBean.setHandler(listgetAt(handlersExternalList,handlerExternalIndex));
			HandlerBean.setMethod(MethodReceived);
		}
		else if( arguments.noThrow eq false ){
			//Check for invalid Event
			if ( onInvalidEvent neq "" ){
					//Check if the invalid event is the same as the current event
					if ( CompareNoCase(onInvalidEvent,event) eq 0){
						getUtil().throwit("The invalid event handler: #onInvalidEvent# is also invalid. Please check your settings","","Framework.InvalidEventHandlerException");
					}
					else{
						//Log Invalid Event
						controller.getPlugin("logger").logEntry("error","Invalid Event detected: #HandlerReceived#.#MethodReceived#");
						//Override Event
						HandlerBean.setHandler(reReplace(onInvalidEvent,"\.[^.]*$",""));
						HandlerBean.setMethod(listLast(onInvalidEvent,"."));
					}
				}
			else{
				getUtil().throwit("The event handler: #event# is not valid registered event.","","Framework.EventHandlerNotRegisteredException");
			}
		}//end if noThrow
	
		//Return validated Handler Bean
		return HandlerBean;
		</cfscript>
	</cffunction>
	
	<!--- Handler Registration System --->
	<cffunction name="registerHandlers" access="public" returntype="void" hint="I register your application's event handlers" output="false">
		<cfscript>
		var HandlersPath = controller.getSetting("HandlersPath");
		var HandlersExternalLocationPath = controller.getSetting("HandlersExternalLocationPath");
		var HandlerArray = Arraynew(1);
		var HandlersExternalArray = ArrayNew(1);

		/* Cleanup Just in Case */
		clearDictionaries();
		
		/* ::::::::::::::::::::::::::::::::::::::::: HANDLERS BY CONVENTION :::::::::::::::::::::::::::::::::::::::::::: */
		
		//Check for Handlers Directory Location
		if ( not directoryExists(HandlersPath) )
			getUtil().throwit("The handlers directory: #handlerspath# does not exist please check your application structure or your Application Mapping.","","Framework.loaderService.HandlersDirectoryNotFoundException");
		//Get recursive Array listing
		HandlerArray = recurseListing(HandlerArray, HandlersPath, HandlersPath);
		//Verify it
		if ( ArrayLen(HandlerArray) eq 0 )
			getUtil().throwit("No handlers were found in: #HandlerPath#. So I have no clue how you are going to run this application.","","Framework.loaderService.NoHandlersFoundException");
		//Set registered Handlers
		controller.setSetting("RegisteredHandlers",arrayToList(HandlerArray));
		
		/* ::::::::::::::::::::::::::::::::::::::::: EXTERNAL HANDLERS :::::::::::::::::::::::::::::::::::::::::::: */
		
		if( HandlersExternalLocationPath neq ""){
			//Check for Handlers Directory Location
			if ( not directoryExists(HandlersExternalLocationPath) )
				getUtil().throwit("The external handlers directory: #HandlersExternalLocationPath# does not exist please check your application structure.","","Framework.loaderService.HandlersDirectoryNotFoundException");
			//Get recursive Array listing
			HandlersExternalArray = recurseListing(HandlersExternalArray, HandlersExternalLocationPath, HandlersExternalLocationPath);
			
			//Sort The Array
			ArraySort(HandlersExternalArray,"text");
		}
		//Set registered External Handlers, if found
		controller.setSetting("RegisteredExternalHandlers",arrayToList(HandlersExternalArray));
		</cfscript>
	</cffunction>

	<cffunction name="clearDictionaries" access="public" returntype="void" hint="Clear the internal cache dictionaries" output="false" >
		<cfscript>
			getHandlerCacheDictionary().clearAll();
			getEventCacheDictionary().clearAll();
		</cfscript>
	</cffunction>
	
<!------------------------------------------- ACCESSOR/MUTATORS ------------------------------------------->
	
	<!--- Handler Cache Dictionary --->
	<cffunction name="getHandlerCacheDictionary" access="public" returntype="coldbox.system.util.baseDictionary" output="false">
		<cfreturn instance.HandlerCacheDictionary>
	</cffunction>
	<cffunction name="setHandlerCacheDictionary" access="public" returntype="void" output="false">
		<cfargument name="HandlerCacheDictionary" type="coldbox.system.util.baseDictionary" required="true">
		<cfset instance.HandlerCacheDictionary = arguments.HandlerCacheDictionary>
	</cffunction>
	
	<!--- Event Cache Dictionary --->
	<cffunction name="getEventCacheDictionary" access="public" returntype="coldbox.system.util.baseDictionary" output="false">
		<cfreturn instance.EventCacheDictionary>
	</cffunction>
	<cffunction name="setEventCacheDictionary" access="public" returntype="void" output="false">
		<cfargument name="EventCacheDictionary" type="coldbox.system.util.baseDictionary" required="true">
		<cfset instance.EventCacheDictionary = arguments.EventCacheDictionary>
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
			
			return mdEntry;
		</cfscript>
	</cffunction>
	
	<!--- Recursive Registration of Handler Directories --->
	<cffunction name="recurseListing" access="private" output="false" returntype="array" hint="Recursive creation of handlers in a directory.">
		<!--- ************************************************************* --->
		<cfargument name="fileArray" 	type="array"  required="true">
		<cfargument name="Directory" 	type="string" required="true">
		<cfargument name="HandlersPath" type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		var oDirectory = CreateObject("java","java.io.File").init(arguments.Directory);
		var Files = oDirectory.list();
		var i = 1;
		var tempfile = "";
		var cleanHandler = "";

		//Loop Through listing if any files found.
		for (; i lte arrayLen(Files); i=i+1 ){
			//get first reference as File Object
			tempFile = CreateObject("java","java.io.File").init(oDirectory,Files[i]);
			//Directory Check for recursion
			if ( tempFile.isDirectory() ){
				//recurse, directory found.
				arguments.fileArray = recurseListing(arguments.fileArray,tempFile.getPath(), arguments.HandlersPath);
			}
			else{
				//Filter only cfc's
				if ( listlast(tempFile.getName(),".") neq "cfc" )
					continue;
				//Clean entry by using Handler Path
				cleanHandler = replacenocase(tempFile.getAbsolutePath(),arguments.handlersPath,"","all");
				//Clean OS separators
				if ( controller.getSetting("OSFileSeparator",1) eq "/")
					cleanHandler = removeChars(replacenocase(cleanHandler,"/",".","all"),1,1);
				else
					cleanHandler = removeChars(replacenocase(cleanHandler,"\",".","all"),1,1);
				//Clean Extension
				cleanHandler = controller.getPlugin("Utilities").ripExtension(cleanhandler);
				//Add data to array
				ArrayAppend(arguments.fileArray,cleanHandler);
			}
		}
		return arguments.fileArray;
		</cfscript>
	</cffunction>

	
</cfcomponent>