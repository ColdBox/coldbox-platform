<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	A basic event pool manager for observed event pools. This event manager will manage 1 or more event pools.
	The manager will inspect target objects for implemented functions and match them to event states.
	However, if a function has the metadata attribute of 'observe=true' on it, then it will also add it
	as a custom state

----------------------------------------------------------------------->
<cfcomponent output="false" hint="A basic event pool manager for observed event pools. This event manager will manage 1 or more event pools.  The manager will inspect target objects for implemented functions and match them to event states. However, if a function has the metadata attribute of 'observe=true' on it, then it will also add it as a custom state.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="EventPoolManager" hint="Constructor">
		<cfargument name="eventStates" 		    type="array" required="true" hint="The event states to listen for"/>
		<cfargument name="stopRecursionClasses" type="string" required="false" default="" hint="The classes (comma-delim) to not inspect for events"/>
		<cfscript>
			instance = structnew();
			// Setup properties of the event manager
			instance.eventStates 			= arrayToList( arguments.eventStates );
			instance.stopRecursionClasses   = arguments.stopRecursionClasses;
			// class id code
			instance.classID = createObject("java", "java.lang.System").identityHashCode( this );

			// Init event pool container
			instance.eventPoolContainer 	= structnew();

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- processState --->
	<cffunction name="processState" access="public" returntype="void" hint="Process a state announcement. If the state does not exist, it will ignore it" output="true">
		<!--- ************************************************************* --->
		<cfargument name="state" 		 required="true" 	type="string" hint="The state to process">
		<cfargument name="interceptData" required="false" 	type="struct" default="#structNew()#" hint="A data structure used to pass intercepted information.">
		<!--- ************************************************************* --->
		<cfscript>
			var pool = getEventPoolContainer();

			// Process The State if it exists, else just exit out
			if( structKeyExists(pool, arguments.state) ){
				pool[ arguments.state ].process( arguments.interceptData );
			}
		</cfscript>
	</cffunction>

	<!--- register --->
	<cffunction name="register" access="public" output="false" returntype="void" hint="Register an object in an event pool. If the target object is already in a state, it will not be added again. The object get's inspected for registered states or you can even send custom states in.  Also, you can annotate the methods in the target object with 'observe=true' and we will register that state also.">
		<!--- ************************************************************* --->
		<cfargument name="target"		 type="any" 	required="true" hint="The target object to register in an event pool"/>
		<cfargument name="name" 		 type="string"  required="false" default="" hint="The name to use when registering the object.  If not passed, the name will be used from the object's metadata"/>
		<cfargument name="customStates"  type="string"  required="false" default="" hint="A comma delimmited list of custom states, if the object or class sent in observes them.">
		<!--- ************************************************************* --->
		<cfscript>
			var objectName 		 = "";
			var eventStatesFound = structNew();
			var stateKey 		 = "";
			var md				 = getMetadata(arguments.target);

			// Check if name sent? If not, get the name from the last part of its name
			if( NOT len(trim(arguments.name)) ){
				arguments.name = listLast(md.name,".");
			}

			// Set the local name
			objectName = arguments.name;

		</cfscript>

		<!--- Lock this registration --->
		<cflock name="EventPoolManager.#instance.classID#.RegisterObject.#objectName#" type="exclusive" throwontimeout="true" timeout="30">
			<cfscript>
				// Append Custom Statess
				appendInterceptionPoints(arguments.customStates);

				// discover event states by convention
				eventStatesFound = structnew();
				eventStatesFound = parseMetadata( md, eventStatesFound);

				// Register this target's event observation states with its appropriate interceptor/observation state
				for(stateKey in eventStatesFound){
					registerInEventState(objectName,stateKey,arguments.target);
				}
			</cfscript>
		</cflock>
	</cffunction>

	<cffunction name="getObject" access="public" output="false" returntype="any" hint="Get an object from a registered event pool.">
		<!--- ************************************************************* --->
		<cfargument name="name" 	required="false" type="string" hint="The name of the object to search for"/>
		<!--- ************************************************************* --->
		<cfscript>
			var poolContainer = getEventPoolContainer();
			var unregistered = false;
			var key = "";

			for( key in poolContainer ){
				if( structFind(poolContainer,key).exists(arguments.name) ){
					return structFind(poolContainer,key).getObject(arguments.name);
				}
			}

			// Throw Exception
			throw(message="Object: #arguments.name# not found in any event pool state: #structKeyList(poolContainer)#.",
				  type="EventPoolManager.ObjectNotFound");
		</cfscript>
	</cffunction>

	<!--- Append custom states --->
	<cffunction name="appendInterceptionPoints" access="public" returntype="void" hint="Append a list of custom event states to the CORE observation states" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="customStates" required="true" type="string" hint="A comma delimmited list of custom observation states to append. If they already exists, then they will not be added again.">
		<!--- ************************************************************* --->
		<cfscript>
			var x 			= 1;
			var currentList = getEventStates();

			// Validate
			if( len(trim(arguments.customStates)) eq 0){ return; }

			// Loop and Add
			for(;x lte listlen(arguments.customStates); x=x+1 ){
				if ( not listfindnocase(currentList, listgetAt(arguments.customStates,x)) ){
					currentList = listAppend(currentList,listgetAt(arguments.customStates,x));
				}
			}

			// Save New Event States
			instance.eventStates = currentList;
		</cfscript>
	</cffunction>

	<cffunction name="getEventPoolContainer" access="public" output="false" returntype="struct" hint="Get all the registered event pools in the event manager">
		<cfreturn instance.eventPoolContainer >
	</cffunction>

	<cffunction name="getEventStates" access="public" output="false" returntype="string" hint="Get the registered event states in this event manager">
		<cfreturn instance.eventStates >
	</cffunction>

	<cffunction name="getStopRecursionClasses" output="false" access="public" returntype="string" hint="The classes that should stop recursion for observation points">
		<cfreturn instance.stopRecursionClasses>
	</cffunction>

	<cffunction name="getEventPool" access="public" returntype="any" hint="Get an event pool by state name, if not found, it returns an empty structure" output="false" >
		<cfargument name="state" required="true" type="string" hint="The state to retrieve">
		<cfscript>
			var pools = getEventPoolContainer();

			if( structKeyExists(pools,arguments.state) ){
				return pools[arguments.state];
			}

			return structnew();
		</cfscript>
	</cffunction>

	<cffunction name="unregister" access="public" returntype="boolean" hint="Unregister an object form an event pool state. If no event state is passed, then we will unregister the object from ALL the pools the object exists in." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 	required="true" type="string" hint="The name of the object to unregister">
		<cfargument name="state" 	required="true" type="string" default="" hint="The named state to unregister this object from. If not passed, then we will unregister the object from ALL the pools it exists in.">
		<!--- ************************************************************* --->
		<cfscript>
			var poolContainer = getEventPoolContainer();
			var unregistered  = false;
			var key 		  = "";

			// Unregister the object
			for(key in poolContainer){
				if( len(trim(arguments.state)) eq 0 OR trim(arguments.state) eq key ){
					structFind(poolContainer,key).unregister(arguments.name);
					unregistered = true;
				}
			}

			return unregistered;
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="parseMetadata" returntype="struct" access="private" output="false" hint="I get a component's valid observation states for registration.">
		<!--- ************************************************************* --->
		<cfargument name="metadata"		required="true" type="any" 		hint="The recursive metadata">
		<cfargument name="eventsFound" 	required="true" type="struct" 	hint="The event states found in the object">
		<!--- ************************************************************* --->
		<cfscript>
			var x = 1;

			// Register local functions
			if( structKeyExists(arguments.metadata, "functions") ){
				for(x=1; x lte ArrayLen(arguments.metadata.functions); x=x+1 ){

					// Verify observe annotation
					if( structKeyExists(arguments.metadata.functions[x],"interceptionPoint") ){
						// Register the observation point just in case
						appendInterceptionPoints(arguments.metadata.functions[x].name);
					}

					// verify it's an observation state and Not Registered already
					if ( listFindNoCase(getEventStates(),arguments.metadata.functions[x].name) and
						 not structKeyExists(arguments.eventsFound,arguments.metadata.functions[x].name) ){
						// Observation Event Found
						structInsert(arguments.eventsFound,arguments.metadata.functions[x].name,true);
					}
				}
			}

			// Start Registering inheritances?
			if ( structKeyExists(arguments.metadata, "extends") AND
			     NOT listFindNoCase(getStopRecursionClasses(),arguments.metadata.extends.name) ){
				parseMetadata(arguments.metadata.extends,arguments.eventsFound);
			}

			//return the event states found
			return arguments.eventsFound;
		</cfscript>
	</cffunction>

	<cffunction name="registerInEventState" access="private" returntype="void" hint="Register an object with a specified event observation state." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="key" 		required="true" type="string" hint="The key to use when storing the object.">
		<cfargument name="state" 	required="true" type="string" hint="The event state pool to save the object in">
		<cfargument name="target" 	required="true" type="any" 	  hint="The object to register">
		<!--- ************************************************************* --->
		<cfscript>
			var eventPool 		= "";
			var poolContainer 	= getEventPoolContainer();

			// Verify if the event state doesn't exist in the evnet pool, else create it
			if ( not structKeyExists(poolContainer, arguments.state) ){
				// Create new event pool
				eventPool = CreateObject("component","coldbox.system.core.events.EventPool").init(arguments.state);
				// Register it with this pool manager
				structInsert(poolContainer, arguments.state, eventPool );
			}
			else{
				// Get the State we need to register in
				eventPool = poolContainer[arguments.state];
			}

			// Verify if the target object is already in the state
			if( NOT eventPool.exists(arguments.key) ){
				//Register it
				eventPool.register(arguments.key, arguments.target);
			}
		</cfscript>
	</cffunction>

	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util") >
	</cffunction>

</cfcomponent>