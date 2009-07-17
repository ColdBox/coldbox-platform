<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	This is an interceptor for ses support. This code is based almost totally on
	Adam Fortuna's ColdCourse cfc, which is an AMAZING SES component
	All credits go to him: http://coldcourse.riaforge.com
----------------------------------------------------------------------->
<cfcomponent name="ses"
			 hint="This is a ses support internceptor"
			 output="false"
			 extends="coldbox.system.interceptor">
				 
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="This is where the ses plugin configures itself." output="false" >
		<cfscript>
			var configFilePath = "/";
			
			/* If AppMapping is not Blank check */
			if( getController().getSetting('AppMapping') neq "" ){
				configFilePath = configFilePath & getController().getSetting('AppMapping') & "/";
			}
			/* Setup the default properties */
			set_courses( ArrayNew(1) );
			setUniqueURLs(true);
			setEnabled(true);
			
			/* Verify the properties */
			if( not propertyExists('configFile') ){
				$throw('The configFile property has not been defined. Please define it.','','interceptors.ses.configFilePropertyNotDefined');
			}
			
			/* Setup the config Path */
			configFilePath = configFilePath & reReplace(getProperty('ConfigFile'),"^/","");
			
			/* We are ready to roll. Import config to setup the routes. */
			try{
				$include(configFilePath);
			}
			catch(Any e){
				$throw("Error including config file: #e.message#",e.detail,"interceptors.ses.executingConfigException");
			}
			
			/* Loose Matching Property: default = false */
			if( not propertyExists('looseMatching') or not isBoolean(getProperty('looseMatching')) ){
				setProperty('looseMatching',false);
			}
			
			/* Validate the base URL */
			if ( len(getBaseURL()) eq 0 ){
				$throw('The baseURL property has not been defined. Please define it using the setBaseURL() method.','','interceptors.ses.invalidPropertyException');
			}
			/* Save the base URL in the application settings */
			setSetting('sesBaseURL', getBaseURL() );
			setSetting('htmlBaseURL', replacenocase(getBaseURL(),"index.cfm",""));
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->
	
	
	<!--- Pre execution process --->
	<cffunction name="preProcess" access="public" returntype="void" hint="This is the course dispatch" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="any" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
		<cfscript>
			/* Find which route this URL matches */
			var acourse = "";
			var key = "";
			var cleanedPathInfo = getCGIElement('path_info');
			var cleanedScriptName = trim(reReplacenocase(getCGIElement('script_name'),"[/\\]index\.cfm",""));
			var routedStruct = structnew();
			var reservedKeys = "handler,action";
			
			/* Check if active or in proxy mode */
			if ( not getEnabled() or arguments.event.isProxyRequest() )
				return;
			
			/* Clean J2EE Context Roots */
			if( len(getContextRoot()) ){
				cleanedPathInfo = replacenocase(cleanedPathInfo,getContextRoot(),"");
				cleanedScriptName = replacenocase(cleanedScriptName,getContextRoot(),"");
			}
			
			/* Check for invalid URL */
			checkForInvalidURL( cleanedPathInfo , cleanedScriptName, arguments.event );
			
			/* Clean up the path_info from index.cfm and nested pathing */
			cleanedPathInfo = trim(reReplacenocase(cleanedPathInfo,"[/\\]index\.cfm",""));
			/* Clean up empty placeholders */
			cleanedPathInfo = replace(cleanedPathInfo,"//","/","all");
			if( len(cleanedScriptName) gt 0)
				cleanedPathInfo = replaceNocase(cleanedPathInfo,cleanedScriptName,'');
			
			/* Find a course */
			acourse = findCourse( cleanedPathInfo, arguments.event );
			
			/* Now course should have all the key/pairs from the URL we need to pass to our event object */
			for( key in acourse ){
				arguments.event.setValue( key, acourse[key] );
				/* Reserved Keys Check */
				if( not listFindNoCase(reservedKeys,key) ){
					routedStruct[key] = acourse[key];
				}
			}
			/* Save the Routed Variables */
			arguments.event.setRoutedStruct(routedStruct);
			
			/* Route to destination */
			routeToDestination(acourse,arguments.event);
			/* Verify we are in ses mode */
			event.setIsSES(true);
			
			/* Execute Cache Test now that routing has been done. We override, because events are determined until now. */
			getController().getRequestService().EventCachingTest(context=arguments.event);
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Route to destination --->
	<cffunction name="routeToDestination" access="private" output="false" hint="Route to destination">
		<!--- ************************************************************* --->
		<cfargument name="course" required="true" type="any" />
		<cfargument name="event"  required="true" type="any" hint="The event object.">
		<!--- ************************************************************* --->
		<cfset var rc = event.getCollection()>
		
		<!--- If handler is set --->		
		<cfif StructKeyExists(arguments.course,"handler")>
			<cfparam name="arguments.course.action" default="#getDefaultFrameworkAction()#" />
			<cfset rc[getSetting('EventName')] = arguments.course.handler & "." & arguments.course.action />
		</cfif>
      	
		<!--- Remove what we set.. like a ninja --->
		<cfset StructDelete(rc, "handler") />
		<cfset StructDelete(rc, "action") />
	</cffunction>
	
	<!--- Check for Invalid URL --->
	<cffunction name="checkForInvalidURL" access="private" output="false" returntype="void" hint="Check for invalid URL's">	
		<!--- ************************************************************* --->
		<cfargument name="course" 		required="true" type="any" />	
		<cfargument name="script_name" 	required="true" type="any" />
		<cfargument name="event" 		required="true" type="any" hint="The event object.">
		<!--- ************************************************************* --->
		<cfset var handler = "" />
		<cfset var action = "" />
		<cfset var newpath = "" />
		<cfset var httpRequestData = "">
		<cfset var EventName = getSetting('EventName')>
		<cfset var DefaultEvent = getSetting('DefaultEvent')>
		<cfset var rc = event.getCollection()>
		
		<!--- Get the HTTP Data --->
		<cfset httpRequestData = GetHttpRequestData()/>
		
		<!--- 
		Verify we have uniqueURLs ON, the event var exists, course is empty or index.cfm
		AND
		if the incoming event is not the default OR it is the default via the URL.
		--->
		<cfif getUniqueURLs() 
			  AND StructKeyExists(rc, EventName)
			  AND (arguments.course EQ "/index.cfm" or arguments.course eq "")
			  AND (
			  		rc[EventName] NEQ DefaultEvent
			  		OR
			  		( structKeyExists(url,EventName) AND rc[EventName] EQ DefaultEvent )
			  )>
			
			<!--- New Pathing Calculations if not the default event. If default, relocate to the domain. --->
			<cfif rc[EventName] neq getSetting('DefaultEvent')>
				<!--- Clean for handler & Action --->
				<cfif StructKeyExists(rc, EventName)>
					<cfset handler = reReplace(rc[EventName],"\.[^.]*$","") />
					<cfset action = ListLast( rc[EventName], "." ) />
				</cfif>
				<!--- course a handler --->
				<cfif len(handler)>
					<cfset newpath = "/" & handler />
				</cfif>
				<!--- Course path with handler + action if not the default event action --->
				<cfif len(handler) 
					  AND len(action) 
					  AND action NEQ getDefaultFrameworkAction()>
					<cfset newpath = newpath & "/" & action />
				</cfif>
			</cfif>
			
			<!--- Relocation headers --->
			<cfif httpRequestData.method EQ "GET">
				<cfheader statuscode="301" statustext="Moved permanently" />
			<cfelse>
				<cfheader statuscode="303" statustext="See Other" />
			</cfif>
			<!--- Relocate --->
			<cfheader name="Location" value="#getBaseURL()##newpath##serializeURL(httpRequestData.content,event)#" />
			<cfabort />			
		</cfif>
	</cffunction>
	
	<!--- Serialize a URL --->
	<cffunction name="serializeURL" access="private" output="false" returntype="string" hint="Serialize a URL">
		<!--- ************************************************************* --->
		<cfargument name="formVars" required="false" default="" type="string">
		<cfargument name="event" 	required="true" type="any" hint="The event object.">
		<!--- ************************************************************* --->
		<cfset var vars = arguments.formVars>
		<cfset var key = "">
		<cfset var rc = event.getCollection()>
		<cfloop collection="#rc#" item="key">
			<cfif NOT ListFindNoCase("course,handler,action,#getSetting('eventName')#",key)>
				<cfset vars = ListAppend(vars, "#lcase(key)#=#rc[key]#", "&")>
			</cfif>
		</cfloop>
		<cfif len(vars) EQ 0><cfreturn ""></cfif>
		<cfreturn "?" & vars>
	</cffunction>
	
	<!--- Find a Course --->
	<cffunction name="findCourse" access="private" output="false" returntype="Struct" hint="Figures out which course matches this request">
		<!--- ************************************************************* --->
		<cfargument name="action" required="true" type="any" hint="The action evaluated by the path_info">
		<cfargument name="event"  required="true" type="any" hint="The event object.">
		<!--- ************************************************************* --->
		<cfset var varMatch = "" />
		<cfset var qsValues = "" />
		<cfset var qsVal = "" />
		<cfset var requestString = arguments.action />
		<cfset var packagedRequestString = "">
		<cfset var conventionString = "">
		<cfset var conventionStringLen = 0>
		<cfset var tmpVar = "">
		<cfset var leftOverLen = 0>
		<cfset var routeParams = arrayNew(1) />
		<cfset var routeParamsLength = 0>
		<cfset var thisRoute = structNew() />
		<cfset var thisPattern = "" />
		<cfset var match = structNew() />
		<cfset var foundRoute = structNew() />
		<cfset var returnRoute = structNew() />
		<cfset var params = structNew() />
		<cfset var key = "" />
		<cfset var i = "" />
		<cfset var rc = event.getCollection()>
		<cfset var _courses = get_courses()>
		<cfset var _coursesLength = ArrayLen(_courses)>
		
		<!--- fix URL variables (IIS only) --->
		<cfif requestString CONTAINS "?">
			<!--- Match the positioning of the ? --->
			<cfset varMatch = REFind("\?.*=", requestString, 1, "TRUE") />
			<!--- Now copy values to the RC. --->
			<cfset qsValues = REreplacenocase(requestString,"^.*\?","","all")>
			<cfloop list="#qsValues#" index="qsVal" delimiters="&">
				<cfset rc[listFirst(qsVal,"=")] = listLast(qsVal,"=")>
			</cfloop>
			<!--- Clean the request string. --->
			<cfset requestString = Mid(requestString, 1, (varMatch.pos[1]-1)) />
		</cfif>
		
		<!--- Remove the leading slash in the request (if there was something more than just a slash to begin with) to match our routes --->
		<cfif len(requestString) GT 1 and left(requestString,1) eq "/">
			<cfset requestString = right(requestString,len(requestString)-1) />
		</cfif>
		<cfif right(requestString,1) IS NOT "/">
			<cfset requestString = requestString & "/" />
		</cfif>
		
		<!--- Compare route to URL --->
		<!--- For each route in config --->
		<cfloop from="1" to="#_coursesLength#" index="i">
			<cfset arrayClear(routeParams) />
			<cfset thisRoute = _courses[i] />
			
			<!--- Replace any :parts with a regular expression for matching against the URL --->
			<!--- Replace -numeric with regex equiv --->
			<cfset thisPattern = REReplace(thisRoute.pattern, ":.[^-]*?/", "([^/]+?)/", "all") />
			<cfset thisPattern = REReplace(thisPattern, ":.*?-numeric/", "([0-9]+?)/", "all") />
			
			<!--- Try to match this route against the URL --->
			<cfset match = REFindNoCase(thisPattern,requestString,1,true) />
			
			<!--- If a match was made, use the result to route the request --->
			<cfif (match.len[1] IS NOT 0 AND getProperty('looseMatching')) OR 
				  (not getProperty('looseMatching') and match.len[1] IS NOT 0 and match.pos[1] EQ 1) >
				<cfset foundRoute = thisRoute />
				<!--- For each part of the URL in the route --->
				<cfloop list="#thisRoute.pattern#" delimiters="/" index="thisPattern">
					<!--- Clean thisPattern of -numeric --->
					<cfset thisPattern = replacenocase(thisPattern,"-numeric","","all")>
					<!--- if this part of the route pattern is a variable --->
					<cfif find(":",thisPattern)>
						<cfset arrayAppend(routeParams,right(thisPattern,len(thisPattern)-1)) />
					</cfif>
				</cfloop>
				<!--- And leave the loop 'cause we found our route --->
				<cfbreak />
			</cfif>			
		</cfloop>
		
		<!--- If FoundRoute is empty, just return, no more processing needed, routes not found. --->
		<cfif structIsEmpty(foundRoute)>
			<cfreturn params>
		</cfif>
		
		<!--- Package Resolver --->
		<cfif thisRoute.packageResolverExempt eq false>
			<!--- Resolve packages for handler placeholder --->
			<cfset packagedRequestString = packageResolver(requestString,routeParams)>
			<!--- If it resolved, reset the patterns --->
			<cfif compare(packagedRequestString,requestString) neq 0>
				<!--- New routing string located, reFind Courses and return results. --->
				<cfreturn findCourse(packagedRequestString,arguments.event)>
			</cfif>
		</cfif>
		
		<!--- Populate the params structure with the proper parts of the URL --->
		<cfset routeParamsLength = arrayLen(routeParams)>
		<cfloop from="1" to="#routeParamsLength#" index="i">
			<cfset params[routeParams[i]] = mid(requestString,match.pos[i+1],match.len[i+1]) />
		</cfloop>
		
		<!--- Convention String, where it will translate the remaining name-value pairs into vars --->
		<cfset leftOverLen = len(requestString)-(match.pos[arraylen(match.pos)]+match.len[arrayLen(match.len)]-1)>
		<cfif leftOverLen gt 0>
			<cfset conventionString		= right(requestString,leftOverLen)>
			<cfset conventionStringLen 	= listLen(conventionString,'/')>
			<cfset tmpVar 				= "">
			<cfif conventionStringLen gt 1>
				<cfloop from="1" to="#conventionStringLen#" index="i">
					<cfif i mod 2 eq 0>
						<!--- Even: Means Variable Value --->
						<cfset params[tmpVar] = listGetAt(conventionString,i,'/')>
					<cfelse>
						<!--- Odd: Means Variable Name --->
						<cfset tmpVar = trim(listGetAt(conventionString,i,'/'))>
						<!--- Verify the var name --->
						<cfif not isValid("variableName",tmpVar)>
							<cfset tmpVar = "_INVALID_VARIABLE_NAME_POS_#i#_">
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		
		<!--- Now set the rest of the variables in the route: handler & action --->
		<cfloop collection="#foundRoute#" item="key">
			<cfif not listfindnocase("pattern,matchVariables,packageresolverexempt",key)>
				<cfset params[key] = foundRoute[key] />
			<cfelseif key eq "matchVariables">
				<!--- Add MatchVariables to Params for further routing --->
				<cfloop list="#foundRoute.matchVariables#" index="i">
					<cfset params[listFirst(i,"=")] = listLast(i,"=")>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn params />
	</cffunction>
	
	<!--- Add a new Course --->
	<cffunction name="addCourse" access="public" hint="Adds a route to dispatch" output="false">
		<!--- ************************************************************* --->
		<cfargument name="pattern" 				 type="string" 	required="true"  hint="The pattern to match against the URL." />
		<cfargument name="handler" 				 type="string" 	required="false" hint="The handler to path to execute if passed.">
		<cfargument name="action"  				 type="string" 	required="false" hint="The action to assign if passed.">
		<cfargument name="packageResolverExempt" type="boolean" required="false" default="false" hint="If this is set to true, then the interceptor will not try to do handler package resolving. Else a package will always be resolved.">
		<cfargument name="matchVariables" 		 type="string" 	required="false" hint="A string of name-value pair variables to add to the request collection when this pattern matches. This is a comma delimmitted list. Ex: spaceFound=true,missingAction=onTest">
		<!--- ************************************************************* --->
		<cfscript>
		var thisCourse = structNew();
		var thisPattern = "";
		var arg = "";
		var x =1;
		var base = "";
		var optionals = "";
		var courseList = "";
		var tempCourse = structnew();
		
		/* Create our our course struct */
		for(arg in arguments){
			if( structKeyExists(arguments,arg) )
				thisCourse[arg] = arguments[arg];
		}
		/* Add trailing / to make it easier to parse */
		if( right(thisCourse.pattern,1) IS NOT "/" ){
			thisCourse.pattern = thisCourse.pattern & "/";
		}		
		/* Check if we have optional args by looking for a ? */
		if( findnocase("?",thisCourse.pattern) ){
			/* Parse our base & optionals */
			for(x=1; x lte listLen(thisCourse.pattern,"/"); x=x+1){
				thisPattern = listgetAt(thisCourse.pattern,x,"/");
				/* Check for ? */
				if( not findnocase("?",thisPattern) ){ 
					base = base & thisPattern & "/"; 
				}
				else{ 
					optionals = optionals & replacenocase(thisPattern,"?","","all") & "/";
				}
			}
			/* Register our courseList */
			courseList = base & optionals;
			/* Recurse and register in reverse order */
			for(x=1; x lte listLen(optionals,"/"); x=x+1){
				/* Create new Course */
				thisCourse.pattern = courseList;
				/* Register Course */
				addCourse(argumentCollection=thisCourse);	
				/* Remove last bit */
				courseList = listDeleteat(courseList,listlen(courseList,"/"),"/");		
			}
			thisCourse.pattern = base;
			addCourse(argumentCollection=thisCourse);
		}
		else{
			/* Append to our courses a basic course */
			ArrayAppend(get_courses(), thisCourse);
		}
		</cfscript>
	</cffunction>
	
	<!--- Getter/Setter for uniqueURLs --->
	<cffunction name="setUniqueURLs" access="public" output="false" returntype="void" hint="Set the uniqueURLs property">
		<!--- ************************************************************* --->
		<cfargument name="uniqueURLs" type="boolean" required="true" />
		<!--- ************************************************************* --->
		<cfset instance.uniqueURLs = arguments.uniqueURLs />
	</cffunction>
	<cffunction name="getUniqueURLs" access="public" output="false" returntype="boolean" hint="Get uniqueURLs">
		<cfreturn instance.uniqueURLs/>
	</cffunction>
	
	<!--- Setter/Getter for Base URL --->
	<cffunction name="setBaseURL" access="public" output="false" returntype="void" hint="Set the base URL for the application.">
		<!--- ************************************************************* --->
		<cfargument name="baseURL" type="string" required="true" />
		<!--- ************************************************************* --->
		<cfset instance.baseURL = arguments.baseURL />
	</cffunction>
	<cffunction name="getBaseURL" access="public" output="false" returntype="string" hint="Get BaseURL">
		<cfreturn instance.BaseURL/>
	</cffunction>
	
	<!--- Getter/Setter Enabled --->
	<cffunction name="setEnabled" access="public" output="false" returntype="void" hint="Set whether the interceptor is enabled or not.">
		<!--- ************************************************************* --->
		<cfargument name="enabled" type="boolean" required="true" />
		<!--- ************************************************************* --->
		<cfset instance.enabled = arguments.enabled />
	</cffunction>
	<cffunction name="getenabled" access="public" output="false" returntype="boolean" hint="Get enabled">
		<cfreturn instance.enabled/>
	</cffunction>
	
	<!--- Getter/Setter courses --->
	<cffunction name="get_courses" access="public" output="false" returntype="Array" hint="Get _courses">
		<cfreturn instance._courses/>
	</cffunction>	
	<cffunction name="set_courses" access="public" output="false" returntype="void" hint="Set _courses">
		<cfargument name="_courses" type="Array" required="true"/>
		<cfset instance._courses = arguments._courses/>
	</cffunction>
	
	<!--- Get Default Framework Action --->
	<cffunction name="getDefaultFrameworkAction" access="private" returntype="string" hint="Get the default framework action" output="false" >
		<cfreturn getController().getSetting("eventAction",1)>
	</cffunction>
	
	<!--- CGI Element Facade. --->
	<cffunction name="getCGIElement" access="private" returntype="string" hint="The cgi element facade method" output="false" >
		<cfargument name="cgielement" required="true" type="string" hint="">
		<cfscript>
			if ( structKeyExists(cgi, arguments.cgielement) )
				return cgi[arguments.cgielement];
			else
				return "";
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

</cfcomponent>