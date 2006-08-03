<!-----------------------------------------------------------------------
Author 	 		: Luis Majano
Date     		: September 23, 2005 
Last Update 	: July 28, 2006
----------------------------------------------------------------------->
<cfcomponent name="controller" hint="This is the ColdBox Controller. I practically do everything">

	<cfset variables.currentPath = getCurrentTemplatePath()>
	<cfset variables.DebugMode = false>

	<cffunction name="init" returntype="any" access="Public" hint="I am the constructor" output="false">
		<cfreturn this>
	</cffunction>

	<cffunction name="getSetting" hint="I get a setting from the FW Config structures. Use the FWSetting boolean argument to retrieve from the fwSettingsStruct." access="public" returntype="any" output="false">
		<cfargument name="name" 	    type="string"   	 hint="Name of the setting key to retrieve"  >
		<cfargument name="FWSetting"  	type="boolean" 	 required="false"  hint="Boolean Flag. If true, it will retrieve from the fwSettingsStruct else from the configStruct. Default is false." default="false">
		<!--- ************************************************************* --->
		<cfif arguments.FWSetting and isDefined("application.ColdBox_FWSettingsStruct.#arguments.name#")>
			<cfreturn Evaluate("application.ColdBox_FWSettingsStruct.#arguments.name#")>
		<cfelseif isDefined("application.ColdBox_configstruct.#arguments.name#")>
			 <cfreturn Evaluate("application.ColdBox_configstruct.#arguments.name#")>
		<cfelse>
			<cfthrow type="Framework.SettingNotFoundException" message="The setting #arguments.name# does not exist." detail="FWSetting flag is #arguments.FWSetting#">
		</cfif>
	</cffunction>

	<cffunction name="setSetting" access="Public" returntype="any" hint="I set a Global Coldbox setting variable in the configstruct, if it exists it will be overrided. This only sets in the ConfigStruct" output="false">
		<cfargument name="name"  type="string"   hint="The name of the setting" >
		<cfargument name="value" type="any"      hint="The value of the setting (Can be simple or complex)">
		<!--- ************************************************************* --->
		<cfset "application.Coldbox_configstruct.#arguments.name#" = arguments.value>
	</cffunction>

	<cffunction name="getPlugin" access="Public" returntype="any" hint="I am the Plugin cfc object factory." output="false">
		<cfargument name="plugin" type="string" hint="The Plugin object's name to instantiate" >
		<!--- ************************************************************* --->
		<cftry>
			<cfreturn CreateObject("component", "plugins.#trim(arguments.plugin)#").init(this)>
			<cfcatch type="any">
				<cfthrow type="Framework.InvalidPluginInstantiationException"	 message="Framework.getPlugin: Error Instantiating Plugin Object (#trim(arguments.plugin)#)<br><br>Diagnostics: #cfcatch.Message#<br>#cfcatch.detail#">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getCurrentPath" access="public" hint="I Get the currentPath of the controller" returntype="string"  output="false">
		<cfreturn variables.currentPath>
	</cffunction>

	<cffunction name="getDebugMode" access="public" hint="I Get the current controller debugmode" returntype="boolean"  output="false">
		<cfreturn variables.DebugMode>
	</cffunction>

	<cffunction name="setDebugMode" access="public" hint="I set the current controller debugmode" returntype="void"  output="false">
		<cfargument name="mode" type="boolean" >
		<cfset variables.DebugMode = arguments.mode>
	</cffunction>

	<cffunction name="reqCapture" access="Public" returntype="void" hint="I capture a framework event request." output="false">
		<cfargument name="FORM" hint="The form scope" type="any">
		<cfargument name="URL"  hint="The url scope"  type="any">
		<!--- ************************************************************* --->
		<cfmodule template="includes/timer.cfm" timertag="Request Capture" >
			<cfset request.reqCollection = structNew()>
			<cfset StructAppend(request.reqCollection, arguments.FORM)>
			<cfset StructAppend(request.reqCollection, arguments.URL)>
			<!--- Debug Mode Checks --->
			<cfif structKeyExists(request.reqCollection,"debugMode") and isBoolean(request.reqCollection.debugmode)>
				<cfif getSetting("debugPassword") eq "">
					<cfset setDebugMode(request.reqCollection.debugmode)>
				<cfelseif structKeyExists(request.reqCollection,"debugpass") and compareNoCase(getSetting("debugPassword"),request.reqCollection.debugpass) eq 0>
					<cfset setDebugMode(request.reqCollection.debugmode)>
				</cfif>
			</cfif>

			<!---Default Event Definition --->
			<cfif not structkeyExists(request.reqCollection,"event") >
				<cfset request.reqCollection.event = getSetting("DefaultEvent")>
			</cfif>

			<!---Event More Than 1 Check, grab the first event instance, other's are discarded --->
			<cfif listLen(request.reqCollection.event) gte 2>
				<cfset request.reqCollection.event = getToken(event,1,",")>
			</cfif>
		</cfmodule>
	</cffunction>

	<cffunction name="getCollection" returntype="any" access="Public" hint="I Get a reference or deep copy of the request Collection" output="false">
		<cfargument name="DeepCopyFlag" hint="Default is false, gives a reference to the collection. True, creates a deep copy of the collection." type="boolean" required="no" default="false">
		<!--- ************************************************************* --->
		<cfif arguments.DeepCopyFlag>
			<cfreturn duplicate(request.reqCollection)>
		<cfelse>
			<cfreturn request.reqCollection>
		</cfif>
	</cffunction>

	<cffunction name="valueExists" returntype="boolean" access="Public"	hint="I Check if a value exists in the request collection." output="false">
		<cfargument name="name" hint="Name of the variable to find in the request collection" type="string">
		<!--- ************************************************************* --->
		<cfreturn isDefined("request.reqCollection.#arguments.name#") >
	</cffunction>

	<cffunction name="getValue" returntype="Any" access="Public" hint="I Get a value from the request collection." output="false">
		<cfargument name="name" hint="Name of the variable to get from the request collection" type="string">
		<cfargument name="defaultValue"
					hint="Default value to return if not found.There are no default values for complex structures. You can send [array][struct][query] and the
						  method will return the empty complex variable.Please remember to include the brackets, syntax sensitive.You can also send complex variables
						  as the defaultValue argument."
					type="any" required="No" default="NONE">
		<!--- ************************************************************* --->
		<cfif isDefined("request.reqCollection.#arguments.name#") >
			<cfreturn Evaluate("request.reqCollection.#arguments.name#")>
		<cfelseif isSimpleValue(arguments.defaultValue) and arguments.defaultValue eq "NONE">
			<cfthrow type="Framework.ValueNotInRequestCollectionException" message="The variable: #arguments.name# is undefined in the request collection.">
		<cfelseif isSimpleValue(arguments.defaultValue) >
			<cfif refind("\[[A-Za-z]*\]", arguments.defaultValue) >
				<cfif findnocase("array", arguments.defaultvalue)>
					<cfreturn ArrayNew(1)>
				<cfelseif findnocase("struct", arguments.defaultvalue)>
					<cfreturn StructNew()>
				<cfelseif findnocase("query", arguments.defaultvalue)>
					<cfreturn QueryNew("")>
				</cfif>
			<cfelse>
				<cfreturn arguments.defaultValue>
			</cfif>
		<cfelse>
			<cfreturn arguments.defaultValue>
		</cfif>
	</cffunction>

	<cffunction name="setValue" access="Public" hint="I Set a value in the request collection" output="false" returntype="void">
		<cfargument name="name"  hint="The name of the variable to set." type="string" >
		<cfargument name="value" hint="The value of the variable to set" type="Any" >
		<!--- ************************************************************* --->
		<cfset "request.reqCollection.#arguments.name#" = arguments.value>
	</cffunction>

	<cffunction name="removeValue" access="Public" hint="I remove a value in the request collection" output="false" returntype="void">
		<cfargument name="name"  hint="The name of the variable to remove." type="string" >
		<!--- ************************************************************* --->
		<cfset structDelete(request.reqCollection,"#arguments.name#")>
	</cffunction>

	<cffunction name="setView" access="Public" returntype="void" hint="I Set the view to render in this request.I am called from event handlers. Request Collection Name: currentView, currentLayout"  output="false">
		<cfargument name="name"  hint="The name of the view to set. If a layout has been defined it will assign it, else if will assign the default layout." type="string">
		<cfargument name="nolayout" type="boolean" required="false" default="false" hint="Boolean flag, wether the view sent in will be using a layout or not. Default is false. Uses a pre set layout or the default layout.">
		<!--- ************************************************************* --->
	    <cfset var viewLayouts = getSetting("ViewLayouts")>
	    <cfif not arguments.nolayout>
		    <cfif not getValue("layoutoverride",false)>
			    <cfif StructKeyExists(viewLayouts, arguments.name) >
					<cfset setValue("currentLayout",viewLayouts[arguments.name])>
				<cfelse>
					<cfset setValue("currentLayout", getSetting("DefaultLayout"))>
				</cfif>
			</cfif>
		</cfif>
		<cfset setValue("currentView",arguments.name)>
	</cffunction>

	<cffunction name="setLayout" access="Public" returntype="void" hint="I Set the layout to override and render. Layouts are pre-defined in the config.xml file. However I can override these settings if needed. Do not append a the cfm extension. Request Collection name: currentLayout"  output="false">
		<cfargument name="name"  hint="The name of the layout file to set." type="string" >
		<!--- ************************************************************* --->
	  	<cfset setValue("currentLayout",trim(arguments.name) & ".cfm" )>
	  	<cfset setValue("layoutoverride",true)>
	</cffunction>

	<cffunction name="setNextEvent" access="Public" returntype="void" hint="I Set the next event to run and relocate the browser to that event."  output="false">
		<cfargument name="event"  			hint="The name of the event to run." 			type="string" default="#getSetting("DefaultEvent")#" >
		<cfargument name="queryString"  	hint="The query string to append, if needed."   type="any" required="No" default="" >
		<!--- ************************************************************* --->
			<cflocation url="#cgi.SCRIPT_NAME#?event=#trim(arguments.event)#&#trim(arguments.queryString)#" addtoken="no">
	</cffunction>

	<cffunction name="overrideEvent" access="Public" hint="I Override the current event in the request collection. This method does not execute the event, it just replaces the event to be executed by the framework's RunEvent() method. This method is usually called from an onRequestStart or onApplicationStart method."  output="false" returntype="void">
		<cfargument name="event" hint="The name of the event to override." type="string">
		<!--- ************************************************************* --->
	    <cfset setValue("event",arguments.event)>
	</cffunction>

	<cffunction name="runEvent" returntype="void" access="Public" hint="I am an event handler runnable factory. If no event is passed in then it will run the default event from the config.xml.">
		<cfargument name="event" hint="The event to run. If no current event is set, use the default event from the config.xml" type="string" required="no" default="#getValue("event")#">
		<!--- ************************************************************* --->
		<cfset var objEventHandler = "">
		<cfset var handlerDir = "handlers">
		<cfset var EventBean = "">
		<!--- Start Timer --->
		<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [#arguments.event#]">
			<!--- Dashboard Determinations --->
			<cfif CompareNocase(getSetting("AppName"),getSetting("DashboardName",1)) eq 0>
				<cfset handlerDir = "admin.handlers">
			<cfelseif getSetting("AppCFMXMapping") neq "">
				<cfset handlerDir = "#replace(getSetting("AppCFMXMapping"),"/",".","all")#.handlers">
			</cfif>
			<!--- Get RegisteredHandler --->
			<cfset EventBean =  getPlugin("settings").getRegisteredHandler(arguments.event)>
			<cftry>
				<cfset objEventHandler = CreateObject("component","#handlerDir#.#EventBean.getHandler()#").init(this)>
				<cfcatch type="any">
					<cfthrow type="Framework.EventHandlerInstantiationException" message="Error Instantiating Event Handler: (#EventBean.getName()#)" detail="#cfcatch.Detail# #cfcatch.Message#">
				</cfcatch>
			</cftry>
			<!---  Run The handler's Method --->
			<cfset evaluate("objEventHandler.#EventBean.getMethod()#()")>
		</cfmodule>
	</cffunction>

</cfcomponent>