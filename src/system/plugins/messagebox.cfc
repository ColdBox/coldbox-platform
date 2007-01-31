<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This plugin is used by the framework for displaying alert message boxes.
	The user has three types of messages: 1) Warning 2) Error 3) Information
	The message is stored in the session scope. The look can be altered by
	creating a class and setting it in the config.xml.cfm

Modification History:
06/09/2006 - Updated for coldbox.
07/29/2006 - Flag to leave contents in the messagebox or delete them once rendered.
10/10/2006 - Added the renderit method for usage under Blue Dragon, removed the render. 
----------------------------------------------------------------------->
<cfcomponent name="messagebox" hint="This is the messagebox plugin. It uses the session scope to save messages. You will need the session scope to be available." extends="coldbox.system.plugin">

	<!--- ************************************************************* --->
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfset super.Init() />
		<cfset variables.instance.pluginName = "Messagebox">
		<cfset variables.instance.pluginVersion = "1.1">
		<cfset variables.instance.pluginDescription = "This is a visual plugin that creates message boxes.">
		<cfreturn this>
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
			<cfwddx action="cfml2wddx" input="#msgStruct#" output="session.ColdBox_fw_messagebox">
		<cfelse>
			<cfthrow type="Framework.plugins.messagebox.InvalidMessageTypeException" message="The message type sent in: #arguments.type# is invalid. Available types: error,warning,info">
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getMessage" access="public" hint="Returns a structure of the message if it exists, else a blank structure." returntype="any" output="false">
		<cfset var rtnStruct = structnew()>
		<cfif structKeyExists(session,"ColdBox_fw_messagebox")>
			<cfwddx action="wddx2cfml" input="#session.ColdBox_fw_messagebox#" output="rtnStruct">
		<cfelse>
			<cfset rtnStruct.type = "">
			<cfset rtnStruct.message = "">
		</cfif>
		<cfreturn rtnStruct>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="clearMessage" access="public" hint="Clears the message structure by deleting it from the session scope." output="false" returntype="void">
		<cfif structKeyExists(session,"ColdBox_fw_messagebox")>
			<cfset structdelete( session, "ColdBox_fw_messagebox")>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="isEmpty" access="public" hint="Checks wether the messagebox is empty or not." returntype="boolean" output="false">
		<cfif structKeyExists(session,"ColdBox_fw_messagebox")>
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