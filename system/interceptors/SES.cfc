<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	This is an interceptor for ses support. This code is based almost totally on
	Adam Fortuna's ColdCourse cfc, which is an AMAZING SES component
	All credits go to him: http://coldcourse.riaforge.com
----------------------------------------------------------------------->
<cfcomponent hint="This interceptor provides complete SES and URL mappings support to ColdBox Applications"
			 output="false"
			 extends="coldbox.system.Interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		// Reserved Keys as needed for cleanups
		instance.RESERVED_KEYS 			  = "handler,action,view,viewNoLayout,module,moduleRouting";
		instance.RESERVED_ROUTE_ARGUMENTS = "constraints,pattern,regexpattern,matchVariables,packageresolverexempt,patternParams,valuePairTranslation";
	</cfscript>

	<cffunction name="configure" access="public" returntype="void" hint="This is where the ses plugin configures itself." output="false" >
		<cfscript>
			// Setup the default interceptor properties
			setRoutes( ArrayNew(1) );
			setModuleRoutingTable( structnew() );
			setLooseMatching( false );
			setUniqueURLs( true );
			setEnabled( true );
			setAutoReload( false );
			setExtensionDetection( true );

			//Import Config
			importConfiguration();

			// Save the base URL in the application settings
			setSetting('sesBaseURL', getBaseURL() );
			setSetting('htmlBaseURL', replacenocase(getBaseURL(),"index.cfm",""));
		</cfscript>
	</cffunction>


<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<!--- Pre execution process --->
	<cffunction name="preProcess" access="public" returntype="void" hint="This is the route dispatch" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="any" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
		<cfscript>
			/* Find which route this URL matches */
			var aRoute = "";
			var key = "";
			var cleanedPaths = getCleanedPaths();
			var routedStruct = structnew();
			var rc = event.getCollection();

			// Check if active or in proxy mode
			if ( NOT getEnabled() OR arguments.event.isProxyRequest() )
				return;

			//Auto Reload?
			if( getAutoReload() ){ configure(); }

			// Set that we are in ses mode
			arguments.event.setIsSES(true);

			// Check for invalid URLs if in strict mode
			if( getUniqueURLs() ){
				checkForInvalidURL( cleanedPaths["pathInfo"] , cleanedPaths["scriptName"], arguments.event );
			}
			
			// Find a route to dispatch
			aRoute = findRoute( cleanedPaths["pathInfo"], arguments.event );

			// Now route should have all the key/pairs from the URL we need to pass to our event object
			for( key in aRoute ){
				// Reserved Keys Check, only translate NON reserved keys
				if( not listFindNoCase(instance.RESERVED_KEYS,key) ){
					rc[key] = aRoute[key];
					routedStruct[key] = aRoute[key];
				}
			}

			// Create Event To Dispatch if handler key exists
			if( structKeyExists(aRoute,"handler") ){
				// If no action found, default to the convention of the framework, must likely 'index'
				if( NOT structKeyExists(aRoute,"action") ){
					aRoute.action = getDefaultFrameworkAction();
				}
				// else check if using HTTP method actions via struct
				else if( isStruct(aRoute.action) ){
					// Verify HTTP method used is valid, else throw exception and 403 error
					if( structKeyExists(aRoute.action,event.getHTTPMethod()) ){
						aRoute.action = aRoute.action[event.getHTTPMethod()];
						// Send for logging in debug mode
						log.debug("Matched HTTP Method (#event.getHTTPMethod()#) to routed action: #aRoute.action#");
					}
					else{
						throwInvalidHTTP("The HTTP method used: #event.getHTTPMethod()# is not valid for the current executing event.");
					}
				}
				// Create event
				rc[getSetting('EventName')] = aRoute.handler & "." & aRoute.action;

				// Do we have a module?
				if( len(aRoute.module) ){
					rc[getSetting('EventName')] = aRoute.module & ":" & rc[getSetting('EventName')];
				}

			}// if handler exists

			// See if View is Dispatched
			if( structKeyExists(aRoute,"view") ){
				// Dispatch the View
				arguments.event.setView(name=aRoute.view,noLayout=aRoute.viewNoLayout);
				arguments.event.noExecution();
			}

			// Save the Routed Variables so event caching can verify them
			arguments.event.setRoutedStruct(routedStruct);

			// Execute Cache Test now that routing has been done. We override, because events are determined until now.
			getController().getRequestService().EventCachingTest(context=arguments.event);
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- addModuleRoutes --->
	<cffunction name="addModuleRoutes" output="false" access="public" returntype="void" hint="Add modules routes in the specified position">
		<cfargument name="pattern" type="string" required="true"  hint="The pattern to match against the URL." />
		<cfargument name="module"  type="string" required="true"  hint="The module to load routes for"/>
		<cfscript>
			var mConfig 	 = getSetting("modules");
			var routingTable = getModulesRoutingTable();
			var x 			 = 1;
			var args		 = structnew();

			// Verify module exists and loaded
			if( NOT structKeyExists(mConfig,arguments.module) ){
				$throw(message="Error loading module routes as the module requested '#arguments.module#' is not loaded.",
					   detail="The loaded modules are: #structKeyList(mConfig)#",
					   type="SES.InvalidModuleName");
			}

			// Create the module routes container if it does not exist already
			if( NOT structKeyExists(routingTable, arguments.module) ){
				routingTable[arguments.module] = arraynew(1);
			}

			// Store the entry point for the module routes.
			addRoute(pattern=arguments.pattern,moduleRouting=arguments.module);

			// Iterate through module routes and process them
			for(x=1; x lte ArrayLen(mConfig[arguments.module].routes); x=x+1){
				args = mConfig[arguments.module].routes[x];
				args.module = arguments.module;
				addRoute(argumentCollection=args);
			}
		</cfscript>
	</cffunction>

	<!--- Add a new Route --->
	<cffunction name="addRoute" access="public" returntype="void" hint="Adds a route to dispatch" output="false">
		<!--- ************************************************************* --->
		<cfargument name="pattern" 				 type="string" 	required="true"  hint="The pattern to match against the URL." />
		<cfargument name="handler" 				 type="string" 	required="false" hint="The handler to execute if pattern matched.">
		<cfargument name="action"  				 type="any" 	required="false" hint="The action in a handler to execute if a pattern is matched.  This can also be a structure or JSON structured based on the HTTP method(GET,POST,PUT,DELETE). ex: {GET:'show', PUT:'update', DELETE:'delete', POST:'save'}">
		<cfargument name="packageResolverExempt" type="boolean" required="false" default="false" hint="If this is set to true, then the interceptor will not try to do handler package resolving. Else a package will always be resolved. Only works if :handler is in a pattern">
		<cfargument name="matchVariables" 		 type="string" 	required="false" hint="A string of name-value pair variables to add to the request collection when this pattern matches. This is a comma delimmitted list. Ex: spaceFound=true,missingAction=onTest">
		<cfargument name="view"  				 type="string"  required="false" hint="The view to dispatch if pattern matches.  No event will be fired, so handler,action will be ignored.">
		<cfargument name="viewNoLayout"  		 type="boolean" required="false" default="false" hint="If view is choosen, then you can choose to override and not display a layout with the view. Else the view renders in the assigned layout.">
		<cfargument name="valuePairTranslation"  type="boolean" required="false" default="true"  hint="Activate convention name value pair translations or not. Turned on by default">
		<cfargument name="constraints" 			 type="any"  	required="false" default="" hint="A structure or JSON structure of regex constraint overrides for variable placeholders. The key is the name of the variable, the value is the regex to try to match."/>
		<cfargument name="module" 				 type="string"  required="false" default="" hint="The module to add this route to"/>
		<cfargument name="moduleRouting" 		 type="string"  required="false" default="" hint="Called internally by addModuleRoutes to add a module routing route."/>
		<!--- ************************************************************* --->
		<cfscript>
		var thisRoute = structNew();
		var thisPattern = "";
		var thisPatternParam = "";
		var arg = 0;
		var x =1;
		var thisRegex = 0;
		var oJSON = getPlugin("JSON");
		var jsonRegex = "^(\{|\[)(.)+(\}|\])$";
		var patternType = "";

		// Process all incoming arguments into the route to store
		for(arg in arguments){
			if( structKeyExists(arguments,arg) ){ thisRoute[arg] = arguments[arg]; }
		}

		// Process actions as a JSON structure?
		if( structKeyExists(arguments,"action") AND isSimpleValue(arguments.action) AND reFindnocase(jsonRegex,arguments.action) ){
			try{
				// Inflate action to structure
				thisRoute.action = oJSON.decode(arguments.action);
			}
			catch(Any e){
				$throw("Invalid JSON action","The action #arguments.action# is not valid JSON","SES.InvalidJSONAction");
			}
		}

		// Cleanup Route: Add trailing / to make it easier to parse
		if( right(thisRoute.pattern,1) IS NOT "/" ){
			thisRoute.pattern = thisRoute.pattern & "/";
		}
		// Cleanup initial /, not needed if found.
		if( left(thisRoute.pattern,1) IS "/" ){
			if( thisRoute.pattern neq "/" ){
				thisRoute.pattern = right(thisRoute.pattern,len(thisRoute.pattern)-1);
			}
		}

		// Check if we have optional args by looking for a ?
		if( findnocase("?",thisRoute.pattern) AND NOT findNoCase("regex:",thisRoute.pattern) ){
			processRouteOptionals(thisRoute);
			return;
		}

		// Process json constraints?
		thisRoute.constraints = structnew();
		// Check if implicit struct first, else try to do JSON conversion.
		if( isStruct(arguments.constraints) ){ thisRoute.constraints = arguments.constraints; }
		else if( reFindnocase(jsonRegex,arguments.constraints) ){
			try{
				// Inflate constratints to structure
				thisRoute.constraints = oJSON.decode(arguments.constraints);
			}
			catch(Any e){
				$throw("Invalid JSON constraints","The constraints #arguments.constraints# is not valid JSON","SES.InvalidJSONConstraint");
			}
		}

		// Init the matching variables
		thisRoute.regexPattern = "";
		thisRoute.patternParams = arrayNew(1);

		// Check for / pattern
		if( len(thisRoute.pattern) eq 1){
			thisRoute.regexPattern = "/";
		}

		// Process the route as a regex pattern
		for(x=1; x lte listLen(thisRoute.pattern,"/");x=x+1){

			// Pattern and Pattern Param
			thisPattern = listGetAt(thisRoute.pattern,x,"/");
			thisPatternParam = replace(listFirst(thisPattern,"-"),":","");

			// Detect Optional Types
			patternType = "alphanumeric";
			if( findnoCase("-numeric",thisPattern) ){ patternType = "numeric"; }
			if( findnoCase("-alpha",thisPattern) ){ patternType = "alpha"; }
			if( findNoCase("regex:",thisPattern) ){ patternType = "regex"; }

			// Pattern Type Regex
			switch(patternType){
				// CUSTOM REGEX
				case "regex" : {
					thisRegex = replacenocase(thisPattern,"regex:","");
					break;
				}

				// ALPHANUMERICAL OPTIONAL
				case "alphanumeric" : {
					if( find(":",thisPattern) ){
						thisRegex = "(" & REReplace(thisPattern,":(.[^-]*)","[^/]");
						// Check Digits Repetions
						if( find("{",thisPattern) ){
							thisRegex = listFirst(thisRegex,"{") & "{#listLast(thisPattern,"{")#)";
							arrayAppend(thisRoute.patternParams,replace(listFirst(thisPattern,"{"),":",""));
						}
						else{
							thisRegex = thisRegex & "+?)";
							arrayAppend(thisRoute.patternParams,thisPatternParam);
						}
						// Override Constraints with your own REGEX
						if( structKeyExists(thisRoute.constraints,thisPatternParam) ){
							thisRegex = thisRoute.constraints[thisPatternParam];
						}
					}
					else{
						thisRegex = thisPattern;
					}
					break;
				}
				// NUMERICAL OPTIONAL
				case "numeric" : {
					// Convert to Regex Pattern
					thisRegex = "(" & REReplace(thisPattern, ":.*?-numeric", "[0-9]");
					// Check Digits
					if( find("{",thisPattern) ){
						thisRegex = listFirst(thisRegex,"{") & "{#listLast(thisPattern,"{")#)";
					}
					else{
						thisRegex = thisRegex & "+?)";
					}
					// Add Route Param
					arrayAppend(thisRoute.patternParams,thisPatternParam);
					break;
				}
				// ALPHA OPTIONAL
				case "alpha" : {
					// Convert to Regex Pattern
					thisRegex = "(" & REReplace(thisPattern, ":.*?-alpha", "[a-zA-Z]");
					// Check Digits
					if( find("{",thisPattern) ){
						thisRegex = listFirst(thisRegex,"{") & "{#listLast(thisPattern,"{")#)";
					}
					else{
						thisRegex = thisRegex & "+?)";
					}
					// Add Route Param
					arrayAppend(thisRoute.patternParams,thisPatternParam);
					break;
				}
			} //end pattern type detection switch

			// Add Regex Created To Pattern
			thisRoute.regexPattern = thisRoute.regexPattern & thisRegex & "/";

		} // end looping of pattern optionals

		// Add it to the routing map table
		if( len(arguments.module) ){
			ArrayAppend(getModuleRoutes(arguments.module), thisRoute);
		}
		else{
			ArrayAppend(getRoutes(), thisRoute);
		}
		</cfscript>
	</cffunction>

	<cffunction name="getAutoReload" access="public" returntype="boolean" output="false" hint="Set to auto reload the rules in each request">
		<cfreturn instance.autoReload>
	</cffunction>
	<cffunction name="setAutoReload" access="public" returntype="void" output="false" hint="Get the auto reload flag.">
		<cfargument name="autoReload" type="boolean" required="true">
		<cfset instance.autoReload = arguments.autoReload>
	</cffunction>

	<!--- Getter/Setter for uniqueURLs --->
	<cffunction name="setUniqueURLs" access="public" output="false" returntype="void" hint="Set the uniqueURLs property">
		<cfargument name="uniqueURLs" type="boolean" required="true" />
		<cfset instance.uniqueURLs = arguments.uniqueURLs />
	</cffunction>
	<cffunction name="getUniqueURLs" access="public" output="false" returntype="boolean" hint="Get uniqueURLs">
		<cfreturn instance.uniqueURLs/>
	</cffunction>

	<!--- Setter/Getter for Base URL --->
	<cffunction name="setBaseURL" access="public" output="false" returntype="void" hint="Set the base URL for the application.">
		<cfargument name="baseURL" type="string" required="true" />
		<cfset instance.baseURL = arguments.baseURL />
	</cffunction>
	<cffunction name="getBaseURL" access="public" output="false" returntype="string" hint="Get BaseURL">
		<cfreturn instance.BaseURL/>
	</cffunction>

	<!--- Get/set Loose Matching --->
	<cffunction name="getLooseMatching" access="public" returntype="boolean" output="false" hint="Get the current loose matching property">
    	<cfreturn instance.looseMatching>
    </cffunction>
    <cffunction name="setLooseMatching" access="public" returntype="void" output="false" hint="Set the loose matching property of the interceptor">
    	<cfargument name="looseMatching" type="boolean" required="true">
    	<cfset instance.looseMatching = arguments.looseMatching>
    </cffunction>
	
	<!--- get/set Extension Detection --->
	<cffunction name="getExtensionDetection" access="public" returntype="boolean" output="false" hint="Get the flag if extension detection is enabled">
    	<cfreturn instance.extensionDetection>
    </cffunction>
    <cffunction name="setExtensionDetection" access="public" returntype="void" output="false" hint="Call it to activate/deactivate automatic extension detection">
    	<cfargument name="extensionDetection" type="boolean" required="true">
    	<cfset instance.extensionDetection = arguments.extensionDetection>
    </cffunction>
    

	<!--- Getter/Setter Enabled --->
	<cffunction name="setEnabled" access="public" output="false" returntype="void" hint="Set whether the interceptor is enabled or not.">
		<cfargument name="enabled" type="boolean" required="true" />
		<cfset instance.enabled = arguments.enabled />
	</cffunction>
	<cffunction name="getEnabled" access="public" output="false" returntype="boolean" hint="Get enabled">
		<cfreturn instance.enabled/>
	</cffunction>

	<!--- Getter routes --->
	<cffunction name="getRoutes" access="public" output="false" returntype="Array" hint="Get the array containing all the routes">
		<cfreturn instance.Routes/>
	</cffunction>

	<!--- getModulesRoutingTable --->
	<cffunction name="getModulesRoutingTable" output="false" access="public" returntype="struct" hint="Get the entire modules routing table">
		<cfreturn instance.moduleRoutingTable>
	</cffunction>

	<!--- getModuleRoutes --->
	<cffunction name="getModuleRoutes" output="false" access="public" returntype="array" hint="Get a modules routes">
		<cfargument name="module" type="string" required="true" default="" hint="The name of the module"/>
		<cfscript>
			var table = getModulesRoutingTable();
			if( structKeyExists(table, arguments.module) ){
				return table[arguments.module];
			}
			$throw(message="Module routes for #arguments.module# do not exists", detail="Loaded module routes are #structKeyList(table)#",type="SES.InvalidModuleException");
		</cfscript>
	</cffunction>



<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- throwInvalidHTTP --->
    <cffunction name="throwInvalidHTTP" output="false" access="private" returntype="void" hint="Throw an invalid HTTP exception">
    	<cfargument name="description" type="string" required="true" hint="The throw description"/>

		<cfheader statuscode="403" statustext="403 Invalid HTTP Method Exception">
		<cfthrow type="SES.403"
			     errorcode="403"
			     message="403 Invalid HTTP Method Exception"
				 detail="#arguments.description#">

    </cffunction>

	<!--- setmoduleRoutingTable --->
	<cffunction name="setModuleRoutingTable" output="false" access="private" returntype="void" hint="Set the module routing table">
		<cfargument name="routes" type="struct" required="true"/>
		<cfset instance.moduleRoutingTable = arguments.routes>
	</cffunction>

	<!--- Set Routes --->
	<cffunction name="setRoutes" access="private" output="false" returntype="void" hint="Internal override of the routes array">
		<cfargument name="routes" type="Array" required="true"/>
		<cfset instance.routes = arguments.routes/>
	</cffunction>

	<!--- Get Default Framework Action --->
	<cffunction name="getDefaultFrameworkAction" access="private" returntype="string" hint="Get the default framework action" output="false" >
		<cfreturn getController().getSetting("eventAction",1)>
	</cffunction>

	<!--- CGI Element Facade. --->
	<cffunction name="getCGIElement" access="private" returntype="string" hint="The cgi element facade method" output="false" >
		<cfargument name="cgielement" required="true" type="string" hint="The cgi element to retrieve">
		<cfscript>
			return cgi[arguments.cgielement];
		</cfscript>
	</cffunction>

	<!--- Package Resolver --->
	<cffunction name="packageResolver" access="private" returntype="any" hint="Resolve handler packages" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="routingString" 	required="true" type="any" hint="The routing string">
		<cfargument name="routeParams" 		required="true" type="any" hint="The route params array">
		<!--- ************************************************************* --->
		<cfscript>
			var root = getSetting("HandlersPath");
			var extRoot = getSetting("HandlersExternalLocationPath");
			var x = 1;
			var newEvent = "";
			var thisFolder = "";
			var foundPaths = "";
			var rString = arguments.routingString;
			var routeParamsLen = ArrayLen(routeParams);
			var returnString = arguments.routingString;

			/* Verify if we have a handler on the route params */
			if( findnocase("handler", arrayToList(arguments.routeParams)) ){
				/* Cleanup routing string to position of :handler */
				for(x=1; x lte routeParamsLen; x=x+1){
					if( routeParams[x] neq "handler" ){
						rString = replace(rString,listFirst(rString,"/") & "/","");
					}
					else{
						break;
					}
				}
				/* Now Find Packaging in our stripped rString */
				for(x=1; x lte listLen(rString,"/"); x=x+1){
					/* Get Folder */
					thisFolder = listgetAt(rString,x,"/");
					/* Check if package exists in convention OR external location */
					if( directoryExists(root & "/" & foundPaths & thisFolder)
						OR
					    ( len(extRoot) AND directoryExists(extRoot & "/" & foundPaths & thisFolder) )
					    ){
						/* Save Found Paths */
						foundPaths = foundPaths & thisFolder & "/";
						/* Save new Event */
						if(len(newEvent) eq 0){
							newEvent = thisFolder & ".";
						}
						else{
							newEvent = newEvent & thisFolder & ".";
						}
					}//end if folder found
					else{
						//newEvent = newEvent & "." & thisFolder;
						break;
					}//end not a folder.
				}//end for loop

				/* Replace Return String */
				if( len(newEvent) ){
					returnString = replacenocase(returnString,replace(newEvent,".","/","all"),newEvent);
				}
			}//end if handler found

			return returnString;
		</cfscript>
	</cffunction>

	<!--- Serialize a URL --->
	<cffunction name="serializeURL" access="private" output="false" returntype="string" hint="Serialize a URL">
		<!--- ************************************************************* --->
		<cfargument name="formVars" required="false" default="" type="string">
		<cfargument name="event" 	required="true" type="any" hint="The event object.">
		<!--- ************************************************************* --->
		<cfscript>
			var vars = arguments.formVars;
			var key = 0;
			var rc = arguments.event.getCollection();

			for(key in rc){
				if( NOT ListFindNoCase("route,handler,action,#getSetting('eventName')#",key) ){
					vars = ListAppend(vars, "#lcase(key)#=#rc[key]#", "&");
				}
			}
			if( len(vars) eq 0 ){
				return "";
			}
			else{
				return "?" & vars;
			}
		</cfscript>
	</cffunction>

	<!--- Check for Invalid URL --->
	<cffunction name="checkForInvalidURL" access="private" output="false" returntype="void" hint="Check for invalid URL's">
		<!--- ************************************************************* --->
		<cfargument name="route" 		required="true" type="any" />
		<cfargument name="script_name" 	required="true" type="any" />
		<cfargument name="event" 		required="true" type="any" hint="The event object.">
		<!--- ************************************************************* --->
		<cfset var handler = "" />
		<cfset var action = "" />
		<cfset var newpath = "" />
		<cfset var httpRequestData = "">
		<cfset var eventName = getSetting('EventName')>
		<cfset var defaultEvent = getSetting('DefaultEvent')>
		<cfset var rc = event.getCollection()>

		<!--- Get the HTTP Data --->
		<cfset httpRequestData = getHttpRequestData()/>

		<!---
		Verify we have uniqueURLs ON, the event var exists, route is empty or index.cfm
		AND
		if the incoming event is not the default OR it is the default via the URL.
		--->
		<cfif StructKeyExists(rc, eventName)
			  AND (arguments.route EQ "/index.cfm" or arguments.route eq "")
			  AND (
			  		rc[eventName] NEQ defaultEvent
			  		OR
			  		( structKeyExists(url,eventName) AND rc[eventName] EQ defaultEvent )
			  )>

			<!--- New Pathing Calculations if not the default event. If default, relocate to the domain. --->
			<cfif rc[eventName] neq defaultEvent>
				<!--- Clean for handler & Action --->
				<cfif StructKeyExists(rc, eventName)>
					<cfset handler = reReplace(rc[eventName],"\.[^.]*$","") />
					<cfset action = ListLast( rc[eventName], "." ) />
				</cfif>
				<!--- route a handler --->
				<cfif len(handler)>
					<cfset newpath = "/" & handler />
				</cfif>
				<!--- route path with handler + action if not the default event action --->
				<cfif len(handler)
					  AND len(action)
					  AND action NEQ getDefaultFrameworkAction()>
					<cfset newpath = newpath & "/" & action />
				</cfif>
			</cfif>

			<!--- Debug Logging --->
			<cfset log.debug("SES Invalid URL detected. Route: #arguments.route#, script_name: #arguments.script_name#")>

			<!--- Relocation headers --->
			<cfif httpRequestData.method EQ "GET">
				<cfheader statuscode="301" statustext="Moved permanently" />
			<cfelse>
				<cfheader statuscode="303" statustext="See Other" />
			</cfif>

			<!--- Relocate --->
			<cfheader name="Location" value="#arguments.event.getSESbaseURL()##newpath##serializeURL(httpRequestData.content,arguments.event)#" />
			<cfabort />
		</cfif>
	</cffunction>

	<!--- Fix Ending IIS funkyness --->
	<cffunction name="fixIISURLVars" access="private" returntype="string" hint="Clean up some IIS funkyness" output="false" >
		<cfargument name="requestString"  type="any" required="true" hint="The request string">
		<cfargument name="rc"  			  type="any" required="true" hint="The request collection">
		<cfscript>
			var varMatch = 0;
			var qsValues = 0;
			var qsVal = 0;
			var x = 1;

			// Find a Matching position of IIS ?
			varMatch = REFind("\?.*=",arguments.requestString,1,"TRUE");
			if( varMatch.pos[1] ){
				// Copy values to the RC
				qsValues = REreplacenocase(arguments.requestString,"^.*\?","","all");
				// loop and create
				for(x=1; x lte listLen(qsValues,"&"); x=x+1){
					qsVal = listGetAt(qsValues,x,"&");
					rc[listFirst(qsVal,"=")] = listLast(qsVal,"=");
				}
				// Clean the request string
				arguments.requestString = Mid(arguments.requestString, 1, (varMatch.pos[1]-1));
			}

			return arguments.requestString;
		</cfscript>
	</cffunction>
	
	<!--- detectExtension --->
    <cffunction name="detectExtension" output="false" access="public" returntype="any" hint="Detect extensions from the incoming request">
    	<cfargument name="requestString" 	type="any"    required="true"  hint="The requested URL string">
		<cfargument name="event"  			type="any"    required="true"  hint="The event object.">
		<cfscript>
    		var extension = listLast(arguments.requestString,".");
			
			// check if extension found
			if( len(extension) ){
				// set the format request collection variable
				event.setValue("format", extension);
				// remove it from the string
				return left(requestString, len(arguments.requestString) - len(extension) - 1 );
			}
		</cfscript>
    </cffunction>

	<!--- Find a route --->
	<cffunction name="findRoute" access="private" output="false" returntype="Struct" hint="Figures out which route matches this request">
		<!--- ************************************************************* --->
		<cfargument name="action" type="any"    required="true"  hint="The action evaluated by the path_info">
		<cfargument name="event"  type="any"    required="true"  hint="The event object.">
		<cfargument name="module" type="string" required="false" default="" hint="Find a route on a module"/>
		<!--- ************************************************************* --->
		<cfset var requestString = arguments.action />
		<cfset var packagedRequestString = "">
		<cfset var match = structNew() />
		<cfset var foundRoute = structNew() />
		<cfset var params = structNew() />
		<cfset var key = "" />
		<cfset var i = 1 />
		<cfset var x = 1 >
		<cfset var rc = event.getCollection()>
		<cfset var _routes = getRoutes()>
		<cfset var _routesLength = ArrayLen(_routes)>

		<cfscript>
		
			// Module call? Switch routes
			if( len(arguments.module) ){
				_routes = getModuleRoutes(arguments.module);
				_routesLength = arrayLen(_routes);
			}

			// fix URL vars after ?
			requestString = fixIISURLVars(requestString,rc);
			
			// Extension detection if enabled
			if( getExtensionDetection() ){
				requestString = detectExtension(requestString,arguments.event);
			}
			
			//Remove the leading slash
			if( len(requestString) GT 1 AND left(requestString,1) eq "/" ){
				requestString = right(requestString,len(requestString)-1);
			}
			// Add ending slash
			if( right(requestString,1) IS NOT "/" ){
				requestString = requestString & "/";
			}
			
			// Let's Find a Route, Loop over all the routes array
			for(i=1; i lte _routesLength; i=i+1){

				// Match The route to request String
				match = reFindNoCase(_routes[i].regexPattern,requestString,1,true);
				if( (match.len[1] IS NOT 0 AND getLooseMatching())
				     OR
				    (NOT getLooseMatching() AND match.len[1] IS NOT 0 AND match.pos[1] EQ 1) ){
					// Setup the found Route
					foundRoute = _routes[i];
					// Debug logging
					log.debug("SES Route matched: #foundRoute.toString()# on routed string: #requestString#");
					break;
				}

			}//end finding routes

			// Check if we found a route, else just return empty params struct
			if( structIsEmpty(foundRoute) ){
				log.debug("No SES routes matched on routed string: #requestString#");
				return params;
			}

			// Check if the match is a module Routing entry point or not?
			if( len( foundRoute.moduleRouting ) ){
				// Try to discover the route via the module routing calls
				params = findRoute(reReplaceNoCase(requestString,foundRoute.regexpattern,""),arguments.event,foundRoute.moduleRouting);
				// If empty, then just continue matching calls, else return matched route.
				if( NOT structIsEmpty(params) ){
					return params;
				}
			}

			// Save Found Route
			arguments.event.setValue(name="currentRoute",value=foundRoute.pattern,private=true);
			// Save Found URL
			arguments.event.setValue(name="currentRoutedURL",value=requestString,private=true);

			// Do we need to do package resolving
			if( NOT foundRoute.packageResolverExempt ){
				// Resolve the packages
				packagedRequestString = packageResolver(requestString,foundRoute.patternParams);
				// reset pattern matching, if packages found.
				if( compare(packagedRequestString,requestString) NEQ 0 ){

					// Log package resolved
					log.debug("SES Package Resolved: #packagedRequestString#");

					// Return found Route recursively.
					return findRoute(packagedRequestString,arguments.event);
				}
			}

			// Populate the params, with variables found in the request string
			for(x=1; x lte arrayLen(foundRoute.patternParams); x=x+1){
				params[foundRoute.patternParams[x]] = mid(requestString, match.pos[x+1], match.len[x+1]);
			}

			// Process Convention Name-Value Pairs
			if( foundRoute.valuePairTranslation ){
				findConventionNameValuePairs(requestString,match,params);
			}

			// Now setup all found variables in the param struct, so we can return
			for(key in foundRoute){
				// Check that the key is not a reserved route argument and NOT already routed
				if( NOT listFindNoCase(instance.RESERVED_ROUTE_ARGUMENTS,key)
					AND NOT structKeyExists(params, key) ){
					params[key] = foundRoute[key];
				}
				else if (key eq "matchVariables"){
					for(i=1; i lte listLen(foundRoute.matchVariables); i = i+1){
						// Check if the key does not exist in the routed params yet.
						if( NOT structKeyExists(params, listFirst(listGetAt(foundRoute.matchVariables,i),"=") ) ){
							params[listFirst(listGetAt(foundRoute.matchVariables,i),"=")] = listLast(listGetAt(foundRoute.matchVariables,i),"=");
						}
					}
				}
			}

			return params;
		</cfscript>
	</cffunction>

	<cffunction name="findConventionNameValuePairs" access="private" returntype="void" hint="Find the convention name value pairs" output="false" >
		<cfargument name="requestString"  	type="string" 	required="true" hint="The request string">
		<cfargument name="match"  			type="any" 		required="true" hint="The regex matcher">
		<cfargument name="params"  		 	type="struct" 	required="true" hint="The parameter structure">
		<cfscript>
		//var leftOverLen = len(arguments.requestString)-(arguments.match.pos[arraylen(arguments.match.pos)]+arguments.match.len[arrayLen(arguments.match.len)]-1);
		var leftOverLen = len(arguments.requestString) - arguments.match.len[1];
		var conventionString = 0;
		var conventionStringLen = 0;
		var tmpVar = 0;
		var i = 1;

		if( leftOverLen gt 0 ){
			// Cleanup remaining string
			conventionString 	= right(arguments.requestString,leftOverLen).split("/");
			conventionStringLen = arrayLen(conventionString);

			// If conventions found, continue parsing
			for(i=1; i lte conventionStringLen; i=i+1){
				if( i mod 2 eq 0 ){
					// Even: Means Variable Value
					arguments.params[tmpVar] = conventionString[i];
				}
				else{
					// ODD: Means variable name
					tmpVar = trim(conventionString[i]);
					// Verify it is a valid variable Name
					if ( NOT isValid("variableName",tmpVar) ){
						tmpVar = "_INVALID_VARIABLE_NAME_POS_#i#_";
					}
					else{
						// Default Value of empty
						arguments.params[tmpVar] = "";
					}
				}
			}//end loop over pairs
		}//end if convention name value pairs
		</cfscript>
	</cffunction>

	<cffunction name="getCleanedPaths" access="private" returntype="struct" hint="Get and Clean the path_info and script names" output="false" >
		<cfscript>
			var items = structnew();

			// Get path_info
			items["pathInfo"] = getCGIElement('path_info');
			items["scriptName"] = trim(reReplacenocase(getCGIElement('script_name'),"[/\\]index\.cfm",""));

			// Clean ContextRoots
			if( len(getContextRoot()) ){
				items["pathInfo"] = replacenocase(items["pathInfo"],getContextRoot(),"");
				items["scriptName"] = replacenocase(items["scriptName"],getContextRoot(),"");
			}
			// Clean up the path_info from index.cfm and nested pathing
			items["pathInfo"] = trim(reReplacenocase(items["pathInfo"],"[/\\]index\.cfm",""));
			if( len(items["scriptName"]) ){
				items["pathInfo"] = replaceNocase(items["pathInfo"],items["scriptName"],'');
			}

			return items;
		</cfscript>
	</cffunction>

	<cffunction name="processRouteOptionals" access="private" returntype="void" hint="Process route optionals" output="false" >
		<cfargument name="thisRoute"  type="struct" required="true" hint="The route struct">
		<cfscript>
			var x=1;
			var thisPattern = 0;
			var base = "";
			var optionals = "";
			var routeList = "";

			// Parse our base & optionals
			for(x=1; x lte listLen(arguments.thisRoute.pattern,"/"); x=x+1){
				thisPattern = listgetAt(arguments.thisRoute.pattern,x,"/");
				// Check for ?
				if( not findnocase("?",thisPattern) ){
					base = base & thisPattern & "/";
				}
				else{
					optionals = optionals & replacenocase(thisPattern,"?","","all") & "/";
				}
			}
			// Register our routeList
			routeList = base & optionals;
			// Recurse and register in reverse order
			for(x=1; x lte listLen(optionals,"/"); x=x+1){
				// Create new route
				arguments.thisRoute.pattern = routeList;
				// Register route
				addRoute(argumentCollection=arguments.thisRoute);
				// Remove last bit
				routeList = listDeleteat(routeList,listlen(routeList,"/"),"/");
			}
			// Setup the base route again
			arguments.thisRoute.pattern = base;
			// Register the final route
			addRoute(argumentCollection=arguments.thisRoute);
		</cfscript>
	</cffunction>

	<!--- importConfiguration --->
	<cffunction name="importConfiguration" output="false" access="private" returntype="void" hint="Import the routing configuration file">
		<cfscript>
			var appLocPrefix = "/";
			var configFilePath = "";
			var refLocal = structnew();

			// Verify the config file, else set it to our convention in the config/Routes.cfm
			if( not propertyExists('configFile') ){
				setProperty('configFile','config/Routes.cfm');
			}

			//App location prefix
			if( len(getSetting('AppMapping')) ){
				appLocPrefix = appLocPrefix & getSetting('AppMapping') & "/";
			}

			// Setup the config Path for relative location first.
			configFilePath = appLocPrefix & reReplace(getProperty('ConfigFile'),"^/","");
			if( NOT fileExists(expandPath(configFilePath)) ){
				//Check absolute location as not found inside our app
				configFilePath = getProperty('ConfigFile');
				if( NOT fileExists(expandPath(configFilePath)) ){
					$throw(message="Error locating routes file: #configFilePath#",type="SES.ConfigFileNotFound");
				}
			}

			// We are ready to roll. Import config to setup the routes.
			try{
				$include(configFilePath);
			}
			catch(Any e){
				$throw("Error including config file: #e.message# #e.detail#",e.tagContext.toString(),"SES.executingConfigException");
			}

			// Validate the base URL
			if ( len(getBaseURL()) eq 0 ){
				$throw('The baseURL property has not been defined. Please define it using the setBaseURL() method.','','interceptors.SES.invalidPropertyException');
			}
		</cfscript>
	</cffunction>

</cfcomponent>