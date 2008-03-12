<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	02/29/2008
Description :
	This interceptor provides security to an application. It is very flexible
	and customizable. It bases off on the ability to secure events by creating
	rules. This interceptor will then try to match a rule to the incoming even
	and the user's credentials. The only requirement is that the developer
	use the coldfusion <cfloging> and <cfloginuser> and set the roles accordingly.

Interceptor Properties:

 - useRegex : boolean [default=true] Whether to use regex on event matching
 - useRoutes : boolean [default=false] Whether to redirec to events or routes
 - rulesSource : string [xml|db|ioc|ocm] Where to get the rules from.
 - debugMode : boolean [default=false] If on, then it logs actions via the logger plugin.
 
XML properties:
The rules will be extracted from an xml configuration file. The format is
defined in the sample.
 - rulesFile : string The relative or absolute location of the rules file.

DB properties:
The rules will be taken off a cfquery using the properties below.
 - rulesDSN : string The datasource to use to connect to the rules table.
 - rulesTable : string The table of where the rules are
 - rulesSQL* : string You can write your own sql if you want. (optional)
 - rulesOrderBy* : string How to order the rules (optional)

The table MUST have the following columns:
Rules Query
 - whitelist
 - securelist
 - roles
 - redirect

IOC properties:
The rules will be grabbed off an IoC bean as a query. They must be a valid rules query.
 - rulesBean : string The bean to call on the IoC container
 - rulesBeanMethod : string The method to call on the bean
 - rulesBeanArgs* : string The arguments to send if any (optional)

OCM Properties:
The rules will be placed by the user in the ColdBox cache manager
and then extracted by this interceptor. They must be a valid rules query.
 - rulesOCMkey : string The key of the rules that will be placed in the OCM.

* Optional properties
----------------------------------------------------------------------->
<cfcomponent name="security"
			 hint="This is a security interceptor"
			 output="false"
			 extends="coldbox.system.interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		<cfscript>
			/* Start processing properties */
			if( not propertyExists('useRegex') or not isBoolean(getproperty('useRegex')) ){
				setProperty('useRegex',true);
			}
			if( not propertyExists('useRoutes') or not isBoolean(getproperty('useRoutes')) ){
				setProperty('useRoutes',false);
			}
			if( not propertyExists('debugMode') or not isBoolean(getproperty('debugMode')) ){
				setProperty('debugMode',false);
			}
			/* Source Checks */
			if( not propertyExists('rulesSource') ){
				throw(message="The rulesSource property has not been set.",type="interceptors.security.settingUndefinedException");
			}
			if( not reFindnocase("^(xml|db|ioc|ocm)$",getProperty('rulesSource')) ){
				throw(message="The rules source you set is invalid: #getProperty('rulesSource')#.",
					  detail="The valid sources are xml,db,ioc, and ocm.",
					  type="interceptors.security.settingUndefinedException");
			}
			/* Now Call sourcesCheck */
			RulesSourceChecks();
			
			/* Create the internal properties now */
			setProperty('rules',Arraynew(1));
			setProperty('rulesLoaded',false);
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<!--- After Aspects Load --->
	<cffunction name="afterAspectsLoad" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
		<cfscript>
			switch( getProperty('rulesSource') ){
				case "xml" : { 
					loadXMLRules(); 
					break; 
				}
				case "db" : { 
					loadDBRules(); 
					break; 
				}
				case "ioc" : { 
					loadIOCRules(); 
					break; 
				}		
			}//end of switch
		</cfscript>
	</cffunction>
	
	<!--- pre-process --->
	<cffunction name="preProcess" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
		<cfscript>
			var rules = getProperty('rules');
			var rulesLen = arrayLen(rules);
			var x = 1;
			var currentEvent = event.getCurrentEvent();
			
			/* Load OCM rules */
			if( getProperty('rulesSource') eq "ocm" and not getProperty('rulesLoaded') ){
				loadOCMRules();
			}
			
			/* Loop through Rules */
			for(x=1; x lte rulesLen; x=x+1){
				/* is current event in this whitelist pattern? then continue to next rule */
				if( isEventInPattern(currentEvent,rules[x].whitelist) ){
					if( getProperty('debugMode') ){
						getPlugin("logger").logEntry("information","#currentEvent# found in whitelist: #rules[x].whitelist#");
					}
					continue;
				}
				/* is currentEvent in the secure list and is user in role */
				if( isEventInPattern(currentEvent,rules[x].securelist) ){
					/* Verify if user is logged in and in roles */	
					if( _isUserInAnyRole(rules[x].roles) eq false ){
						/* Log if Necessary */
						if( getProperty('debugMode') ){
							getPlugin("logger").logEntry("warning","User not in appropriate roles #rules[x].roles# for event=#currentEvent#");
						}
						/* Redirect */
						if( getProperty('useRoutes') ) 
							setNextRoute(rules[x].redirect);
						else 
							setNextEvent(rules[x].redirect);
						break;
					}//end user in roles
					else{
						if( getProperty('debugMode') ){
							//User is in role. continue.
							getPlugin("logger").logEntry("information","Secure event=#currentEvent# matched and user is in roles=#rules[x].roles#. Proceeding");
						}
						break;
					}
				}//end if current event did not match a secure event.
				else{
					if( getProperty('debugMode') ){
						getPlugin("logger").logEntry("information","#currentEvent# Did not match this rule: #rules[x].toString()#");
					}
				}							
			}//end of rules checks
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE METHDOS ------------------------------------------->
	
	<!--- isEventInPattern --->
	<cffunction name="_isUserInAnyRole" access="private" returntype="boolean" output="false" hint="Verifies that the user is in any role">
		<!--- ************************************************************* --->
		<cfargument name="roleList" 	required="true" type="string" hint="The role list needed to match.">
		<!--- ************************************************************* --->
		<cfset var thisRole = "">
		<!--- Loop Over Roles --->
		<cfloop list="#arguments.roleList#" index="thisRole">
			<cfif isUserInRole(thisRole)>
				<cfreturn true>
			</cfif>
		</cfloop>	
		<cfreturn false>	
	</cffunction>
	
	<!--- isEventInPattern --->
	<cffunction name="isEventInPattern" access="private" returntype="boolean" output="false" hint="Verifies that the current event is in a given pattern list">
		<!--- ************************************************************* --->
		<cfargument name="currentEvent" 	required="true" type="string" hint="The current event.">
		<cfargument name="patternList" 		required="true" type="string" hint="The list to test.">
		<!--- ************************************************************* --->
		<cfset var pattern = "">
		<!--- Loop Over Patterns --->
		<cfloop list="#arguments.patternList#" index="pattern">
			<!--- Using Regex --->
			<cfif getProperty('useRegex')>
				<cfif reFindNocase(pattern,arguments.currentEvent)>
					<cfreturn true>
				</cfif>
			<cfelseif FindNocase(pattern,arguments.currentEvent)>
					<cfreturn true>
			</cfif>	
		</cfloop>	
		<cfreturn false>	
	</cffunction>
		
	<!--- Load XML Rules --->
	<cffunction name="loadXMLRules" access="private" returntype="void" output="false" hint="Load rules from XML file">
		<cfscript>
			/* Validate the XML File */
			var rulesFile = "";
			var xmlRules = "";
			var x=1;
			var node = "";
			var appRoot = getController().getAppRootPath();
		
			/* Clean app root */
			if( right(appRoot,1) neq getSetting("OSFileSeparator",true) ){
				appRoot = appRoot & getSetting("OSFileSeparator",true);
			}
			
			//Test if the file exists
			if ( fileExists(appRoot & getProperty('rulesFile')) ){
				rulesFile = appRoot & getProperty('rulesFile');
			}
			/* Expanded Relative */
			else if( fileExists( ExpandPath(getProperty('rulesFile')) ) ){
				rulesFile = ExpandPath( getProperty('rulesFile') );
			}
			/* Absolute Path */
			else if( fileExists( getProperty('rulesFile') ) ){
				rulesFile = getProperty('rulesFile');
			}
			else{
				throw('Security Rules File could not be located: #getProperty('rulesFile')#. Please check again.','','interceptors.security.rulesFileNotFound');
			}
			/* Set the correct expanded path now */
			setProperty('rulesFile',rulesFile);
			/* Read in and parse */
			xmlRules = xmlSearch(XMLParse(rulesFile),"/rules/rule");
			/* Loop And create Rules */
			for(x=1; x lte Arraylen(xmlRules); x=x+1){
				node = structnew();
				node.whitelist = trim(xmlRules[x].whitelist.xmlText);
				node.securelist = trim(xmlRules[x].securelist.xmlText);
				node.roles = trim(xmlRules[x].roles.xmlText);
				node.redirect = trim(xmlRules[x].redirect.xmlText);
				ArrayAppend(getProperty('rules'),node);
			}
			/* finalize */
			setProperty('rulesLoaded',true);	
		</cfscript>
	</cffunction>
	
	<!--- Load DB Rules --->
	<cffunction name="loadDBRules" access="private" returntype="void" output="false" hint="Load rules from the database">
		<cfset var qRules = "">
		
		<!--- Let's get our rules from the DB --->
		<cfquery name="qRules" datasource="#getProperty('rulesDSN')#">
		<cfif propertyExists('rulesSQL') and len(getProperty('rulesSQL'))>
			#getProperty('rulesSQL')#
		<cfelse>
			SELECT *
			  FROM #getProperty('rulesTable')#
			<cfif propertyExists('rulesOrderBy') and len(getProperty('rulesOrderBy'))>
			ORDER BY #getProperty('rulesOrderBy')#
			</cfif>
		</cfif>
		</cfquery>
		
		<!--- validate query --->
		<cfset validateRulesQuery(qRules)>
		
		<!--- let's setup the array of struct Rules now --->
		<cfset setProperty('rules', queryToArray(qRules))>
		<cfset setProperty('rulesLoaded',true)>
	</cffunction>
	
	<!--- Load XML Rules --->
	<cffunction name="loadIOCRules" access="private" returntype="void" output="false" hint="Load rules from an IOC bean">
		<cfset var qRules = "">
		<cfset var bean = "">
		
		<!--- Get rules from IOC Container --->
		<cfset bean = getPlugin("ioc").getBean(getproperty('rulesBean'))>
		
		<cfif propertyExists('rulesBeanArgs') and len(getProperty('rulesBeanArgs'))>
			<cfset qRules = evaluate("bean.#getproperty('rulesBeanMethod')#( #getProperty('rulesBeanArgs')# )")>
		<cfelse>
			<!--- Now call method on it --->
			<cfinvoke component="#bean#" method="#getProperty('rulesBeanMethod')#" returnvariable="qRules" />
		</cfif>
		
		<!--- validate query --->
		<cfset validateRulesQuery(qRules)>
		
		<!--- let's setup the array of struct Rules now --->
		<cfset setProperty('rules', queryToArray(qRules))>
		<cfset setProperty('rulesLoaded',true)>
	</cffunction>
	
	<!--- Load XML Rules --->
	<cffunction name="loadOCMRules" access="private" returntype="void" output="false" hint="Load rules from the OCM">
		<cfset var qRules = "">
		
		<!--- Get Rules From OCM --->
		<cfif not getColdboxOCM().lookup(getProperty('rulesOCMkey'))>
			<cfthrow message="No key #getProperty('rulesOCMKey')# in the OCM." type="interceptors.security.invalidOCMKey">
		<cfelse>
			<cfset qRules = getColdboxOCM().get(getProperty('rulesOCMKey'))>
		</cfif>
		
		<!--- validate query --->
		<cfset validateRulesQuery(qRules)>
		
		<!--- let's setup the array of struct Rules now --->
		<cfset setProperty('rules', queryToArray(qRules))>
		<cfset setProperty('rulesLoaded',true)>
	</cffunction>
	
	<!--- ValidateRules Query --->
	<cffunction name="validateRulesQuery" access="private" returntype="void" output="false" hint="Validate a query as a rules query, else throw error.">
		<!--- ************************************************************* --->
		<cfargument name="qRules" type="query" required="true" hint="The query to check">
		<!--- ************************************************************* --->
		<cfset var validColumns = "whitelist,securelist,roles,redirect">
		<cfset var col = "">
		<!--- Validate Query --->
		<cfloop list="#validColumns#" index="col">
			<cfif not listfindnocase(arguments.qRules.columnlist,col)>
				<cfthrow message="The required column: #col# was not found in the rules query" type="interceptors.security.invalidRuleQuery">
			</cfif>
		</cfloop>
	</cffunction>
	
	<!--- queryToArray --->
	<cffunction name="queryToArray" access="private" returntype="array" output="false" hint="Convert a rules query to our array format">
		<!--- ************************************************************* --->
		<cfargument name="qRules" type="query" required="true" hint="The query to convert">
		<!--- ************************************************************* --->
		<cfscript>
			var x =1;
			var node = "";
			var rtnArray = ArrayNew(1);
			
			/* Loop over Rules */
			for(x=1; x lte qRules.recordcount; x=x+1){
				node = structnew();
				node.whitelist = qRules.whitelist[x];
				node.securelist = qRules.securelist[x];
				node.roles = qRules.roles[x];
				node.redirect = qRules.redirect[x];
				ArrayAppend(rtnArray,node);
			}
			/* reutnr array */
			return rtnArray;
		</cfscript>
	</cffunction>
	
	<!--- rules sources check --->
	<cffunction name="RulesSourceChecks" access="private" returntype="void" output="false" hint="Validate the rules source property" >
		<cfscript>
			switch( getProperty('rulesSource') ){
				
				case "xml" :
				{
					/* Check if file property exists */
					if( not propertyExists('rulesFile') ){
						throw(message="Missing setting for XML source: rulesFile ",type="interceptors.security.settingUndefinedException");
					}
					break;
				}//end of xml check
				
				case "db" :
				{
					/* Check for DSN */
					if( not propertyExists('rulesDSN') ){
						throw(message="Missing setting for DB source: rulesDSN ",type="interceptors.security.settingUndefinedException");
					}
					/* Check for table */
					if( not propertyExists('rulesTable') ){
						throw(message="Missing setting for DB source: rulesTable ",type="interceptors.security.settingUndefinedException");
					}
					/* Optional DB settings are checked when loading rules. */
					break;
				}//end of db check
				
				case "ioc" :
				{
					/* Check for bean */
					if( not propertyExists('rulesBean') ){
						throw(message="Missing setting for ioc source: rulesBean ",type="interceptors.security.settingUndefinedException");
					}
					if( not propertyExists('rulesBeanMethod') ){
						throw(message="Missing setting for ioc source: rulesBeanMethod ",type="interceptors.security.settingUndefinedException");
					}
					
					break;
				}//end of ioc check
				
				case "ocm" :
				{
					/* Check for bean */
					if( not propertyExists('rulesOCMkey') ){
						throw(message="Missing setting for ioc source: rulesOCMkey ",type="interceptors.security.settingUndefinedException");
					}
					break;
				}//end of OCM check			
			
			}//end of switch statement			
		</cfscript>
	</cffunction>

</cfcomponent>