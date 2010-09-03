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

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="MessageBox" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.web.Controller">
		<!--- ************************************************************* --->
		<cfscript>	
			super.Init(arguments.controller);
			
			// Plugin Properties
			setpluginName("Messagebox");
			setpluginVersion("2.0");
			setpluginDescription("This is a visual plugin that creates message boxes.");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");
			
			// static constant save key
			instance.flashKey = "coldbox_plugin_messagebox";

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
	
	<!--- error --->
    <cffunction name="info" output="false" access="public" returntype="void" hint="Facade to setmessage with info type">
   		<!--- ************************************************************* --->
		<cfargument name="message"  	required="false"  type="string" default="" hint="The message to show.">
		<cfargument name="messageArray" required="false"  type="Array"  hint="You can also send in an array of messages to render separated by a <br />">
		<!--- ************************************************************* --->
		<cfset arguments.type="information">
		<cfset setMessage(argumentCollection=arguments)> 
	</cffunction>
	
	<!--- error --->
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
			if( refindnocase("(error|warning|info)", trim(arguments.type)) ){
				// Populate message
				msg.type 	= arguments.type;
				msg.message = arguments.message;
				
				// Do we have a message array to flatten?
				if( structKeyExists(arguments,"messageArray") ){
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
			if( isEmpty() ){
				// Set default message
				setMessage('information',arguments.message);
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
			if( isEmpty() ){
				// Set default message
				setMessage(type='information',messageArray=arguments.messageArray);
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
	<cffunction name="isEmpty" access="public" hint="Checks wether the MessageBox is empty or not." returntype="boolean" output="false">
		<cfscript>
			var msgStruct = getMessage();
			
			if( msgStruct.type.length() eq 0 and msgStruct.message.length() eq 0 ){
				return true;
			}
			return false;
		</cfscript>
	</cffunction>

	<!--- Render It --->
	<cffunction name="renderit" access="public" hint="Renders the message box and clears the message structure by default." output="false" returntype="any">
		<!--- ************************************************************* --->
		<cfargument name="clearMessage" type="boolean" required="false" default="true" hint="Flag to clear the message structure or not after rendering. Default is true.">
		<!--- ************************************************************* --->
		<cfset var msgStruct = getMessage()>
		<cfset var results = "">
		
		<cfif msgStruct.type.length() neq 0>
			<cfsavecontent variable="results"><cfinclude template="/coldbox/system/includes/messagebox/MessageBox.cfm"></cfsavecontent>
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
		<!--- ************************************************************* --->
		<cfset var msgStruct = structnew()>
		<cfset var i = 0>
		<cfset var results = "">
		
		<!--- Verify Message Type --->
		<cfif refindnocase("(error|warning|info)", trim(arguments.type))>
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
			
		<cfsavecontent variable="results"><cfinclude template="/coldbox/system/includes/messagebox/MessageBox.cfm"></cfsavecontent>
		
		<cfreturn results>		
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>

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