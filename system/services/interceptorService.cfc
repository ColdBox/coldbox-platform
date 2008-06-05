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
<cfcomponent name="interceptorService" output="false" hint="The coldbox interceptor service" extends="baseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="interceptorService" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			/* Setup The Controller. */
			setController(arguments.controller);
			/* Register the interception points ENUM */
			setInterceptionPoints('afterConfigurationLoad,afterAspectsLoad,afterHandlerCreation,afterPluginCreation,sessionStart,sessionEnd,preProcess,preEvent,postEvent,preRender,postRender,postProcess,afterCacheElementInsert,afterCacheElementRemoved');
			/* Init Container */
			setInterceptionStates(structnew());
			
			/* Set public cache key */
			this.INTERCEPTOR_CACHEKEY_PREFIX = "cboxinterceptor_interceptor-";
			
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
				registerInterceptor(interceptorConfig.interceptors[x].class,interceptorConfig.interceptors[x].properties);				
			}//end declared interceptor loop			
		</cfscript>
	</cffunction>

	<!--- Process a State's Interceptors --->
	<cffunction name="processState" access="public" returntype="void" hint="Process an interception state announcement" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="state" 		 required="true" 	type="string" hint="An interception state to process">
		<cfargument name="interceptData" required="false" 	type="struct" default="#structNew()#" hint="A data structure used to pass intercepted information.">
		<!--- ************************************************************* --->
		<cfscript>
			var event = getController().getRequestService().getContext();
			/* Validate incoming state */
			if( getController().getSetting("InterceptorConfig").throwOnInvalidStates and not listfindnocase(getInterceptionPoints(),arguments.state) ){
				getUtil().throwit("The interception state sent in to process is not valid: #arguments.state#","","Framework.InterceptorService.InvalidInterceptionState");
			}
		</cfscript>
				
		<!--- Process The State if it exists, else just exit out. --->
		<cfif structKeyExists(getinterceptionStates(), arguments.state) >
			<cfmodule template="../includes/timer.cfm" timertag="interception [#arguments.state#]" debugmode="#getController().getDebuggerService().getDebugMode()#">
				<cfset structFind( getinterceptionStates(), arguments.state).process(event,arguments.interceptData)>
			</cfmodule>				
		</cfif>
	</cffunction>
	
	<!--- Register an Interceptor --->
	<cffunction name="registerInterceptor" access="public" output="false" returntype="void" hint="Register an interceptor. This method is here for runtime additions. If the interceptor is already in a state, it will not be added again.">
		<!--- ************************************************************* --->
		<cfargument name="interceptorClass" 		required="true" 	type="string" 	hint="The qualified class of the interceptor to register">
		<cfargument name="interceptorProperties" 	required="false" 	type="struct" 	hint="The structure of properties to register this interceptor with.">
		<!--- ************************************************************* --->
		<cfscript>
			var interceptorKey = this.INTERCEPTOR_CACHEKEY_PREFIX & arguments.interceptorClass;
			var oInterceptor = "";
			var interceptionPointsFound = structNew();
			var stateKey = "";
			var interceptData = structnew();
			var autowireInterceptor = this.INTERCEPTOR_CACHEKEY_PREFIX & "coldbox.system.interceptors.autowire";			
		</cfscript>
		
		<!--- Lock this registration --->
		<cflock name="interceptorService.registerInterceptor.#arguments.interceptorClass#" type="exclusive" throwontimeout="true" timeout="30">
			<cfscript>
				/* Create the Interceptor Class */
				oInterceptor = CreateObject("component", arguments.interceptorClass ).init(getController(),interceptorProperties);
				/* Configure the Interceptor */
				oInterceptor.configure();
				
				/* Cache Interceptor */
				if ( not getController().getColdBoxOCM().set(interceptorKey, oInterceptor, 0) ){
					getUtil().throwit("The interceptor could not be cached, either the cache is full, the threshold has been reached or we are out of memory.","Please check your cache limits, try increasing them or verify your server memory","Framework.InterceptorService.InterceptorCantBeCached");
				}
				
				/* Parse Interception Points, thanks to inheritance. */
				interceptionPointsFound = structnew();
				interceptionPointsFound = parseMetadata( getMetaData(oInterceptor), interceptionPointsFound);
				
				/* Register this Interceptor's interception point with its appropriate interceptor state */
				for(stateKey in interceptionPointsFound){
					RegisterInterceptionPoint(interceptorKey,stateKey);
				}
				
				/* TODO: Autowire from plugin */
			
			</cfscript>
		</cflock>
	</cffunction>
	
	<!--- Get Interceptor --->
	<cffunction name="getInterceptor" access="public" output="false" returntype="any" hint="Get an interceptor according to its class name from cache, not from a state. If retrieved, it does not mean that the interceptor is registered still. It just means, that it is in cache.">
		<!--- ************************************************************* --->
		<cfargument name="interceptorClass" required="true" type="string" hint="The qualified class of the interceptor to retrieve">
		<!--- ************************************************************* --->
		<cfscript>
			var interceptorKey = this.INTERCEPTOR_CACHEKEY_PREFIX & arguments.interceptorClass;
			
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
			
			/* Loop and Add */
			for(;x lte listlen(arguments.customPoints); x=x+1 ){
				if ( not listfindnocase(currentList, listgetAt(arguments.customPoints,x)) ){
					currentList = currentList & "," & listgetAt(arguments.customPoints,x);
				}
			}
			/* Save */
			setInterceptionPoints(currentList);			
		</cfscript>
	</cffunction>
	
	<!--- getter setter interceptionPoints --->
	<cffunction name="getinterceptionPoints" access="public" output="false" returntype="string" hint="Get the interceptionPoints ENUM">
		<cfreturn instance.interceptionPoints/>
	</cffunction>
	<cffunction name="setinterceptionPoints" access="public" output="false" returntype="void" hint="Set the interceptionPoints ENUM">
		<cfargument name="interceptionPoints" type="string" required="true"/>
		<cfset instance.interceptionPoints = arguments.interceptionPoints/>
	</cffunction>

	<!--- getter setter interception states --->
	<cffunction name="getinterceptionStates" access="public" output="false" returntype="struct" hint="Get interceptionStates">
		<cfreturn instance.interceptionStates/>
	</cffunction>
	<cffunction name="setinterceptionStates" access="public" output="false" returntype="void" hint="Set interceptionStates">
		<cfargument name="interceptionStates" type="struct" required="true"/>
		<cfset instance.interceptionStates = arguments.interceptionStates/>
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
			var interceptorKey = this.INTERCEPTOR_CACHEKEY_PREFIX & arguments.interceptorClass;
			
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
				 (arguments.metadata.extends.name neq "coldbox.system.interceptor" or
				  arguments.metadata.extends.name neq "coldbox.system.plugin" or
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
			/* Register it */
			oInterceptorState.register(arguments.interceptorKey, getController().getColdBoxOCM().get(arguments.interceptorKey) );			
		</cfscript>
	</cffunction>

	<!--- Create Interception States --->
	<cffunction name="createInterceptionStates" access="private" returntype="void" hint="Create the interception states container" output="false" >
		<cfscript>
			setInterceptionStates(structnew());
		</cfscript>
	</cffunction>

</cfcomponent>