<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Description :
	I model mail server settings. You can send this bean to model or EJB's
	and when sending email. It will use its settings.


----------------------------------------------------------------------->
<cfcomponent hint="I model mail server settings" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" hint="I return a mail setting bean." returntype="MailSettingsBean">
		<!--- ************************************************************* --->
		<cfargument name="server"	required="false" default="">
		<cfargument name="username"	required="false" default="">
		<cfargument name="password"	required="false" default="">
		<cfargument name="port"		required="false" default="">
		<cfargument name="protocol"		required="false" type="struct" default="#structNew()#">
		<!--- ************************************************************* --->
		<cfscript>
			instance 			= structnew();
			instance.server 	= arguments.server;
			instance.username 	= arguments.username;
			instance.password 	= arguments.password;
			instance.port 		= arguments.port;
			instance.protocol = arguments.protocol;
			
			// Register the protocol.
			registerProtocol(argumentcollection=instance.protocol);
			
			// Return an instance of the class.
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<cffunction name="registerProtocol" access="public" returntype="void" hint="I register a protocol with the settings.">
		<cfargument name="class" required="false" default="coldbox.system.core.mail.protocols.cfmailProtocol" />
		<cfargument name="properties" required="false" default="#structNew()#" />
		
		<cfscript>
			// Try to load this protocol
			try {
				// Create an instance with the required settings.
				_protocol = createObject("component", arguments.class).init(arguments.properties);
			} catch(Any e) {
				// We were unable to create an instance of the protocol.
				// Throw an exception to this effect.
				throw(message="We were unable to successfully load the supplied mail protocol. (#instance.protocol.class#) because (#e#)", type="coldbox.mail.FailLoadProtocol");
			};
		</cfscript>
	
	</cffunction>

	<!--- memento --->
	<cffunction name="getMemento" access="public" returntype="any" output="false" hint="Get the memento">
		<cfreturn variables.instance >
	</cffunction>
	<cffunction name="setMemento" access="public" returntype="void" output="false" hint="Set the memento">
		<cfargument name="memento" type="struct" required="true">
		<cfset variables.instance = arguments.memento>
	</cffunction>

	<!--- get/set server --->
	<cffunction name="setServer" access="public" return="any" output="false" hint="Set server">
		<cfargument name="server" >
		<cfset instance.server=arguments.server >
		<cfreturn this>
	</cffunction>
	<cffunction name="getServer" access="public" return="string" output="false" hint="Get server">
		<cfreturn instance.server >
	</cffunction>
	
	<!--- get/set protocolsettings --->
	<cffunction name="setprotocol" access="public" return="any" output="false" hint="Set protocolsettings">
		<cfargument name="protocol" >
		<cfset instance.protocol=arguments.protocol >
		<cfreturn this>
	</cffunction>
	<cffunction name="getprotocol" access="public" return="struct" output="false" hint="Get protocolsettings">
		<cfreturn instance.protocol >
	</cffunction>	
	
	<!--- get the protocol --->
	<cffunction name="getTransit" access="public" return="any" output="false" hint="Get protocol">
		<cfreturn _protocol >
	</cffunction>

	<!--- get/set port --->
	<cffunction name="setPort" access="public" return="any" output="false" hint="Set port">
		<cfargument name="port" >
		<cfset instance.port=arguments.port >
		<cfreturn this>
	</cffunction>
	<cffunction name="getPort" access="public" return="string" output="false" hint="Get port">
		<cfreturn instance.port >
	</cffunction>
	
	<!--- get/set username --->
	<cffunction name="setUsername" access="public" return="any" output="false" hint="Set Username">
	  <cfargument name="username" >
	  <cfset instance.username=arguments.username >
	  <cfreturn this>
	</cffunction>
	<cffunction name="getUsername" access="public" return="string" output="false" hint="Get Username">
		<cfreturn instance.Username >
	</cffunction>

	<!--- get/set password --->
	<cffunction name="setPassword" access="public" return="any" output="false" hint="Set Password">
		<cfargument name="password" >
		<cfset instance.password=arguments.password >
		<cfreturn this>
	</cffunction>
	<cffunction name="getPassword" access="public" return="string" output="false" hint="Get Password">
		<cfreturn instance.Password >
	</cffunction>

</cfcomponent>