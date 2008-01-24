<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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
			setConfigSettings(structnew());
			setColdboxSettings(structnew());
			setAppStartHandlerFired(false);
			
			//Set the Application hash on creation
			setAppHash( hash(arguments.AppRootPath) );
			setAppRootPath(arguments.AppRootPath);
			
			//TODO: change all this to object factory.
			//Create & init ColdBox Services
			if ( (this.oCFMLENGINE.getEngine() eq this.oCFMLENGINE.ADOBE and this.oCFMLENGINE.getVersion() gte 8) or
			     (this.oCFMLENGINE.getEngine() eq this.oCFMLENGINE.BLUEDRAGON and this.oCFMLENGINE.getVersion() gte 7) ){
				setColdboxOCM( CreateObject("component","coldbox.system.cache.MTcacheManager").init(this) );
			}
			else{
				setColdboxOCM( CreateObject("component","coldbox.system.cache.cacheManager").init(this) );
			}
			//Setup the rest of the services.
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
	<cffunction name="getAppRootPath" access="public" returntype="string" output="false">
		<cfreturn instance.AppRootPath>
	</cffunction>
	<cffunction name="setAppRootPath" access="public" returntype="void" output="false">
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

	<!--- Accessor ColdBox Initiation Flag --->
	<cffunction name="getColdboxInitiated" access="public" output="false" returntype="boolean" hint="Get ColdboxInitiated">
		<cfreturn instance.ColdboxInitiated/>
	</cffunction>
	<cffunction name="setColdboxInitiated" access="public" output="false" returntype="void" hint="Set ColdboxInitiated">
		<cfargument name="ColdboxInitiated" type="boolean" required="true"/>
		<cfset instance.ColdboxInitiated = arguments.ColdboxInitiated/>
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
			throw("The setting #arguments.name# does not exist.","FWSetting flag is #arguments.FWSetting#","Framework.SettingNotFoundException");
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
	<cffunction name="getService" access="public" output="false" returntype="any" hint="Internal ColdBox Transient Minimalistic Service Locator.">
		<cfargument name="service" type="string" required="true" hint="The transient service/manager to create.">
		<cfscript>
		//Some services get loaded as singleton's, other are just created as needed
		var servicePath = "";
		switch(arguments.service){
			//Loader
			case "loader":
				servicePath = "coldbox.system.services.loaderService";
				break;
			case "exception":
				servicePath = "coldbox.system.services.exceptionService";
				break;
			//Default Case
			default:
				throw("Invalid Service detected","service:#arguments.service#","Framework.ServiceNotDefinedException");
		}
		return CreateObject("component",servicePath).init(this);
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
	<cffunction name="setNextEvent" access="Public" returntype="void" hint="I Set the next event to run and relocate the browser to that event."  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event"  			hint="The name of the event to run." 			type="string" required="No" default="#getSetting("DefaultEvent")#" >
		<cfargument name="queryString"  	hint="The query string to append, if needed."   type="string" required="No" default="" >
		<cfargument name="addToken"			hint="Wether to add the tokens or not. Default is false" type="boolean" required="false" default="false"	>
		<cfargument name="persist" 			hint="What request collection keys to persist in the relocation" required="false" type="string" default="">
		<!--- ************************************************************* --->
		<cfset var EventName = getSetting("EventName")>
		<cfset var frontController = listlast(cgi.script_name,"/")>
		
		<!--- Cleanup Event --->
		<cfif len(trim(arguments.event)) eq 0>
			<cfset arguments.event = getSetting("DefaultEvent")>
		</cfif>
		
		<!--- Persistance Logic --->
		<cfif trim(len(arguments.persist)) neq 0>
			<cfset persistVariables(arguments.persist)>
		</cfif>
		
		<!--- Check if query String needs appending --->
		<cfif len(trim(arguments.queryString)) eq 0>
			<cflocation url="#frontController#?#EventName#=#arguments.event#" addtoken="#arguments.addToken#">
		<cfelse>
			<cflocation url="#frontController#?#EventName#=#arguments.event#&#arguments.queryString#" addtoken="#arguments.addToken#">
		</cfif>
	</cffunction>
	
	<!--- Set Next Route --->
	<cffunction name="setNextRoute" access="Public" returntype="void" hint="I Set the next ses route to relocate to. This method pre-pends the baseURL"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="route"  			hint="The route to relocate to, do not prepend the baseURL or /." type="string" required="yes" >
		<cfargument name="persist" 			hint="What request collection keys to persist in the relocation" required="false" type="string" default="">
		<!--- ************************************************************* --->
		<Cfset var routeLocation = getSetting("sesBaseURL")>
		
		<!--- Persistance Logic --->
		<cfif trim(len(arguments.persist)) neq 0>
			<cfset persistVariables(arguments.persist)>
		</cfif>
		
		<!--- Create Route --->
		<cfif right(routeLocation,1) eq "/">
			<cfset routeLocation = routeLocation & arguments.route>
		<cfelse>
			<cfset routeLocation = routeLocation & "/" & arguments.route>
		</cfif>
		
		<!--- Reroute --->
		<cflocation url="#routeLocation#" addtoken="no">
	</cffunction>
	
	<!--- Event Service Locator Factory --->
	<cffunction name="runEvent" returntype="any" access="Public" hint="I am an event handler runnable factory. If no event is passed in then it will run the default event from the config file.">
		<!--- ************************************************************* --->
		<cfargument name="event"         hint="The event to run as a string. If no current event is set, use the default event from the config.xml. This is a string" type="any" required="false" default="">
		<cfargument name="prepostExempt" hint="If true, pre/post handlers will not be fired." type="boolean" required="false" default="false">
		<!--- ************************************************************* --->
		<cfset var oEventHandler = "">
		<cfset var oEventHandlerBean = "">
		<cfset var oRequestContext = getRequestService().getContext()>
		<cfset var interceptMetadata = structnew()>
		<cfset var Results = "">
		
		<!--- Default Event Test --->
		<cfif arguments.event eq "">
			<cfset arguments.event = oRequestContext.getValue(getSetting("EventName"))>
		</cfif>
		
		<!--- Validate the incoming event --->
		<cfset oEventHandlerBean = getHandlerService().getRegisteredHandler(arguments.event)>
		<!--- Get the event handler to execute --->
		<cfset oEventHandler = getHandlerService().getHandler(oEventHandlerBean)>
		
		<!--- InterceptMetadata --->
		<cfset interceptMetadata.processedEvent = arguments.event>
		
		<!--- Execute preEvent Interception --->
		<cfset getInterceptorService().processState("preEvent",interceptMetadata)>
			
		<!--- PreHandler Execution --->
		<cfif not arguments.prepostExempt and structKeyExists(oEventHandler,"preHandler")>
			<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [preHandler] for #arguments.event#">
			<cfset oEventHandler.preHandler(oRequestContext)>
			</cfmodule>
		</cfif>

		<!--- Start Timer --->
		<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [#arguments.event#]">
			<!--- Execute the Event --->
			<cfinvoke component="#oEventHandler#" method="#oEventHandlerBean.getMethod()#" returnvariable="Results">
				<cfinvokeargument name="event" value="#oRequestContext#">
			</cfinvoke>
		</cfmodule>

		<!--- PostHandler Execution --->
		<cfif not arguments.prepostExempt and structKeyExists(oEventHandler,"postHandler")>
			<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [postHandler] for #arguments.event#">
			<cfset oEventHandler.postHandler(oRequestContext)>
			</cfmodule>
		</cfif>
		
		<!--- Execute postEvent Interception --->
		<cfset getInterceptorService().processState("postEvent",interceptMetadata)>
		
		<!--- Return Results for proxy if needed. --->
		<cfif isDefined("Results")>
			<cfreturn Results>
		</cfif>
	</cffunction>

	<!--- Utility throw. --->
	<cffunction name="throw" access="public" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>

	<!--- Get the util object --->
	<cffunction name="getUtil" access="public" output="false" returntype="coldbox.system.util.util" hint="Create and return a util object">
		<cfreturn CreateObject("component","coldbox.system.util.util")/>
	</cffunction>

	<!--- Flash Perist variables. --->
	<cffunction name="persistVariables" access="public" returntype="void" hint="Persist variables for flash redirections" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="persist" 	hint="What request collection keys to persist in the relocation" required="false" type="string" default="">
		<!--- ************************************************************* --->
		<cfset var PersistList = trim(arguments.persist)>
		<cfset var tempPersistValue = "">
		<cfset var PersistStruct = structnew()>
		<cfset var rc = getRequestService().getContext().getCollection()>
		<cfset var i = 0>
		
		<!--- Persistance Logic --->
		<cfloop from="1" to="#listlen(PersistList)#" index="i">
			<cfset tempPersistValue = listgetat(PersistList,i)>
			<cfif structkeyExists(rc, tempPersistValue)>
				<cfset PersistStruct[tempPersistValue] = rc[tempPersistValue]>
			</cfif>
		</cfloop>
		
		<!--- Flash Save it --->
		<cfset getPlugin("sessionStorage").setVar('_coldbox_persistStruct', PersistStruct)>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	
</cfcomponent>