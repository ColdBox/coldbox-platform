<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Description :
	I model mail server settings. You can send this bean to model or EJB's
	and when sending email. It will use its settings.

By 3.5 remove all direct get/set and leave get/setValue() instead

----------------------------------------------------------------------->
<cfcomponent hint="I model mail server settings to be used with our Mail Service" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" access="public" output="false" hint="I return a mail setting bean." returntype="MailSettingsBean">
		<cfargument name="server" 			required="false" type="string" 	default=""		hint="Initial value for the server property." />
		<cfargument name="username" 		required="false" type="string" 	default="" 		hint="Initial value for the username property." />
		<cfargument name="password" 		required="false" type="string" 	default=""		hint="Initial value for the password property." />
		<cfargument name="port" 			required="false" type="numeric" default="0"		hint="Initial value for the port property." />
		<cfargument name="protocol"			required="false" type="struct" 	default="#structNew()#">
		<!--- Mail Tag Settings --->
		<cfargument name="from" 			required="false" type="string" 		hint="Initial value for the from property." />
		<cfargument name="to" 				required="false" type="string" 		hint="Initial value for the to property." />
		<cfargument name="body" 			required="false" type="string" 		hint="Initial value for the email body." />
		<cfargument name="bcc" 				required="false" type="string" 		hint="Initial value for the bcc property." />
		<cfargument name="cc" 				required="false" type="string" 		hint="Initial value for the cc property." />
		<cfargument name="charset" 			required="false" type="string" 		hint="Initial value for the charset property." />
		<cfargument name="debug" 			required="false" type="boolean" 	hint="Initial value for the debug property." />
		<cfargument name="failto" 			required="false" type="string" 		hint="Initial value for the failto property." />
		<cfargument name="group"			required="false" type="string" 		hint="Initial value for the group property." />
		<cfargument name="groupcasesensitive" required="false" type="boolean" 	hint="Initial value for the groupcasesensitive property." />
		<cfargument name="mailerid" 		required="false" type="string" 		hint="Initial value for the mailerid property." />
		<cfargument name="maxrows" 			required="false" type="numeric" 	hint="Initial value for the maxrows property." />
		<cfargument name="mimeattach" 		required="false" type="string" 		hint="Initial value for the mimeattach property." />
		<cfargument name="priority" 		required="false" type="string" 		hint="Initial value for the priority property." />
		<cfargument name="query" 			required="false" type="string" 		hint="Initial value for the query property." />
		<cfargument name="replyto" 			required="false" type="string" 		hint="Initial value for the replyto property." />
		<cfargument name="spoolenable" 		required="false" type="boolean" 	hint="Initial value for the spoolenable property." />
		<cfargument name="startrow" 		required="false" type="numeric" 	hint="Initial value for the startrow property." />
		<cfargument name="subject" 			required="false" type="string" 		hint="Initial value for the subject property." />
		<cfargument name="timeout" 			required="false" type="numeric" 	hint="Initial value for the timeout property." />
		<cfargument name="type" 			required="false" type="string" 		hint="Initial value for the type property." />
		<cfargument name="useSSL" 			required="false" type="boolean" 	hint="Initial value for the useSSL property." />
		<cfargument name="useTLS" 			required="false" type="boolean" 	hint="Initial value for the useTLS property." />
		<cfargument name="wraptext" 		required="false" type="numeric" 	hint="Initial value for the wraptext property." />
		<!--- ************************************************************* --->
		<cfscript>
			var key = 0;

			instance 			= structnew();

			// init _protocol
			variables._protocol	= "";

			// populate mail setting keys
			for(key in arguments){
				if( structKeyExists(arguments,key) ){
					instance[key] = arguments[key];
				}
			}

			// Register the protocol to be used
			registerProtocol(argumentcollection=instance.protocol);

			// Return an instance of the class.
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- getValue --->
    <cffunction name="getValue" output="false" access="public" returntype="any" hint="Get a value of a setting">
    	<cfargument name="setting" type="any" required="true" hint="The name of the setting to retrieve"/>
		<cfargument name="default" type="any" required="false" hint="The default value to return">
		<cfscript>
			if( structKeyExists(instance, arguments.setting) ){ return instance[arguments.setting];}
			if( structKeyExists(arguments,"default") ){ return arguments.default; }
		</cfscript>

		<cfthrow type="MailSettingsBean.InvalidValue"
				 message="The setting you requested #arguments.setting# does not exist"
				 detail="Valid settings are #structKeyList(instance)#">

    </cffunction>

	<!--- setValue --->
    <cffunction name="setValue" output="false" access="public" returntype="any" hint="Set a new setting value and return yourself">
    	<cfargument name="setting"	type="any" required="true" hint="The name of the setting "/>
		<cfargument name="value" 	type="any" required="true" hint="The value of the setting "/>
		<cfscript>
    		instance[arguments.setting] = arguments.value;
			return this;
		</cfscript>
    </cffunction>

	<!--- registerProtocol --->
	<cffunction name="registerProtocol" access="public" returntype="void" hint="I register a protocol with the settings.">
		<cfargument name="class" 		required="false" default="coldbox.system.core.mail.protocols.CFMailProtocol" hint="The instantiation path of the mail protocol object"/>
		<cfargument name="properties"	required="false" default="#structNew()#" hint="The properties to construct the protocol object with" />
		<cftry>
			<cfset variables._protocol = createObject("component", arguments.class).init(arguments.properties)>
			<cfcatch type="any">
				<cfthrow type="MailSettingsBean.FailLoadProtocolException"
					     message="Unable to successfully load the supplied mail protocol: #arguments.toString()#"
						 detail="#cfcatch.message# #cfcatch.detail# #cfcatch.stacktrace#">
			</cfcatch>
		</cftry>
	</cffunction>

	<!--- memento --->
	<cffunction name="getMemento" access="public" returntype="any" output="false" hint="Get the memento">
		<cfreturn variables.instance >
	</cffunction>
	<cffunction name="setMemento" access="public" returntype="void" output="false" hint="Set the memento">
		<cfargument name="memento" type="struct" required="true">
		<cfset variables.instance = arguments.memento>
	</cffunction>

	<!--- get/set protocolsettings --->
	<cffunction name="setProtocol" access="public" return="any" output="false" hint="Set protocolsettings">
		<cfargument name="protocol" type="struct">
		<cfset instance.protocol=arguments.protocol >
		<cfreturn this>
	</cffunction>
	<cffunction name="getprotocol" access="public" return="struct" output="false" hint="Get protocolsettings">
		<cfreturn instance.protocol >
	</cffunction>

	<!--- get the protocol --->
	<cffunction name="getTransit" access="public" return="any" output="false" hint="Get the protocol implementation object">
		<cfreturn variables._protocol >
	</cffunction>

<!------------------------------------------- DEPRECATE BY 3.5 ------------------------------------------>

	<!--- get/set server --->
	<cffunction name="setServer" access="public" return="any" output="false" hint="Set server DEPRECATED">
		<cfargument name="server" >
		<cfset instance.server=arguments.server >
		<cfreturn this>
	</cffunction>
	<cffunction name="getServer" access="public" return="string" output="false" hint="Get server DEPRECATED">
		<cfreturn instance.server >
	</cffunction>

	<!--- get/set port --->
	<cffunction name="setPort" access="public" return="any" output="false" hint="Set port DEPRECATED">
		<cfargument name="port" >
		<cfset instance.port=arguments.port >
		<cfreturn this>
	</cffunction>
	<cffunction name="getPort" access="public" return="string" output="false" hint="Get port DEPRECATED">
		<cfreturn instance.port >
	</cffunction>

	<!--- get/set username --->
	<cffunction name="setUsername" access="public" return="any" output="false" hint="Set Username DEPRECATED">
	  <cfargument name="username" >
	  <cfset instance.username=arguments.username >
	  <cfreturn this>
	</cffunction>
	<cffunction name="getUsername" access="public" return="string" output="false" hint="Get Username DEPRECATED">
		<cfreturn instance.Username >
	</cffunction>

	<!--- get/set password --->
	<cffunction name="setPassword" access="public" return="any" output="false" hint="Set Password DEPRECATED">
		<cfargument name="password" >
		<cfset instance.password=arguments.password >
		<cfreturn this>
	</cffunction>
	<cffunction name="getPassword" access="public" return="string" output="false" hint="Get Password DEPRECATED">
		<cfreturn instance.Password >
	</cffunction>

</cfcomponent>