<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	A socket appender that logs to a socket

Inspiration from Tim Blair <tim@bla.ir> by the cflogger project

Properties:
- host : the host to connect to
- port : the port to connect to
- timeout : the timeout in seconds. defaults to 5 seconds
- persistConnection : Whether to persist the connection or create a new one every log time. Defaults to true;
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="A NIO socket appender">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="SocketAppender" hint="Constructor" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 		required="true" hint="The unique name for this appender."/>
		<cfargument name="properties" 	required="false" default="#structnew()#" hint="A map of configuration properties for the appender"/>
		<cfargument name="layout" 		required="false" default="" hint="The layout class to use in this appender for custom message rendering."/>
		<cfargument name="levelMin"  	required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN"/>
		<cfargument name="levelMax"  	required="false" default="4" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN"/>
		<!--- ************************************************************* --->
		<cfscript>
			// Init supertype
			super.init(argumentCollection=arguments);
			
			// Verify properties
			if( NOT propertyExists('host') ){
				throw(message="The host must be provided",type="SocketAppender.HostNotFound");
			}
			if( NOT propertyExists('port') ){
				throw(message="The port must be provided",type="SocketAppender.PortNotFound");
			}
			if( NOT propertyExists('timeout') OR NOT isNumeric(getProperty("timeout"))){
				setProperty("timeout",5);
			}
			if( NOT propertyExists('persistConnection') ){
				setProperty("persistConnection",true);
			}
			
			// Socket storage
			instance.socket = "";
			instance.socketWriter = "";
			
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- onRegistration --->
	<cffunction name="onRegistration" output="false" access="public" returntype="void" hint="When registration occurs">
		<cfif getProperty("persistConnection")>
			<cfset openConnection()>
		</cfif>
	</cffunction>
	
	<!--- onRegistration --->
	<cffunction name="onUnRegistration" output="false" access="public" returntype="void" hint="When Unregistration occurs">
		<cfif getProperty("persistConnection")>
			<cfset closeConnection()>
		</cfif>
	</cffunction>
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="true" returntype="void" hint="Write an entry into the appender.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="any" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<cfscript>
			var loge = arguments.logEvent;
			var entry = "";
			
			// Prepare entry to send.
			if( hasCustomLayout() ){
				entry = getCustomLayout().format(loge);
			}
			else{
				entry = "#severityToString(loge.getseverity())# #loge.getCategory()# #loge.getmessage()# ExtraInfo: #loge.getextraInfoAsString()#";
			}	
			
			// Open connection?
			if( NOT getProperty("persistConnection") ){
				openConnection();
			}
			
			// Send data to Socket
			try{
				getSocketWriter().println(entry);
			}
			catch(Any e){
				$log("ERROR","#getName()# - Error sending entry to socket #getProperties().toString()#. #e.message# #e.detail#");
			}
			
			// Close Connection?
			if( NOT getProperty("persistConnection") ){
				closeConnection();
			}			
		</cfscript>	   
	</cffunction>
	
	<cffunction name="getSocket" access="public" returntype="any" output="false" hint="Get the socket object">
		<cfreturn instance.socket>
	</cffunction>
	
	<cffunction name="getSocketWriter" access="public" returntype="any" output="false" hint="Get the socket writer object">
		<cfreturn instance.socketWriter>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- Open a Connection --->
	<cffunction name="openConnection" access="private" returntype="void" output="false" hint="Opens a socket connection">
		<cfscript>
			try{
				instance.socket = createObject("java", "java.net.Socket").init(getProperty("host"), javaCast("int",getProperty("port")));
			}
			catch(Any e){
				throw(message="Error opening socket to #getProperty("host")#:#getProperty("port")#",
					   detail=e.message & e.detail & e.stacktrace,
					   type="SocketAppender.ConnectionException");
			}
			// Set Timeout
			instance.socket.setSoTimeout(javaCast("int",getProperty("timeout") * 1000));
			
			//Prepare Writer
			instance.socketWriter = createObject("java","java.io.PrintWriter").init(instance.socket.getOutputStream());
		</cfscript>
	</cffunction>

	<!--- Close the socket connection --->
	<cffunction name="closeConnection" access="public" returntype="void" output="no" hint="Closes the socket connection">
		<cfscript>
			getSocketWriter().close();
			getSocket().close();
		</cfscript>
	</cffunction>
	
	
</cfcomponent>