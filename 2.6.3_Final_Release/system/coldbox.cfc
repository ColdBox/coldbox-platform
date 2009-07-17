<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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
		setLockTimeout(30);
		//Set the app hash
		setAppHash(hash(getBaseTemplatePath()));
		
		//Set the COLDBOX CONFIG FILE
		setCOLDBOX_CONFIG_FILE(COLDBOX_CONFIG_FILE);
		//Set the Root
		setCOLDBOX_APP_ROOT_PATH(COLDBOX_APP_ROOT_PATH);
	</cfscript>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Init --->
	<cffunction name="init" access="public" returntype="coldbox" hint="Used when not using inheritance" output="false" >
		<cfargument name="COLDBOX_CONFIG_FILE" 	 required="true" type="string" hint="The coldbox config file from the application.cfc">
		<cfargument name="COLDBOX_APP_ROOT_PATH" required="true" type="string" hint="The coldbox app root path from the application.cfc">
		<cfscript>
			/* Set vars for two main locations */
			setCOLDBOX_CONFIG_FILE(arguments.COLDBOX_CONFIG_FILE);
			setCOLDBOX_APP_ROOT_PATH(arguments.COLDBOX_APP_ROOT_PATH);
			return this;
		</cfscript>
	</cffunction>

	<!--- Load ColdBox --->
	<cffunction name="loadColdbox" access="public" returntype="void" hint="Load the framework" output="false" >
		<!--- Clean up If Necessary --->
		<cfif structkeyExists(application,"cbController")>
			<cfset structDelete(application,"cbController")>
		</cfif>
		<!--- Create Brand New Controller --->
		<cfset application.cbController = CreateObject("component","coldbox.system.controller").init(COLDBOX_APP_ROOT_PATH)>
		<!--- Setup the Framework And Application --->
		<cfset application.cbController.getLoaderService().setupCalls(COLDBOX_CONFIG_FILE)>
	</cffunction>
	
	<!--- Reload Checks --->
	<cffunction name="reloadChecks" access="public" returntype="void" hint="Reload checks and reload settings." output="false" >
		<cfset var ExceptionService = "">
		<cfset var ExceptionBean = "">
		
		<!--- Initialize the Controller If Needed--->
		<cfif not structkeyExists(application,"cbController") or not application.cbController.getColdboxInitiated() or isfwReinit()>
			<cflock type="exclusive" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
				<cfif not structkeyExists(application,"cbController") or not application.cbController.getColdboxInitiated() or isfwReinit()>
					<cfset loadColdBox()>
				</cfif>
			</cflock>
		<cfelse>
			<cftry>
				<!--- AutoReload Tests --->
				<cfif application.cbController.getSetting("ConfigAutoReload")>
					<cflock type="exclusive" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
						<cfset application.cbController.setAppStartHandlerFired(false)>
						<cfset application.cbController.getLoaderService().setupCalls(COLDBOX_CONFIG_FILE)>
					</cflock>
				<cfelse>
					<!--- Handler's Index Auto Reload --->
					<cfif application.cbController.getSetting("HandlersIndexAutoReload")>
						<cflock type="exclusive" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
							<cfset application.cbController.getHandlerService().registerHandlers()>
						</cflock>
					</cfif>
					<!--- IOC Framework Reload --->
					<cfif application.cbController.getSetting("IOCFrameworkReload")>
						<cflock type="exclusive" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
							<cfset application.cbController.getPlugin("ioc").configure()>
						</cflock>
					</cfif>
				</cfif>
				
				<!--- Trap Framework Errors --->
				<cfcatch type="any">
					<cfset ExceptionService = application.cbController.getExceptionService()>
					<cfset ExceptionBean = ExceptionService.ExceptionHandler(cfcatch,"framework","Framework Initialization/Configuration Exception")>
					<cfoutput>#ExceptionService.renderBugReport(ExceptionBean)#</cfoutput>
					<cfabort>
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>
	
	<!--- Process A ColdBox Request --->
	<cffunction name="processColdBoxRequest" access="public" returntype="void" hint="Process a Coldbox Request" output="true" >
		<cfset var cbController = 0>
		<cfset var Event = 0>
		<cfset var ExceptionService = 0>
		<cfset var ExceptionBean = 0>
		<cfset var renderedContent = "">
		<cfset var eventCacheEntry = 0>
		<cfset var interceptorData = structnew()>
		
		<!--- Start Application Requests --->
		<cflock type="readonly" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
			<cftry>
				<!--- set request time --->
				<cfset request.fwExecTime = getTickCount()>
				<!--- Local Reference --->
				<cfset cbController = application.cbController>
				<!--- Create Request Context & Capture Request --->
				<cfset Event = cbController.getRequestService().requestCapture()>
				
				<!--- Debugging Monitors & Commands Check --->
				<cfif cbController.getDebuggerService().getDebugMode()>
					<!--- Commands Check --->
					<cfset coldboxCommands(cbController,event)>
					<!--- Which panel to render --->
					<cfif event.getValue("debugPanel","") eq "cache">
						<cfoutput>#cbController.getDebuggerService().renderCachePanel()#</cfoutput>
						<cfabort>
					<cfelseif event.getValue("debugPanel","") eq "cacheviewer">
						<cfoutput>#cbController.getDebuggerService().renderCacheDumper()#</cfoutput>
						<cfabort>
					<cfelseif event.getValue("debugPanel","") eq "profiler">
						<cfoutput>#cbController.getDebuggerService().renderProfiler()#</cfoutput>
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
				<cfif Event.isEventCacheable() and cbController.getColdboxOCM().lookup(Event.getEventCacheableEntry())>
					<cfset renderedContent = cbController.getColdboxOCM().get(Event.getEventCacheableEntry())>
					<cfoutput>#renderedContent#</cfoutput>
				<cfelse>
				
					<!--- Run Default/Set Event --->
					<cfset cbController.runEvent(default=true)>
					
					<!--- No Render Test --->
					<cfif not event.isNoRender()>
						<!--- Check for Marshalling and data render --->
						<cfif isStruct(event.getRenderData()) and not structisEmpty(event.getRenderData())>
							<cfset renderedContent = cbController.getPlugin("Utilities").marshallData(argumentCollection=event.getRenderData())>
						<cfelse>
							<!--- Render Layout/View pair via set variable to eliminate whitespace--->
							<cfset renderedContent = cbController.getPlugin("renderer").renderLayout()>
						</cfif>
						
						<!--- PreRender Data:--->
						<cfset interceptorData.renderedContent = renderedContent>
						<!--- Execute preRender Interception --->
						<cfset cbController.getInterceptorService().processState("preRender",interceptorData)>
						
						<!--- Check if caching the content --->
						<cfif event.isEventCacheable()>
							<cfset eventCacheEntry = Event.getEventCacheableEntry()>
							<!--- Cache the content of the event --->
							<cfset cbController.getColdboxOCM().set(eventCacheEntry.cacheKey,
																	renderedContent,
																	eventCacheEntry.timeout,
																	eventCacheEntry.lastAccessTimeout)>
						</cfif>
						
						<!--- Render Content Type if using Render Data --->
						<cfif isStruct(event.getRenderData()) and not structisEmpty(event.getRenderData())>
							<!--- Render the Data Content Type --->
							<cfcontent type="#event.getRenderData().contentType#" reset="true">
							<!--- Remove panels --->
							<cfsetting showdebugoutput="false">
							<cfset event.showDebugPanel(false)>
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
					<!--- Get Exception Service --->
					<cfset ExceptionService = cbController.getExceptionService()>
					
					<!--- Intercept The Exception --->
					<cfset interceptorData = structnew()>
					<cfset interceptorData.exception = cfcatch>
					<cfset cbController.getInterceptorService().processState("onException",interceptorData)>
					
					<!--- Handle The Exception --->
					<cfset ExceptionBean = ExceptionService.ExceptionHandler(cfcatch,"application","Application Execution Exception")>
					
					<!--- Render The Exception --->
					<cfoutput>#ExceptionService.renderBugReport(ExceptionBean)#</cfoutput>
				</cfcatch>
			</cftry>
			
			<!--- DebugMode Routines --->
			<cfif cbController.getDebuggerService().getDebugMode()>
				<!--- Request Profilers --->
				<cfif cbController.getDebuggerService().getDebuggerConfigBean().getPersistentRequestProfiler() and
					  structKeyExists(request,"debugTimers")>
					<cfset cbController.getDebuggerService().pushProfiler(request.DebugTimers)>
				</cfif>
				<!--- Render DebugPanel --->
				<cfif Event.getdebugpanelFlag()>
					<!--- Time the request --->
					<cfset request.fwExecTime = GetTickCount() - request.fwExecTime>
					<!--- Render Debug Log --->
					<cfoutput>#cbController.getDebuggerService().renderDebugLog()#</cfoutput>
				</cfif>
			</cfif>
		</cflock>
		
	</cffunction>
	
	<!--- Session Start --->
	<cffunction name="onSessionStart" returnType="void" output="false" hint="An onSessionStart method to use or call from your Application.cfc">
		<cfset var cbController = "">
		
		<cflock type="readonly" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
		<cfscript>
			//Setup the local controller 
			cbController = application.cbController;
			
			//Execute Session Start interceptors
			cbController.getInterceptorService().processState("sessionStart",session);
			
			//Execute Session Start Handler
			if ( cbController.getSetting("SessionStartHandler") neq "" ){
				cbController.runEvent(cbController.getSetting("SessionStartHandler"),true);
			}
		</cfscript>
		</cflock>
	</cffunction>
	
	<!--- Session End --->
	<cffunction name="onSessionEnd" returnType="void" output="false" hint="An onSessionEnd method to use or call from your Application.cfc">
		<!--- ************************************************************* --->
		<cfargument name="sessionScope" type="struct" required="true">
		<cfargument name="appScope" 	type="struct" required="false">
		<!--- ************************************************************* --->
		<cfset var cbController = "">
		<cfset var event = "">
		
		<cflock type="readonly" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
		<cfscript>
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
					//Place app reference on event object
					event.setValue("applicationReference", arguments.appScope);
					//Execute the Handler
					cbController.runEvent(event=cbController.getSetting("SessionEndHandler"),
										  prepostExempt=true,
										  default=true);
				}
			}
		</cfscript>
		</cflock>
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
	
	<!--- FW needs reinit --->
	<cffunction name="isfwReinit" access="public" returntype="boolean" hint="Verify if we need to reboot the framework" output="false" >
		<cfset var reinitPass = "">
		<cfset var incomingPass = "">
		
		<!--- CF Parm Structures just in case. --->
		<cfparam name="FORM" default="#StructNew()#">
		<cfparam name="URL"	 default="#StructNew()#">
		
		<cfscript>
			/* Check if we have a reinit password at hand. */
			if ( application.cbController.settingExists("ReinitPassword") ){
				reinitPass = application.cbController.getSetting("ReinitPassword");
			}			
			/* Verify the reinit key is passed */
			if ( structKeyExists(url,"fwreinit") or structKeyExists(form,"fwreinit") ){
				
				/* pass Checks */
				if ( reinitPass eq "" ){
					return true;
				}
				else{
					/* Get the incoming pass from form or url */
					if( structKeyExists(form,"fwreinit") ){
						incomingPass = form.fwreinit;
					}
					else{
						incomingPass = url.fwreinit;
					}
					/* Compare the passwords */
					if( Compare(reinitPass, incomingPass) eq 0 ){
						return true;
					}
					else{
						return false;
					}
				}//end if reinitpass neq ""
				
			}//else if reinit found.
			else{
				return false;
			}
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->	
	
	<!--- coldboxCommands --->
	<cffunction name="coldboxCommands" output="false" access="private" returntype="void" hint="Execute some coldbox commands">
		<cfargument name="cbController" type="any" required="true" default="" hint="The cb Controller"/>
		<cfargument name="event" 		type="any" required="true" hint="An event context object"/>
		<cfset var command = event.getTrimValue("cbox_command","")>
		<cfscript>
			/* Verify it */
			if( len(command) eq 0 ){ return; }
			/* Commands */
			switch(command){
				case "expirecache" : {cbController.getColdboxOCM().expireAll();break;}
				case "delcacheentry" : {cbController.getColdboxOCM().clearKey(event.getValue('cbox_cacheentry',""));break;}
				case "clearallevents" : {cbController.getColdboxOCM().clearAllEvents();break;}
				case "clearallviews" : {cbController.getColdboxOCM().clearAllViews();break;}
				default: break;
			}
		</cfscript>
		<!--- Relocate --->
		<cfif event.getValue("debugPanel","") eq "">
			<cflocation url="index.cfm" addtoken="false">
		<cfelse>
			<cflocation url="index.cfm?debugpanel=#event.getValue('debugPanel','')#" addtoken="false">
		</cfif>
	</cffunction>
	
	<!--- Getter setter lock timeout --->
	<cffunction name="getLockTimeout" access="private" output="false" returntype="numeric" hint="Get LockTimeout">
		<cfreturn instance.LockTimeout/>
	</cffunction>
	<cffunction name="setLockTimeout" access="private" output="false" returntype="void" hint="Set LockTimeout">
		<cfargument name="LockTimeout" type="numeric" required="true"/>
		<cfset instance.LockTimeout = arguments.LockTimeout/>
	</cffunction>
	
	<!--- AppHash --->
	<cffunction name="getAppHash" access="private" output="false" returntype="string" hint="Get AppHash">
		<cfreturn instance.AppHash/>
	</cffunction>
	<cffunction name="setAppHash" access="private" output="false" returntype="void" hint="Set AppHash">
		<cfargument name="AppHash" type="string" required="true"/>
		<cfset instance.AppHash = arguments.AppHash/>
	</cffunction>

</cfcomponent>