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
		variables.instance.ColdboxInitiated = false;
		variables.instance.ConfigSettings = structnew();
		variables.instance.ColdboxSettings = structnew();
		variables.instance.AppStartHandlerFired = false;
		//Services & Managers
		variables.instance.ColdboxOCM = "";
		variables.instance.RequestService = "";
	</cfscript>

	<cffunction name="init" returntype="any" access="Public" hint="I am the constructor" output="false">
		<cfscript>
			//Create Managers & Services
			instance.ColdboxOCM = CreateObject("component","coldbox.system.util.objectCacheManager").init(this);
			instance.RequestService = CreateObject("component","coldbox.system.util.requestService").init(this);
			//Return instance
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Getters / Setters Services & Managers --->
	<cffunction name="getRequestService" access="public" output="false" returntype="coldbox.system.util.requestService" hint="Get RequestService">
		<cfreturn instance.RequestService/>
	</cffunction>
	<cffunction name="getColdboxOCM" access="public" output="false" returntype="coldbox.system.util.objectCacheManager" hint="Get ColdboxOCM">
		<cfreturn instance.ColdboxOCM/>
	</cffunction>

	<!--- Accessor ColdBox Initiation Flag --->
	<cffunction name="getColdboxInitiated" access="public" output="false" returntype="boolean" hint="Get ColdboxInitiated">
		<cfreturn instance.ColdboxInitiated/>
	</cffunction>
	<!--- Accessor/Mutator App Start Handler Fired --->
	<cffunction name="setAppStartHandlerFired" access="public" output="false" returntype="void" hint="Set AppStartHandlerFired">
		<cfargument name="AppStartHandlerFired" type="boolean" required="true"/>
		<cfset instance.AppStartHandlerFired = arguments.AppStartHandlerFired/>
	</cffunction>
	<cffunction name="getAppStartHandlerFired" access="public" output="false" returntype="boolean" hint="Get AppStartHandlerFired">
		<cfreturn instance.AppStartHandlerFired/>
	</cffunction>

	<!--- Debugging Accessor/Mutators --->
	<cffunction name="getDebugMode" access="public" hint="I Get the current user's debugmode" returntype="boolean"  output="false">
		<cfset var appName = URLEncodedFormat(replace(replace(getSetting("AppName")," ","","all"),".","_","all"))>
		<cfif structKeyExists(cookie,"ColdBox_debugMode_#appName#")>
			<cfreturn cookie["ColdBox_debugMode_#appName#"]>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	<cffunction name="setDebugMode" access="public" hint="I set the current user's debugmode" returntype="void"  output="false">
		<cfargument name="mode" type="boolean" required="true" >
		<cfset var appName = URLEncodedFormat(replace(replace(getSetting("AppName")," ","","all"),".","_","all"))>
		<cfif arguments.mode>
			<cfcookie name="ColdBox_debugMode_#appName#" value="true">
		<cfelseif structKeyExists(cookie,"ColdBox_debugMode_#appName#")>
			<cfcookie name="ColdBox_debugMode_#appName#" value="false" expires="#now()#">
		</cfif>
	</cffunction>

	<!--- Config Loader Method --->
	<cffunction name="configLoader" returntype="void" access="Public" hint="I Load the configurations and init the framework variables." output="false">
		<cfscript>
		var XMLParser = getPlugin("XMLParser");
		//Load Coldbox Config Settings Structure
		instance.ColdboxSettings = XMLParser.loadFramework();
		//Load Application Config Settings
		instance.ConfigSettings = XMLParser.parseConfig();
		//Configure Caching Manager
		instance.ColdboxOCM.configure();

		//IoC Plugin Manager
		if ( getSetting("IOCFramework") neq "" ){
			getPlugin("ioc");
		}
		//Load i18N if application is using it.
		if ( getSetting("using_i18N") )
			getPlugin("i18n").init_i18N(getSetting("DefaultResourceBundle"),getSetting("DefaultLocale"));

		//Initialize AOP Logging if requested.
		if ( getSetting("EnableColdboxLogging") )
			getPlugin("logger").initLogLocation();

		//Set Debugging Mode according to configuration
		setDebugMode(getSetting("DebugMode"));

		// Flag the initiation, Framework is ready to serve requests. Praise be to GOD.
		instance.ColdboxInitiated = true;
		</cfscript>
	</cffunction>
	<!--- Framework Register Handlers --->
	<cffunction name="registerHandlers" access="public" returntype="void" hint="I register your application's event handlers" output="false">
		<cfset var HandlersPath = getSetting("HandlersPath")>
		<cfset var HandlerArray = Arraynew(1)>

		<!--- Check for Handlers Directory Location --->
		<cfif not directoryExists(HandlersPath)>
			<cfthrow type="Framework.plugins.settings.HandlersDirectoryNotFoundException" message="The handlers directory: #handlerspath# does not exist please check your application structure or your Application Mapping.">
		</cfif>

		<!--- Get recursive Array listing --->
		<cfset HandlerArray = recurseListing(HandlerArray, HandlersPath, HandlersPath)>
		<!--- Verify it --->
		<cfif ArrayLen(HandlerArray) eq 0>
			<cfthrow type="Framework.plugins.settings.NoHandlersFoundException" message="No handlers were found in: #HandlerPath#. So I have no clue how you are going to run this application.">
		</cfif>

		<!--- Sort The Array --->
		<cfset ArraySort(HandlerArray,"text")>

		<!--- Set registered Handlers --->
		<cfset setSetting("RegisteredHandlers",arrayToList(HandlerArray))>
	</cffunction>


	<!--- Config Structure Accessors/Mutators --->
	<cffunction name="getSettingStructure" hint="I get the entire setting structure. By default I retrieve the configStruct. You can change this by using the fwsetting flag." access="public" returntype="struct" output="false">
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
			 return Evaluate("instance.ConfigSettings.#arguments.name#");
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
			return isDefined("instance.ConfigSettings.#arguments.name#");
		}
		</cfscript>
	</cffunction>
	<cffunction name="setSetting" access="Public" returntype="void" hint="I set a Global Coldbox setting variable in the configstruct, if it exists it will be overrided. This only sets in the ConfigStruct" output="false">
		<cfargument name="name"  type="string"   hint="The name of the setting" >
		<cfargument name="value" type="any"      hint="The value of the setting (Can be simple or complex)">
		<!--- ************************************************************* --->
		<cfscript>
		"instance.ConfigSettings.#arguments.name#" = arguments.value;
		</cfscript>
	</cffunction>

	<!--- Plugin Factories --->
	<cffunction name="getPlugin" access="Public" returntype="any" hint="I am the Plugin cfc object factory." output="false">
		<cfargument name="plugin" 		type="string" hint="The Plugin object's name to instantiate" >
		<cfargument name="customPlugin" type="boolean" required="false" default="false" hint="Used internally to create custom plugins.">
		<!--- ************************************************************* --->
		<cfset var oPlugin = "">
		<cfset var MetaData = structNew()>
		<cfset var objTimeout = "">
		<cfset var pluginKey = "plugin_" & arguments.plugin>
		<cfset var pluginPath = "coldbox.system.plugins.#trim(arguments.plugin)#">

		<!--- Custom Plugin Test --->
		<cfif arguments.customPlugin>
			<cfset pluginKey = "custom_plugin_" & arguments.plugin>
			<cfset pluginPath = "#getSetting("MyPluginsLocation")#.#trim(arguments.plugin)#">
		</cfif>

		<!--- Lookup in Cache --->
		<cfif instance.ColdboxOCM.lookup(pluginKey)>
			<cfset oPlugin = instance.ColdboxOCM.get(pluginKey)>
		<cfelse>
			<!--- Object not found, proceed to create and verify --->
			<cfset oPlugin = CreateObject("component", pluginPath).init(this)>
			<!--- Get Object's MetaData --->
			<cfset MetaData = getMetaData(oPlugin)>
			<!--- Test for caching parameters --->
			<cfif structKeyExists(MetaData, "cache") and isBoolean(MetaData["cache"]) and MetaData["cache"]>
				<cfif structKeyExists(MetaData,"cachetimeout") >
					<cfset objTimeout = MetaData["cachetimeout"]>
				</cfif>
				<cfset instance.ColdboxOCM.set(pluginKey,oPlugin,objTimeout)>
			</cfif>
		</cfif>
		<!--- Return Plugin --->
		<cfreturn oPlugin>
	</cffunction>

	<!--- Event Context Methods --->
	<cffunction name="setNextEvent" access="Public" returntype="void" hint="I Set the next event to run and relocate the browser to that event."  output="false">
		<cfargument name="event"  			hint="The name of the event to run." 			type="string" required="No" default="#getSetting("DefaultEvent")#" >
		<cfargument name="queryString"  	hint="The query string to append, if needed."   type="string" required="No" default="" >
		<cfargument name="addToken"			hint="Wether to add the tokens or not. Default is false" type="boolean" required="false" default="false"	>
		<!--- ************************************************************* --->
		<cfif len(trim(arguments.event)) eq 0><cfset arguments.event = getSetting("DefaultEvent")></cfif>
		<cfif len(trim(arguments.queryString)) eq 0>
			<cflocation url="#cgi.SCRIPT_NAME#?event=#arguments.event#" addtoken="#arguments.addToken#">
		<cfelse>
			<cflocation url="#cgi.SCRIPT_NAME#?event=#arguments.event#&#arguments.queryString#" addtoken="#arguments.addToken#">
		</cfif>
	</cffunction>

	<cffunction name="runEvent" returntype="void" access="Public" hint="I am an event handler runnable factory. If no event is passed in then it will run the default event from the config.xml.">
		<cfargument name="event"         hint="The event to run. If no current event is set, use the default event from the config.xml" type="string" required="false" default="">
		<cfargument name="prepostExempt" hint="If true, pre/post handlers will not be fired." type="boolean" required="false" default="false">
		<!--- ************************************************************* --->
		<cfset var oEventHandler = "">
		<cfset var oEventBean = "">
		<cfset var objTimeout = "">
		<cfset var MetaData = "">
		<cfset var ExecutingHandler = "">
		<cfset var ExecutingMethod = "">
		<cfset var RequestContext = instance.RequestService.getContext()>

		<!--- Default Event Set --->
		<cfif arguments.event eq "">
			<cfset arguments.event = RequestContext.getValue("event")>
		</cfif>

		<!--- Start Timer --->
		<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [#arguments.event#]">
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
					<!--- Relocate to Invalid Event --->
					<cfset setNextEvent(getSetting("onInvalidEvent"))>
				<cfelse>
					<cfthrow type="Framework.InvalidEventException" message="An invalid event has been detected: #ExecutingMethod#">
				</cfif>
			</cfif>

			<!--- PreHandler Execution --->
			<cfif not arguments.prepostExempt and structKeyExists(oEventHandler,"preHandler")>
				<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [preHandler] for #arguments.event#">
				<cfset oEventHandler.preHandler(requestContext)>
				</cfmodule>
			</cfif>

			<!--- Execute the Event --->
			<cfinvoke component="#oEventHandler#" method="#ExecutingMethod#">
				<cfinvokeargument name="event" value="#RequestContext#">
			</cfinvoke>

			<!--- PostHandler Execution --->
			<cfif not arguments.prepostExempt and structKeyExists(oEventHandler,"postHandler")>
				<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [postHandler] for #arguments.event#">
				<cfset oEventHandler.postHandler(requestContext)>
				</cfmodule>
			</cfif>

		</cfmodule>
	</cffunction>

	<cffunction name="ExceptionHandler" access="public" hint="I handle a framework/application exception. I return a framework exception bean" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="Exception" 	 type="any"  	required="true"  hint="The exception structure. Passed as any due to CF glitch">
		<cfargument name="ErrorType" 	 type="string" 	required="false" default="application">
		<cfargument name="ExtraMessage"  type="string"  required="false" default="">
		<!--- ************************************************************* --->
		<cfscript>
		var BugReport = "";
		var ExceptionBean = getPlugin("beanFactory").create("coldbox.system.beans.exceptionBean").init(errorStruct=arguments.Exception,extramessage=arguments.extraMessage,errorType=arguments.ErrorType);
		var requestContext = getRequestService().getContext();
		// Test Error Type
		if ( not reFindnocase("(application|framework)",arguments.errorType) )
			arguments.errorType = "application";

		if ( arguments.ErrorType eq "application" ){
			//Run custom Exception handler if Found, else run default
			if ( getSetting("ExceptionHandler") neq "" ){
				try{
					requestContext.setValue("ExceptionBean",ExceptionBean);
					runEvent(getSetting("Exceptionhandler"));
				}
				catch(Any e){
					ExceptionBean = getPlugin("beanFactory").create("coldbox.system.beans.exceptionBean").init(errorStruct=e,extramessage="Error Running Custom Exception handler",errorType="application");
					getPlugin("logger").logErrorWithBean(ExceptionBean);
				}
			}
			else{
				getPlugin("logger").logErrorWithBean(ExceptionBean);
			}
		}
		//return
		return ExceptionBean;
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="recurseListing" access="private" output="false" returntype="array">
		<cfargument name="fileArray" type="array"  required="true">
		<cfargument name="Directory" type="string" required="true">
		<cfargument name="HandlersPath" type="string" required="true">
		<cfscript>
		var oDirectory = CreateObject("java","java.io.File").init(arguments.Directory);
		var Files = oDirectory.list();
		var i = 1;
		var tempfile = "";
		var cleanHandler = "";

		//Loop Through listing if any files found.
		for ( i=1; i lte arrayLen(Files); i=i+1 ){
			//get first reference as File Object
			tempFile = CreateObject("java","java.io.File").init(oDirectory,Files[i]);
			//Directory Check for recursion
			if ( tempFile.isDirectory() ){
				//recurse, directory found.
				arguments.fileArray = recurseListing(arguments.fileArray,tempFile.getPath(), arguments.HandlersPath);
			}
			else{
				//Filter only cfc's
				if ( listlast(tempFile.getName(),".") neq "cfc" )
					continue;
				//Clean entry by using Handler Path
				cleanHandler = replacenocase(tempFile.getAbsolutePath(),arguments.handlersPath,"","all");
				//Clean OS separators
				if ( getSetting("OSFileSeparator",1) eq "/")
					cleanHandler = removeChars(replacenocase(cleanHandler,"/",".","all"),1,1);
				else
					cleanHandler = removeChars(replacenocase(cleanHandler,"\",".","all"),1,1);
				//Clean Extension
				cleanHandler = getPlugin("fileUtilities").ripExtension(cleanhandler);
				//Add data to array
				ArrayAppend(arguments.fileArray,cleanHandler);
			}
		}
		return arguments.fileArray;
		</cfscript>
	</cffunction>

	<cffunction name="throw" access="private" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>

	<cffunction name="getRegisteredHandler" access="private" hint="I get a registered handler and method according to passed event from the registeredHandlers setting." returntype="coldbox.system.beans.eventhandlerBean"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event" hint="The event to check and get." type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		var handlerIndex = 0;
		var HandlerReceived = "";
		var MethodReceived = "";
		var handlersList = getSetting("RegisteredHandlers");
		var onInvalidEvent = getSetting("onInvalidEvent");
		var HandlerBean = CreateObject("component","coldbox.system.beans.eventhandlerBean").init(getSetting("HandlersInvocationPath"));
		//Rip the method
		HandlerReceived = getPlugin("fileUtilities").ripExtension(arguments.event);
		MethodReceived = listLast(arguments.event,".");

		//Check Registration
		handlerIndex = listFindNoCase(handlersList, HandlerReceived);

		//Check for registration results
		if ( handlerIndex ){
			HandlerBean.setHandler(listgetAt(handlersList,handlerIndex));
			HandlerBean.setMethod(MethodReceived);
		}
		else if ( onInvalidEvent neq "" ){
				//Check if the invalid event is the same as the current event
				if ( CompareNoCase(onInvalidEvent,arguments.event) eq 0){
					throw("The invalid event handler: #onInvalidEvent# is also invalid. Please check your settings","","Framework.InvalidEventHandlerException");
				}
				else{
					//Log Invalid Event
					getPlugin("logger").logEntry("error","Invalid Event detected: #HandlerReceived#.#MethodReceived#");
					//Override Event
					HandlerBean.setHandler(getPlugin("fileUtilities").ripExtension(onInvalidEvent));
					HandlerBean.setMethod(listLast(onInvalidEvent,"."));
				}
			}
		else{
			throw("The event handler: #arguments.event# is not valid registered event.","","Framework.EventHandlerNotRegisteredException");
		}
		return HandlerBean;
		</cfscript>
	</cffunction>
</cfcomponent>