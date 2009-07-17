<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	02/29/2008
Description :

This interceptor provides security to an application. It is very flexible
and customizable. It bases off on the ability to secure events by creating
rules. This interceptor will then try to match a rule to the incoming event
and the user's credentials on roles and/or permissions. 
	
For the latest usage, please visit the wiki.
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
				$throw(message="The rulesSource property has not been set.",type="interceptors.security.settingUndefinedException");
			}
			if( not reFindnocase("^(xml|db|ioc|ocm|model)$",getProperty('rulesSource')) ){
				$throw(message="The rules source you set is invalid: #getProperty('rulesSource')#.",
					  detail="The valid sources are xml,db,ioc, model and ocm.",
					  type="interceptors.security.settingUndefinedException");
			}
			/* Query Checks */
			if( not propertyExists("queryChecks") or not isBoolean(getProperty("queryChecks")) ){
				setProperty("queryChecks",true);
			}
			/* PreEvent Security */
			if( not propertyExists("preEventSecurity") or not isBoolean(getProperty("preEventSecurity")) ){
				setProperty("preEventSecurity",false);
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
			var oValidator = "";
			
			/* Load Rules */
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
				case "model" : {
					loadModelRules();
					break;
				}
			}//end of switch
			
			/* See if using validator */
			if( propertyExists('validator') ){
				/* Try to create Validator */
				try{
					/* Create it */
					oValidator = CreateObject("component",getProperty('validator'));
					/* Verify the init */
					if( structKeyExists(oValidator, "init") ){
						oValidator = oValidator.init(controller);
					}
					/* Cache It */
					setValidator(oValidator);
				}
				catch(Any e){
					$throw("Error creating validator",e.message & e.detail, "interceptors.security.validatorCreationException");
				}
			}
			/* See if using validator from ioc */
			else if( propertyExists('validatorIOC') ){
				/* Try to create Validator */
				try{
					setValidator( getPlugin("ioc").getBean(getProperty('validatorIOC')) );
				}
				catch(Any e){
					$throw("Error creating validatorIOC",e.message & e.detail, "interceptors.security.validatorCreationException");
				}
			}
			/* See if using validator from model */
			else if( propertyExists('validatorModel') ){
				/* Try to create Validator */
				try{
					setValidator( getModel(getProperty('validatorModel') ) );
				}
				catch(Any e){
					$throw("Error creating validatorModel",e.message & e.detail, "interceptors.security.validatorCreationException");
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- pre-process --->
	<cffunction name="preProcess" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
		<cfscript>
			/* Load OCM rules */
			if( getProperty('rulesSource') eq "ocm" and not getProperty('rulesLoaded') ){
				loadOCMRules();
			}
			
			/* Execute Rule processing */
			processRules(arguments.event,arguments.interceptData,arguments.event.getCurrentEvent());
			
		</cfscript>
	</cffunction>
	
	<!--- pre-event --->
	<cffunction name="preEvent" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
		<cfscript>
			
			/* Execute Rule processing */
			processRules(arguments.event,arguments.interceptData,arguments.interceptData.processedEvent);
			
		</cfscript>
	</cffunction>
	
	<!--- Process Rules --->
	<cffunction name="processRules" access="public" returntype="void" hint="Process security rules. This method is called from an interception point" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="interceptData of intercepted info.">
		<cfargument name="currentEvent"  required="true" type="string" hint="The event to check">
		<!--- ************************************************************* --->
		<cfscript>
			var x = 1;
			var rules = getProperty('rules');
			var rulesLen = arrayLen(rules);
			var rc = event.getCollection();
			
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
					/* Verify if user is logged in and in a secure state */	
					if( _isUserInValidState(rules[x]) eq false ){
						/* Log if Necessary */
						if( getProperty('debugMode') ){
							getPlugin("logger").logEntry("warning","User not in appropriate roles #rules[x].roles# for event=#currentEvent#");
						}
						/* Redirect */
						if( getProperty('useRoutes') ){
							/* Save the secured URL */
							rc._securedURL = "#cgi.script_name##cgi.path_info#";
							if( cgi.query_string neq ""){
								rc._securedURL = rc._securedURL & "?#cgi.query_string#";
							}
							/* Route to safe event */
							setNextRoute(route=rules[x].redirect,persist="_securedURL");
						}
						else{ 
							/* Save the secured URL */
							rc._securedURL = "#cgi.script_name#";
							if( cgi.query_string neq ""){
								rc._securedURL = rc._securedURL & "?#cgi.query_string#";
							}
							/* Route to safe event */
							setNextEvent(event=rules[x].redirect,persist="_securedURL");
						}
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
	
	<!--- Register a validator --->
	<cffunction name="registerValidator" access="public" returntype="void" hint="Register a validator object with this interceptor" output="false" >
		<cfargument name="validatorObject" required="true" type="any" hint="The validator object to register">
		<cfscript>
			/* Test if it has the correct method on it */
			if( structKeyExists(arguments.validatorObject,"userValidator") ){
				setValidator(arguments.validatorObject);
			}
			else{
				$throw(message="Validator object does not have a 'userValidator' method ",type="interceptors.security.validatorException");
			}
		</cfscript>
	</cffunction>	
	
<!------------------------------------------- PRIVATE METHDOS ------------------------------------------->
	
	<!--- isEventInPattern --->
	<cffunction name="_isUserInValidState" access="private" returntype="boolean" output="false" hint="Verifies that the user is in any role">
		<!--- ************************************************************* --->
		<cfargument name="rule" required="true" type="struct" hint="The rule we are validating.">
		<!--- ************************************************************* --->
		<cfset var thisRole = "">
		
		<!--- Verify if using validator --->
		<cfif isValidatorUsed()>
			<!--- Validate via Validator --->
			<cfreturn getValidator().userValidator(arguments.rule,getPlugin("messagebox"),controller)>
		<cfelse>
			<!--- Loop Over Roles --->
			<cfloop list="#arguments.rule.roles#" index="thisRole">
				<cfif isUserInRole(thisRole)>
					<cfreturn true>
				</cfif>
			</cfloop>	
			<cfreturn false>
		</cfif>	
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
				<cfif reFindNocase(trim(pattern),arguments.currentEvent)>
					<cfreturn true>
				</cfif>
			<cfelseif FindNocase(trim(pattern),arguments.currentEvent)>
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
			
			/* Try to locate the file path */
			rulesFile = locateFilePath(getProperty('rulesFile'));
			/* Validate Location */
			if( len(rulesFile) eq 0 ){
				$throw('Security Rules File could not be located: #getProperty('rulesFile')#. Please check again.','','interceptors.security.rulesFileNotFound');
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
				node.permissions = trim(xmlRules[x].permissions.xmlText);
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
	
	<!--- Load IOC Rules --->
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
	
	<!--- Load Model Rules --->
	<cffunction name="loadModelRules" access="private" returntype="void" output="false" hint="Load rules from a model object">
		<cfset var qRules = "">
		<cfset var oModel = "">
		
		<!--- Get rules from a Model Object --->
		<cfset oModel = getModel(getproperty('rulesModel'))>
		
		<cfif propertyExists('rulesModelArgs') and len(getProperty('rulesModelArgs'))>
			<cfset qRules = evaluate("oModel.#getproperty('rulesModelMethod')#( #getProperty('rulesModelArgs')# )")>
		<cfelse>
			<!--- Now call method on it --->
			<cfinvoke component="#oModel#" method="#getProperty('rulesModelMethod')#" returnvariable="qRules" />
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
		<cfset var validColumns = "whitelist,securelist,roles,permissions,redirect">
		<cfset var col = "">
		
		<!--- Verify only if used --->
		<cfif getProperty("queryChecks")>
			<!--- Validate Query --->
			<cfloop list="#validColumns#" index="col">
				<cfif not listfindnocase(arguments.qRules.columnlist,col)>
					<cfthrow message="The required column: #col# was not found in the rules query" type="interceptors.security.invalidRuleQuery">
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>
	
	<!--- queryToArray --->
	<cffunction name="queryToArray" access="private" returntype="array" output="false" hint="Convert a rules query to our array format">
		<!--- ************************************************************* --->
		<cfargument name="qRules" type="query" required="true" hint="The query to convert">
		<!--- ************************************************************* --->
		<cfscript>
			var x =1;
			var y =1;
			var node = "";
			var rtnArray = ArrayNew(1);
			var columns = arguments.qRules.columnlist;
			
			/* Loop over Rules */
			for(x=1; x lte qRules.recordcount; x=x+1){
				/* Create Row Node */
				node = structnew();
				
				/* Create Node with all columns */
				for(y=1; y lte listLen(columns); y=y+1){
					node[listgetAt(columns,y)] = qRules[listgetAt(columns,y)][x];
				}
				
				/* Append it to the array */
				ArrayAppend(rtnArray,node);
			}
			/* return array */
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
						$throw(message="Missing setting for XML source: rulesFile ",type="interceptors.security.settingUndefinedException");
					}
					break;
				}//end of xml check
				
				case "db" :
				{
					/* Check for DSN */
					if( not propertyExists('rulesDSN') ){
						$throw(message="Missing setting for DB source: rulesDSN ",type="interceptors.security.settingUndefinedException");
					}
					/* Check for table */
					if( not propertyExists('rulesTable') ){
						$throw(message="Missing setting for DB source: rulesTable ",type="interceptors.security.settingUndefinedException");
					}
					/* Optional DB settings are checked when loading rules. */
					break;
				}//end of db check
				
				case "ioc" :
				{
					/* Check for bean */
					if( not propertyExists('rulesBean') ){
						$throw(message="Missing setting for ioc source: rulesBean ",type="interceptors.security.settingUndefinedException");
					}
					if( not propertyExists('rulesBeanMethod') ){
						$throw(message="Missing setting for ioc source: rulesBeanMethod ",type="interceptors.security.settingUndefinedException");
					}
					
					break;
				}//end of ioc check
				
				case "model" :
				{
					/* Check for bean */
					if( not propertyExists('rulesModel') ){
						$throw(message="Missing setting for model source: rulesModel ",type="interceptors.security.settingUndefinedException");
					}
					if( not propertyExists('rulesModelMethod') ){
						$throw(message="Missing setting for model source: rulesModelMethod ",type="interceptors.security.settingUndefinedException");
					}
					
					break;
				}//end of ioc check
				
				case "ocm" :
				{
					/* Check for bean */
					if( not propertyExists('rulesOCMkey') ){
						$throw(message="Missing setting for ioc source: rulesOCMkey ",type="interceptors.security.settingUndefinedException");
					}
					break;
				}//end of OCM check			
			
			}//end of switch statement			
		</cfscript>
	</cffunction>
	
	<!--- Get/Set Validator --->
	<cffunction name="getvalidator" access="private" output="false" returntype="any" hint="Get validator">
		<cfreturn instance.validator/>
	</cffunction>	
	<cffunction name="setvalidator" access="private" output="false" returntype="void" hint="Set validator">
		<cfargument name="validator" type="any" required="true"/>
		<cfset instance.validator = arguments.validator/>
	</cffunction>
	
	<!--- Check if using validator --->
	<cffunction name="isValidatorUsed" access="private" returntype="boolean" hint="Check to see if using the validator" output="false" >
		<cfreturn structKeyExists(instance, "validator")>
	</cffunction>
	
</cfcomponent>