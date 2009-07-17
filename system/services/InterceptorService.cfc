<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	The interceptor service for all interception related methods.
----------------------------------------------------------------------->
<cfcomponent name="InterceptorService" output="false" hint="The coldbox interceptor service" extends="coldbox.system.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="InterceptorService" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			/* Setup The Controller. */
			setController(arguments.controller);
			/* Register the interception points ENUM */
			instance.InterceptionPoints = 'afterConfigurationLoad,afterAspectsLoad,afterHandlerCreation,afterPluginCreation,sessionStart,sessionEnd,preProcess,preEvent,postEvent,preRender,postRender,postProcess,afterCacheElementInsert,afterCacheElementRemoved,onException,afterCacheElementExpired';
			/* Init Container */
			instance.interceptionStates = structnew();
			/* Init the Request Buffer */
			instance.requestBuffer = CreateObject("component","coldbox.system.util.RequestBuffer").init();
			/* Return Service */			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Register All the interceptors --->
	<cffunction name="registerInterceptors" access="public" returntype="void" hint="Register all the interceptors according to configuration. All interception states are lazy loaded in." output="false" >
		<cfscript>
			var interceptorConfig = getController().getSetting("InterceptorConfig");
			var x = 1;
			
			/* Create a spanking new Interception States Container */
			createInterceptionStates();
			
			/* Check if we have custom interception points, and register them if we do */
			if( len(interceptorConfig.CustomInterceptionPoints) neq 0 ){
				appendInterceptionPoints( interceptorConfig.CustomInterceptionPoints);
			}
			
			/* Loop over the Interceptor Array, to begin registration */
			for (; x lte arrayLen(interceptorConfig.interceptors); x=x+1){
				/* register this interceptor */
				registerInterceptor(interceptorClass=interceptorConfig.interceptors[x].class,interceptorProperties=interceptorConfig.interceptors[x].properties);				
			}//end declared interceptor loop			
		</cfscript>
	</cffunction>

	<!--- Process a State's Interceptors --->
	<cffunction name="processState" access="public" returntype="void" hint="Process an interception state announcement" output="true">
		<!--- ************************************************************* --->
		<cfargument name="state" 		 required="true" 	type="string" hint="An interception state to process">
		<cfargument name="interceptData" required="false" 	type="struct" default="#structNew()#" hint="A data structure used to pass intercepted information.">
		<!--- ************************************************************* --->
		<cfset var timerHash = 0><cfsetting enablecfoutputonly="true"><cfsilent>
		<cfscript>
		/* Is ColdBox Inited and ready to serve requests? */
		if ( not controller.getColdboxInitiated() ){ 
			return;
		}
		
		/* Validate Incoming State */
		if ( controller.getSetting("InterceptorConfig").throwOnInvalidStates AND NOT listfindnocase(getInterceptionPoints(),arguments.state) ){
			getUtil().throwit("The interception state sent in to process is not valid: #arguments.state#","","Framework.InterceptorService.InvalidInterceptionState");
		}
		
		/* Process The State if it exists, else just exit out */
		if( structKeyExists(getinterceptionStates(), arguments.state) ){
			/* Execute Interception */
			timerHash = controller.getDebuggerService().timerStart("interception [#arguments.state#]");
				structFind( getinterceptionStates(), arguments.state).process(controller.getRequestService().getContext(),arguments.interceptData);
			controller.getDebuggerService().timerEnd(timerHash);
		}
		
		/* Process Output Buffer: looks weird, but we are outputting stuff */
		</cfscript>
		</cfsilent><cfif getRequestBuffer().isBufferInScope()><cfset writeOutput(getRequestBuffer().getString())><cfset getRequestBuffer().clear()></cfif><cfsetting enablecfoutputonly="false">
	</cffunction>
	
	<!--- Register an Interceptor --->
	<cffunction name="registerInterceptor" access="public" output="false" returntype="void" hint="Register an interceptor. This method is here for runtime additions. If the interceptor is already in a state, it will not be added again. You can register an interceptor by class or with an already instantiated and configured object.">
		<!--- ************************************************************* --->
		<cfargument name="interceptorClass" 		required="false" 	type="string" 	hint="Mutex with interceptorObject, this is the qualified class of the interceptor to register">
		<cfargument name="interceptorObject" 		required="false" 	type="any" 		hint="Mutex with interceptor Class, this is used to register an already instantiated object as an interceptor">
		<cfargument name="interceptorProperties" 	required="false" 	type="struct"	default="#structNew()#" 	hint="The structure of properties to register this interceptor with.">
		<cfargument name="customPoints" 			required="false" 	type="string" 	default="" hint="A comma delimmited list of custom interception points, if the object or class sent in observes them.">
		<!--- ************************************************************* --->
		<cfscript>
			var interceptorKey = '';
			var oInterceptor = "";
			var interceptorName = "";
			var interceptionPointsFound = structNew();
			var stateKey = "";
			var interceptData = structnew();			
		</cfscript>
		
		<!--- Determine Registration Name and set local interception object if sent --->
		<cfif structKeyExists(arguments,"interceptorClass") >
			<cfset interceptorName = arguments.interceptorClass>
		<cfelseif structKeyExists(arguments,"interceptorObject")>
			<cfset interceptorName = getMetaData(arguments.interceptorObject).name>
			<cfset interceptorKey = getColdboxOCM().INTERCEPTOR_CACHEKEY_PREFIX & interceptorName>
			<cfset oInterceptor = arguments.interceptorObject>			
		<cfelse>
			<cfthrow message="Invalid registration" detail="You did not send in an interceptorClass or interceptorObject for registration" type="Framework.InterceptorService.InvalidRegistration">
		</cfif>
		
		<!--- Lock this registration --->
		<cflock name="interceptorService.registerInterceptor.#interceptorName#" type="exclusive" throwontimeout="true" timeout="30">
			<cfscript>
				/* Did we send in a class to instantiate */
				if( structKeyExists(arguments,"interceptorClass") ){
					/* Cache Key */
					interceptorKey = getColdboxOCM().INTERCEPTOR_CACHEKEY_PREFIX & arguments.interceptorClass;
					/* Create the Interceptor Class */
					try{
						oInterceptor = CreateObject("component", arguments.interceptorClass ).init(getController(),interceptorProperties);
					}
					catch(Any e){
						getUtil().rethrowit(e);
					}
					/* Configure the Interceptor */
					oInterceptor.configure();
					/* Cache Interceptor */
					if ( not getController().getColdBoxOCM().set(interceptorKey, oInterceptor, 0) ){
						getUtil().throwit("The interceptor could not be cached, either the cache is full, the threshold has been reached or we are out of memory.","Please check your cache limits, try increasing them or verify your server memory","Framework.InterceptorService.InterceptorCantBeCached");
					}
				}//end if class is sent.
				
				/* Append Custom Poings */
				appendInterceptionPoints(arguments.customPoints);
				
				/* Parse Interception Points, thanks to inheritance. */
				interceptionPointsFound = structnew();
				interceptionPointsFound = parseMetadata( getMetaData(oInterceptor), interceptionPointsFound);
				
				/* Register this Interceptor's interception point with its appropriate interceptor state */
				for(stateKey in interceptionPointsFound){
					RegisterInterceptionPoint(interceptorKey,stateKey,oInterceptor);
				}
				
				/* Autowire this interceptor only if called after aspect registration */
				if( getController().getAspectsInitiated() ){
					getController().getPlugin("beanFactory").autowire(target=oInterceptor,annotationCheck=true);
				}			
			</cfscript>
		</cflock>
	</cffunction>
	
	<!--- Get Interceptor --->
	<cffunction name="getInterceptor" access="public" output="false" returntype="any" hint="Get an interceptor according to its class name from cache, not from a state. If retrieved, it does not mean that the interceptor is registered still. It just means, that it is in cache.">
		<!--- ************************************************************* --->
		<cfargument name="interceptorClass" required="true" type="string" hint="The qualified class of the interceptor to retrieve">
		<!--- ************************************************************* --->
		<cfscript>
			var interceptorKey = getColdboxOCM().INTERCEPTOR_CACHEKEY_PREFIX & arguments.interceptorClass;
			
			/* Verify it exists else throw error */
			if( not getController().getColdboxOCM().lookup(interceptorKey) ){
				getUtil().throwit(message="Interceptor class: #arguments.interceptorClass# not found in cache.",
					  			  type="Framework.InterceptorService.InvalidInterceptionClass");
			}
			else{
				return getController().getColdboxOCM().get(interceptorKey);
			}
		</cfscript>
	</cffunction>
	
	<!--- Append Interception Points --->
	<cffunction name="appendInterceptionPoints" access="public" returntype="void" hint="Append a list of custom interception points to the CORE interception points" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="customPoints" required="true" type="string" hint="A comma delimmited list of custom interception points to append. If they already exists, then they will not be added again.">
		<!--- ************************************************************* --->
		<cfscript>
			var x = 1;
			var currentList = getInterceptionPoints();
			
			/* Validate customPoints */
			if( len(trim(arguments.customPoints)) eq 0){ return; }
			
			/* Loop and Add */
			for(;x lte listlen(arguments.customPoints); x=x+1 ){
				if ( not listfindnocase(currentList, listgetAt(arguments.customPoints,x)) ){
					currentList = currentList & "," & listgetAt(arguments.customPoints,x);
				}
			}
			/* Save New Interception Points */
			instance.InterceptionPoints = currentList;			
		</cfscript>
	</cffunction>
	
	<!--- getter interceptionPoints --->
	<cffunction name="getinterceptionPoints" access="public" output="false" returntype="string" hint="Get the interceptionPoints ENUM">
		<cfreturn instance.interceptionPoints/>
	</cffunction>

	<!--- getter interception states --->
	<cffunction name="getinterceptionStates" access="public" output="false" returntype="struct" hint="Get interceptionStates">
		<cfreturn instance.interceptionStates/>
	</cffunction>
	
	<cffunction name="getRequestBuffer" access="public" returntype="any" output="false" hint="Get a coldbox request buffer: coldbox.system.util.RequestBuffer">
		<cfreturn instance.RequestBuffer>
	</cffunction>
	
	<!--- Get State Container --->
	<cffunction name="getStateContainer" access="public" returntype="any" hint="Get a State Container, it will return a blank structure if the state is not found." output="false" >
		<cfargument name="state" required="true" type="string" hint="The state to retrieve">
		<cfscript>
			var states = getInterceptionStates();
			
			if( structKeyExists(states,arguments.state) ){
				return states[arguments.state];
			}
			else{
				return structnew();
			}
		</cfscript>
	</cffunction>
	
	<!--- Unregister From a State --->
	<cffunction name="unregister" access="public" returntype="boolean" hint="Unregister an interceptor from an interception state. If the state does not exists, it returns false" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptorClass" 	required="true" type="string" hint="The qualified class of the interceptor to unregister">
		<cfargument name="state" 				required="true" type="string" hint="The named state to unregister this interceptor from">
		<!--- ************************************************************* --->
		<cfscript>
			/* Verify the state */
			var foundState = getStateContainer(arguments.state);
			var interceptorKey = getColdboxOCM().INTERCEPTOR_CACHEKEY_PREFIX & arguments.interceptorClass;
			
			/* State Exists */
			if( isObject(foundState) ){
				foundState.unregister(interceptorKey);
				return true;
			}	
			else{
				return false;
			}						
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Get an interceptors interception points via metadata --->
	<cffunction name="parseMetadata" returntype="struct" access="private" output="false" hint="I get a components valid interception points">
		<!--- ************************************************************* --->
		<cfargument name="metadata" required="true" type="any" 		hint="The recursive metadata">
		<cfargument name="points" 	required="true" type="struct" 	hint="The active points">
		<!--- ************************************************************* --->
		<cfscript>
			var x = 1;
			var pointsFound = arguments.points;
			
			/* Register local functions */		
			if( structKeyExists(arguments.metadata, "functions") ){
				for(x=1; x lte ArrayLen(arguments.metadata.functions); x=x+1 ){
					/* verify its a plugin point */
					if ( listfindnocase(getinterceptionPoints(),arguments.metadata.functions[x].name) and 
						 not structKeyExists(pointsFound,arguments.metadata.functions[x].name) ){
						/* Insert to md struct */
						structInsert(pointsFound,arguments.metadata.functions[x].name,true);			
					}
				}
			}
			
			/* Start Registering inheritances */
			if ( structKeyExists(arguments.metadata, "extends") and 
				 (arguments.metadata.extends.name neq "coldbox.system.interceptor" and
				  arguments.metadata.extends.name neq "coldbox.system.plugin" and
				  arguments.metadata.extends.name neq "coldbox.system.eventhandler" )
			){
				/* Recursive lookup */
				parseMetadata(arguments.metadata.extends,pointsFound);
			}
			//return the interception points found
			return pointsFound;
		</cfscript>	
	</cffunction>
	
	<!--- Register an Interception Point --->
	<cffunction name="RegisterInterceptionPoint" access="private" returntype="void" hint="Register an Interception point into a new or created interception state." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptorKey" 	required="true" type="string" hint="The interceptor key in the cache.">
		<cfargument name="state" 			required="true" type="string" hint="The state to create">
		<cfargument name="oInterceptor" 	required="true" type="any" 	  hint="The interceptor to register">
		<!--- ************************************************************* --->
		<cfscript>
			var oInterceptorState = "";
			
			/* Verify if state doesn't exist, create it */
			if ( not structKeyExists(getInterceptionStates(), arguments.state) ){
				oInterceptorState = CreateObject("component","coldbox.system.beans.interceptorState").init(arguments.state);
				structInsert(getInterceptionStates(), arguments.state, oInterceptorState );
			}
			else{
				/* Get the State we need to register in */
				oInterceptorState = structFind( getInterceptionStates(), arguments.state );
			}
			
			/* Verify if the interceptor is already in the state */
			if( NOT oInterceptorState.exists(arguments.interceptorKey) ){
				/* Register it */
				oInterceptorState.register(arguments.interceptorKey, arguments.oInterceptor );	
			}	
		</cfscript>
	</cffunction>

	<!--- Create Interception States --->
	<cffunction name="createInterceptionStates" access="private" returntype="void" hint="Create the interception states container" output="false" >
		<cfscript>
			instance.interceptionStates = structnew();
		</cfscript>
	</cffunction>

</cfcomponent>