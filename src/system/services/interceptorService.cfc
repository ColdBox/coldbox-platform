<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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
			setInterceptionPoints('afterConfigurationLoad,afterAspectsLoad,sessionStart,sessionEnd,preProcess,preEvent,postEvent,preRender,postRender,postProcess,afterCacheElementInsert,afterCacheElementRemoved');
			/* Init Container */
			setInterceptionStates(structnew());
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
			var oInterceptor = "";
			var interceptorKey = "";
			var interceptionPointsFound = structnew();
			var stateKey = "";
			
			/* Create a spanking new Interception States Container */
			createInterceptionStates();
			
			/* Check if we have custom interception points, and register them if we do */
			if( len(interceptorConfig.CustomInterceptionPoints) neq 0 ){
				appendInterceptionPoints( interceptorConfig.CustomInterceptionPoints);
			}
			
			/* Loop over the Interceptor Array, to begin registration */
			for (; x lte arrayLen(interceptorConfig.interceptors); x=x+1){
				/* Create Cache Interceptor Key */
				interceptorKey = "cboxinterceptor_" & interceptorConfig.interceptors[x].class;
				/* Create the Interceptor Class */
				oInterceptor = CreateObject("component", interceptorConfig.interceptors[x].class ).init(getController(),interceptorConfig.interceptors[x].properties);
				/* Configure the Interceptor */
				oInterceptor.configure();
				/* Cache Interceptor */
				getController().getColdBoxOCM().set(interceptorKey, oInterceptor, 0);
				
				/* Parse Interception Points, thanks to inheritance. */
				interceptionPointsFound = parseMetadata( getMetaData(oInterceptor), interceptionPointsFound);
				
				/* Register this Interceptor's interception point with its appropriate interceptor state */
				for(stateKey in interceptionPointsFound){
					RegisterInterceptionPoint(interceptorKey,stateKey);
				}
				
			}//end declared interceptor loop
		</cfscript>
	</cffunction>

	<!--- Process a State's Interceptors --->
	<cffunction name="processState" access="public" returntype="void" hint="Process an interception state" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="state" 		 required="true" 	type="string" hint="An interception state to process">
		<cfargument name="interceptData" required="false" 	type="struct" default="#structNew()#" hint="A data structure used to pass intercepted information.">
		<!--- ************************************************************* --->
		<cfscript>
			var event = getController().getRequestService().getContext();
			/* Validate incoming state */
			if( not listfindnocase(getInterceptionPoints(),arguments.state) ){
				getController().throw("The interception state sent in to process is not valid: #arguments.state#","","Framework.InterceptorService.InvalidInterceptionState");
			}
			/* Process The State if it exists, else just exit out. */
			if ( structKeyExists(getinterceptionStates(), arguments.state) ){
				structFind( getinterceptionStates(), arguments.state).process(event,arguments.interceptData);	
			}
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

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Append Interception Points --->
	<cffunction name="appendInterceptionPoints" access="public" returntype="void" hint="Append a list of custom interception points to the CORE interception points" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="customPoints" required="true" type="string" hint="A comma delimmited list of custom interception points to append">
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
	
	<!--- Get an interceptors interception points via metadata --->
	<cffunction name="parseMetadata" returntype="struct" access="public" output="false" hint="I get a components valid interception points">
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
			if ( structKeyExists(arguments.metadata, "extends") and arguments.metadata.extends.name neq "coldbox.system.interceptor"){
				/* Recursive lookup */
				parseMetadata(arguments.metadata.extends,pointsFound);
			}
			//return the interception points found
			return pointsFound;
		</cfscript>	
	</cffunction>
	
	<!--- Register an Interception Point --->
	<cffunction name="RegisterInterceptionPoint" access="public" returntype="void" hint="Register an Interception point into a new or created interception state." output="false" >
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
	<cffunction name="createInterceptionStates" access="public" returntype="void" hint="Create the interception states container" output="false" >
		<cfscript>
		if ( not structIsEmpty(getInterceptionStates()) ){
			structClear( getInterceptionStates() );
			setInterceptionStates(structnew());
		}
		</cfscript>
	</cffunction>

</cfcomponent>