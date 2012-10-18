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
	<cffunction name="loadColdbox" access="public" returntype="void" hint="Load the framework, initialize it and execute application start procedures" output="false" >
		<cfscript>
			var appKey = locateAppKey();
			// Cleanup of old code
			if( structkeyExists( application, appKey ) ){
				structDelete( application, appKey );
			}
			// Create Brand New Controller
			application[ appKey ] = CreateObject("component","coldbox.system.web.Controller").init( COLDBOX_APP_ROOT_PATH, appKey );
			// Setup the Framework And Application
			application[ appKey ].getLoaderService().loadApplication( COLDBOX_CONFIG_FILE, COLDBOX_APP_MAPPING );
			// Application Start Handler
			if ( len( application[ appKey ].getSetting("ApplicationStartHandler")) ){
				application[ appKey ].runEvent( application[ appKey ].getSetting("ApplicationStartHandler"), true );
			}
		</cfscript>
	</cffunction>

	<!--- Reload Checks --->
	<cffunction name="reloadChecks" access="public" returntype="void" hint="Reload checks and reload settings." output="false" >
		<cfset var exceptionService = "">
		<cfset var ExceptionBean 	= "">
		<cfset var appKey 			= locateAppKey()>
		<cfset var cbController 	= 0>
		<cfset var needReinit 		= isfwReinit()>

		<!--- Initialize the Controller If Needed, double locked --->
		<cfif NOT structkeyExists(application,appkey) OR NOT application[appKey].getColdboxInitiated() OR needReinit>
			<cflock type="exclusive" name="#instance.appHash#" timeout="#instance.lockTimeout#" throwontimeout="true">
				<cfif NOT structkeyExists(application,appkey) OR NOT application[appKey].getColdboxInitiated() OR needReinit>

					<!--- Verify if we are Reiniting? --->
					<cfif structkeyExists(application,appKey) AND application[appKey].getColdboxInitiated() AND needReinit>
						<!--- Process user interceptors --->
						<cfset application[appKey].getInterceptorService().processState("preReinit")>

						<!--- Shutdown the application services --->
						<cfset application[appKey].getLoaderService().processShutdown()>
					</cfif>

					<!--- Reload ColdBox --->
					<cfset loadColdBox()>
					<cfset structDelete(request,"cb_requestContext")>
				</cfif>
			</cflock>
			<cfreturn>
		</cfif>

		<cftry>
			<!--- Get Controller Reference --->
			<cflock type="readonly" name="#instance.appHash#" timeout="#instance.lockTimeout#" throwontimeout="true">
				<cfset cbController = application[appKey]>
			</cflock>

			<!--- WireBox Singleton AutoReload --->
			<cfif cbController.getSetting("Wirebox").singletonReload>
				<cflock type="exclusive" name="#instance.appHash#" timeout="#instance.lockTimeout#" throwontimeout="true">
					<cfset cbController.getWireBox().clearSingletons()>
				</cflock>
			</cfif>

			<!--- Modules Auto Reload --->
			<cfif cbController.getSetting("ModulesAutoReload")>
				<cflock type="exclusive" name="#instance.appHash#" timeout="#instance.lockTimeout#" throwontimeout="true">
					<cfset cbController.getModuleService().reloadAll()>
				</cflock>
			</cfif>

			<!--- Handler's Index Auto Reload --->
			<cfif cbController.getSetting("HandlersIndexAutoReload")>
				<cflock type="exclusive" name="#instance.appHash#" timeout="#instance.lockTimeout#" throwontimeout="true">
					<cfset cbController.getHandlerService().registerHandlers()>
				</cflock>
			</cfif>

			<!--- IOC Framework Reload --->
			<cfif cbController.getSetting("IOCFrameworkReload")>
				<cflock type="exclusive" name="#instance.appHash#" timeout="#instance.lockTimeout#" throwontimeout="true">
					<cfset cbController.getPlugin("IOC").configure()>
				</cflock>
			</cfif>

			<!--- Trap Framework Errors --->
			<cfcatch type="any">
				<cfset exceptionService = cbController.getExceptionService()>
				<cfset exceptionBean = exceptionService.ExceptionHandler(cfcatch,"framework","Framework Initialization/Configuration Exception")>
				<cfoutput>#exceptionService.renderBugReport(ExceptionBean)#</cfoutput>
				<cfabort>
			</cfcatch>
		</cftry>
	</cffunction>

	<!--- Process A ColdBox Request --->
	<cffunction name="processColdBoxRequest" access="public" returntype="void" hint="Process a Coldbox Request" output="true" >
		<cfset var cbController 	= 0>
		<cfset var event 			= 0>
		<cfset var exceptionService = 0>
		<cfset var exceptionBean 	= 0>
		<cfset var renderedContent  = "">
		<cfset var eventCacheEntry  = 0>
		<cfset var interceptorData  = structnew()>
		<cfset var renderData 	    = structnew()>
		<cfset var refResults 		= structnew()>
		<cfset var debugPanel		= "">
		<cfset var interceptorService = "">

		<!--- Start Application Requests --->
		<cflock type="readonly" name="#instance.appHash#" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfset cbController = application[locateAppKey()]>
		</cflock>

		<!--- Setup Local Vars --->
		<cfset interceptorService 	= cbController.getInterceptorService()>
		<cfset templateCache		= cbController.getColdboxOCM("template")>

		<cftry>
			<!--- set request time --->
			<cfset request.fwExecTime = getTickCount()>

			<!--- Create Request Context & Capture Request --->
			<cfset event = cbController.getRequestService().requestCapture()>

			<!--- Debugging Monitors & Commands Check --->
			<cfif cbController.getDebuggerService().getDebugMode()>

				<!--- ColdBox Command Executions --->
				<cfset coldboxCommands(cbController,event)>

				<!--- Debug Panel rendering --->
				<cfset debugPanel = event.getValue("debugPanel","")>
				<cfswitch expression="#debugPanel#">
					<cfcase value="profiler">
						<cfoutput>#cbController.getDebuggerService().renderProfiler()#</cfoutput>
					</cfcase>
					<cfcase value="cache,cacheReport,cacheContentReport,cacheViewer">
						<cfmodule template="/coldbox/system/cache/report/monitor.cfm"
								  cacheFactory="#cbController.getCacheBox()#">
					</cfcase>
				</cfswitch>
				<!--- Stop Processing, we are rendering a debugger panel --->
				<cfif len(debugPanel)>
					<cfsetting showdebugoutput="false">
					<cfreturn>
				</cfif>
			</cfif>

			<!--- Execute preProcess Interception --->
			<cfset interceptorService.processState("preProcess")>

			<!--- IF Found in config, run onRequestStart Handler --->
			<cfif len(cbController.getSetting("RequestStartHandler"))>
				<cfset cbController.runEvent(cbController.getSetting("RequestStartHandler"),true)>
			</cfif>

			<!--- Before Any Execution, do we have cached content to deliver --->
			<cfif structKeyExists(event.getEventCacheableEntry(), "cachekey")>
				<cfset refResults.eventCaching = templateCache.get( event.getEventCacheableEntry().cacheKey )>
			</cfif>
			<cfif structKeyExists(refResults,"eventCaching")>
				<!--- Is this a renderdata type? --->
				<cfif refResults.eventCaching.renderData>
					<cfset renderDataSetup(argumentCollection=refResults.eventCaching)>
					<cfset event.showDebugPanel(false)>
				</cfif>
				<!--- Render Content as binary or just output --->
				<cfif refResults.eventCaching.isBinary>
					<cfcontent type="#refResults.eventCaching.contentType#" variable="#refResults.eventCaching.renderedContent#" />
				<cfelse>
					<cfoutput>#refResults.eventCaching.renderedContent#</cfoutput>
				</cfif>
				<!--- Authoritative Header --->
				<cfheader statuscode="203" statustext="Non-Authoritative Information" />
			<cfelse>
				<!--- Run Default/Set Event not executing an event --->
				<cfif NOT event.isNoExecution()>
					<cfset refResults.results = cbController.runEvent(default=true)>
				</cfif>

				<!--- No Render Test --->
				<cfif not event.isNoRender()>

					<!--- Execute preLayout Interception --->
					<cfset interceptorService.processState("preLayout")>

					<!--- Check for Marshalling and data render --->
					<cfset renderData = event.getRenderData()>

					<!--- Rendering/Marshalling of content --->
					<cfif isStruct(renderData) and not structisEmpty(renderData)>
						<cfset renderedContent = cbController.getPlugin("Utilities").marshallData(argumentCollection=renderData)>
					<!--- Check for Event Handler return results --->
					<cfelseif structKeyExists(refResults,"results")>
						<cfset renderedContent = refResults.results>
					<cfelse>
						<!--- Render Layout/View pair via set variable to eliminate whitespace--->
						<cfset renderedContent = cbController.getPlugin("Renderer").renderLayout(module=event.getCurrentLayoutModule(),viewModule=event.getCurrentViewModule())>
					</cfif>

					<!--- PreRender Data:--->
					<cfset interceptorData.renderedContent = renderedContent>
					<!--- Execute preRender Interception --->
					<cfset interceptorService.processState("preRender",interceptorData)>
					<!--- Replace back Content From Interception --->
					<cfset renderedContent = interceptorData.renderedContent>

					<!--- Check if caching the event, this is a cacheable event? --->
					<cfset eventCacheEntry = event.getEventCacheableEntry()>
					<cfif structKeyExists(eventCacheEntry,"cacheKey") AND
						  structKeyExists(eventCacheEntry,"timeout") AND
						  structKeyExists(eventCacheEntry,"lastAccessTimeout") >

						<cflock name="#instance.appHash#.caching.#eventCacheEntry.cacheKey#" type="exclusive" timeout="10" throwontimeout="true">
							<!--- Double lock for concurrency --->
							<cfif NOT templateCache.lookup( eventCacheEntry.cacheKey )>

								<!--- Prepare event caching entry --->
								<cfset refResults.eventCachingEntry = {
									renderedContent = renderedContent,
									renderData		= false,
									contentType 	= "",
									encoding		= "",
									statusCode		= "",
									statusText		= "",
									isBinary		= false
								}>

								<!--- Render Data Caching Metadata --->
								<cfif isStruct(renderData) and not structisEmpty(renderData)>
									<cfset refResults.eventCachingEntry.renderData 	= true>
									<cfset refResults.eventCachingEntry.contentType = renderData.contentType>
									<cfset refResults.eventCachingEntry.encoding	= renderData.encoding>
									<cfset refResults.eventCachingEntry.statusCode 	= renderData.statusCode>
									<cfset refResults.eventCachingEntry.statusText	= renderData.statusText>
									<cfset refResults.eventCachingEntry.isBinary	= renderData.isBinary>
								</cfif>

								<!--- Cache the content of the event --->
								<cfset templateCache.set(eventCacheEntry.cacheKey,
														 refResults.eventCachingEntry,
														 eventCacheEntry.timeout,
														 eventCacheEntry.lastAccessTimeout)>
							</cfif>
						</cflock>
					</cfif>

					<!--- Render Data? --->
					<cfif isStruct(renderData) and not structisEmpty(renderData)>
						<cfset event.showDebugPanel(false)>
						<cfset renderDataSetup(argumentCollection=renderData)><!---
						Binary 
						---><cfif renderData.isBinary><cfcontent type="#renderData.contentType#" variable="#renderedContent#" /><!---
						Non Binary
						---><cfelse><cfoutput>#renderedContent#</cfoutput></cfif>
					<!--- Normal HTML --->
					<cfelse>
						<cfoutput>#renderedContent#</cfoutput>
					</cfif>

					<!--- Execute postRender Interception --->
					<cfset interceptorService.processState("postRender")>
				</cfif>

			<!--- End else if not cached event --->
			</cfif>

			<!--- If Found in config, run onRequestEnd Handler --->
			<cfif len(cbController.getSetting("RequestEndHandler"))>
				<cfset cbController.runEvent(cbController.getSetting("RequestEndHandler"),true)>
			</cfif>

			<!--- Execute postProcess Interception --->
			<cfset interceptorService.processState("postProcess")>

			<!--- Save Flash Scope --->
			<cfif cbController.getSetting("flash").autoSave>
				<cfset cbController.getRequestService().getFlashScope().saveFlash()>
			</cfif>

			<!--- Trap Application Errors --->
			<cfcatch type="any">
				<!--- Get Exception Service --->
				<cfset exceptionService = cbController.getExceptionService()>

				<!--- Intercept The Exception --->
				<cfset interceptorData = structnew()>
				<cfset interceptorData.exception = cfcatch>
				<cfset interceptorService.processState("onException",interceptorData)>

				<!--- Handle The Exception --->
				<cfset ExceptionBean = exceptionService.ExceptionHandler(cfcatch,"application","Application Execution Exception")>

				<!--- Render The Exception --->
				<cfoutput>#exceptionService.renderBugReport(ExceptionBean)#</cfoutput>
			</cfcatch>
		</cftry>

		<!--- Time the request --->
		<cfset request.fwExecTime = getTickCount() - request.fwExecTime>

		<!--- DebugMode Routines --->
		<cfif cbController.getDebuggerService().getDebugMode()>
			<!--- Record Profilers --->
			<cfset cbController.getDebuggerService().recordProfiler()>
			<!--- Render DebugPanel --->
			<cfif event.getDebugPanelFlag()>
				<!--- Render Debug Log --->
				<cfoutput>#interceptorService.processState("beforeDebuggerPanel")##cbController.getDebuggerService().renderDebugLog()##interceptorService.processState("afterDebuggerPanel")#</cfoutput>
			</cfif>
		</cfif>
	</cffunction>

	<!--- on Request Start --->
	<cffunction name="onRequestStart" returnType="boolean" output="true">
		<!--- ************************************************************* --->
		<cfargument name="targetPage" type="string" required="true" />
		<!--- ************************************************************* --->
		<!--- Reload Checks --->
		<cfset reloadChecks()>

		<!--- Process A ColdBox Request Only --->
		<cfif findNoCase('index.cfm', listLast(arguments.targetPage, '/'))>
			<cfset processColdBoxRequest()>
		</cfif>

		<!--- WHATEVER YOU WANT BELOW --->
		<cfreturn true>
	</cffunction>

	<!--- renderData --->
    <cffunction name="renderDataSetup" output="false" access="private" returntype="void" hint="Render data items">
		<cfargument name="statusCode" 	type="any" required="true"/>
		<cfargument name="statusText"	type="any" required="true"/>
		<cfargument name="contentType" 	type="any" required="true"/>
		<cfargument name="encoding" 	type="any" required="true"/>

		<!--- Status Codes --->
		<cfheader statuscode="#arguments.statusCode#" statustext="#arguments.statusText#" >
		<!--- Render the Data Content Type --->
		<cfcontent type="#arguments.contentType#; charset=#arguments.encoding#" reset="true">
		<!--- Remove panels --->
		<cfsetting showdebugoutput="false">

	</cffunction>

	<!--- OnMissing Template --->
	<cffunction	name="onMissingTemplate" access="public" returntype="boolean" output="true" hint="I execute when a non-existing CFM page was requested.">
		<cfargument name="template"	type="any" required="true"	hint="I am the template that the user requested."/>
		<cfset var cbController = "">
		<cfset var event = "">
		<cfset var interceptData = structnew()>

		<cflock type="readonly" name="#instance.appHash#" timeout="#instance.lockTimeout#" throwontimeout="true">
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
				onRequestStart("index.cfm");

				// Return processed
				return true;
			}

			return false;
		</cfscript>
	</cffunction>

	<!--- Session Start --->
	<cffunction name="onSessionStart" returnType="void" output="false" hint="An onSessionStart method to use or call from your Application.cfc">
		<cfset var cbController = "">

		<cflock type="readonly" name="#getAppHash()#" timeout="#instance.lockTimeout#" throwontimeout="true">
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

		<cflock type="readonly" name="#getAppHash()#" timeout="#instance.lockTimeout#" throwontimeout="true">
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

	<!--- on Application Start --->
	<cffunction name="onApplicationStart" returnType="boolean" output="false" hint="An onApplicationStart method to use or call from your Application.cfc">
		<cfscript>
			//Load ColdBox
			loadColdBox();
			return true;
		</cfscript>
	</cffunction>

	<!--- Application End --->
	<cffunction name="onApplicationEnd" returnType="void" output="false" hint="An onApplicationEnd method to use or call from your Application.cfc">
		<!--- ************************************************************* --->
		<cfargument name="appScope" 	type="struct" required="false">
		<!--- ************************************************************* --->
		<cfscript>
			var cbController = arguments.appScope[locateAppKey()];

			// Execute Application End interceptors
			cbController.getInterceptorService().processState("applicationEnd");

			// Execute Application End Handler
			if( len(cbController.getSetting('applicationEndHandler')) ){
				cbController.runEvent(event=cbController.getSetting("applicationEndHandler"),prePostExempt=true);
			}

			// Controlled service shutdown operations
			cbController.getLoaderService().processShutdown();
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
		<cfargument name="lockTimeout" type="any" required="true" hint="Numeric"/>
		<cfset instance.lockTimeout = arguments.lockTimeout/>
	</cffunction>
	<!--- Get Lock Timeout --->
	<cffunction name="getLockTimeout" access="public" output="false" returntype="any" hint="Get LockTimeout for inits">
		<cfreturn instance.lockTimeout/>
	</cffunction>

	<!--- FW needs reinit --->
	<cffunction name="isfwReinit" access="public" returntype="any" hint="Verify if we need to reboot the framework. Boolean" output="false" >
		<cfset var reinitPass 	= "">
		<cfset var incomingPass = "">
		<cfset var appKey 		= locateAppKey()>

		<!--- CF Parm Structures just in case. --->
		<cfparam name="FORM" default="#structNew()#">
		<cfparam name="URL"	 default="#structNew()#">

		<cfscript>
			// Check if app exists already in scope
			if(not structKeyExists(application,appKey) ){
				return true;
			}

			// Verify the reinit key is passed
			if ( structKeyExists(url,"fwreinit") or structKeyExists(form,"fwreinit") ){

				// Check if we have a reinit password at hand.
				if ( application[appKey].settingExists("ReinitPassword") ){
					reinitPass = application[appKey].getSetting("ReinitPassword");
				}

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
				if( compare(reinitPass, hash(incomingPass)) eq 0 ){
					return true;
				}
			}//else if reinit found.

			return false;
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- coldboxCommands --->
	<cffunction name="coldboxCommands" output="false" access="private" returntype="void" hint="Execute some coldbox commands">
		<cfargument name="cbController" type="any" required="true" hint="The cb Controller"/>
		<cfargument name="event" 		type="any" required="true" hint="The event context object"/>
		<cfscript>
			var command = event.getTrimValue("cbox_command","");

			// Verify command
			if( NOT len(command) ){ return; }

			// Commands
			switch(command){
				// Module Commands
				case "reloadModules"  : { cbController.getModuleService().reloadAll(); break;}
				case "unloadModules"  : { cbController.getModuleService().unloadAll(); break;}
				case "reloadModule"   : { cbController.getModuleService().reload(event.getValue("module","")); break;}
				case "unloadModule"   : { cbController.getModuleService().unload(event.getValue("module","")); break;}
				default: return;
			}
		</cfscript>
		<!--- Relocate to correct URL --->
		<cfif event.getValue("debugPanel","") eq "">
			<cflocation url="#listlast(cgi.script_name,"/")#" addtoken="false">
		<cfelse>
			<cflocation url="#listlast(cgi.script_name,"/")#?debugpanel=#event.getValue('debugPanel','')#" addtoken="false">
		</cfif>
	</cffunction>

	<!--- Locate the Application Key --->
	<cffunction name="locateAppKey" access="private" output="false" returntype="any" hint="Get COLDBOX_APP_KEY used in this application">
		<cfscript>
			if( len(trim(COLDBOX_APP_KEY)) ){
				return variables.COLDBOX_APP_KEY;
			}
			return "cbController";
		</cfscript>
	</cffunction>

	<!--- AppHash --->
	<cffunction name="getAppHash" access="public" output="false" returntype="any" hint="Get AppHash used in the cflocks">
		<cfreturn instance.appHash/>
	</cffunction>
	<cffunction name="setAppHash" access="public" output="false" returntype="void" hint="Set AppHash used in the cflocks">
		<cfargument name="appHash" type="any" required="true"/>
		<cfset instance.appHash = arguments.appHash/>
	</cffunction>

</cfcomponent>