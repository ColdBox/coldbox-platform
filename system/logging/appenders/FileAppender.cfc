<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	Simple File Appender
	
Properties:

- filepath : The location of where to store the log file.
- autoExpand : Whether to expand the file path or not. Defaults to true.
- filename : The name of the file, if not defined, then it will use the name of this appender.
		     Do not append an extension to it. We will append a .log to it.
- fileEncoding : The file encoding to use, by default we use UTF-8;
----------------------------------------------------------------------->
<cfcomponent name="FileAppender" 
			 extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="This is a simple implementation of an appender that is file based.">
			 
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- Constructor --->
	<cffunction name="init" access="public" returntype="FileAppender" hint="Constructor" output="false">
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true" hint="The unique name for this appender."/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="A map of configuration properties for the appender"/>
		<!--- ************************************************************* --->
		<cfscript>
			super.init(argumentCollection=arguments);
			
			// Setup Properties
			if( NOT propertyExists("filepath") ){
				$throw(message="Filepath property not defined",type="FileAppender.PropertyNotFound");
			}
			if( NOT propertyExists("autoExpand") ){
				setProperty("autoExpand",true);
			}
			if( NOT propertyExists("filename") ){
				setProperty("filename",getName());
			}
			if( NOT propertyExists("fileEncoding") ){
				setProperty("fileEncoding","UTF-8");
			}
			
			// Setup the log file full path
			instance.logFullpath = getProperty("filePath");
			// Clean ending slash
			if( right(instance.logFullpath,1) eq "/" OR right(instance.logFullPath,1) eq "\"){
				instance.logFullPath = left(instance.logFullpath, len(instance.logFullPath)-1);
			}
			instance.logFullPath = instance.logFullpath & "/" & getProperty("filename") & ".log";
			
			// Do we expand the path?
			if( getProperty("autoExpand") ){
				instance.logFullPath = expandPath(instance.logFullpath);
			}
			
			//lock information
			instance.lockName = getname() & "logOperation";
			instance.lockTimeout = 25;
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- Get Lock Name --->
	<cffunction name="getlockname" access="public" returntype="string" output="false" hint="The file Lock name">
		<cfreturn instance.lockname>
	</cffunction>
	<cffunction name="getlockTimeout" access="public" returntype="numeric" output="false" hint="The lock timeout">
		<cfreturn instance.lockTimeout>
	</cffunction>
	
	<!--- onRegistration --->
	<cffunction name="onRegistration" output="false" access="public" returntype="void" hint="Runs on registration">
		<cfscript>
			// Default Log Directory
			ensureDefaultLogDirectory();
			// Init the log location
			initLogLocation();
		</cfscript>
	</cffunction>
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the appender.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="coldbox.system.logging.LogEvent" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<cfscript>
			var loge = arguments.logEvent;
			var timestamp = loge.getTimestamp();
			var message = loge.getMessage();
			var extra = "";
			
			// Does file still exist?
			if( NOT fileExists(getLogFullpath()) ){ initLogLocation(); }
			
			// Cleanup main message
			message = replace(message,'"','""',"all");
			message = replace(message,"#chr(13)##chr(10)#",'  ',"all");
			message = replace(message,chr(13),'  ',"all");
			if( len(loge.getExtraInfoAsString()) ){
				message = message & " " & loge.getExtraInfoAsString();
			}
			
			// Setup the real entry
			append('"#severityToString(logEvent.getSeverity())#","#getname()#","#dateformat(timestamp,"MM/DD/YYYY")#","#timeformat(timestamp,"HH:MM:SS")#","#loge.getCategory()#","#message#"');		
		</cfscript>
	</cffunction>
	
	<!--- get/set log full path --->
	<cffunction name="getlogFullpath" access="public" returntype="string" output="false" hint="Get the full log path used.">
		<cfreturn instance.logFullpath>
	</cffunction>
	
	<!--- Remove the log File --->
	<cffunction name="removeLogFile" access="public" hint="Removes the log file" output="false" returntype="void">
		<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cffile action="delete" file="#getLogFullPath()#">
		</cflock>
	</cffunction>

	<!--- Init Log Location --->
	<cffunction name="initLogLocation" access="public" hint="Initialize the file log location if it does not exist." output="false" returntype="void">
		<cfset var fileObj = "">
		
		<!--- Create Log File if It does not exist and initialize it. --->
		<cfif not fileExists(getLogFullPath())>
			<!--- Log File Setup --->
			<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfscript>
				// Double Lock
				if( not fileExists(getLogFullpath()) ){
					// Create empty log file
					try{
						fileObj = createObject("java","java.io.File").init(JavaCast("string",getLogFullPath())).createNewFile();
					}
					catch(Any e){
						$log("ERROR","Cannot create appender's: #getName()# log file. File #getLogFullPath()#. #e.message# #e.detail#");
					}					
				}	
			</cfscript>		
			</cflock>
			<!--- Log First Entry --->
			<cfset append('"Severity","Appender","Date","Time","Category","Message"')>
		<cfelse>
			<cfscript>
			//Check if we can write
			fileObj = createObject("java","java.io.File").init(JavaCast("string",getLogFullPath()));
			if( NOT fileObj.canWrite() ){
				$log("ERROR","Cannot write to file: #getLogFullpath()# by appender #getName()#");
			}
			</cfscript>
		</cfif>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	

	<!--- append --->
	<cffunction name="append" output="false" access="private" returntype="void" hint="Append a message to a file">
		<cfargument name="message" type="any" required="true" hint="The message to append"/>
		<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cffile action="append" 
					addnewline="true" 
					file="#getlogFullPath()#" 
					output="#arguments.message#"
					charset="#getProperty("fileEncoding")#">		
		</cflock>				
	</cffunction>

	<!--- Ensure directory --->
	<cffunction name="ensureDefaultLogDirectory" access="private" hint="Ensures the log directory." output="false" returntype="void">
		<cfset var dirPath = getDirectoryFrompath(getLogFullpath())>
		
		<!--- Check if the directory already exists --->
		<cfif not directoryExists(dirPath)>
			<cfdirectory action="create" directory="#dirPath#">
		</cfif>
	</cffunction>
	

</cfcomponent>