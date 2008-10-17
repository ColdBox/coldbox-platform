<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 		: Luis Majano
Date     		: September 23, 2005
Description		: This is the main ColdBox front Controller.
----------------------------------------------------------------------->
<cfcomponent name="controller" hint="This is the ColdBox Front Controller." output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		variables.instance = structnew();
	</cfscript>

	<cffunction name="init" returntype="coldbox.system.controller" access="Public" hint="I am the constructor" output="false">
		<cfargument name="AppRootPath" type="string" required="true" hint="The app Root Path"/>
		<cfscript>
			//Public Variable.
			this.oCFMLENGINE = CreateObject("component","coldbox.system.util.CFMLEngine").init();
			
			//properties
			setColdboxInitiated(false);
			setAspectsInitiated(false);
			setConfigSettings(structnew());
			setColdboxSettings(structnew());
			setAppStartHandlerFired(false);
			
			//Set the Application hash on creation
			setAppHash( hash(arguments.AppRootPath) );
			//App Root
			setAppRootPath(arguments.AppRootPath);
			
			//TODO: change all this to object factory.
			//Create & init ColdBox Services
			if ( this.oCFMLENGINE.isMT() ){
				setColdboxOCM( CreateObject("component","coldbox.system.cache.MTcacheManager").init(this) );
			}
			else{
				setColdboxOCM( CreateObject("component","coldbox.system.cache.cacheManager").init(this) );
			}
			//Setup the rest of the services.
			setLoaderService( CreateObject("component", "coldbox.system.services.loaderService").init(this) );
			setRequestService( CreateObject("component","coldbox.system.services.requestService").init(this) );
			setDebuggerService( CreateObject("component","coldbox.system.services.debuggerService").init(this) );
			setPluginService( CreateObject("component","coldbox.system.services.pluginService").init(this) );
			setInterceptorService( CreateObject("component", "coldbox.system.services.interceptorService").init(this) );
			setHandlerService( CreateObject("component", "coldbox.system.services.handlerService").init(this) );
			
			//Return instance
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- AppRootPath --->
	<cffunction name="getAppRootPath" access="public" returntype="string" output="false" hint="Get this application's physical path">
		<cfreturn instance.AppRootPath>
	</cffunction>
	<cffunction name="setAppRootPath" access="public" returntype="void" output="false" hint="Set this application's physical path.">
		<cfargument name="AppRootPath" type="string" required="true">
		<cfset instance.AppRootPath = arguments.AppRootPath>
	</cffunction>
	
	<!--- ColdBox Cache Manager --->
	<cffunction name="getColdboxOCM" access="public" output="false" returntype="any" hint="Get ColdboxOCM: coldbox.system.cache.cacheManager">
		<cfreturn instance.ColdboxOCM/>
	</cffunction>
	<cffunction name="setColdboxOCM" access="public" output="false" returntype="void" hint="Set ColdboxOCM">
		<cfargument name="ColdboxOCM" type="any" required="true" hint="coldbox.system.cache.cacheManager"/>
		<cfset instance.ColdboxOCM = arguments.ColdboxOCM/>
	</cffunction>
	
	<!--- Loader Service --->
	<cffunction name="getLoaderService" access="public" output="false" returntype="any" hint="Get LoaderService: coldbox.system.services.loaderService">
		<cfreturn instance.LoaderService/>
	</cffunction>
	<cffunction name="setLoaderService" access="public" output="false" returntype="void" hint="Set LoaderService">
		<cfargument name="LoaderService" type="any" required="true"/>
		<cfset instance.LoaderService = arguments.LoaderService/>
	</cffunction>
	
	<!--- Exception Service --->
	<cffunction name="getExceptionService" access="public" output="false" returntype="any" hint="Get ExceptionService: coldbox.system.services.exceptionService">
		<cfreturn CreateObject("component", "coldbox.system.services.exceptionService").init(this)/>
	</cffunction>
	
	<!--- Request Service --->
	<cffunction name="getRequestService" access="public" output="false" returntype="any" hint="Get RequestService: coldbox.system.services.requestService">
		<cfreturn instance.RequestService/>
	</cffunction>
	<cffunction name="setRequestService" access="public" output="false" returntype="void" hint="Set RequestService">
		<cfargument name="RequestService" type="any" required="true"/>
		<cfset instance.RequestService = arguments.RequestService/>
	</cffunction>
	
	<!--- Debugger Service --->
	<cffunction name="getDebuggerService" access="public" output="false" returntype="any" hint="Get DebuggerService: coldbox.system.services.debuggerService">
		<cfreturn instance.DebuggerService/>
	</cffunction>
	<cffunction name="setDebuggerService" access="public" output="false" returntype="void" hint="Set DebuggerService">
		<cfargument name="DebuggerService" type="any" required="true"/>
		<cfset instance.DebuggerService = arguments.DebuggerService/>
	</cffunction>
	
	<!--- Plugin Service --->
	<cffunction name="getPluginService" access="public" output="false" returntype="any" hint="Get PluginService: coldbox.system.services.pluginService">
		<cfreturn instance.PluginService/>
	</cffunction>
	<cffunction name="setPluginService" access="public" output="false" returntype="void" hint="Set PluginService">
		<cfargument name="PluginService" type="Any" required="true"/>
		<cfset instance.PluginService = arguments.PluginService/>
	</cffunction>
	
	<!--- Interceptor Service --->
	<cffunction name="getinterceptorService" access="public" output="false" returntype="any" hint="Get interceptorService: coldbox.system.services.interceptorService">
		<cfreturn instance.interceptorService/>
	</cffunction>	
	<cffunction name="setinterceptorService" access="public" output="false" returntype="void" hint="Set interceptorService">
		<cfargument name="interceptorService" type="any" required="true"/>
		<cfset instance.interceptorService = arguments.interceptorService/>
	</cffunction>

	<!--- Handler Service --->
	<cffunction name="getHandlerService" access="public" output="false" returntype="any" hint="Get HandlerService: coldbox.system.services.handlerService">
		<cfreturn instance.HandlerService/>
	</cffunction>
	<cffunction name="setHandlerService" access="public" output="false" returntype="void" hint="Set HandlerService">
		<cfargument name="HandlerService" type="any" required="true"/>
		<cfset instance.HandlerService = arguments.HandlerService/>
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
			return Evaluate("instance.ColdboxSettings.#arguments.name#");
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
			return isDefined("instance.ColdboxSettings.#arguments.name#");
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
	<cffunction name="getPlugin" access="Public" returntype="any" hint="I am the Plugin cfc object factory." output="true">
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
		<cfargument name="event"  			hint="The name of the event to run." 			type="string" required="No" default="#getSetting("DefaultEvent")#" >
		<cfargument name="queryString"  	hint="The query string to append, if needed."   type="string" required="No" default="" >
		<cfargument name="addToken"			hint="Whether to add the tokens or not. Default is false" type="boolean" required="false" default="false"	>
		<cfargument name="persist" 			hint="What request collection keys to persist in the relocation" required="false" type="string" default="">
		<cfargument name="varStruct" 		hint="A structure key-value pairs to persist." required="false" type="struct" default="#structNew()#" >
		<!--- ************************************************************* --->
		<cfset var EventName = getSetting("EventName")>
		<cfset var frontController = listlast(cgi.script_name,"/")>
		<cfset var oRequestContext = getRequestService().getContext()>
		<cfset var routeString = 0>
		
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
						 		addToken=arguments.addToken)>
		
		<cfelse>
			<!--- Persistance Logic --->
			<cfset persistVariables(argumentCollection=arguments)>
			<!--- Push Timers --->
			<cfset pushTimers()>
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
		<cfargument name="route"  			hint="The route to relocate to, do not prepend the baseURL or /." type="string" required="yes" >
		<cfargument name="persist" 			hint="What request collection keys to persist in the relocation" required="false" type="string" default="">
		<cfargument name="varStruct" 		hint="A structure key-value pairs to persist." required="false" type="struct">
		<cfargument name="addToken"			hint="Wether to add the tokens or not. Default is false" type="boolean" required="false" default="false"	>
		<!--- ************************************************************* --->
		<Cfset var routeLocation = getSetting("sesBaseURL")>
		
		<!--- Persistance Logic --->
		<cfset persistVariables(argumentCollection=arguments)>
		
		<!--- Create Route --->
		<cfif right(routeLocation,1) eq "/">
			<cfset routeLocation = routeLocation & arguments.route>
		<cfelse>
			<cfset routeLocation = routeLocation & "/" & arguments.route>
		</cfif>
		
		<!--- Push Timers --->
		<cfset pushTimers()>
		
		<!--- Reroute --->
		<cflocation url="#routeLocation#" addtoken="#arguments.addToken#">
	</cffunction>
	
	<!--- Event Service Locator Factory --->
	<cffunction name="runEvent" returntype="any" access="Public" hint="I am an event handler runnable factory. If no event is passed in then it will run the default event from the config file.">
		<!--- ************************************************************* --->
		<cfargument name="event"         type="any" 	required="false" default="" hint="The event to run as a string. If no current event is set, use the default event from the config.xml. This is a string">
		<cfargument name="prepostExempt" type="boolean" required="false" default="false" hint="If true, pre/post handlers will not be fired.">
		<cfargument name="private" 		 type="boolean" required="false" default="false" hint="Execute a private event or not, default is false"/>
		<!--- ************************************************************* --->
		<cfset var oEventHandler = "">
		<cfset var oEventHandlerBean = "">
		<cfset var oRequestContext = getRequestService().getContext()>
		<cfset var interceptMetadata = structnew()>
		<cfset var local = structnew()>
		<cfset var privateArgCollection = structnew()>
		
		<!--- Default Event Test --->
		<cfif len(trim(arguments.event)) eq 0>
			<cfset arguments.event = oRequestContext.getValue(getSetting("EventName"))>
		</cfif>
		
		<!--- Validate the incoming event --->
		<cfset oEventHandlerBean = getHandlerService().getRegisteredHandler(arguments.event)>
		<!--- Private Event or Not? --->
		<cfset oEventHandlerBean.setisPrivate(arguments.private)>
		
		<!--- Get the event handler to execute --->
		<cfset oEventHandler = getHandlerService().getHandler(oEventHandlerBean)>
		
		<!--- InterceptMetadata --->
		<cfset interceptMetadata.processedEvent = arguments.event>
		
		<!--- Execute preEvent Interception --->
		<cfset getInterceptorService().processState("preEvent",interceptMetadata)>
			
		<!--- PreHandler Execution --->
		<cfif not arguments.prepostExempt and structKeyExists(oEventHandler,"preHandler")>
			<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [preHandler] for #arguments.event#" controller="#this#">
			<cfset oEventHandler.preHandler(oRequestContext)>
			</cfmodule>
		</cfif>

		<!--- Private or Public Event Execution --->
		<cfif arguments.private>
			<!--- Private Arg Collection --->
			<cfset privateArgCollection["event"] = oRequestContext>
			<!--- Start Timer --->
			<cfmodule template="includes/timer.cfm" timertag="invoking PRIVATE runEvent [#arguments.event#]" controller="#this#">
				<!--- Call Private Event --->
				<cfinvoke component="#oEventHandler#" method="_privateInvoker" returnvariable="local.results">
					<cfinvokeargument name="method" value="#oEventHandlerBean.getMethod()#">
					<cfinvokeargument name="argCollection" value="#privateArgCollection#">
				</cfinvoke>
			</cfmodule>
		<cfelse>
			<!--- Start Timer --->
			<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [#arguments.event#]" controller="#this#">
				<cfif oEventHandlerBean.getisMissingAction()>
					<!--- Execute the Public Event --->
					<cfinvoke component="#oEventHandler#" method="onMissingAction" returnvariable="local.results">
						<cfinvokeargument name="event" 			value="#oRequestContext#">
						<cfinvokeargument name="missingAction"  value="#oEventHandlerBean.getMissingAction()#">
					</cfinvoke>
				<cfelse>
					<!--- Execute the Public Event --->
					<cfinvoke component="#oEventHandler#" method="#oEventHandlerBean.getMethod()#" returnvariable="local.results">
						<cfinvokeargument name="event" value="#oRequestContext#">
					</cfinvoke>
				</cfif>
			</cfmodule>
		</cfif>	

		<!--- PostHandler Execution --->
		<cfif not arguments.prepostExempt and structKeyExists(oEventHandler,"postHandler")>
			<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [postHandler] for #arguments.event#" controller="#this#">
			<cfset oEventHandler.postHandler(oRequestContext)>
			</cfmodule>
		</cfif>
		
		<!--- Execute postEvent Interception --->
		<cfset getInterceptorService().processState("postEvent",interceptMetadata)>
		
		<!--- Return Results for proxy if needed. --->
		<cfif structKeyExists(local,"results")>
			<cfreturn local.results>
		</cfif>
	</cffunction>

	<!--- Flash Perist variables. --->
	<cffunction name="persistVariables" access="public" returntype="void" hint="Persist variables for flash redirections" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="persist" 	 	required="false" type="string" default="" hint="What request collection keys to persist in the relocation.">
		<cfargument name="varStruct" 	required="false" type="struct" hint="A structure key-value pairs to persist.">
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
			<cfset oStorage = getPlugin("sessionstorage")>
		<cfelse>
			<cfset oStorage = getPlugin("clientstorage")>
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
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.util.util" hint="Create and return a util object">
		<cfreturn CreateObject("component","coldbox.system.util.util")/>
	</cffunction>
	
	<!--- Push Timers --->
	<cffunction name="pushTimers" access="private" returntype="void" hint="Push timers into stack" output="false" >
		<cfscript>
			/* Request Profilers */
			if ( getDebuggerService().getDebuggerConfigBean().getPersistentRequestProfiler() and
				 structKeyExists(request,"debugTimers") ){
				/* Push timers */
				getDebuggerService().pushProfiler(request.DebugTimers);
			}
		</cfscript>
	</cffunction>
	
</cfcomponent>