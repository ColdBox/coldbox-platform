<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/10/2007
Description :
	This is the base component used to provide Application.cfc support.
----------------------------------------------------------------------->
<cfcomponent name="coldbox" hint="This is the base component used to provide Application.cfc support" output="false" serializable="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- Constructor --->
	<cfparam name="variables.COLDBOX_CONFIG_FILE" 	default="" type="string">
	<cfparam name="variables.COLDBOX_APP_ROOT_PATH" default="#getDirectoryFromPath(getbaseTemplatePath())#" type="string">
	<cfparam name="variables.COLDBOX_APP_KEY" 		default="cbController" type="string">
	<cfparam name="variables.COLDBOX_APP_MAPPING" 	default="" type="string">
	
	<cfscript>
		instance = structnew();
		//Set the default lock timeout
		setLockTimeout(30);
		//Set the app hash
		setAppHash(hash(getBaseTemplatePath()));
		//Set the COLDBOX CONFIG FILE
		setCOLDBOX_CONFIG_FILE(COLDBOX_CONFIG_FILE);
		//Set the App Root Location
		setCOLDBOX_APP_ROOT_PATH(COLDBOX_APP_ROOT_PATH);
		//Set the App Key to use in application scope
		setCOLDBOX_APP_KEY(COLDBOX_APP_KEY);
		//Set the App Mapping
		setCOLDBOX_APP_MAPPING(COLDBOX_APP_MAPPING); 
	</cfscript>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Init --->
	<cffunction name="init" access="public" returntype="coldbox" hint="Used when not using inheritance" output="false" >
		<cfargument name="COLDBOX_CONFIG_FILE" 	 required="true"  type="string" hint="The coldbox config file from the application.cfc">
		<cfargument name="COLDBOX_APP_ROOT_PATH" required="true"  type="string" hint="The coldbox app root path from the application.cfc">
		<cfargument name="COLDBOX_APP_KEY" 		 required="false" type="string" hint="The key name to use when storing the Coldbox application">
		<cfargument name="COLDBOX_APP_MAPPING" 	 required="false" type="string" default="" hint="The dot notation path to this application">
		<cfscript>
			// Set vars for two main locations
			setCOLDBOX_CONFIG_FILE(arguments.COLDBOX_CONFIG_FILE);
			setCOLDBOX_APP_ROOT_PATH(arguments.COLDBOX_APP_ROOT_PATH);
			setCOLDBOX_APP_MAPPING(arguments.COLDBOX_APP_MAPPING); 
			
			// App Key Check
			if( structKeyExists(arguments,"COLDBOX_APP_KEY") AND len(trim(arguments.COLDBOX_APP_KEY)) ){
				setCOLDBOX_APP_KEY(arguments.COLDBOX_APP_KEY);
			}
			return this;
		</cfscript>
	</cffunction>

	<!--- Load ColdBox --->
	<cffunction name="loadColdbox" access="public" returntype="void" hint="Load the framework" output="false" >
		<cfscript>
			var appKey = locateAppKey();
			// Cleanup of old code
			if( structkeyExists(application,appKey) ){
				structDelete(application,appKey);
			}
			// Create Brand New Controller
			application[appKey] = CreateObject("component","coldbox.system.web.Controller").init(COLDBOX_APP_ROOT_PATH);
			// Setup the Framework And Application
			application[appKey].getLoaderService().loadApplication(COLDBOX_CONFIG_FILE,COLDBOX_APP_MAPPING);			
		</cfscript>
	</cffunction>
	
	<!--- Reload Checks --->
	<cffunction name="reloadChecks" access="public" returntype="void" hint="Reload checks and reload settings." output="false" >
		<cfset var ExceptionService = "">
		<cfset var ExceptionBean = "">
		<cfset var appKey = locateAppKey()>
		<cfset var cbController = 0>
		<cfset var needReinit = isfwReinit()>
		
		<!--- Initialize the Controller If Needed, double locked --->
		<cfif NOT structkeyExists(application,appkey) OR NOT application[appKey].getColdboxInitiated() OR needReinit>
			<cflock type="exclusive" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
				<cfif NOT structkeyExists(application,"cbController") OR NOT application[appKey].getColdboxInitiated() OR needReinit>
					<!--- Verify if reiniting onColdboxReinit interceptor --->
					<cfif structkeyExists(application,appKey) AND application[appKey].getColdboxInitiated() AND needReinit>
						<cfset application[appKey].getInterceptorService().processState("preReinit")>
					</cfif>
					<!--- Reload ColdBox --->
					<cfset loadColdBox()>
				</cfif>
			</cflock>
		<cfelse>
			<cftry>
				<!--- Get Controller Reference --->
				<cflock type="readonly" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
					<cfset cbController = application[appKey]>
				</cflock>
				<!--- AutoReload Tests --->
				<cfif cbController.getSetting("ConfigAutoReload")>
					<cflock type="exclusive" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
						<cfif cbController.getSetting("ConfigAutoReload")>
							<cfset cbController.setAppStartHandlerFired(false)>
							<cfset cbController.getLoaderService().loadApplication(COLDBOX_CONFIG_FILE)>
						</cfif>
					</cflock>
				<cfelse>
					<!--- Handler's Index Auto Reload --->
					<cfif cbController.getSetting("HandlersIndexAutoReload")>
						<cflock type="exclusive" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
							<cfif cbController.getSetting("HandlersIndexAutoReload")>
								<cfset cbController.getHandlerService().registerHandlers()>
							</cfif>
						</cflock>
					</cfif>
					<!--- IOC Framework Reload --->
					<cfif cbController.getSetting("IOCFrameworkReload")>
						<cflock type="exclusive" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
							<cfset cbController.getPlugin("IOC").configure()>
						</cflock>
					</cfif>
				</cfif>
				
				<!--- Trap Framework Errors --->
				<cfcatch type="any">
					<cfset ExceptionService = cbController.getExceptionService()>
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
		<cfset var renderData = structnew()>
		<cfset var refResults = structnew()>
		
		<!--- Start Application Requests --->
		<cflock type="readonly" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
			<cfset cbController = application[locateAppKey()]>
		</cflock>
			
		<cftry>
			<!--- set request time --->
			<cfset request.fwExecTime = getTickCount()>
			
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
			<cfif len(cbController.getSetting("ApplicationStartHandler")) and (not cbController.getAppStartHandlerFired())>
				<cfset cbController.runEvent(cbController.getSetting("ApplicationStartHandler"),true)>
				<cfset cbController.setAppStartHandlerFired(true)>
			</cfif>
			
			<!--- Execute preProcess Interception --->
			<cfset cbController.getInterceptorService().processState("preProcess")>
			
			<!--- IF Found in config, run onRequestStart Handler --->
			<cfif len(cbController.getSetting("RequestStartHandler"))>
				<cfset cbController.runEvent(cbController.getSetting("RequestStartHandler"),true)>
			</cfif>
			
			<!--- Before Any Execution, do we have cached content to deliver --->
			<cfif event.isEventCacheable() and cbController.getColdboxOCM().lookup(event.getEventCacheableEntry())>
				<cfset renderedContent = cbController.getColdboxOCM().get(event.getEventCacheableEntry())>
				<cfoutput>#renderedContent#</cfoutput>
			<cfelse>
			
				<!--- Run Default/Set Event not executing an event --->
				<cfif NOT event.isNoExecution()>
					<cfset refResults.results = cbController.runEvent(default=true)>
				</cfif>
				
				<!--- No Render Test --->
				<cfif not event.isNoRender()>
					
					<!--- Execute preLayout Interception --->
					<cfset cbController.getInterceptorService().processState("preLayout")>
					
					<!--- Check for Marshalling and data render --->
					<cfset renderData = event.getRenderData()>
					<cfif isStruct(renderData) and not structisEmpty(renderData)>
						<cfset renderedContent = cbController.getPlugin("Utilities").marshallData(argumentCollection=renderData)>
					<!--- Check for Event Handler return results --->
					<cfelseif structKeyExists(refResults,"results")>
						<cfset renderedContent = refResults.results>
					<cfelse>
						<!--- Render Layout/View pair via set variable to eliminate whitespace--->
						<cfset renderedContent = cbController.getPlugin("Renderer").renderLayout()>
					</cfif>
					
					<!--- PreRender Data:--->
					<cfset interceptorData.renderedContent = renderedContent>
					<!--- Execute preRender Interception --->
					<cfset cbController.getInterceptorService().processState("preRender",interceptorData)>
					<!--- Replace back Content --->
					<cfset renderedContent = interceptorData.renderedContent>
					
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
					<cfif isStruct(renderData) and not structisEmpty(renderData)>
						<!--- Status Codes --->
						<cfheader statuscode="#renderData.statusCode#" statustext="#renderData.statusText#" >
						<!--- Render the Data Content Type --->
						<cfcontent type="#renderData.contentType#; charset=#renderData.encoding#" reset="true">
						<!--- Remove panels --->
						<cfsetting showdebugoutput="false">
						<cfset event.showDebugPanel(false)>
					</cfif>
					
					<!--- Render the Content --->
					<cfoutput>#renderedContent#</cfoutput>
						
					<!--- Execute postRender Interception --->
					<cfset cbController.getInterceptorService().processState("postRender")>
				</cfif>
			
			<!--- End else if not cached event --->
			</cfif>
			
			<!--- If Found in config, run onRequestEnd Handler --->
			<cfif len(cbController.getSetting("RequestEndHandler"))>
				<cfset cbController.runEvent(cbController.getSetting("RequestEndHandler"),true)>
			</cfif>
			
			<!--- Execute postProcess Interception --->
			<cfset cbController.getInterceptorService().processState("postProcess")>
			
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
			<cfset cbController.getDebuggerService().recordProfiler()>
			<!--- Render DebugPanel --->
			<cfif Event.getdebugpanelFlag()>
				<!--- Time the request --->
				<cfset request.fwExecTime = GetTickCount() - request.fwExecTime>
				<!--- Render Debug Log --->
				<cfoutput>#cbController.getDebuggerService().renderDebugLog()#</cfoutput>
			</cfif>
		</cfif>		
	</cffunction>
	
	<!--- OnMissing Template --->
	<cffunction	name="onMissingTemplate" access="public" returntype="boolean" output="true" hint="I execute when a non-existing CFM page was requested.">
		<cfargument name="template"	type="string" required="true"	hint="I am the template that the user requested."/>
		<cfset var cbController = "">
		<cfset var event = "">
		<cfset var interceptData = structnew()>
		
		<cflock type="readonly" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
			<cfset cbController = application[locateAppKey()]>
		</cflock>	
		
		<cfscript>
			//Execute Missing Template Handler if it exists
			if ( len(cbController.getSetting("MissingTemplateHandler")) ){
				// Save missing template in RC and right handler for this call.
				event = cbController.getRequestService().getContext();
				event.setValue("missingTemplate",arguments.template);
				event.setValue(cbController.getSetting("EventName"),cbController.getSetting("MissingTemplateHandler"));
				
				//Process it
				processColdBoxRequest();
				
				// Return processed
				return true;
			}
			
			return false;
		</cfscript>
	</cffunction>
	
	<!--- Session Start --->
	<cffunction name="onSessionStart" returnType="void" output="false" hint="An onSessionStart method to use or call from your Application.cfc">
		<cfset var cbController = "">
		
		<cflock type="readonly" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
			<cfset cbController = application[locateAppKey()]>
		</cflock>	
		
		<cfscript>
			//Execute Session Start interceptors
			cbController.getInterceptorService().processState("sessionStart",session);
			
			//Execute Session Start Handler
			if ( len(cbController.getSetting("SessionStartHandler")) ){
				cbController.runEvent(event=cbController.getSetting("SessionStartHandler"),prePostExempt=true);
			}
		</cfscript>
	</cffunction>
	
	<!--- Session End --->
	<cffunction name="onSessionEnd" returnType="void" output="false" hint="An onSessionEnd method to use or call from your Application.cfc">
		<!--- ************************************************************* --->
		<cfargument name="sessionScope" type="struct" required="true">
		<cfargument name="appScope" 	type="struct" required="false">
		<!--- ************************************************************* --->
		<cfset var cbController = "">
		<cfset var event = "">
		<cfset var iData = structnew()>
		
		<cflock type="readonly" name="#getAppHash()#" timeout="#getLockTimeout()#" throwontimeout="true">
			<cfscript>
				//Check for cb Controller
				if ( structKeyExists(arguments.appScope,locateAppKey()) ){
					cbController = arguments.appScope.cbController;
					
				}
			</cfscript>
		</cflock>
		
		<cfscript>
			if ( not isSimpleValue(cbController) ){
				// Get Context
				event = cbController.getRequestService().getContext();
					
				//Execute Session End interceptors
				iData.sessionReference = arguments.sessionScope;
				iData.applicationReference = arguments.appScope;
				cbController.getInterceptorService().processState("sessionEnd",iData);
				
				//Execute Session End Handler
				if ( len(cbController.getSetting("SessionEndHandler")) ){
					//Place session reference on event object
					event.setValue("sessionReference", arguments.sessionScope);
					//Place app reference on event object
					event.setValue("applicationReference", arguments.appScope);
					//Execute the Handler
					cbController.runEvent(event=cbController.getSetting("SessionEndHandler"),prepostExempt=true);
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- Application End --->
	<cffunction name="onApplicationEnd" returnType="void" output="false" hint="An onApplicationEnd method to use or call from your Application.cfc">
		<!--- ************************************************************* --->
		<cfargument name="appScope" 	type="struct" required="false">
		<!--- ************************************************************* --->
		<cfscript>
			var cbController = arguments.appScope[locateAppKey()];
			
			//Execute Application End interceptors
			cbController.getInterceptorService().processState("applicationEnd");
			
			// Execute Application End Handler
			if( len(cbController.getSetting('applicationEndHandler')) ){
				cbController.runEvent(event=cbController.getSetting("applicationEndHandler"),prePostExempt=true);
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
	
	<!--- setter COLDBOX_APP_KEY --->
	<cffunction name="setCOLDBOX_APP_KEY" access="public" output="false" returntype="void" hint="Set COLDBOX_APP_KEY">
		<cfargument name="COLDBOX_APP_KEY" type="string" required="true"/>
		<cfset variables.COLDBOX_APP_KEY = arguments.COLDBOX_APP_KEY/>
	</cffunction>
	
	<!--- setter COLDBOX_APP_MAPPING --->
	<cffunction name="setCOLDBOX_APP_MAPPING" access="public" output="false" returntype="void" hint="Set COLDBOX_APP_MAPPING">
		<cfargument name="COLDBOX_APP_MAPPING" type="string" required="true"/>
		<cfset variables.COLDBOX_APP_MAPPING = arguments.COLDBOX_APP_MAPPING/>
	</cffunction>
	
	<!--- Getter setter lock timeout --->
	<cffunction name="setLockTimeout" access="public" output="false" returntype="void" hint="Set LockTimeout">
		<cfargument name="LockTimeout" type="numeric" required="true"/>
		<cfset instance.LockTimeout = arguments.LockTimeout/>
	</cffunction>
	<!--- Get Lock Timeout --->
	<cffunction name="getLockTimeout" access="public" output="false" returntype="numeric" hint="Get LockTimeout">
		<cfreturn instance.LockTimeout/>
	</cffunction>
	
	<!--- FW needs reinit --->
	<cffunction name="isfwReinit" access="public" returntype="boolean" hint="Verify if we need to reboot the framework" output="false" >
		<cfset var reinitPass = "">
		<cfset var incomingPass = "">
		<cfset var appKey = locateAppKey()>
		
		<!--- CF Parm Structures just in case. --->
		<cfparam name="FORM" default="#structNew()#">
		<cfparam name="URL"	 default="#structNew()#">
		
		<cfscript>
			// Check if app exists already in scope
			if(not structKeyExists(application,appKey) ){
				return true;
			}
			
			// Check if we have a reinit password at hand.
			if ( application[appKey].settingExists("ReinitPassword") ){
				reinitPass = application[appKey].getSetting("ReinitPassword");
			}			
			
			// Verify the reinit key is passed
			if ( structKeyExists(url,"fwreinit") or structKeyExists(form,"fwreinit") ){
				
				// pass Checks
				if ( NOT len(reinitPass) ){
					return true;
				}
				
				// Get the incoming pass from form or url
				if( structKeyExists(form,"fwreinit") ){
					incomingPass = form.fwreinit;
				}
				else{
					incomingPass = url.fwreinit;
				}
				
				// Compare the passwords
				if( compare(reinitPass, incomingPass) eq 0 ){
					return true;
				}
			}//else if reinit found.
			
			return false;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->	
	
	<!--- coldboxCommands --->
	<cffunction name="coldboxCommands" output="false" access="private" returntype="void" hint="Execute some coldbox commands">
		<cfargument name="cbController" type="any" required="true" default="" hint="The cb Controller"/>
		<cfargument name="event" 		type="any" required="true" hint="An event context object"/>
		<cfset var command = event.getTrimValue("cbox_command","")>
		<cfscript>
			// Verify command
			if( len(command) eq 0 ){ return; }
			// Commands
			switch(command){
				case "expirecache"    : { cbController.getColdboxOCM().expireAll();break;}
				case "delcacheentry"  : { cbController.getColdboxOCM().clearKey(event.getValue('cbox_cacheentry',""));break;}
				case "clearallevents" : { cbController.getColdboxOCM().clearAllEvents();break;}
				case "clearallviews"  : { cbController.getColdboxOCM().clearAllViews();break;}
				default: break;
			}
		</cfscript>
		<!--- TODO: use ses or not? Relocate --->
		<cfif event.getValue("debugPanel","") eq "">
			<cflocation url="index.cfm" addtoken="false">
		<cfelse>
			<cflocation url="index.cfm?debugpanel=#event.getValue('debugPanel','')#" addtoken="false">
		</cfif>
	</cffunction>
	
	<!--- Locate the Application Key --->
	<cffunction name="locateAppKey" access="private" output="false" returntype="string" hint="Get COLDBOX_APP_KEY used in this application">
		<cfscript>
			if( len(trim(COLDBOX_APP_KEY)) ){
				return variables.COLDBOX_APP_KEY;
			}
			else{
				return "cbController";
			}
		</cfscript>
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