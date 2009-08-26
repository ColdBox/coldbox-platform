<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	This is a basic event manager for executing interception points or announcement points.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="A basic event manager for interception or announcement points. This event manager will manage 1 or more event pools.  The manager will inspect target objects for implemented functions and match them to event states. However, if a function has the metadata attribute of 'observe=true' on it, then it will also add it as a custom state.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="EventManager" hint="Constructor">
		<cfargument name="eventStates" type="string" required="true" default="" hint="The event states to listen for"/>
		<cfargument name="stopRecursionClasses" type="string" required="true" default="" hint="The classes (comma-delim) to not inspect for events"/>
		<cfscript>
			// Setup properties of the event manager
			instance.eventStates = arguments.eventStates;
			instance.stopRecursion = arguments.stopRecursionClasses;
			
			// Init event pool containers
			instance.eventPools = structnew();
			
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="processState" access="public" returntype="void" hint="Process a state announcement" output="true">
		<!--- ************************************************************* --->
		<cfargument name="state" 		 required="true" 	type="string" hint="The state to process">
		<cfargument name="interceptData" required="false" 	type="struct" default="#structNew()#" hint="A data structure used to pass intercepted information.">
		<!--- ************************************************************* --->
		<cfscript>
			var states = getEventStates();
			
			// Process The State if it exists, else just exit out
			if( structKeyExists(states, arguments.state) ){
				structFind(states, arguments.state).process(arguments.interceptData);
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="register" access="public" output="false" returntype="void" hint="Register an object in an event pool. If the target object is already in a state, it will not be added again.">
		<!--- ************************************************************* --->
		<cfargument name="target"		 type="any" required="true" default="" hint="The target object to register in an event pool"/>
		<cfargument name="name" 		 type="string" required="false" default="" hint="The name to use when registering the object.  If not passed, the name will be used from the object's metadata"/>
		<cfargument name="customStates"  type="string" required="false" default="" hint="A comma delimmited list of custom states, if the object or class sent in observes them.">
		<!--- ************************************************************* --->
		<cfscript>
			var oInterceptor = "";
			var objectName = "";
			var objectKey = '';
			var interceptionPointsFound = structNew();
			var stateKey = "";
			var interceptData = structnew();			
		</cfscript>
		
		<!--- Determine Registration Name and set local interception object if sent --->
		<cfif structKeyExists(arguments,"interceptorClass") >
			<cfset objectName = listLast(arguments.interceptorClass,".")>
			<cfif structKeyExists(arguments,"interceptorName")>
				<cfset objectName = arguments.interceptorName>
			</cfif>
			<cfset objectKey = getColdboxOCM().INTERCEPTOR_CACHEKEY_PREFIX & objectName>
		<cfelseif structKeyExists(arguments,"interceptorObject")>
			<cfset objectName = listLast(getMetaData(arguments.interceptorObject).name,".")>
			<cfif structKeyExists(arguments,"interceptorName")>
				<cfset objectName = arguments.interceptorName>
			</cfif>			
			<cfset objectKey = getColdboxOCM().INTERCEPTOR_CACHEKEY_PREFIX & interceptorName>
			<cfset oInterceptor = arguments.interceptorObject>			
		<cfelse>
			<cfthrow message="Invalid registration" detail="You did not send in an interceptorClass or interceptorObject for registration" type="Framework.InterceptorService.InvalidRegistration">
		</cfif>
		
		<!--- Lock this registration --->
		<cflock name="interceptorService.registerInterceptor.#objectName#" type="exclusive" throwontimeout="true" timeout="30">
			<cfscript>
				// Did we send in a class to instantiate
				if( structKeyExists(arguments,"interceptorClass") ){
					// Create the Interceptor Class
					try{
						oInterceptor = createObject("component", arguments.interceptorClass ).init(controller,interceptorProperties);
					}
					catch(Any e){
						getUtil().rethrowit(e);
					}
					// Configure the Interceptor
					oInterceptor.configure();
					// Cache The Interceptor for quick references
					if ( NOT controller.getColdBoxOCM().set(objectKey, oInterceptor, 0) ){
						getUtil().throwit("The interceptor could not be cached, either the cache is full, the threshold has been reached or we are out of memory.","Please check your cache limits, try increasing them or verify your server memory","InterceptorService.InterceptorCantBeCached");
					}
				}//end if class is sent.
				
				// Append Custom Poings
				appendInterceptionPoints(arguments.customPoints);
				
				// Parse Interception Points, thanks to inheritance.
				interceptionPointsFound = structnew();
				interceptionPointsFound = parseMetadata( getMetaData(oInterceptor), interceptionPointsFound);
				
				// Register this Interceptor's interception point with its appropriate interceptor state
				for(stateKey in interceptionPointsFound){
					registerInterceptionPoint(objectKey,stateKey,oInterceptor);
				}
				
				// Autowire this interceptor only if called after aspect registration
				if( controller.getAspectsInitiated() ){
					controller.getPlugin("BeanFactory").autowire(target=oInterceptor);
				}			
			</cfscript>
		</cflock>
	</cffunction>
	
	<cffunction name="getObject" access="public" output="false" returntype="any" hint="Get an object from a registered event pool.">
		<!--- ************************************************************* --->
		<cfargument name="name" 	required="false" type="string" hint="The name of the object to search for"/>
		<!--- ************************************************************* --->
		<cfscript>
			var interceptorKey = getColdboxOCM().INTERCEPTOR_CACHEKEY_PREFIX & arguments.interceptorName;
			var states = getEventStates();
			var state = "";
			var key = "";
			
			for( key in states ){
				state = states[key];
				if( state.exists(interceptorKey) ){ return state.getInterceptor(interceptorKey); }
			}
			// Throw Exception
			getUtil().throwit(message="Interceptor: #arguments.interceptorName# not found in any state: #structKeyList(states)#.",
				  			  type="InterceptorService.InterceptorNotFound");
			
			// ELSE Cache Lookup
			// Verify it exists else throw error
			if( not controller.getColdboxOCM().lookup(interceptorKey) ){
				getUtil().throwit(message="Interceptor: #arguments.interceptorName# not found in cache.",
					  			  type="InterceptorService.InterceptorNotFound");
			}
			
			return controller.getColdboxOCM().get(interceptorKey);
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
			
			// Validate customPoints
			if( len(trim(arguments.customPoints)) eq 0){ return; }
			
			// Loop and Add
			for(;x lte listlen(arguments.customPoints); x=x+1 ){
				if ( not listfindnocase(currentList, listgetAt(arguments.customPoints,x)) ){
					currentList = currentList & "," & listgetAt(arguments.customPoints,x);
				}
			}
			// Save New Interception Points
			instance.InterceptionPoints = currentList;			
		</cfscript>
	</cffunction>
	
	<cffunction name="getEventPools" access="public" output="false" returntype="string" hint="Get all the registered event pools in the event manager">
		<cfreturn instance.eventPools >
	</cffunction>

	<cffunction name="getEventStates" access="public" output="false" returntype="struct" hint="Get the registered event states in this event manager">
		<cfreturn instance.eventStates >
	</cffunction>
	
	<cffunction name="getEventPool" access="public" returntype="any" hint="Get an event pool by state name, if not found, it returns an empty structure" output="false" >
		<cfargument name="state" required="true" type="string" hint="The state to retrieve">
		<cfscript>
			var states = getEventStates();
			
			if( structKeyExists(states,arguments.state) ){
				return states[arguments.state];
			}
			else{
				return structnew();
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="unregister" access="public" returntype="boolean" hint="Unregister an object form an event pool state. If the state does not exists, it returns false" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 	required="true" type="string" hint="The name of the object to unregister">
		<cfargument name="state" 	required="true" type="string" hint="The named state to unregister this interceptor from">
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
			
			// Register local functions		
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
			
			// Start Registering inheritances
			if ( structKeyExists(arguments.metadata, "extends") and 
				 (arguments.metadata.extends.name neq "coldbox.system.Interceptor" and
				  arguments.metadata.extends.name neq "coldbox.system.Plugin" and
				  arguments.metadata.extends.name neq "coldbox.system.EventHandler" )
			){
				// Recursive lookup
				parseMetadata(arguments.metadata.extends,pointsFound);
			}
			//return the interception points found
			return pointsFound;
		</cfscript>	
	</cffunction>
	
	<!--- Register an Interception Point --->
	<cffunction name="registerInterceptionPoint" access="private" returntype="void" hint="Register an Interception point into a new or created interception state." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptorKey" 	required="true" type="string" hint="The interceptor key in the cache.">
		<cfargument name="state" 			required="true" type="string" hint="The state to create">
		<cfargument name="oInterceptor" 	required="true" type="any" 	  hint="The interceptor to register">
		<!--- ************************************************************* --->
		<cfscript>
			var oInterceptorState = "";
			
			// Verify if state doesn't exist, create it
			if ( not structKeyExists(getInterceptionStates(), arguments.state) ){
				oInterceptorState = CreateObject("component","coldbox.system.beans.InterceptorState").init(arguments.state);
				structInsert(getInterceptionStates(), arguments.state, oInterceptorState );
			}
			else{
				// Get the State we need to register in
				oInterceptorState = structFind( getInterceptionStates(), arguments.state );
			}
			
			// Verify if the interceptor is already in the state
			if( NOT oInterceptorState.exists(arguments.interceptorKey) ){
				//Register it
				oInterceptorState.register(arguments.interceptorKey, arguments.oInterceptor );	
			}	
		</cfscript>
	</cffunction>


</cfcomponent>