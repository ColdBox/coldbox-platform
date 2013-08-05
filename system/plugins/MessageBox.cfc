<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This plugin is used by the framework for displaying alert message boxes.
	The user has three types of messages: 1) Warning 2) Error 3) Information
	The message is stored in the session scope. It can be changed to client
	by changing the framework's settings.xml file.
	The look can be altered by creating a class and setting it in the config file

----------------------------------------------------------------------->
<cfcomponent hint="This is the MessageBox plugin. It uses the session/client scope to save messages."
			 extends="coldbox.system.Plugin"
			 output="false"
			 cache="true">

	<cfproperty name="JSON" inject="coldbox:plugin:JSON">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="MessageBox" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.web.Controller">
		<!--- ************************************************************* --->
		<cfscript>
			super.Init(arguments.controller);

			// Plugin Properties
			setpluginName("Messagebox");
			setpluginVersion("2.1");
			setpluginDescription("This is a visual plugin that creates message boxes.");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");

			// static constant save key
			instance.flashKey = "coldbox_plugin_messagebox";
			instance.flashDataKey = "coldbox_plugin_messagebox_data";

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- error --->
	<cffunction name="error" output="false" access="public" returntype="void" hint="Facade to setmessage with error type">
   		<!--- ************************************************************* --->
		<cfargument name="message"  	required="false"  type="string" default="" hint="The message to show.">
		<cfargument name="messageArray" required="false"  type="Array"  hint="You can also send in an array of messages to render separated by a <br />">
		<!--- ************************************************************* --->
		<cfset arguments.type="error">
		<cfset setMessage(argumentCollection=arguments)>
	 </cffunction>

	<!--- info --->
	<cffunction name="info" output="false" access="public" returntype="void" hint="Facade to setmessage with info type">
   		<!--- ************************************************************* --->
		<cfargument name="message"  	required="false"  type="string" default="" hint="The message to show.">
		<cfargument name="messageArray" required="false"  type="Array"  hint="You can also send in an array of messages to render separated by a <br />">
		<!--- ************************************************************* --->
		<cfset arguments.type="info">
		<cfset setMessage(argumentCollection=arguments)>
	</cffunction>

	<!--- warn --->
	<cffunction name="warn" output="false" access="public" returntype="void" hint="Facade to setmessage with warning type">
		<!--- ************************************************************* --->
		<cfargument name="message"  	required="false"  type="string" default="" hint="The message to show.">
		<cfargument name="messageArray" required="false"  type="Array"  hint="You can also send in an array of messages to render separated by a <br />">
		<!--- ************************************************************* --->
		<cfset arguments.type="warning">
		<cfset setMessage(argumentCollection=arguments)>
	</cffunction>


	<!--- Set a message --->
	<cffunction name="setMessage" access="public" hint="Create a new MessageBox. Look at types." output="false" returntype="void">
		<!--- ************************************************************* --->
		<cfargument name="type"     	required="true"   type="string" hint="The message type.Available types [error][warning][info]">
		<cfargument name="message"  	required="false"  type="string" default="" hint="The message to show.">
		<cfargument name="messageArray" required="false"  type="Array"  hint="You can also send in an array of messages to render separated by a <br />">
		<!--- ************************************************************* --->
		<cfscript>
			var msg = structnew();

			// check message type
			if( isValidMessageType(arguments.type) ){
				// Populate message
				msg.type 	= arguments.type;
				msg.message = arguments.message;

				// Do we have a message array to flatten?
				if( structKeyExists(arguments,"messageArray") AND arrayLen(arguments.messageArray) ){
					msg.message = flattenMessageArray(arguments.messageArray);
				}

				// Flash it
				flash.put(name=instance.flashKey,value=msg,inflateToRC=false,saveNow=true,autoPurge=false);

			}
			else{
				$throw("The message type is invalid: #arguments.type#","Valid types are info,error or warning","MessageBox.InvalidMessageType");
			}
		</cfscript>
	</cffunction>

	<!--- Append A message --->
	<cffunction name="append" access="public" returntype="void" hint="Append a message to the MessageBox. If there is no message, then it sets the type to information." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="message"  	required="true"  type="string" hint="The message to append, it does not include any breaks or delimiters. You must send that.">
		<!--- ************************************************************* --->
		<cfscript>
			var currentMessage = "";
			var newMessage = "";

			// Do we have a message?
			if( isEmptyMessage() ){
				// Set default message
				setMessage('info',arguments.message);
			}
			else{
				// Get Current Message
				currentMessage = getMessage();
				// Append
				newMessage = currentMessage.message & arguments.message;
				// Set it back
				setMessage(currentMessage.type,newMessage);
			}
		</cfscript>
	</cffunction>

	<!--- Append A message --->
	<cffunction name="appendArray" access="public" returntype="void" hint="Append an array of messages to the MessageBox. If there is no message, then it sets the type to information." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="messageArray"  	required="true"  type="Array" hint="The array of messages to append. You must send that.">
		<!--- ************************************************************* --->
		<cfscript>
			var currentMessage = "";
			var newMessage = "";

			// Do we have a message?
			if( isEmptyMessage() ){
				// Set default message
				setMessage(type='info',messageArray=arguments.messageArray);
			}
			else{
				// Get Current Message
				currentMessage = getMessage();
				// Append
				ArrayPrePend(arguments.messageArray,currentMessage.message);
				// Set it back
				setMessage(type=currentMessage.type,messageArray=arguments.messageArray);
			}
		</cfscript>
	</cffunction>

	<!--- Prepend A message --->
	<cffunction name="prependArray" access="public" returntype="void" hint="Prepend an array of messages to the MessageBox. If there is no message, then it sets the type to information." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="messageArray"  	required="true"  type="Array" hint="The array of messages to append. You must send that.">
		<!--- ************************************************************* --->
		<cfscript>
			var currentMessage = "";
			var newMessage = "";

			// Do we have a message?
			if( isEmptyMessage() ){
				// Set default message
				setMessage(type='info',messageArray=arguments.messageArray);
			}
			else{
				// Get Current Message
				currentMessage = getMessage();
				// Append
				ArrayAppend(arguments.messageArray,currentMessage.message);
				// Set it back
				setMessage(type=currentMessage.type,messageArray=arguments.messageArray);
			}
		</cfscript>
	</cffunction>

	<!--- Get a Message --->
	<cffunction name="getMessage" access="public" hint="Returns a structure of the message if it exists, else a blank structure." returntype="any" output="false">
		<cfscript>
			var msg = structnew();

			// Check flash
			if( flash.exists(instance.flashKey) ){
				return flash.get(instance.flashKey);
			}

			// return empty messagebox.
			msg.type = "";
			msg.message = "";

			return msg;
		</cfscript>
	</cffunction>

	<!--- Clear the message --->
	<cffunction name="clearMessage" access="public" hint="Clears the message structure by deleting it from the session scope." output="false" returntype="void">
		<cfscript>
			flash.remove(name=instance.flashKey,saveNow=true);
		</cfscript>
	</cffunction>

	<!--- Is Empty --->
	<cffunction name="isEmptyMessage" access="public" hint="Checks wether the MessageBox is empty or not." returntype="boolean" output="false">
		<cfscript>
			var msgStruct = getMessage();

			if( msgStruct.type.length() eq 0 and msgStruct.message.length() eq 0 ){
				return true;
			}
			return false;
		</cfscript>
	</cffunction>

	<!--- A cool method to add key - value pairs to the messageBox usefull for form validation --->
	<cffunction name="putData" access="public" returntype="void" hint="Add data that can be used for arbitrary stuff">
		<cfargument name="theData" type="array" required="true">
		<cfscript>
			// Flash it
			flash.put(name=instance.flashDataKey,value=theData,inflateToRC=false,saveNow=true,autoPurge=false);
		</cfscript>
	</cffunction>

	<cffunction name="addData" access="public" returntype="void" hint="Add data that can be used for arbitrary stuff">
		<cfargument name="key" type="string" required="true">
		<cfargument name="value" type="string" required="true">
		<cfscript>
			var data = arrayNew(1);
			var tempStruct = {key = arguments.key, value = arguments.value};
			// Check flash
			if( flash.exists(instance.flashDataKey) ){
				data = flash.get(instance.flashDataKey);
			}
			arrayAppend(data, tempStruct);
			// Flash it
			flash.put(name=instance.flashDataKey,value=data,inflateToRC=false,saveNow=true,autoPurge=false);
		</cfscript>
	</cffunction>

	<cffunction name="getData" access="public" returntype="array" hint="Add data that can be used for arbitrary stuff">
		<cfargument name="clearData" type="boolean" required="false" default="true" hint="Flag to clear the data structure or not after rendering. Default is true.">
		<cfscript>
			var data = arrayNew(1);
			// Check flash
			if( flash.exists(instance.flashDataKey) ){
				data = flash.get(instance.flashDataKey);
			}
		</cfscript>

		<!--- Test to clear data structure from flash? --->
		<cfif arguments.clearData>
			<cfset flash.remove(name=instance.flashDataKey,saveNow=true)>
		</cfif>

		<cfreturn data>
	</cffunction>

	<cffunction name="getDataJSON" access="public" returntype="string" hint="Get the data as JSON">
		<cfargument name="clearData" type="boolean" required="false" default="true" hint="Flag to clear the data structure or not after rendering. Default is true.">
		<cfscript>
			return JSON.encode(getData(clearData));
		</cfscript>
	</cffunction>

	<!--- Render It --->
	<cffunction name="renderit" access="public" hint="Renders the message box and clears the message structure by default." output="false" returntype="any">
		<!--- ************************************************************* --->
		<cfargument name="clearMessage" type="boolean" 	required="false" default="true" hint="Flag to clear the message structure or not after rendering. Default is true.">
		<cfargument name="template" 	type="string" 	required="false" default="" 	hint="An optional template to use for rendering instead of core or setting"/>
		<!--- ************************************************************* --->
		<cfset var msgStruct 	= getMessage()>
		<cfset var results 		= "">
		<cfset var thisTemplate	= getSetting(name="messagebox_template", defaultValue="/coldbox/system/includes/messagebox/MessageBox.cfm")>

		<cfif len( trim( arguments.template ) )><cfset thisTemplate = arguments.template></cfif>

		<cfif msgStruct.type.length() neq 0>
			<cfsavecontent variable="results"><cfinclude template="#thisTemplate#"></cfsavecontent>
		<cfelse>
			<cfset results = "">
		</cfif>

		<!--- Test to clear message structure from flash? --->
		<cfif arguments.clearMessage>
			<cfset flash.remove(name=instance.flashKey,saveNow=true)>
		</cfif>

		<!--- Return Message --->
		<cfreturn results>
	</cffunction>

	<!--- renderMessage --->
	<cffunction name="renderMessage" access="public" hint="Renders a messagebox immediately for you with the passed in arguments" output="false" returntype="any">
		<!--- ************************************************************* --->
		<cfargument name="type"     	required="true"   type="string" hint="The message type.Available types [error][warning][info]">
		<cfargument name="message"  	required="false"  type="string" default="" hint="The message to show.">
		<cfargument name="messageArray" required="false"  type="Array"  hint="You can also send in an array of messages to render separated by a <br />">
		<cfargument name="template" 	required="false"  type="string" default="" 	hint="An optional template to use for rendering instead of core or setting"/>
		<!--- ************************************************************* --->
		<cfset var msgStruct = structnew()>
		<cfset var i = 0>
		<cfset var results = "">
		<cfset var thisTemplate = getSetting(name="messagebox_template", defaultValue="/coldbox/system/includes/messagebox/MessageBox.cfm")>

		<cfif len( trim( arguments.template ) )><cfset thisTemplate = arguments.template></cfif>
		
		<!--- Verify Message Type --->
		<cfif isValidMessageType(arguments.type)>
			<!--- Populate message struct --->
			<cfset msgStruct.type = arguments.type>
			<cfset msgStruct.message = arguments.message>
		<cfelse>
			<cfthrow message="Invalid message type: #arguments.type#" detail="Valid types are info,warning,error" type="Messagebox.InvalidMessageType">
		</cfif>

		<!--- Array Check --->
		<cfif structKeyExists(arguments, "messageArray")>
			<cfset msgStruct.message = flattenMessageArray(arguments.messageArray)>
		</cfif>

		<cfsavecontent variable="results"><cfinclude template="#thisTemplate#"></cfsavecontent>

		<cfreturn results>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>

    <cffunction name="isValidMessageType" access="private" output="false" returntype="string" hint="Returns a list of valid message types.">
	<cfargument name="type" type="string" required="true" />
	<cfreturn refindnocase("(error|warning|info)", trim(arguments.type)) />
    </cffunction>

	<!--- flattenMessageArray --->
    <cffunction name="flattenMessageArray" output="false" access="private" returntype="any">
    	<cfargument name="messageArray" required="true"  type="Array" hint="Array of messages to flatten">
		<cfset var i = 1>
		<cfset var message = "">

		<cfloop from="1" to="#arrayLen(arguments.messageArray)#" index="i">
			<cfset message = message & arguments.messageArray[i]>
			<cfif i neq ArrayLen(arguments.messageArray)>
				<cfset message = message & "<br/>">
			</cfif>
		</cfloop>

		<cfreturn message>
    </cffunction>

</cfcomponent>
