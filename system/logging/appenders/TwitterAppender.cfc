<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	A cool twitter appender that sends either status updates
	or direct messages.

Properties:
- username : The account username
- password : The account password
- logType : status or dm (To either update status or a direct message). Defaults to direct message.
- dmUser  : The user to send the direct message to.


----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="A cool twitter appender">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="TwitterAppender" hint="Constructor" output="false" >
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
			if( NOT propertyExists('username') ){
				$throw(message="Please define a twitter username",type="TwitterAppender.MissingUsername");
			}
			if( NOT propertyExists('password') ){
				$throw(message="Please define a twitter password",type="TwitterAppender.MissingPassword");
			}
			if( NOT propertyExists('logType') ){
				setProperty("logType","DM");
			}
			if( getProperty("logType") eq "DM" and NOT propertyExists("dmUser") ){
				$throw(message="Please define a direct message user property: dmUser",type="TwitterAppender.MissingDMUser");
			}
			if( NOT reFindNoCase("^(status|dm)$", getProperty("logType")) ){
				$throw(message="Invalid logtype. Valid types are: dm or status",type="TwitterAppender.InvalidLogType");
			}
			
									
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="true" returntype="void" hint="Write an entry into the appender.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="any" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<cfscript>
			var entry = structnew();
			var loge = arguments.logEvent;
			var udfCall = "";
			
			// Render entry
			if( hasCustomLayout() ){
				entry = getCustomLayout().format(loge);
			}
			else{
				entry = "#severityToString(loge.getseverity())# #loge.getCategory()# #loge.getmessage()# ExtraInfo: #loge.getextraInfoAsString()#";
			}
			
			// Type of message
			if( getProperty("logType") eq "dm"){
				udfCall = variables.directMessage;
			}
			else{
				udfCall = variables.statusUpdate;
			}
			
			//Call it
			try{
				udfCall(entry);
			}
			catch(Any e){
				$log("ERROR","Error sending twitter message of type #getProperty("logType")#. #e.message# #e.detail#");
			}
		</cfscript>	   
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- directMessage --->
	<cffunction name="directMessage" output="false" access="private" returntype="void" hint="Send a direct message">
		<cfargument name="message" required="true" hint="The message to post"/>
		
		<cfset var msg = "">
		<cfhttp url="http://twitter.com/direct_messages/new.xml" 
				username="#getProperty("username")#" 
				password="#getProperty("password")#" 
				result="msg" 
				method="post"
				timeout="5">
		    <cfhttpparam type="formfield" name="user" value="#getProperty("dmUser")#">
		    <cfhttpparam type="formfield" name="text" value="#arguments.message#">
		</cfhttp>
	</cffunction>
	
	<!--- statusUpdate --->
	<cffunction name="statusUpdate" output="false" access="private" returntype="void" hint="Send a status update">
		<cfargument name="message" required="true" hint="The message to post"/>
		
		<cfset var msg = "">
		<cfhttp url="http://twitter.com/statuses/update.xml" 
				username="#getProperty("username")#" 
				password="#getProperty("password")#" 
				result="msg" 
				method="post"
				timeout="5">
			<cfhttpparam name="status" value="#arguments.message#" type="formfield" />
		</cfhttp>
	</cffunction>
	
	
</cfcomponent>