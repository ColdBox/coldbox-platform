<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 		: Luis Majano
Date     		: September 23, 2005
Description		: 

This is the ColdBox Front Controller that dispatches events and manages your ColdBox application.  
Only one instance of a specific ColdBox application exists.

----------------------------------------------------------------------->
<cfcomponent name="controller" hint="This is the ColdBox Front Controller that dispatches events and manages your ColdBox application." output="false" serializable="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		instance = structnew();
		services = structnew();
	</cfscript>

	<cffunction name="init" returntype="coldbox.system.Controller" access="Public" hint="Constructor" output="false">
		<cfargument name="AppRootPath" type="string" required="true" hint="The app Root Path"/>
		<cfscript>
			
			//Public Available Engine Utility
			this.oCFMLENGINE = CreateObject("component","coldbox.system.util.CFMLEngine").init();
			
			// Set Main Application Properties
			setColdboxInitiated(false);
			setAspectsInitiated(false);
			setAppStartHandlerFired(false);
			setAppHash( hash(arguments.AppRootPath) );
			setAppRootPath(arguments.AppRootPath);
			
			// Init Configuration structures
			setConfigSettings(structnew());
			setColdboxSettings(structnew());
			
			// Setup the ColdBox Services
			setLoaderService( CreateObject("component", "coldbox.system.services.LoaderService").init(this) );
			setRequestService( CreateObject("component","coldbox.system.services.RequestService").init(this) );
			setDebuggerService( CreateObject("component","coldbox.system.services.DebuggerService").init(this) );
			setPluginService( CreateObject("component","coldbox.system.services.PluginService").init(this) );
			setInterceptorService( CreateObject("component", "coldbox.system.services.InterceptorService").init(this) );
			setHandlerService( CreateObject("component", "coldbox.system.services.HandlerService").init(this) );
			
			// LogBox Configuration & Creation
			setLogBox(getLoaderService().createLogBox());
			setLogger(getLogBox().getLogger("coldbox.system.Controller"));
			
			// Log Creation
			getLogger().info("ColdBox Application Controller Created Successfully at #arguments.appRootPath#");
			//Return instance
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- getLogBox --->
	<cffunction name="getLogBox" output="false" access="public" returntype="coldbox.system.logging.LogBox" hint="Get the application's LogBox instance">
		<cfreturn instance.logBox>
	</cffunction>
	<cffunction name="setLogBox" output="false" access="public" returntype="void" hint="Set the logBox instance">
		<cfargument name="logBox" type="coldbox.system.logging.LogBox" required="true" default="" hint="The logBox instance"/>
		<cfset instance.logBox = arguments.logBox>
	</cffunction>
	
	<!--- This class's logger object --->
	<cffunction name="getLogger" access="public" returntype="coldbox.system.logging.Logger" output="false" hint="The coldbox controller logger">
		<cfreturn instance.logger>
	</cffunction>
	<cffunction name="setLogger" access="public" returntype="void" output="false" hint="Set the coldbox controller logger">
		<cfargument name="logger" type="coldbox.system.logging.Logger" required="true">
		<cfset instance.logger = arguments.logger>
	</cffunction>
	
	<!--- getServices --->
	<cffunction name="getServices" output="false" access="public" returntype="struct" hint="Get all the registered services">
		<cfreturn services>
	</cffunction>
	
	<!--- AppRootPath --->
	<cffunction name="getAppRootPath" access="public" returntype="string" output="false" hint="Get this application's physical path">
		<cfreturn instance.AppRootPath>
	</cffunction>
	<cffunction name="setAppRootPath" access="public" returntype="void" output="false" hint="Set this application's physical path.">
		<cfargument name="AppRootPath" type="string" required="true">
		<cfset instance.AppRootPath = arguments.AppRootPath>
	</cffunction>
	
	<!--- ColdBox Cache Manager --->
	<cffunction name="getColdboxOCM" access="public" output="false" returntype="any" hint="Get ColdboxOCM: coldbox.system.cache.CacheManager">
		<cfreturn instance.ColdboxOCM/>
	</cffunction>
	<cffunction name="setColdboxOCM" access="public" output="false" returntype="void" hint="Set ColdboxOCM">
		<cfargument name="ColdboxOCM" type="any" required="true" hint="coldbox.system.cache.CacheManager"/>
		<cfset instance.ColdboxOCM = arguments.ColdboxOCM/>
	</cffunction>
	
	<!--- Loader Service --->
	<cffunction name="getLoaderService" access="public" output="false" returntype="any" hint="Get LoaderService: coldbox.system.services.LoaderService">
		<cfreturn services.LoaderService/>
	</cffunction>
	<cffunction name="setLoaderService" access="public" output="false" returntype="void" hint="Set LoaderService">
		<cfargument name="LoaderService" type="any" required="true"/>
		<cfset services.LoaderService = arguments.LoaderService/>
	</cffunction>
	
	<!--- Exception Service --->
	<cffunction name="getExceptionService" access="public" output="false" returntype="any" hint="Get ExceptionService: coldbox.system.services.ExceptionService">
		<cfreturn CreateObject("component", "coldbox.system.services.ExceptionService").init(this)/>
	</cffunction>
	
	<!--- Request Service --->
	<cffunction name="getRequestService" access="public" output="false" returntype="any" hint="Get RequestService: coldbox.system.services.RequestService">
		<cfreturn services.RequestService/>
	</cffunction>
	<cffunction name="setRequestService" access="public" output="false" returntype="void" hint="Set RequestService">
		<cfargument name="RequestService" type="any" required="true"/>
		<cfset services.RequestService = arguments.RequestService/>
	</cffunction>
	
	<!--- Debugger Service --->
	<cffunction name="getDebuggerService" access="public" output="false" returntype="any" hint="Get DebuggerService: coldbox.system.services.DebuggerService">
		<cfreturn services.DebuggerService/>
	</cffunction>
	<cffunction name="setDebuggerService" access="public" output="false" returntype="void" hint="Set DebuggerService">
		<cfargument name="DebuggerService" type="any" required="true"/>
		<cfset services.DebuggerService = arguments.DebuggerService/>
	</cffunction>
	
	<!--- Plugin Service --->
	<cffunction name="getPluginService" access="public" output="false" returntype="any" hint="Get PluginService: coldbox.system.services.PluginService">
		<cfreturn services.PluginService/>
	</cffunction>
	<cffunction name="setPluginService" access="public" output="false" returntype="void" hint="Set PluginService">
		<cfargument name="PluginService" type="Any" required="true"/>
		<cfset services.PluginService = arguments.PluginService/>
	</cffunction>
	
	<!--- Interceptor Service --->
	<cffunction name="getInterceptorService" access="public" output="false" returntype="any" hint="Get interceptorService: coldbox.system.services.InterceptorService">
		<cfreturn services.interceptorService/>
	</cffunction>	
	<cffunction name="setInterceptorService" access="public" output="false" returntype="void" hint="Set interceptorService">
		<cfargument name="interceptorService" type="any" required="true"/>
		<cfset services.interceptorService = arguments.interceptorService/>
	</cffunction>

	<!--- Handler Service --->
	<cffunction name="getHandlerService" access="public" output="false" returntype="any" hint="Get HandlerService: coldbox.system.services.HandlerService">
		<cfreturn services.HandlerService/>
	</cffunction>
	<cffunction name="setHandlerService" access="public" output="false" returntype="void" hint="Set HandlerService">
		<cfargument name="HandlerService" type="any" required="true"/>
		<cfset services.HandlerService = arguments.HandlerService/>
	</cffunction>
	
	<!--- Getter & Setter Internal Configuration Structures --->
	<cffunction name="getConfigSettings" access="public" returntype="struct" output="false" hint="I retrieve the Config Settings Structure by Reference">
		<cfreturn instance.ConfigSettings>
	</cffunction>
	<cffunction name="setConfigSettings" access="public" output="false" returntype="void" hint="Set ConfigSettings">
		<cfargument name="ConfigSettings" type="struct" required="true"/>
		<cfset instance.ConfigSettings = arguments.ConfigSettings/>
	</cffunction>
	<cffunction name="getColdboxSettings" access="public" returntype="struct" output="false" hint="I retrieve the ColdBox Settings Structure by Reference">
		<cfreturn instance.ColdboxSettings>
	</cffunction>
	<cffunction name="setColdboxSettings" access="public" output="false" returntype="void" hint="Set ColdboxSettings">
		<cfargument name="ColdboxSettings" type="struct" required="true"/>
		<cfset instance.ColdboxSettings = arguments.ColdboxSettings/>
	</cffunction>

	<!--- ColdBox Initiation Flag --->
	<cffunction name="getColdboxInitiated" access="public" output="false" returntype="boolean" hint="Get ColdboxInitiated">
		<cfreturn instance.ColdboxInitiated/>
	</cffunction>
	<cffunction name="setColdboxInitiated" access="public" output="false" returntype="void" hint="Set ColdboxInitiated">
		<cfargument name="ColdboxInitiated" type="boolean" required="true"/>
		<cfset instance.ColdboxInitiated = arguments.ColdboxInitiated/>
	</cffunction>
	
	<!--- Aspects Initiated Flag --->
	<cffunction name="getAspectsInitiated" access="public" output="false" returntype="boolean" hint="Get AspectsInitiated">
		<cfreturn instance.AspectsInitiated/>
	</cffunction>	
	<cffunction name="setAspectsInitiated" access="public" output="false" returntype="void" hint="Set AspectsInitiated">
		<cfargument name="AspectsInitiated" type="boolean" required="true"/>
		<cfset instance.AspectsInitiated = arguments.AspectsInitiated/>
	</cffunction>

	<!--- App hash --->
	<cffunction name="getAppHash" access="public" output="false" returntype="string" hint="Get AppHash">
		<cfreturn instance.AppHash/>
	</cffunction>
	<cffunction name="setAppHash" access="public" output="false" returntype="void" hint="Set AppHash">
		<cfargument name="AppHash" type="string" required="true"/>
		<cfset instance.AppHash = arguments.AppHash/>
	</cffunction>
	
	<!--- Accessor/Mutator App Start Handler Fired --->
	<cffunction name="setAppStartHandlerFired" access="public" output="false" returntype="void" hint="Set AppStartHandlerFired">
		<cfargument name="AppStartHandlerFired" type="boolean" required="true"/>
		<cfset instance.AppStartHandlerFired = arguments.AppStartHandlerFired/>
	</cffunction>
	<cffunction name="getAppStartHandlerFired" access="public" output="false" returntype="boolean" hint="Get AppStartHandlerFired">
		<cfreturn instance.AppStartHandlerFired/>
	</cffunction>

	<!--- Config Structures Accessors/Mutators --->
	<cffunction name="getSettingStructure" hint="Compatability & Utility Method. By default I retrieve the Config Settings. You can change this by using the FWSetting flag." access="public" returntype="struct" output="false">
		<!--- ************************************************************* --->
		<cfargument name="FWSetting"  	type="boolean" 	 required="false"  hint="Boolean Flag. If true, it will retrieve from the fwSettingsStruct else the configStruct. Default is false." default="false">
		<cfargument name="DeepCopyFlag" hint="Default is false. True, creates a deep copy of the structure." type="boolean" required="no" default="false">
		<!--- ************************************************************* --->
		<cfscript>
		if (arguments.FWSetting){
			if (arguments.DeepCopyFlag)
				return duplicate(instance.ColdboxSettings);
			else
				return instance.ColdboxSettings;
		}
		else{
			if (arguments.DeepCopyFlag)
				return duplicate(instance.ConfigSettings);
			else
				return instance.ConfigSettings;
		}
		</cfscript>
	</cffunction>
	<cffunction name="getSetting" hint="I get a setting from the FW Config structures. Use the FWSetting boolean argument to retrieve from the fwSettingsStruct." access="public" returntype="any" output="false">
		<cfargument name="name" 	    type="string"   	hint="Name of the setting key to retrieve"  >
		<cfargument name="FWSetting"  	type="boolean" 	 	required="false"  hint="Boolean Flag. If true, it will retrieve from the fwSettingsStruct else from the configStruct. Default is false." default="false">
		<!--- ************************************************************* --->
		<cfscript>
		if ( arguments.FWSetting and settingExists(arguments.name,true) )
			return instance.ColdboxSettings[arguments.name];
		else if ( settingExists(arguments.name) )
			 return instance.ConfigSettings[arguments.name];
		else
			getUtil().throwit("The setting #arguments.name# does not exist.","FWSetting flag is #arguments.FWSetting#","Framework.SettingNotFoundException");
		</cfscript>
	</cffunction>
	<cffunction name="settingExists" returntype="boolean" access="Public"	hint="I Check if a value exists in the configstruct or the fwsettingsStruct." output="false">
		<cfargument name="name" hint="Name of the setting to find." type="string">
		<cfargument name="FWSetting"  	type="boolean" 	 required="false"  hint="Boolean Flag. If true, it will retrieve from the fwSettingsStruct else from the configStruct. Default is false." default="false">
		<!--- ************************************************************* --->
		<cfscript>
		if (arguments.FWSetting){
			return structKeyExists(instance.ColdboxSettings,arguments.name);
		}
		else{
			return structKeyExists(instance.ConfigSettings, arguments.name);
		}
		</cfscript>
	</cffunction>
	<cffunction name="setSetting" access="Public" returntype="void" hint="I set a Global Coldbox setting variable in the configstruct, if it exists it will be overrided. This only sets in the ConfigStruct" output="false">
		<cfargument name="name"  type="string"   hint="The name of the setting" >
		<cfargument name="value" type="any"      hint="The value of the setting (Can be simple or complex)">
		<!--- ************************************************************* --->
		<cfscript>
		instance.ConfigSettings['#arguments.name#'] = arguments.value;
		</cfscript>
	</cffunction>

	<!--- Minimalistic Service Locator for rarely used services --->
	<cffunction name="getService" access="public" output="false" returntype="any" hint="DEPRECATED: Internal ColdBox Transient Minimalistic Service Locator.">
		<cfargument name="service" type="string" required="true" hint="The transient service/manager to create.">
		<cfscript>
		switch(arguments.service){
			//Loader
			case "loader":
				return getLoaderService();
				break;
			case "exception":
				return getExceptionService();
				break;
			//Default Case
			default:
				getUtil().throwit("Invalid Service detected","service:#arguments.service#","Framework.ServiceNotDefinedException");
		}
		</cfscript>
	</cffunction>

	<!--- Plugin Factories --->
	<cffunction name="getPlugin" access="Public" returntype="any" hint="I am the Plugin cfc object factory." output="false">
		<cfargument name="plugin" 		type="string"  hint="The Plugin object's name to instantiate" >
		<cfargument name="customPlugin" type="boolean" required="false" default="false" hint="Used internally to create custom plugins.">
		<cfargument name="newInstance"  type="boolean" required="false" default="false" hint="If true, it will create and return a new plugin. No caching or persistance.">
		<!--- ************************************************************* --->
		<cfscript>
		if ( arguments.newInstance ){
			return getPluginService().new(arguments.plugin,arguments.customPlugin);
		}
		else{
			return getPluginService().get(arguments.plugin,arguments.customPlugin);
		}
		</cfscript>		
	</cffunction>

	<!--- Set Next Event --->
	<cffunction name="setNextEvent" access="Public" returntype="void" hint="I Set the next event to run and relocate the browser to that event. If you are in SES mode, this method will use routing instead"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event"  			required="false" type="string" default="#getSetting("DefaultEvent")#" hint="The name of the event to run.">
		<cfargument name="queryString"  	required="false" type="string"  default="" hint="The query string to append, if needed.">
		<cfargument name="addToken"			required="false" type="boolean" default="false"	hint="Wether to add the tokens or not. Default is false">
		<cfargument name="persist" 			required="false" type="string" default="" hint="What request collection keys to persist in flash ram">
		<cfargument name="varStruct" 		required="false" type="struct" hint="A structure key-value pairs to persist in flash ram.">
		<cfargument name="ssl"				required="false" type="boolean" default="false"	hint="Whether to relocate in SSL or not">
		<cfargument name="baseURL" 			required="false" type="string" default="" hint="Use this baseURL instead of the index.cfm that is used by default. You can use this for ssl or any full base url you would like to use. Ex: https://mysite.com/index.cfm"/>
		<cfargument name="postProcessExempt"  type="boolean" required="false" default="false" hint="Do not fire the postProcess interceptors">
		<!--- ************************************************************* --->
		<cfset var EventName = getSetting("EventName")>
		<cfset var frontController = listlast(cgi.script_name,"/")>
		<cfset var oRequestContext = getRequestService().getContext()>
		<cfset var routeString = 0>
		
		<!--- Front Controller Base URL --->
		<cfif len(trim(arguments.baseURL)) neq 0>
			<cfset frontController = arguments.baseURL>
		</cfif>
		
		<!--- Cleanup Event --->
		<cfif len(trim(arguments.event)) eq 0>
			<cfset arguments.event = getSetting("DefaultEvent")>
		</cfif>
		
		<!--- Are we in SES Mode? --->
		<cfif oRequestContext.isSES()>
			<!--- setup the route --->
			<cfset routeString = replace(arguments.event,".","/","all")>
			<cfif len(trim(arguments.queryString))>
				<cfset routeString = routeString & "/" & replace(arguments.queryString,"&","/","all")>
				<cfset routeString = replace(routeString,"=","/","all")>
			</cfif>
			<!--- Relocate with routing --->
			<cfset setNextRoute(route=routeString,
						 		persist=arguments.persist,varStruct=arguments.varStruct,
						 		addToken=arguments.addToken,
						 		ssl=arguments.ssl)>		
		<cfelse>
			<!--- Persistance Logic --->
			<cfset persistVariables(argumentCollection=arguments)>
			<!--- Push Timers --->
			<cfset pushTimers()>
			
			<!--- Post Process --->
			<cfif arguments.postProcessExempt>
				<cfset getInterceptorService().processState("postProcess")>
			</cfif>
			
			<!--- Check if query String needs appending --->
			<cfif len(trim(arguments.queryString)) eq 0>
				<cflocation url="#frontController#?#EventName#=#arguments.event#" addtoken="#arguments.addToken#">
			<cfelse>
				<cflocation url="#frontController#?#EventName#=#arguments.event#&#arguments.queryString#" addtoken="#arguments.addToken#">
			</cfif>		
		</cfif>
	</cffunction>
	
	<!--- Set Next Route --->
	<cffunction name="setNextRoute" access="Public" returntype="void" hint="I Set the next ses route to relocate to. This method pre-pends the baseURL"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="route"  		required="true"	 type="string" hint="The route to relocate to, do not prepend the baseURL or /.">
		<cfargument name="persist" 		required="false" type="string" default="" hint="What request collection keys to persist in flash ram">
		<cfargument name="varStruct" 	required="false" type="struct" hint="A structure key-value pairs to persist in flash ram.">
		<cfargument name="addToken"		required="false" type="boolean" default="false"	hint="Wether to add the tokens or not. Default is false">
		<cfargument name="ssl"			required="false" type="boolean" default="false"	hint="Whether to relocate in SSL or not">
		<cfargument name="queryString"  required="false" type="string"  default="" hint="The query string to append, if needed.">
		<cfargument name="postProcessExempt"  type="boolean" required="false" default="false" hint="Do not fire the postProcess interceptors">
		<!--- ************************************************************* --->
		<cfset var routeLocation = getSetting("sesBaseURL")>
		
		<!--- SSL --->
		<cfif arguments.ssl>
			<cfset routeLocation = replacenocase(routeLocation,"http:","https:")>
		</cfif>
		
		<!--- Persistance Logic --->
		<cfset persistVariables(argumentCollection=arguments)>
		
		<!--- Create Route --->
		<cfif right(routeLocation,1) eq "/">
			<cfset routeLocation = routeLocation & arguments.route>
		<cfelse>
			<cfset routeLocation = routeLocation & "/" & arguments.route>
		</cfif>
		
		<!--- Query String --->
		<cfif len(trim(arguments.queryString))>
			<cfset routeLocation = routeLocation & "/" & replace(arguments.queryString,"&","/","all")>
			<cfset routeLocation = replace(routeLocation,"=","/","all")>
		</cfif>
		
		<!--- Push Timers --->
		<cfset pushTimers()>
		
		<!--- Post PRocess --->
		<cfif arguments.postProcessExempt>
			<cfset getInterceptorService().processState("postProcess")>
		</cfif>
			
		<!--- Reroute --->
		<cflocation url="#routeLocation#" addtoken="#arguments.addToken#">
	</cffunction>
	
	<!--- Event Service Locator Factory --->
	<cffunction name="runEvent" returntype="any" access="Public" hint="I am an event handler runnable factory. If no event is passed in then it will run the default event from the config file.">
		<!--- ************************************************************* --->
		<cfargument name="event"         type="any" 	required="false" default="" 	 hint="The event to run as a string. If no current event is set, use the default event from the config.xml. This is a string">
		<cfargument name="prepostExempt" type="boolean" required="false" default="false" hint="If true, pre/post handlers will not be fired.">
		<cfargument name="private" 		 type="boolean" required="false" default="false" hint="Execute a private event or not, default is false"/>
		<cfargument name="default" 		 type="boolean" required="false" default="false" hint="The flag that let's this service now if it is the default set event running or not. USED BY THE FRAMEWORK ONLY">
		<!--- ************************************************************* --->
		<cfset var oEventHandler = "">
		<cfset var oEventHandlerBean = "">
		<cfset var oRequestContext = getRequestService().getContext()>
		<cfset var interceptMetadata = structnew()>
		<cfset var refLocal = structnew()>
		<cfset var privateArgCollection = structnew()>
		<cfset var timerHash = 0>
		
		<!--- Default Event Check --->
		<cfif len(trim(arguments.event)) eq 0>
			<cfset arguments.event = oRequestContext.getCurrentEvent()>
		</cfif>
		
		<!--- Validate the incoming event and get a Handler Bean simulating the event to execute --->
		<cfset oEventHandlerBean = getHandlerService().getRegisteredHandler(arguments.event)>
		<!--- Private Event or Not? --->
		<cfset oEventHandlerBean.setisPrivate(arguments.private)>
		<!--- Get the event handler to execute --->
		<cfset oEventHandler = getHandlerService().getHandler(oEventHandlerBean,oRequestContext)>
		
		<!--- InterceptMetadata --->
		<cfset interceptMetadata.processedEvent = arguments.event>
		<!--- Execute preEvent Interception --->
		<cfif not arguments.prepostExempt>
			<cfset getInterceptorService().processState("preEvent",interceptMetadata)>
		</cfif>		
		
		<cftry>
			<!--- Determine if it is an Allowed HTTP Method to Execute the requested action --->
			<cfif NOT structIsEmpty(oEventHandler.allowedMethods) AND
				  structKeyExists(oEventHandler.allowedMethods,oEventHandlerBean.getMethod()) AND
				  NOT listFindNoCase(oEventHandler.allowedMethods[oEventHandlerBean.getMethod()],oRequestContext.getHTTPMethod())>
				
				<cfset throwInvalidHTTP("The requested event: #event# cannot be executed using the incoming HTTP request method '#oRequestContext.getHTTPMethod()#'.")>
			
			</cfif>
			
			<!--- PreHandler Execution --->
			<cfif not arguments.prepostExempt and oEventHandler._actionExists("preHandler")>
				<!--- Validate ONLY & EXCEPT lists --->
				<cfif ( (len(oEventHandler.PREHANDLER_ONLY) AND listfindnocase(oEventHandler.PREHANDLER_ONLY,oEventHandlerBean.getMethod())) 
					     OR 
					    (len(oEventHandler.PREHANDLER_ONLY) EQ 0) )
					  AND
					  ( listFindNoCase(oEventHandler.PREHANDLER_EXCEPT,oEventHandlerBean.getMethod()) EQ 0 )>
					<cfset timerHash = getDebuggerService().timerStart("invoking runEvent [preHandler] for #arguments.event#")>
						<!--- Execute the preHandler() action --->
						<cfset oEventHandler.preHandler(oRequestContext,oEventHandlerBean.getMethod())>
					<cfset getDebuggerService().timerEnd(timerHash)>
				</cfif>
			</cfif>
			
			<!--- Verify if event was overriden --->
			<cfif (arguments.default) and (arguments.event neq oRequestContext.getCurrentEvent())>
				<!--- Validate the overriden event --->
				<cfset oEventHandlerBean = getHandlerService().getRegisteredHandler(oRequestContext.getCurrentEvent())>
				<!--- Get the new event handler to execute --->
				<cfset oEventHandler = getHandlerService().getHandler(oEventHandlerBean,oRequestContext)>
			</cfif>
	
			<!--- Private or Public Event Execution --->
			<cfif arguments.private>
				<!--- Private Arg Collection --->
				<cfset privateArgCollection["event"] = oRequestContext>
				
				<!--- Start Timer --->
				<cfset timerHash = getDebuggerService().timerStart("invoking PRIVATE runEvent [#arguments.event#]")>
					<!--- Call Private Event --->
					<cfinvoke component="#oEventHandler#" method="_privateInvoker" returnvariable="refLocal.results">
						<cfinvokeargument name="method" value="#oEventHandlerBean.getMethod()#">
						<cfinvokeargument name="argCollection" value="#privateArgCollection#">
					</cfinvoke>
				<cfset getDebuggerService().timerEnd(timerHash)>
				
			<cfelse>
				<!--- Start Timer --->
				<cfset timerHash = getDebuggerService().timerStart("invoking runEvent [#arguments.event#]")>
					<cfif oEventHandlerBean.getisMissingAction()>
						<!--- Execute OnMissingACtion() --->
						<cfinvoke component="#oEventHandler#" method="onMissingAction" returnvariable="refLocal.results">
							<cfinvokeargument name="event" 			value="#oRequestContext#">
							<cfinvokeargument name="missingAction"  value="#oEventHandlerBean.getMissingAction()#">
						</cfinvoke>
					<cfelse>
						<!--- Execute the Public Event --->
						<cfinvoke component="#oEventHandler#" method="#oEventHandlerBean.getMethod()#" returnvariable="refLocal.results">
							<cfinvokeargument name="event" value="#oRequestContext#">
						</cfinvoke>
					</cfif>
				<cfset getDebuggerService().timerEnd(timerHash)>
			</cfif>	
	
			<!--- PostHandler Execution --->
			<cfif not arguments.prepostExempt and oEventHandler._actionExists("postHandler")>
				<cfif ( (len(oEventHandler.POSTHANDLER_ONLY) AND listfindnocase(oEventHandler.POSTHANDLER_ONLY,oEventHandlerBean.getMethod())) 
					     OR 
					    (len(oEventHandler.POSTHANDLER_ONLY) EQ 0) )
					  AND
					  ( listFindNoCase(oEventHandler.POSTHANDLER_EXCEPT,oEventHandlerBean.getMethod()) EQ 0 )>
					<cfset timerHash = getDebuggerService().timerStart("invoking runEvent [postHandler] for #arguments.event#")>
						<!--- Execute the postHandler() action --->
						<cfset oEventHandler.postHandler(oRequestContext,oEventHandlerBean.getMethod())>
					<cfset getDebuggerService().timerEnd(timerHash)>
				</cfif>
			</cfif>
			
			<cfcatch type="any">
				<!--- Check if onError Exists --->
				<cfif oEventHandler._actionExists("onError")>
					<cfset oEventHandler.onError(oRequestContext,oEventHandlerBean.getmethod(),cfcatch)>
				<cfelse>
					<cfrethrow>
				</cfif>
			</cfcatch>
		</cftry>
		
		<!--- Execute postEvent Interception --->
		<cfif not arguments.prepostExempt>
			<cfset getInterceptorService().processState("postEvent",interceptMetadata)>
		</cfif>
		
		<!--- Return Results for proxy if needed. --->
		<cfif structKeyExists(refLocal,"results")>
			<cfreturn refLocal.results>
		</cfif>
	</cffunction>

	<!--- Flash Perist variables. --->
	<cffunction name="persistVariables" access="public" returntype="void" hint="Persist variables for flash redirections, it can use a structure of name-value pairs or keys from the request collection" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="persist" 	 	required="false" type="string" default="" hint="What request collection keys to persist in the relocation. Keys must exist in the relocation">
		<cfargument name="varStruct" 	required="false" type="struct" hint="A structure of key-value pairs to persist.">
		<!--- ************************************************************* --->
		<cfset var PersistList = trim(arguments.persist)>
		<cfset var tempPersistValue = "">
		<cfset var PersistStruct = structnew()>
		<cfset var rc = getRequestService().getContext().getCollection()>
		<cfset var i = 0>
		<cfset var oStorage = 0>
		
		<!--- Persistance Logic --->
		<cfloop list="#PersistList#" index="tempPersistValue">
			<!--- Check that it exists in the collection --->
			<cfif structkeyExists(rc, tempPersistValue)>
				<cfset PersistStruct[tempPersistValue] = rc[tempPersistValue]>
			</cfif>
		</cfloop>
		
		<!--- Verify varStruct --->
		<cfif structKeyExists(arguments,"varStruct")>
			<cfset structAppend(PersistStruct, arguments.varStruct,true)>
		</cfif>
		
		<!--- Flash Save it --->
		<cfif getSetting("FlashURLPersistScope",1) eq "session">
			<cfset oStorage = getPlugin("SessionStorage")>
		<cfelse>
			<cfset oStorage = getPlugin("ClientStorage")>
		</cfif>
		
		<!--- Check for Existance --->
		<cfif oStorage.exists('_coldbox_persistStruct')>
			<cfset structAppend( oStorage.getVar('_coldbox_persistStruct'), PersistStruct,true)>
		<cfelse>
			<cfset oStorage.setVar('_coldbox_persistStruct', PersistStruct)>
		</cfif>		
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Get the util object --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.util.Util" hint="Create and return a util object">
		<cfreturn CreateObject("component","coldbox.system.util.Util")/>
	</cffunction>
	
	<!--- Push Timers --->
	<cffunction name="pushTimers" access="private" returntype="void" hint="Push timers into stack" output="false" >
		<cfset getDebuggerService().recordProfiler()>
	</cffunction>
	
	<!--- throwInvalidHTTP --->
    <cffunction name="throwInvalidHTTP" output="false" access="private" returntype="void" hint="Throw an invalid HTTP exception">
    	<cfargument name="description" type="string" required="true" hint="The exception description"/>
		<cfheader statuscode="403" statustext="403 Invalid HTTP Method Exception">
		<cfthrow type="ColdBox.403" 
			     errorcode="403"
			     message="403 Invalid HTTP Method Exception"
				 detail="#arguments.description#">
    </cffunction>
	
</cfcomponent>