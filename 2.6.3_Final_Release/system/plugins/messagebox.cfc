<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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

	<cffunction name="init" access="public" returntype="messagebox" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.controller">
		<!--- ************************************************************* --->
		<cfscript>	
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("Messagebox");
			setpluginVersion("2.0");
			setpluginDescription("This is a visual plugin that creates message boxes.");
			
			/* Setup The initial storage scope. */
			if( settingExists("messagebox_storage_scope") ){
				setStorageScope( getSetting("messagebox_storage_scope") );
			}
			else{
				/* Set framework storage scope */
				setStorageScope( getSetting("MessageBoxStorage",true) );
			}
			
			/* Return */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Storage Scope --->
	<cffunction name="getstorageScope" access="public" output="false" returntype="string" hint="Get storageScope">
		<cfreturn instance.storageScope/>
	</cffunction>
	
	<!--- Set The Storage Scope --->
	<cffunction name="setstorageScope" access="public" output="false" returntype="void" hint="Set storageScope. If not session/client, then it defaults to the framework setting.">
		<!--- ************************************************************* --->
		<cfargument name="storageScope" type="string" required="true" hint="The scope you want to have storage for."/>
		<!--- ************************************************************* --->
		<cfscript>
			if( reFindnocase("(session|client)", arguments.storageScope) ){
				instance.storageScope = arguments.storageScope;
			}
			else{
				instance.storageScope = getSetting("MessageBoxStorage",true);
			}
		</cfscript>
	</cffunction>

	<!--- Set a message --->
	<cffunction name="setMessage" access="public" hint="Create a new messagebox. Look at types." output="false" returntype="void">
		<!--- ************************************************************* --->
		<cfargument name="type"     	required="true"   type="string" hint="The message type.Available types [error][warning][info]">
		<cfargument name="message"  	required="false"  type="string" default="" hint="The message to show.">
		<cfargument name="messageArray" required="false"  type="Array"  hint="You can also send in an array of messages to render separated by a <br />">
		<!--- ************************************************************* --->
		<cfset var msgStruct = structnew()>
		<cfset var i = 1>
		
		<!--- Verify Message Type --->
		<cfif refindnocase("(error|warning|info)", trim(arguments.type))>
			<!--- Populate message struct --->
			<cfset msgStruct.type = arguments.type>
			<cfset msgStruct.message = arguments.message>
			
			<!--- Array Check --->
			<cfif structKeyExists(arguments, "messageArray")>
				<cfloop from="1" to="#arrayLen(arguments.messageArray)#" index="i">
					<cfset msgStruct.message = msgStruct.message & arguments.messageArray[i]>
					<cfif i neq ArrayLen(arguments.messageArray)>
						<cfset msgStruct.message = msgStruct.message & "<br/>">	
					</cfif>
				</cfloop>
			</cfif>
			
			<!--- Flatten it --->
			<cfwddx action="cfml2wddx" input="#msgStruct#" output="#getstorageScope()#.ColdBox_fw_messagebox">
		<cfelse>
			<cfthrow type="ColdBox.plugins.messagebox.InvalidMessageTypeException" message="The message type sent in: #arguments.type# is invalid. Available types: error,warning,info">
		</cfif>
	</cffunction>
	
	<!--- Append A message --->			
	<cffunction name="append" access="public" returntype="void" hint="Append a message to the messagebox. If there is no message, then it sets the type to information." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="message"  	required="true"  type="string" default="" hint="The message to append, it does not include any breaks or delimiters. You must send that.">
		<!--- ************************************************************* --->
		<cfscript>
			var currentMessage = "";
			var newMessage = "";
			
			/* Do we have a message? */
			if( isEmpty() ){
				/* Set default message */
				setMessage('information',arguments.message);
			}
			else{
				/* Get Current Message */
				currentMessage = getMessage();
				/* Append */
				newMessage = currentMessage.message & arguments.message;
				/* Set it back */
				setMessage(currentMessage.type,newMessage);				
			}
		</cfscript>
	</cffunction>
	
	<!--- Append A message --->			
	<cffunction name="appendArray" access="public" returntype="void" hint="Append an array of messages to the messagebox. If there is no message, then it sets the type to information." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="messageArray"  	required="true"  type="Array" default="" hint="The array of messages to append. You must send that.">
		<!--- ************************************************************* --->
		<cfscript>
			var currentMessage = "";
			var newMessage = "";
			
			/* Do we have a message? */
			if( isEmpty() ){
				/* Set default message */
				setMessage(type='information',messageArray=arguments.messageArray);
			}
			else{
				/* Get Current Message */
				currentMessage = getMessage();
				/* Append */
				ArrayPrePend(arguments.messageArray,currentMessage.message);
				/* Set it back */
				setMessage(type=currentMessage.type,messageArray=arguments.messageArray);				
			}
		</cfscript>
	</cffunction>
	

	<!--- Get a Message --->
	<cffunction name="getMessage" access="public" hint="Returns a structure of the message if it exists, else a blank structure." returntype="any" output="false">
		<cfset var rtnStruct = structnew()>
		<cfset var storageScope = evaluate(getstorageScope())>
		
		<!--- Verify if messagebox exists --->
		<cfif structKeyExists(storageScope,"ColdBox_fw_messagebox")>
			<cfwddx action="wddx2cfml" 
					input="#StructFind( storageScope,'ColdBox_fw_messagebox')#" 
					output="rtnStruct">
		<cfelse>
			<cfset rtnStruct.type = "">
			<cfset rtnStruct.message = "">
		</cfif>
		
		<cfreturn rtnStruct>
	</cffunction>
	
	<!--- Clear the message --->
	<cffunction name="clearMessage" access="public" hint="Clears the message structure by deleting it from the session scope." output="false" returntype="void">
		<cfscript>
			var storageScope = evaluate(getstorageScope());
			structDelete(storageScope, "ColdBox_fw_messagebox");
		</cfscript>
	</cffunction>

	<!--- Is Empty --->
	<cffunction name="isEmpty" access="public" hint="Checks wether the messagebox is empty or not." returntype="boolean" output="false">
		<cfscript>
			var msgStruct = getMessage();
			
			if( msgStruct.type.length() eq 0 and msgStruct.message.length() eq 0 ){
				return true;
			}
			else{
				return false;
			}
		</cfscript>
	</cffunction>

	<!--- Render It --->
	<cffunction name="renderit" access="public" hint="Renders the message box and clears the message structure by default." output="false" returntype="any">
		<!--- ************************************************************* --->
		<cfargument name="clearFlag" type="boolean" required="false" default="true" hint="Flag to clear the message structure or not after rendering. Default is true.">
		<!--- ************************************************************* --->
		<cfset var msgStruct = getMessage()>
		<cfset var results = "">
		
		<cfif msgStruct.type.length() neq 0>
			<cfsavecontent variable="results"><cfinclude template="../includes/messagebox/MessageBox.cfm"></cfsavecontent>
		<cfelse>
			<cfset results = "">
		</cfif>
		
		<!--- Test to clear message structure --->
		<cfif arguments.clearFlag>
			<cfset clearMessage()>
		</cfif>
		
		<!--- Return Message --->
		<cfreturn results>
	</cffunction>

</cfcomponent>