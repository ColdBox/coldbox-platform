<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/10/2007
Description :
	This is the base component used to provide Application.cfc support.
----------------------------------------------------------------------->
<cfcomponent name="coldbox" hint="This is the base component used to provide Application.cfc support" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- Constructor --->
	<cfparam name="variables.COLDBOX_CONFIG_FILE" 	default="" type="string">
	<cfparam name="variables.COLDBOX_APP_ROOT_PATH" default="#getDirectoryFromPath(getbaseTemplatePath())#" type="string">
	
	<cfscript>
		instance = structnew();
		//Set the timeout
		setLockTimeout(60);
		//Set the app hash
		setAppHash(hash(getBaseTemplatePath()));
		//set request time
		request.fwExecTime = getTickCount();
		//Set the COLDBOX CONFIG FILE
		setCOLDBOX_CONFIG_FILE(COLDBOX_CONFIG_FILE);
		//Set the Root
		setCOLDBOX_APP_ROOT_PATH(COLDBOX_APP_ROOT_PATH);
	</cfscript>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Load ColdBox --->
	<cffunction name="loadColdbox" access="public" returntype="void" hint="Load the framework" output="false" >
		<!--- Clean up If Necessary --->
		<cfif structkeyExists(application,"cbController")>
			<cfset structDelete(application,"cbController")>
		</cfif>
		<!--- Create Brand New Controller --->
		<cfset application.cbController = CreateObject("component","coldbox.system.controller").init(COLDBOX_APP_ROOT_PATH)>
		<!--- Setup the Framework And Application --->
		<cfset application.cbController.getService("loader").setupCalls(COLDBOX_CONFIG_FILE)>
	</cffunction>
	
	<!--- Reload Checks --->
	<cffunction name="reloadChecks" access="public" returntype="void" hint="Reload checks and reload settings." output="false" >
		<cfset var ExceptionService = "">
		<cfset var ExceptionBean = "">
		
		<!--- Initialize the Controller If Needed--->
		<cfif not structkeyExists(application,"cbController") or not application.cbController.getColdboxInitiated() or isfwReinit()>
			<cflock type="exclusive" name="#getAppHash()#" timeout="#getLockTimeout()#">
				<cfif not structkeyExists(application,"cbController") or not application.cbController.getColdboxInitiated() or isfwReinit()>
					<cfset loadColdBox()>
				</cfif>
			</cflock>
		<cfelse>
			<cftry>
				
				<!--- AutoReload Tests --->
				<cfif application.cbController.getSetting("ConfigAutoReload")>
					<cflock type="exclusive" name="#getAppHash()#" timeout="#getLockTimeout()#">
						<cfset application.cbController.setAppStartHandlerFired(false)>
						<cfset application.cbController.getService("loader").setupCalls(COLDBOX_CONFIG_FILE)>
					</cflock>
				<cfelseif application.cbController.getSetting("HandlersIndexAutoReload")>
					<cflock type="exclusive" name="#getAppHash()#" timeout="#getLockTimeout()#">
						<cfset application.cbController.getHandlerService().registerHandlers()>
					</cflock>
				</cfif>
				
				<!--- Trap Framework Errors --->
				<cfcatch type="any">
					<cfset ExceptionService = application.cbController.getService("exception")>
					<cfset ExceptionBean = ExceptionService.ExceptionHandler(cfcatch,"framework","Framework Initialization/Configuration Exception")>
					<cfoutput>#ExceptionService.renderBugReport(ExceptionBean)#</cfoutput>
					<cfabort>
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>
	
	<!--- Process A ColdBox Request --->
	<cffunction name="processColdBoxRequest" access="public" returntype="void" hint="Process a Coldbox Request" output="true" >
		<cfset var cbController = "">
		<cfset var Event = "">
		<cfset var ExceptionService = "">
		<cfset var ExceptionBean = "">
		<cfset var renderedContent = "">
		
		<!--- Start Application Requests --->
		<cflock type="readonly" name="#getAppHash()#" timeout="#getLockTimeout()#">
			<cftry>
				<!--- Local Reference --->
				<cfset cbController = application.cbController>
				<!--- Create Request Context & Capture Request --->
				<cfset Event = cbController.getRequestService().requestCapture()>
				
				<!--- Debugging Monitors Check --->
				<cfif cbController.getDebuggerService().getDebugMode() and event.getValue("debugPanel","") neq "">
					<!--- Which panel to render --->
					<cfif event.getValue("debugPanel") eq "cache">
						<cfoutput>#cbController.getDebuggerService().renderCachePanel()#</cfoutput>
						<cfabort>
					<cfelseif event.getValue("debugPanel") eq "cacheviewer">
						<cfoutput>#cbController.getDebuggerService().renderCacheDumper()#</cfoutput>
						<cfabort>
					</cfif>
				</cfif>
			
				<!--- Application Start Handler --->
				<cfif cbController.getSetting("ApplicationStartHandler") neq "" and (not cbController.getAppStartHandlerFired())>
					<cfset cbController.runEvent(cbController.getSetting("ApplicationStartHandler"),true)>
					<cfset cbController.setAppStartHandlerFired(true)>
				</cfif>
				
				<!--- Execute preProcess Interception --->
				<cfset cbController.getInterceptorService().processState("preProcess")>
				
				<!--- IF Found in config, run onRequestStart Handler --->
				<cfif cbController.getSetting("RequestStartHandler") neq "">
					<cfset cbController.runEvent(cbController.getSetting("RequestStartHandler"),true)>
				</cfif>
				
				<!--- Before Any Execution, do we have cached content to deliver --->
				<cfif Event.isEventCacheable()>
					<cfset renderedContent = cbController.getColdboxOCM().get(Event.getEventCacheableEntry())>
					<cfoutput>#renderedContent#</cfoutput>
				<cfelse>
				
					<!--- Run Default/Set Event --->
					<cfset cbController.runEvent()>
					
					<!--- No Render Test --->
					<cfif not event.isNoRender()>
						<!--- Execute preRender Interception --->
						<cfset cbController.getInterceptorService().processState("preRender")>
						
						<!--- Render Layout/View pair via set variable to eliminate whitespace--->
						<cfset renderedContent = cbController.getPlugin("renderer").renderLayout()>
						
						<!--- Check if caching the content --->
						<cfif event.isEventCacheable()>
							<cfset eventCacheEntry = Event.getEventCacheableEntry()>
							<!--- Cache the content --->
							<cfset cbController.getColdboxOCM().set(eventCacheEntry.cacheKey,
																	renderedContent,
																	eventCacheEntry.timeout,
																	eventCacheEntry.lastAccessTimeout)>
						</cfif>
						
						<!--- Render the Content --->
						<cfoutput>#renderedContent#</cfoutput>
						
						<!--- Execute postRender Interception --->
						<cfset cbController.getInterceptorService().processState("postRender")>
					</cfif>
					
					<!--- If Found in config, run onRequestEnd Handler --->
					<cfif cbController.getSetting("RequestEndHandler") neq "">
						<cfset cbController.runEvent(cbController.getSetting("RequestEndHandler"),true)>
					</cfif>
					
					<!--- Execute postProcess Interception --->
					<cfset cbController.getInterceptorService().processState("postProcess")>
				
				<!--- End else if not cached event --->
				</cfif>
				
				<!--- Trap Application Errors --->
				<cfcatch type="any">
					<cfset ExceptionService = cbController.getService("exception")>
					<cfset ExceptionBean = ExceptionService.ExceptionHandler(cfcatch,"application","Application Execution Exception")>
					<cfoutput>#ExceptionService.renderBugReport(ExceptionBean)#</cfoutput>
				</cfcatch>
			</cftry>
			
			<!--- DebugMode Renders --->
			<cfif cbController.getDebuggerService().getDebugMode() and Event.getdebugpanelFlag()>
				<!--- Time the request --->
				<cfset request.fwExecTime = GetTickCount() - request.fwExecTime>
				<!--- Render Debug Log --->
				<cfoutput>#cbController.getDebuggerService().renderDebugLog()#</cfoutput>
			</cfif>
		</cflock>
		
	</cffunction>
	
	<!--- Session Start --->
	<cffunction name="onSessionStart" returnType="void" output="false">
		<cfscript>
			var cbController = "";
			
			//Setup the local controller 
			cbController = application.cbController;
			
			//Execute Session Start interceptors
			cbController.getInterceptorService().processState("sessionStart",session);
			
			//Execute Session Start Handler
			if ( cbController.getSetting("SessionStartHandler") neq "" ){
				cbController.runEvent(cbController.getSetting("SessionStartHandler"),true);
			}
		</cfscript>
	</cffunction>
	
	<!--- Session End --->
	<cffunction name="onSessionEnd" returnType="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="sessionScope" type="struct" required="true">
		<cfargument name="appScope" 	type="struct" required="false">
		<!--- ************************************************************* --->
		<cfscript>
			var cbController = "";
			var event = "";
			
			//Check for cb Controller
			if ( structKeyExists(arguments.appScope,"cbController") ){
				//setup the controller
				cbController = arguments.appScope.cbController;
				event = cbController.getRequestService().getContext();
				
				//Execute Session End interceptors
				cbController.getInterceptorService().processState("sessionEnd",arguments.sessionScope);
				
				//Execute Session End Handler
				if ( cbController.getSetting("SessionEndHandler") neq "" ){
					//Place session reference on event object
					event.setValue("sessionReference", arguments.sessionScope);
					//Execute the Handler
					cbController.runEvent(cbController.getSetting("SessionEndHandler"),true);
				}
			}
		</cfscript>
	</cffunction>

	<!--- setter COLDBOX CONFIG FILE --->
	<cffunction name="setCOLDBOX_CONFIG_FILE" access="public" output="false" returntype="void" hint="Set COLDBOX_CONFIG_FILE">
		<cfargument name="COLDBOX_CONFIG_FILE" type="string" required="true"/>
		<cfset variables.COLDBOX_CONFIG_FILE = arguments.COLDBOX_CONFIG_FILE/>
	</cffunction>
	
	<!--- setter COLDBOX_APP_ROOT_PATH --->
	<cffunction name="setCOLDBOX_APP_ROOT_PATH" access="public" output="false" returntype="void" hint="Set COLDBOX_APP_ROOT_PATH">
		<cfargument name="COLDBOX_APP_ROOT_PATH" type="string" required="true"/>
		<cfset variables.COLDBOX_APP_ROOT_PATH = arguments.COLDBOX_APP_ROOT_PATH/>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->	
	
	<!--- FW needs reinit --->
	<cffunction name="isfwReinit" access="public" returntype="boolean" hint="Verify if we need to reboot" output="false" >
		<cfscript>
			var reinitPass = "";
			if ( not application.cbController.settingExists("ReinitPassword") )
				return true;
			else
				reinitPass = application.cbController.getSetting("ReinitPassword");
		
			if ( structKeyExists(url,"fwreinit") ){
				if ( reinitPass eq "" ){
					return true;
				}
				else if ( Compare(reinitPass, url.fwreinit) eq 0){
					return true;
				}
				else{
					return false;
				}
			}
			else
				return false;
		</cfscript>
	</cffunction>
	
	<!--- Getter setter lock timeout --->
	<cffunction name="getLockTimeout" access="public" output="false" returntype="numeric" hint="Get LockTimeout">
		<cfreturn instance.LockTimeout/>
	</cffunction>
	<cffunction name="setLockTimeout" access="public" output="false" returntype="void" hint="Set LockTimeout">
		<cfargument name="LockTimeout" type="numeric" required="true"/>
		<cfset instance.LockTimeout = arguments.LockTimeout/>
	</cffunction>
	
	<!--- AppHash --->
	<cffunction name="getAppHash" access="public" output="false" returntype="string" hint="Get AppHash">
		<cfreturn instance.AppHash/>
	</cffunction>
	<cffunction name="setAppHash" access="public" output="false" returntype="void" hint="Set AppHash">
		<cfargument name="AppHash" type="string" required="true"/>
		<cfset instance.AppHash = arguments.AppHash/>
	</cffunction>

</cfcomponent>