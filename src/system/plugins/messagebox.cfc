<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This plugin is used by the framework for displaying alert message boxes.
	The user has three types of messages: 1) Warning 2) Error 3) Information
	The message is stored in the session scope. It can be changed to client
	by changing the framework's settings.xml file.
	The look can be altered by creating a class and setting it in the config file

Modification History:
06/09/2006 - Updated for coldbox.
07/29/2006 - Flag to leave contents in the messagebox or delete them once rendered.
10/10/2006 - Added the renderit method for usage under Blue Dragon, removed the render.
01/28/2007 - Prepared for 1.2.0, using new storage centers.
----------------------------------------------------------------------->
<cfcomponent name="messagebox"
			 hint="This is the messagebox plugin. It uses the session/client scope to save messages."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="messagebox" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("Messagebox")>
		<cfset setpluginVersion("1.1")>
		<cfset setpluginDescription("This is a visual plugin that creates message boxes.")>
		<cfset instance.storageScope = getController().getSetting("MessageBoxStorage",true)>
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Storage Scope --->
	<cffunction name="getstorageScope" access="public" output="false" returntype="string" hint="Get storageScope">
		<cfreturn instance.storageScope/>
	</cffunction>
	<cffunction name="setstorageScope" access="public" output="false" returntype="void" hint="Set storageScope. If not session/client, then it defaults to the framework setting.">
		<cfargument name="storageScope" type="string" required="true"/>
		<!--- Validate Scope --->
		<cfif reFindnocase("(session|client)",arguments.storageScope)>
			<cfset instance.storageScope = arguments.storageScope/>
		<cfelse>
			<cfset instance.storageScope = getController().getSetting("MessageBoxStorage",true)>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setMessage" access="public" hint="Create a new messagebox. Look at types." output="false" returntype="void">
		<!--- ************************************************************* --->
		<cfargument name="type"     required="true" type="string" hint="The message type.Available types [error][warning][info]">
		<cfargument name="message"  required="true" type="string" hint="The message to show.">
		<!--- ************************************************************* --->
		<cfset var msgStruct = structnew()>
		<cfif refindnocase("(error|warning|info)", trim(arguments.type))>
			<cfset msgStruct.type = arguments.type>
			<cfset msgStruct.message = arguments.message>
			<cfwddx action="cfml2wddx" input="#msgStruct#" output="#getstorageScope()#.ColdBox_fw_messagebox">
		<cfelse>
			<cfthrow type="Framework.plugins.messagebox.InvalidMessageTypeException" message="The message type sent in: #arguments.type# is invalid. Available types: error,warning,info">
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getMessage" access="public" hint="Returns a structure of the message if it exists, else a blank structure." returntype="any" output="false">
		<cfset var rtnStruct = structnew()>
		<cfset var Storage = getstorageScope() & ".ColdBox_fw_messagebox">
		<cfif structKeyExists(evaluate(getstorageScope()),"ColdBox_fw_messagebox")>
			<cfwddx action="wddx2cfml" input="#evaluate(storage)#" output="rtnStruct">
		<cfelse>
			<cfset rtnStruct.type = "">
			<cfset rtnStruct.message = "">
		</cfif>
		<cfreturn rtnStruct>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="clearMessage" access="public" hint="Clears the message structure by deleting it from the session scope." output="false" returntype="void">
		<cfset var Storage = evaluate(getstorageScope())>
		<cfif structKeyExists(Storage,"ColdBox_fw_messagebox")>
			<cfset structdelete(Storage, "ColdBox_fw_messagebox")>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="isEmpty" access="public" hint="Checks wether the messagebox is empty or not." returntype="boolean" output="false">
		<cfset var Storage = evaluate(getstorageScope())>
		<cfif structKeyExists(Storage,"ColdBox_fw_messagebox")>
			<cfif structisEmpty(getMessage())>
				<cfreturn true>
			<cfelse>
				<cfreturn false>
			</cfif>
		<cfelse>
			<cfreturn true>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="renderit" access="public" hint="Renders the message box and clears the message structure by default." output="false" returntype="any">
		<!--- ************************************************************* --->
		<cfargument name="clearFlag" type="boolean" required="false" default="true" hint="Flag to clear the message structure or not after rendering. Default is true.">
		<cfset var msgStruct = getMessage()>
		<cfset var results = "">
		<cfif msgStruct.type neq "">
			<cfsavecontent variable="results"><cfinclude template="../includes/messagebox.cfm"></cfsavecontent>
		<cfelse>
			<cfset results = "">
		</cfif>
		<!--- Test to clear message structure --->
		<cfif arguments.clearFlag>
			<cfset clearMessage()>
		</cfif>
		<cfreturn results>
	</cffunction>

	<!--- ************************************************************* --->

</cfcomponent>