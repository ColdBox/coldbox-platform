<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	Simple Async File Appender
	
Properties:

- filepath : The location of where to store the log file.
- autoExpand : Whether to expand the file path or not. Defaults to true.
- filename : The name of the file, if not defined, then it will use the name of this appender.
		     Do not append an extension to it. We will append a .log to it.
- fileEncoding : The file encoding to use, by default we use UTF-8;
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.logging.appenders.FileAppender" 
			 output="false"
			 hint="This is a simple implementation of an appender that is file based but multithreaded">
			 
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- Constructor --->
	<cffunction name="init" access="public" returntype="AsyncFileAppender" hint="Constructor" output="false">
		<!--- ************************************************************* --->
		<cfargument name="name" 		required="true" hint="The unique name for this appender."/>
		<cfargument name="properties" 	required="false" default="#structnew()#" hint="A map of configuration properties for the appender"/>
		<cfargument name="layout" 		required="false" default="" hint="The layout class to use in this appender for custom message rendering."/>
		<cfargument name="levelMin"  	required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN"/>
		<cfargument name="levelMax"  	required="false" default="4" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN"/>
		<!--- ************************************************************* --->
		<cfscript>
			super.init(argumentCollection=arguments);
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the appender.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="any" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<cfscript>
			var uuid = createobject("java", "java.util.UUID").randomUUID();
			var ThreadName = "#getname()#_logMessage_#replace(uuid,"-","","all")#";
			var loge = arguments.logEvent;
			var timestamp = loge.getTimestamp();
			var message = loge.getMessage();
			var extra = "";
			var entry = "";
			
			// Does file still exist?
			if( NOT fileExists(getLogFullpath()) ){ initLogLocation(); }
			
			// Custom Layout?
			if( hasCustomLayout() ){
				entry = getCustomLayout().format(loge);
			}
			else{
				// Cleanup main message
				message = replace(message,'"','""',"all");
				message = replace(message,"#chr(13)##chr(10)#",'  ',"all");
				message = replace(message,chr(13),'  ',"all");
				if( len(loge.getExtraInfoAsString()) ){
					message &= " ExtraInfo:" & loge.getExtraInfoAsString();
				}			
				
				// Prepare Entry
				entry = '"#severityToString(logEvent.getSeverity())#","#getname()#","#dateformat(timestamp,"MM/DD/YYYY")#","#timeformat(timestamp,"HH:MM:SS")#","#loge.getCategory()#","#message#"';
			}
			
		</cfscript>
		
		<!--- Are we in a thread already? --->
		<cfif getUtil().inThread()>
			<cfset append(entry)>
		<cfelse>
			<!--- Thread this puppy --->
			<cfthread name="#threadName#" entry="#entry#"> 
				<cfset variables.append(attributes.entry)>
			</cfthread>		
		</cfif>
				
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>