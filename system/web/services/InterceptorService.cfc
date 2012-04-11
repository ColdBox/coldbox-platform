<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	The interceptor service for all interception related methods.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="The coldbox interceptor service" extends="coldbox.system.web.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="InterceptorService" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			// Register Controller
			setController( arguments.controller );

			// Register the interception points ENUM
			instance.interceptionPoints = [
				// Application startup points
				"afterConfigurationLoad", "afterAspectsLoad", "preReinit",
				// On Actions
				"onException", "onRequestCapture", "onInvalidEvent",
				// After FW Object Creations
				"afterHandlerCreation", "afterInstanceCreation", "afterPluginCreation",
				// Life-cycle
				"applicationEnd" , "sessionStart", "sessionEnd", "preProcess", "preEvent", "postEvent", "postProcess", "preProxyResults",
				// Layout-View Events
				"preLayout", "preRender", "postRender", "preViewRender", "postViewRender", "preLayoutRender", "postLayoutRender",
				// Module Events
				"preModuleLoad", "postModuleLoad", "preModuleUnload", "postModuleUnload",
				// Debugger
				"beforeDebuggerPanel", "afterDebuggerPanel",
				// ORM Bridge Events
				"ORMPostNew", "ORMPreLoad", "ORMPostLoad", "ORMPostDelete", "ORMPreDelete", "ORMPreUpdate", "ORMPostUpdate", "ORMPreInsert", "ORMPostInsert", "ORMPreSave", "ORMPostSave" ];

			// Init Container of interception statues
			instance.interceptionStates = {};
			// Init the Request Buffer
			instance.requestBuffer = CreateObject("component","coldbox.system.core.util.RequestBuffer").init();
			// Default Logging
			instance.log = controller.getLogBox().getLogger( this );
    		// Setup Default Configuration
    		instance.interceptorConfig = {};

			// Interceptor base class
			instance.INTERCEPTOR_BASE_CLASS = "coldbox.system.Interceptor";

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERNAL COLDBOX EVENTS ------------------------------------------->

	<!--- onConfigurationLoad --->
    <cffunction name="onConfigurationLoad" output="false" access="public" returntype="void" hint="Called by loader service when configuration file loads">
    	<cfscript>
			// Reconfigure Logging
    		instance.log = controller.getLogBox().getLogger( this );
    		// Setup Configuration
    		instance.interceptorConfig = controller.getSetting("InterceptorConfig");
			// Register CFC Configuration Object
			registerInterceptor(interceptorObject=controller.getSetting('coldboxConfig'),interceptorName="coldboxConfig");
			// Register The Interceptors
			registerInterceptors();
    	</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Register All the interceptors --->
	<cffunction name="registerInterceptors" access="public" returntype="any" hint="Register all the interceptors according to configuration. All interception states are lazy loaded in." output="false" >
		<cfscript>
			var x = 1;

			// if simple, inflate
			if( isSimpleValue( instance.interceptorConfig.customInterceptionPoints ) ){
				instance.interceptorConfig.customInterceptionPoints = listToArray( instance.interceptorConfig.customInterceptionPoints );
			}

			// Check if we have custom interception points, and register them if we do
			if( arrayLen( instance.interceptorConfig.customInterceptionPoints ) ){
				appendInterceptionPoints( instance.interceptorConfig.customInterceptionPoints );

				if( instance.log.canDebug() ){
					instance.log.debug("Registering custom interception points: #instance.interceptorConfig.customInterceptionPoints.toString()#");
				}
			}

			// Loop over the Interceptor Array, to begin registration
			for (; x lte arrayLen(instance.interceptorConfig.interceptors); x=x+1){
				registerInterceptor(interceptorClass=instance.interceptorConfig.interceptors[x].class,
									interceptorProperties=instance.interceptorConfig.interceptors[x].properties,
									interceptorName=instance.interceptorConfig.interceptors[x].name);
			}

			return this;
		</cfscript>
	</cffunction>

	<!--- Process a State's Interceptors --->
	<cffunction name="processState" access="public" returntype="any" hint="Process an interception state announcement" output="true">
		<!--- ************************************************************* --->
		<cfargument name="state" 		 required="true" 	type="any" hint="An interception state to process">
		<cfargument name="interceptData" required="false" 	type="any" default="#structNew()#" hint="A data structure used to pass intercepted information.">
		<!--- ************************************************************* --->
		<cfset var timerHash = 0><cfsilent>
		<cfscript>
		// Is ColdBox Inited and ready to serve requests?
		if ( NOT controller.getColdboxInitiated() ){
			return this;
		}

		// Validate Incoming State
		if ( instance.interceptorConfig.throwOnInvalidStates AND NOT listFindNoCase(arrayToList( instance.interceptionPoints ), arguments.state)){
			getUtil().throwit("The interception state sent in to process is not valid: #arguments.state#","Valid states are #instance.interceptionPoints.toString()#","InterceptorService.InvalidInterceptionState");
		}

		// Process The State if it exists, else just exit out
		if( structKeyExists(instance.interceptionStates, arguments.state) ){
			// Execute Interception
			structFind( instance.interceptionStates, arguments.state).process(controller.getRequestService().getContext(),arguments.interceptData);
		}

		// Process Output Buffer: looks weird, but we are outputting stuff
		</cfscript>
		</cfsilent><!---
		---><cfif instance.requestBuffer.isBufferInScope()><!---
			---><cfset writeOutput(instance.requestBuffer.getString())><!---
			---><cfset instance.requestBuffer.clear()><!---
		---></cfif>
	</cffunction>

	<!--- Register an Interceptor --->
	<cffunction name="registerInterceptor" access="public" output="false" returntype="any" hint="Register an interceptor. This method is here for runtime additions. If the interceptor is already in a state, it will not be added again. You can register an interceptor by class or with an already instantiated and configured object.">
		<!--- ************************************************************* --->
		<cfargument name="interceptorClass" 		required="false" 	type="any" 		hint="Mutex with interceptorObject, this is the qualified class of the interceptor to register">
		<cfargument name="interceptorObject" 		required="false" 	type="any" 		hint="Mutex with interceptor Class, this is used to register an already instantiated object as an interceptor">
		<cfargument name="interceptorProperties" 	required="false" 	type="any"		default="#structNew()#" 	hint="The structure of properties to register this interceptor with." colddoc:generic="struct">
		<cfargument name="customPoints" 			required="false" 	type="any" 		default="" hint="A comma delimmited list or array of custom interception points, if the object or class sent in observes them.">
		<cfargument name="interceptorName" 			required="false"    type="any"   	hint="The name to use for the interceptor when stored. If not used, we will use the name found in the object's class"/>
		<!--- ************************************************************* --->
		<cfscript>
			var oInterceptor = "";
			var objectName = "";
			var interceptionPointsFound = structNew();
			var stateKey = "";
			var interceptData = structnew();

			// determine registration names
			if( structKeyExists(arguments,"interceptorClass") ){
				objectName = listLast(arguments.interceptorClass,".");
				if( structKeyExists(arguments,"interceptorName") ){
					objectName = arguments.interceptorName;
				}
			}
			else if ( structKeyExists(arguments,"interceptorObject") ){
				objectName = listLast( getMetaData(arguments.interceptorObject).name, ".");
				if( structKeyExists(arguments,"interceptorName") ){
					objectName = arguments.interceptorName;
				}
				oInterceptor = arguments.interceptorObject;
			}
			else{
				getUtil().throwit(message="Invalid registration.",
								  detail="You did not send in an interceptorClass or interceptorObject for registration",
					  			  type="InterceptorService.InvalidRegistration");
			}
		</cfscript>

		<!--- Lock this registration --->
		<cflock name="interceptorService.registerInterceptor.#objectName#" type="exclusive" throwontimeout="true" timeout="30">
			<cfscript>
				// Did we send in a class to instantiate
				if( structKeyExists(arguments,"interceptorClass") ){
					// Create the Interceptor Class
					try{
						oInterceptor = createInterceptor(interceptorClass,objectName,interceptorProperties);
					}
					catch(Any e){
						instance.log.error("Error creating interceptor: #arguments.interceptorClass#. #e.detail# #e.message# #e.stackTrace#",e.tagContext);
						getUtil().rethrowit(e);
					}

					// Configure the Interceptor
					oInterceptor.configure();

				}//end if class is sent.

				// Append Custom Points
				appendInterceptionPoints( arguments.customPoints );

				// Parse Interception Points
				interceptionPointsFound = structnew();
				interceptionPointsFound = parseMetadata( getMetaData(oInterceptor), interceptionPointsFound);

				// Register this Interceptor's interception point with its appropriate interceptor state
				for(stateKey in interceptionPointsFound){
					registerInterceptionPoint(objectName,stateKey,oInterceptor);
					if( instance.log.canDebug() ){
						instance.log.debug("Registering #objectName# on '#statekey#' interception point ");
					}
				}
			</cfscript>
		</cflock>

		<cfreturn this>
	</cffunction>

	<!--- createInterceptor --->
    <cffunction name="createInterceptor" output="false" access="private" returntype="any" hint="Create an interceptor object">
    	<cfargument name="interceptorClass" 		required="true" hint="The class path to instantiate"/>
		<cfargument name="interceptorName" 	 		required="true" hint="The unique name of the interceptor"/>
		<cfargument name="interceptorProperties" 	required="false" default="#structnew()#" hint="The properties" colddoc:generic="struct"/>
		<cfscript>
			var oInterceptor = "";

			// Check if interceptor mapped?
			if( NOT controller.getWireBox().getBinder().mappingExists( "interceptor-" & interceptorName ) ){
				// wirebox lazy load checks
				wireboxSetup();
				// feed this interceptor to wirebox with virtual inheritance just in case, use registerNewInstance so its thread safe
				controller.getWireBox().registerNewInstance(name="interceptor-" & interceptorName,instancePath=interceptorClass)
					.asSingleton().virtualInheritance("coldbox.system.Interceptor").initWith(controller=controller,properties=interceptorProperties);
			}
			// retrieve, build and wire from wirebox
			oInterceptor = controller.getWireBox().getInstance( "interceptor-" & interceptorName );
			// check for virtual $super, if it does, pass new properties
			if( structKeyExists(oInterceptor,"$super") ){
				oInterceptor.$super.setProperties(interceptorProperties);
			}

			return oInterceptor;
		</cfscript>
    </cffunction>

	<!--- Get Interceptor --->
	<cffunction name="getInterceptor" access="public" output="false" returntype="any" hint="Get an interceptor according to its name from a state. If retrieved, it does not mean that the interceptor is registered still. Use the deepSearch argument if you want to check all the interception states for the interceptor.">
		<!--- ************************************************************* --->
		<cfargument name="interceptorName" 	required="false" type="string" hint="The name of the interceptor to search for"/>
		<!--- ************************************************************* --->
		<cfscript>
			var interceptorKey 	= arguments.interceptorName;
			var states 			= instance.interceptionStates;
			var state 			= "";
			var key 			= "";

			for( key in states ){
				state = states[key];
				if( state.exists( interceptorKey ) ){ return state.getInterceptor( interceptorKey ); }
			}

			// Throw Exception
			getUtil().throwit(message="Interceptor: #arguments.interceptorName# not found in any state: #structKeyList(states)#.",
				  			  type="InterceptorService.InterceptorNotFound");

		</cfscript>
	</cffunction>

	<!--- Append Interception Points --->
	<cffunction name="appendInterceptionPoints" access="public" returntype="any" hint="Append a list of custom interception points to the CORE interception points and returns itself" output="false" >
		<cfargument name="customPoints" required="true" type="any" hint="A comma delimmited list or array of custom interception points to append. If they already exists, then they will not be added again.">
		<cfscript>
			var x 			= 1;
			var currentList = arrayToList( instance.interceptionPoints );

			// Inflate custom points
			if( isSimpleValue( arguments.customPoints ) ){
				arguments.customPoints = listToArray( arguments.customPoints );
			}

			// Validate customPoints or just return yourself
			if( arrayLen( arguments.customPoints ) EQ 0 ){ return this; }

			// Loop and Add custom points
			for(; x LTE arrayLen(arguments.customPoints); x++ ){
				// add only if not found
				if ( NOT listfindnocase( currentList, arguments.customPoints[x] ) ){
					// Add to both lists
					currentList = listAppend(currentList, arguments.customPoints[x] );
					arrayAppend( instance.interceptionPoints, arguments.customPoints[x] );
				}
			}

			return instance.interceptionPoints;
		</cfscript>
	</cffunction>

	<!--- getter interceptionPoints --->
	<cffunction name="getInterceptionPoints" access="public" output="false" returntype="any" hint="Get the interceptionPoints ENUM of all registered points of execution as an array" colddoc:generic="array">
		<cfreturn instance.interceptionPoints/>
	</cffunction>

	<!--- getter interception states --->
	<cffunction name="getInterceptionStates" access="public" output="false" returntype="any" hint="Get all the interception states defined in this service" colddoc:generic="struct">
		<cfreturn instance.interceptionStates/>
	</cffunction>

	<!--- getter request buffer --->
	<cffunction name="getRequestBuffer" access="public" returntype="any" output="false" hint="Get a coldbox request buffer: coldbox.system.core.util.RequestBuffer">
		<cfreturn instance.RequestBuffer>
	</cffunction>

	<!--- Get State Container --->
	<cffunction name="getStateContainer" access="public" returntype="any" hint="Get a State Container, it will return a blank structure if the state is not found." output="false" >
		<cfargument name="state" required="true" hint="The state name to retrieve">
		<cfscript>
			var states = getInterceptionStates();

			if( structKeyExists(states,arguments.state) ){
				return states[arguments.state];
			}

			return structnew();
		</cfscript>
	</cffunction>

	<!--- Unregister From a State --->
	<cffunction name="unregister" access="public" returntype="boolean" hint="Unregister an interceptor from an interception state or all states. If the state does not exists, it returns false" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptorName" 	required="true" hint="The name of the interceptor to search for"/>
		<cfargument name="state" 			required="false" default="" hint="The named state to unregister this interceptor from. If not passed, then it will be unregistered from all states.">
		<!--- ************************************************************* --->
		<cfscript>
			var states 		 = instance.interceptionStates;
			var unregistered = false;
			var key 		 = "";

			// Else, unregister from all states
			for(key in states){

				if( len(trim(arguments.state)) eq 0 OR trim(arguments.state) eq key ){
					structFind(states,key).unregister( arguments.interceptorName );
					unregistered = true;
				}

			}

			return unregistered;
		</cfscript>
	</cffunction>

	<!--- Register an Interception Point --->
	<cffunction name="registerInterceptionPoint" access="public" returntype="any" hint="Register an Interception point into a new or created interception state." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptorKey" 	required="true" type="any" hint="The interceptor key to use for lookups in the state.">
		<cfargument name="state" 			required="true" type="any" hint="The state to create">
		<cfargument name="oInterceptor" 	required="true" type="any" hint="The interceptor to register">
		<!--- ************************************************************* --->
		<cfscript>
			var oInterceptorState = "";

			// Verify if state doesn't exist, create it
			if ( NOT structKeyExists( instance.interceptionStates, arguments.state ) ){
				oInterceptorState = CreateObject("component","coldbox.system.web.context.InterceptorState").init( arguments.state );
				structInsert( instance.interceptionStates , arguments.state, oInterceptorState );
			}
			else{
				// Get the State we need to register in
				oInterceptorState = structFind( instance.interceptionStates, arguments.state );
			}

			// Verify if the interceptor is already in the state
			if( NOT oInterceptorState.exists( arguments.interceptorKey ) ){
				//Register it
				oInterceptorState.register( arguments.interceptorKey, arguments.oInterceptor );
			}

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- wireboxSetup --->
    <cffunction name="wireboxSetup" output="false" access="private" returntype="any" hint="Verifies the setup for interceptor classes is online">
    	<cfscript>
			// Check if handler mapped?
			if( NOT controller.getWireBox().getBinder().mappingExists( instance.INTERCEPTOR_BASE_CLASS ) ){
				// feed the base class
				binder = controller.getWireBox().registerNewInstance(name=instance.INTERCEPTOR_BASE_CLASS,instancePath=instance.INTERCEPTOR_BASE_CLASS)
					.initWith(controller=controller,properties=structNew())
					.noAutowire();
			}
    	</cfscript>
    </cffunction>

	<!--- Get an interceptors interception points via metadata --->
	<cffunction name="parseMetadata" returntype="struct" access="private" output="false" hint="I get a components valid interception points">
		<!--- ************************************************************* --->
		<cfargument name="metadata" required="true" type="any" 		hint="The recursive metadata">
		<cfargument name="points" 	required="true" type="struct" 	hint="The active points">
		<!--- ************************************************************* --->
		<cfscript>
			var x 			= 1;
			var pointsFound = arguments.points;
			var currentList = arrayToList( instance.interceptionPoints );

			// Register local functions
			if( structKeyExists(arguments.metadata, "functions") ){

				for(x=1; x lte ArrayLen(arguments.metadata.functions); x=x+1 ){

					// Verify the @interceptionPoint annotation
					if( structKeyExists(arguments.metadata.functions[x],"interceptionPoint") ){
						// Register the point by convention and annotation
						currentList = arrayToList( appendInterceptionPoints( arguments.metadata.functions[x].name ) );
					}

					// verify its a plugin point by comparing it to the local defined interception points
					if ( listFindNoCase( currentList, arguments.metadata.functions[x].name ) AND
						 NOT structKeyExists( pointsFound, arguments.metadata.functions[x].name ) ){
						// Insert to metadata struct of points found
						structInsert( pointsFound, arguments.metadata.functions[x].name, true );
					}

				}// loop over functions
			}

			// Start Registering inheritances
			if ( structKeyExists(arguments.metadata, "extends") and
				 (arguments.metadata.extends.name neq "coldbox.system.Interceptor" and
				  arguments.metadata.extends.name neq "coldbox.system.Plugin" and
				  arguments.metadata.extends.name neq "coldbox.system.EventHandler" )
			){
				// Recursive lookup
				parseMetadata( arguments.metadata.extends, pointsFound );
			}
			//return the interception points found
			return pointsFound;
		</cfscript>
	</cffunction>

</cfcomponent>