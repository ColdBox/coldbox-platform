<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	A RollingFileAppender. This appenders rotates the log files according
	to the properties defined.
	
Properties:

- filepath : The location of where to store the log file.
- autoExpand : Whether to expand the file path or not. Defaults to true.
- filename : The name of the file, if not defined, then it will use the name of this appender.
		     Do not append an extension to it. We will append a .log to it.
- fileEncoding : The file encoding to use, by default we use UTF-8;
- fileMaxSize : The max file size for log files. Defaults to 2000 (2 MB)
- fileMaxArchives : The max number of archives to keep. Defaults to 2.
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.logging.appenders.FileAppender" 
			 output="false"
			 hint="This is a simple implementation of an appender that is file based but multithreaded">
			 
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- Constructor --->
	<cffunction name="init" access="public" returntype="RollingFileAppender" hint="Constructor" output="false">
		<!--- ************************************************************* --->
		<cfargument name="name" 		required="true" hint="The unique name for this appender."/>
		<cfargument name="properties" 	required="false" default="#structnew()#" hint="A map of configuration properties for the appender"/>
		<cfargument name="layout" 		required="false" default="" hint="The layout class to use in this appender for custom message rendering."/>
		<cfargument name="levelMin"  	required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN"/>
		<cfargument name="levelMax"  	required="false" default="4" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN"/>
		<!--- ************************************************************* --->
		<cfscript>
			super.init(argumentCollection=arguments);
			
			if( NOT propertyExists("fileMaxSize") OR NOT isNumeric(getProperty("fileMaxSize")) ){
				setProperty("fileMaxSize","2000");
			}
			if( NOT propertyExists("fileMaxArchives") OR NOT isNumeric(getProperty("fileMaxArchives")) ){
				setProperty("fileMaxArchives","2");
			}
			
			instance.fileRotator = createObject("component","coldbox.system.logging.util.FileRotator").init();
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the appender.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="any" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<cfscript>
			// Log the message in the super.
			super.logMessage(arguments.logEvent);
			
			// Rotate
			try{
				instance.fileRotator.checkRotation(this);
			}
			catch(Any e){
				$log("ERROR","Could not zip and rotate log files in #getName()#. #e.message# #e.detail#");
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	
</cfcomponent>