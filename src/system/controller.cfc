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
		
		//properties
		instance.ColdboxInitiated = false;
		instance.ConfigSettings = structnew();
		instance.ColdboxSettings = structnew();
		instance.AppStartHandlerFired = false;
		instance.AppHash = "";
		
		//Services & Managers
		instance.ColdboxOCM = structNew();
		instance.DebuggerService = structNew();
		instance.RequestService = structNew();
	</cfscript>

	<cffunction name="init" returntype="any" access="Public" hint="I am the constructor" output="false">
		<cfscript>
			//Set the App hash
			instance.AppHash = hash(createUUID());
			//Create & init ColdBox Services
			instance.ColdboxOCM = CreateObject("component","cache.cacheManager").init(this);
			instance.RequestService = CreateObject("component","services.requestService").init(this);
			instance.DebuggerService = CreateObject("component","services.debuggerService").init(this);
			//Return instance
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Getters / Setters Services & Managers --->
	<cffunction name="getColdboxOCM" access="public" output="false" returntype="any" hint="Get ColdboxOCM">
		<cfreturn instance.ColdboxOCM/>
	</cffunction>
	<cffunction name="getRequestService" access="public" output="false" returntype="any" hint="Get RequestService">
		<cfreturn instance.RequestService/>
	</cffunction>
	<cffunction name="getDebuggerService" access="public" output="false" returntype="any" hint="Get DebuggerService">
		<cfreturn instance.DebuggerService/>
	</cffunction>

	<!--- Getter & Setter Internal Structures --->
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

	<!--- App hash Get --->
	<cffunction name="getAppHash" access="public" output="false" returntype="string" hint="Get AppHash">
		<cfreturn instance.AppHash/>
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

	<!--- Service Locator --->
	<cffunction name="getService" access="public" output="false" returntype="any" hint="Internal ColdBox Transient Service Locator.">
		<cfargument name="service" type="string" required="true" hint="The transient service/manager to create.">
		<cfscript>
		//Some services get loaded as singleton's, other are just created as needed
		var servicePath = "";
		switch(arguments.service){
			//Loader
			case "loader":
				servicePath = "services.loaderService";
				break;
			case "exception":
				servicePath = "services.exceptionService";
				break;
			//Default Case
			default:
				throw("Invalid Service detected","service:#arguments.service#","Framework.ServiceNotDefinedException");
		}
		return CreateObject("component",servicePath).init(this);
		</cfscript>
	</cffunction>

	<!--- Plugin Factories --->
	<cffunction name="getMyPlugin" access="Public" returntype="any" hint="I am the Custom Plugin cfc object factory." output="false">
		<cfargument name="plugin" 		type="string" hint="The Custom Plugin object's name to instantiate" >
		<cfreturn getPlugin(arguments.plugin,true)>
	</cffunction>
	<cffunction name="getPlugin" access="Public" returntype="any" hint="I am the Plugin cfc object factory." output="true">
		<cfargument name="plugin" 		type="string"  hint="The Plugin object's name to instantiate" >
		<cfargument name="customPlugin" type="boolean" required="false" default="false" hint="Used internally to create custom plugins.">
		<cfargument name="newInstance"  type="boolean" required="false" default="false" hint="If true, it will create and return a new plugin. No caching or persistance.">
		<!--- ************************************************************* --->
		<cfscript>
		var oPlugin = "";
		var MetaData = structNew();
		var objTimeout = "";
		var pluginKey = "plugin_" & arguments.plugin;
		var pluginPath = "coldbox.system.plugins.#trim(arguments.plugin)#";
		var pluginFilePath = "";
		
		/* Custom Plugin Test  */
		if ( arguments.customPlugin ){
			
			/* Set plugin key and file path check */
			pluginKey = "custom_plugin_" & arguments.plugin;
			pluginFilePath = replace(arguments.plugin,".",getSetting("OSFileSeparator",true),"all") & ".cfc";
						
			/* Check for Convention First */
			if ( fileExists(getSetting("MyPluginsPath") & getSetting("OSFileSeparator",true) & pluginFilePath ) ){
				pluginPath = "#getSetting("MyPluginsInvocationPath")#.#arguments.plugin#";
			}
			else{
				/* Will search the alternate custom location */
				pluginPath = "#getSetting("MyPluginsLocation")#.#arguments.plugin#";
			}
		}//end if custom plugin

		/* Check if a new instance is required */
		if ( arguments.newInstance ){
			/* Object not found, proceed to create and verify */
			oPlugin = CreateObject("component", pluginPath).init(this);
		}
		else{
			
			/* Lookup in Cache */
			if ( instance.ColdboxOCM.lookup(pluginKey) ){
				oPlugin = instance.ColdboxOCM.get(pluginKey);
			}
			else{
				/* Object not found, proceed to create and verify */
				oPlugin = CreateObject("component", pluginPath).init(this);
				/* Get Object's MetaData */
				MetaData = getMetaData(oPlugin);
				/* Test for caching parameters */
				if ( structKeyExists(MetaData, "cache") and isBoolean(MetaData["cache"]) and MetaData["cache"] ){
					if ( structKeyExists(MetaData,"cachetimeout") ){
						objTimeout = MetaData["cachetimeout"];
					}
					/* Set in the cache */
					instance.ColdboxOCM.set(pluginKey,oPlugin,objTimeout);
				}//end if caching
				
			}//end if instance not in cache.
			
		}//end if not a new instance.

		/*  Return Plugin */
		return oPlugin;
		</cfscript>		
	</cffunction>

	<!--- Event Context Methods --->
	<cffunction name="setNextEvent" access="Public" returntype="void" hint="I Set the next event to run and relocate the browser to that event."  output="false">
		<cfargument name="event"  			hint="The name of the event to run." 			type="string" required="No" default="#getSetting("DefaultEvent")#" >
		<cfargument name="queryString"  	hint="The query string to append, if needed."   type="string" required="No" default="" >
		<cfargument name="addToken"			hint="Wether to add the tokens or not. Default is false" type="boolean" required="false" default="false"	>
		<cfargument name="persist" 			hint="What request collection keys to persist in the relocation" required="false" type="string" default="">
		<!--- ************************************************************* --->
		<cfset var EventName = getSetting("EventName")>
		<cfset var frontController = listlast(cgi.script_name,"/")>
		<cfset var PersistStruct = structnew()>
		<cfset var PersistList = trim(arguments.persist)>
		<cfset var tempPersistValue = "">
		<cfset var i = 1>
		<cfset var rc = structnew()>
		
		<!--- Cleanup Event --->
		<cfif len(trim(arguments.event)) eq 0>
			<cfset arguments.event = getSetting("DefaultEvent")>
		</cfif>
		
		<!--- Persistance Logic --->
		<cfif len(PersistList) neq 0>
			<cfset rc = getRequestService().getContext().getCollection()>
			<cfloop from="1" to="#listlen(PersistList)#" index="i">
				<cfset tempPersistValue = listgetat(PersistList,i)>
				<cfif structkeyExists(rc, tempPersistValue)>
					<cfset PersistStruct[tempPersistValue] = rc[tempPersistValue]>
				</cfif>
			</cfloop>
			<!--- Flash Save it --->
			<cfset getPlugin("sessionstorage").setVar('_coldbox_persistStruct', PersistStruct)>
		</cfif>
		
		<!--- Check if query String needs appending --->
		<cfif len(trim(arguments.queryString)) eq 0>
			<cflocation url="#frontController#?#EventName#=#arguments.event#" addtoken="#arguments.addToken#">
		<cfelse>
			<cflocation url="#frontController#?#EventName#=#arguments.event#&#arguments.queryString#" addtoken="#arguments.addToken#">
		</cfif>
	</cffunction>

	<!--- Event Service Locator Factory --->
	<cffunction name="runEvent" returntype="void" access="Public" hint="I am an event handler runnable factory. If no event is passed in then it will run the default event from the config file.">
		<cfargument name="event"         hint="The event to run. If no current event is set, use the default event from the config.xml" type="string" required="false" default="">
		<cfargument name="prepostExempt" hint="If true, pre/post handlers will not be fired." type="boolean" required="false" default="false">
		<!--- ************************************************************* --->
		<cfset var oEventHandler = "">
		<cfset var oEventBean = "">
		<cfset var ExecutingEventData = "">
		<cfset var objTimeout = "">
		<cfset var MetaData = "">
		<cfset var ExecutingHandler = "">
		<cfset var ExecutingMethod = "">
		<cfset var RequestContext = instance.RequestService.getContext()>
		<cfset var EventName = getSetting("EventName")>
		
		<!--- Default Event Set --->
		<cfif arguments.event eq "">
			<cfset arguments.event = RequestContext.getValue(EventName)>
		</cfif>

		<!--- Validate and Get registered handler --->
		<cfset oEventBean = getRegisteredHandler(arguments.event)>
		
		<!--- Set Executing Parameters --->
		<cfset ExecutingHandler = oEventBean.getRunnable()>
		<cfset ExecutingMethod = oEventBean.getMethod()>

		<!--- Check if using handler caching --->
		<cfif getSetting("HandlerCaching")>
			<!--- Lookup in Cache --->
			<cfif instance.ColdboxOCM.lookup("handler_" & ExecutingHandler)>
				<cfset oEventHandler = instance.ColdboxOCM.get("handler_" & ExecutingHandler)>
			<cfelse>
				<cfset oEventHandler = CreateObject("component",ExecutingHandler).init(this)>
				<!--- Get Object MetaData --->
				<cfset MetaData = getMetaData(oEventHandler)>
				<!--- By Default, handlers with no cache flag are set to true --->
				<cfif not structKeyExists(MetaData,"cache")>
					<cfset MetaData.cache = true>
				</cfif>
				<cfif isBoolean(MetaData["cache"]) and MetaData["cache"]>
					<cfif structKeyExists(MetaData,"cachetimeout") >
						<cfset objTimeout = MetaData["cachetimeout"]>
					</cfif>
					<!--- Set the Runnable Object --->
					<cfset instance.ColdboxOCM.set("handler_" & ExecutingHandler,oEventHandler,objTimeout)>
				</cfif>
			</cfif>
		<cfelse>
			<!--- Create Runnable Object --->
			<cfset oEventHandler = CreateObject("component",ExecutingHandler).init(this)>
		</cfif>

		<!--- Verify Event Method Exists --->
		<cfif not structKeyExists(oEventHandler,ExecutingMethod)>
			<!--- Invalid Event Detected, log it --->
			<cfset getPlugin("logger").logEntry("error","Invalid Event detected: #ExecutingHandler#.#ExecutingMethod#")>
			<cfif getSetting("onInvalidEvent") neq "">
				<!--- Test for invalid Event Error --->
				<cfif compareNoCase(getSetting("onInvalidEvent"),arguments.event) eq 0>
					<cfthrow type="Framework.onInValidEventSettingException" message="An invalid event has been detected: #RequestContext.getValue("invalidevent","")# and the onInvalidEvent setting is also invalid: #getSetting("onInvalidEvent")#. Please check your settings.">
				</cfif>
				<!--- Relocate to Invalid Event --->
				<cfset setNextEvent(getSetting("onInvalidEvent"),"invalidevent=#ExecutingHandler#.#ExecutingMethod#")>
			<cfelse>
				<cfthrow type="Framework.InvalidEventException" message="An invalid event has been detected: #ExecutingHandler#.#ExecutingMethod#. This event does not exist in the specified handler controller.">
			</cfif>
		</cfif>

		<!--- PreHandler Execution --->
		<cfif not arguments.prepostExempt and structKeyExists(oEventHandler,"preHandler")>
			<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [preHandler] for #arguments.event#">
			<cfset oEventHandler.preHandler(RequestContext)>
			</cfmodule>
		</cfif>

		<!--- Start Timer --->
		<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [#arguments.event#]">
			<!--- Execute the Event --->
			<cfinvoke component="#oEventHandler#" method="#ExecutingMethod#">
				<cfinvokeargument name="event" value="#RequestContext#">
			</cfinvoke>
		</cfmodule>

		<!--- PostHandler Execution --->
		<cfif not arguments.prepostExempt and structKeyExists(oEventHandler,"postHandler")>
			<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [postHandler] for #arguments.event#">
			<cfset oEventHandler.postHandler(RequestContext)>
			</cfmodule>
		</cfif>
	</cffunction>

	<cffunction name="throw" access="public" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="getRegisteredHandler" access="private" hint="I get a registered handler and method according to passed event from the registeredHandlers setting." returntype="coldbox.system.beans.eventhandlerBean"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event" hint="The event to check and get." type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		var incomingEvent = arguments.event;
		var handlerIndex = 0;
		var HandlerReceived = "";
		var MethodReceived = "";
		var handlersList = getSetting("RegisteredHandlers");
		var onInvalidEvent = getSetting("onInvalidEvent");
		var HandlerBean = CreateObject("component","coldbox.system.beans.eventhandlerBean").init(getSetting("HandlersInvocationPath"));
	
		//Rip the method
		HandlerReceived = reReplace(incomingEvent,"\.[^.]*$","");
		MethodReceived = listLast(incomingEvent,".");

		//Check Registration
		handlerIndex = listFindNoCase(handlersList, HandlerReceived);

		//Check for registration results
		if ( handlerIndex ){
			HandlerBean.setHandler(listgetAt(handlersList,handlerIndex));
			HandlerBean.setMethod(MethodReceived);
		}
		else if ( onInvalidEvent neq "" ){
				//Check if the invalid event is the same as the current event
				if ( CompareNoCase(onInvalidEvent,incomingEvent) eq 0){
					throw("The invalid event handler: #onInvalidEvent# is also invalid. Please check your settings","","Framework.InvalidEventHandlerException");
				}
				else{
					//Log Invalid Event
					getPlugin("logger").logEntry("error","Invalid Event detected: #HandlerReceived#.#MethodReceived#");
					//Override Event
					HandlerBean.setHandler(reReplace(onInvalidEvent,"\.[^.]*$",""));
					HandlerBean.setMethod(listLast(onInvalidEvent,"."));
				}
			}
		else{
			throw("The event handler: #incomingEvent# is not valid registered event.","","Framework.EventHandlerNotRegisteredException");
		}
		return HandlerBean;
		</cfscript>
	</cffunction>

	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.extras.util" hint="Create and return a util object">
		<cfreturn CreateObject("component","coldbox.system.extras.util")/>
	</cffunction>
</cfcomponent>