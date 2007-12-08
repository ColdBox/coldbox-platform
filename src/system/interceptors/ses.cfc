<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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
			var configFilePath = "/#getController().getSetting('AppMapping')#/";
			
			/* Setup the default properties */
			set_courses( ArrayNew(1) );
			setUniqueURLs(true);
			setEnabled(true);
			
			/* Verify the properties */
			if( not propertyExists('configFile') ){
				throw('The configFile property has not been defined. Please define it.','','interceptors.ses.invalidPropertyException');
			}
			
			/* Setup the config Path */
			configFilePath = configFilePath & getProperty('configFile');
			
			/* We are ready to roll. Import config to setup the routes. */
			try{
				include(configFilePath);
			}
			catch(Any e){
				throw("Error including config file: #e.message#",e.detail,"interceptors.ses.executingConfigException");
			}
			
			/* Validate the base URL */
			if ( len(getBaseURL()) eq 0 ){
				throw('The baseURL property has not been defined. Please define it using the setBaseURL() method.','','interceptors.ses.invalidPropertyException');
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
			var cleanedScriptName = trim(replacenocase(getCGIElement('script_name'),"/index.cfm",""));
	
			/* Check if active */
			if ( not getEnabled() )
				return;
	
			/* Check for invalid URL */
			checkForInvalidURL( getCGIElement('path_info') , getCGIElement('script_name'), arguments.event );
			
			/* Clean up the path_info */
			if( len(cleanedScriptName) gt 0)
				cleanedPathInfo = replaceNocase(getCGIElement('path_info'),cleanedScriptName,'');
			
			/* Find a course */
			acourse = findCourse( cleanedPathInfo, event );
			
			/* Now course should have all the key/pairs from the URL we need to pass to our event object */
			for( key in acourse ){
				event.setValue( key, acourse[key] );
			}
			
			/* Route to destination */
			routeToDestination(acourse,event);
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
		
		<!--- If they're accessing a default action explicity, and unique URLs are on --->
		<cfif getUniqueURLs()
				AND StructKeyExists(arguments.course,"handler") 
				AND StructKeyExists(arguments.course,"action")
				AND arguments.course.action EQ getDefaultFrameworkAction()>
			<cfheader statuscode="301" statustext="Moved permanently" />
			<cfheader name="Location" value="#getBaseURL()#/#arguments.course.handler##serializeURL('',event)#" />
			<cfabort />
			
		<!--- If handler is set --->		
		<cfelseif StructKeyExists(arguments.course,"handler")>
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
		<cfset var rc = event.getCollection()>

		<cfset httpRequestData = GetHttpRequestData()/>
		
		<cfif getUniqueURLs() 
			  AND StructKeyExists(rc, EventName)
			  AND (arguments.course EQ "/index.cfm" or arguments.course eq "")>
			
			<cfif StructKeyExists(rc, EventName)>
				<cfset handler = reReplace(rc[EventName],"\.[^.]*$","") />
				<cfset action = ListLast( rc[EventName], "." ) />
			</cfif>
			
			<cfif len(handler)>
				<cfset newpath = "/" & handler />
			</cfif>
			
			<cfif len(handler) 
				  AND len(action) 
				  AND action NEQ getDefaultFrameworkAction()>
				<cfset newpath = newpath & "/" & action />
			</cfif>
			
			<cfif httpRequestData.method EQ "GET">
				<cfheader statuscode="301" statustext="Moved permanently" />
			<cfelse>
				<cfheader statuscode="303" statustext="See Other" />
			</cfif>
			
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
		<cfargument name="action" required="true" type="any" hint="The action">
		<cfargument name="event"  required="true" type="any" hint="The event object.">
		<!--- ************************************************************* --->
		<cfset var varMatch = "" />
		<cfset var valMatch = ""/>
		<cfset var vari = "" />
		<cfset var vali = "" />
		<cfset var requestString = arguments.action />
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
			<cfset varMatch = REFind("\?.*=", requestString, 1, "TRUE") />
			<cfset valMatch = REFind("=.*$", requestString, 1, "TRUE") />
			<cfset vari = Mid(requestString, (varMatch.pos[1]+1), (varMatch.len[1]-2)) />
			<cfset vali = Mid(requestString, (valMatch.pos[1]+1), (valMatch.len[1]-1)) />
			<cfset rc[vari] = vali />
			<cfset requestString = Mid(requestString, 1, (var_match.pos[1]-1)) />
		</cfif>
		
		<!--- Remove the leading slash in the request (if there was something more than just a slash to begin with) to match our routes --->
		<cfif len(requestString) GT 1>
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
			<cfset thisPattern = REReplace(thisRoute.pattern, ":.*?/", "(.+?)/", "all") />
			
			<!--- Try to match this route against the URL --->
			<cfset match = REFindNoCase(thisPattern,requestString,1,true) />
			
			<!--- If a match was made, use the result to route the request --->
			<cfif match.len[1] IS NOT 0>
				<cfset foundRoute = thisRoute />
				<!--- For each part of the URL in the route --->
				<cfloop list="#thisRoute.pattern#" delimiters="/" index="thisPattern">
					<!--- if this part of the route pattern is a variable --->
					<cfif find(":",thisPattern)>
						<cfset arrayAppend(routeParams,right(thisPattern,len(thisPattern)-1)) />
					</cfif>
				</cfloop>
				
				<!--- And leave the loop 'cause we found our route --->
				<cfbreak />
			</cfif>
			
		</cfloop>
		
		<!--- Populate the params structure with the proper parts of the URL --->
		<cfset routeParamsLength = arrayLen(routeParams)>
		<cfloop from="1" to="#routeParamsLength#" index="i">
			<cfset "params.#routeParams[i]#" = mid(requestString,match.pos[i+1],match.len[i+1]) />
		</cfloop>
				
		<!--- Now set the rest of the variables in the route --->
		<cfloop collection="#foundRoute#" item="key">
			<cfif key IS NOT "pattern">
				<cfset params[key] = foundRoute[key] />
			</cfif>
		</cfloop>
		
		<cfreturn params />
	</cffunction>
	
	<!--- Add a new Course --->
	<cffunction name="addCourse" access="private" hint="Adds a route to dispatch" output="false">
		<!--- ************************************************************* --->
		<cfargument name="pattern" type="string" required="true" hint="The pattern to match against the URL." />
		<!--- ************************************************************* --->
		<cfset var thisCourse= structNew() />
		<cfset var arg = "" />		
			
		<cfloop collection="#arguments#" item="arg">
			<cfset thisCourse[arg] = arguments[arg] />
		</cfloop>
		
		<!--- Add a trailing slash to ease pattern matching --->
		<cfif right(thisCourse.pattern,1) IS NOT "/">
			<cfset thisCourse.pattern = thisCourse.pattern & "/" />
		</cfif>
		
		<cfset arrayAppend(get_courses(),thisCourse) />	
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
		<cfreturn listLast(getSetting('DefaultEvent'),".")>
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

</cfcomponent>