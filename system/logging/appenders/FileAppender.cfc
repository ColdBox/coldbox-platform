<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
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
- fileEncoding : The file encoding to use, by default we use ISO-8859-1;
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.logging.AbstractAppender"
			 output="false"
			 hint="This is a simple implementation of an appender that is file based.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- Constructor --->
	<cffunction name="init" access="public" returntype="FileAppender" hint="Constructor" output="false">
		<!--- ************************************************************* --->
		<cfargument name="name" 		required="true" hint="The unique name for this appender."/>
		<cfargument name="properties" 	required="false" default="#structnew()#" hint="A map of configuration properties for the appender"/>
		<cfargument name="layout" 		required="false" default="" hint="The layout class to use in this appender for custom message rendering."/>
		<cfargument name="levelMin"  	required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN"/>
		<cfargument name="levelMax"  	required="false" default="4" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN"/>
		<!--- ************************************************************* --->
		<cfscript>
			super.init(argumentCollection=arguments);

			// Setup Properties
			if( NOT propertyExists("filepath") ){
				throw(message="Filepath property not defined",type="FileAppender.PropertyNotFound");
			}
			if( NOT propertyExists("autoExpand") ){
				setProperty("autoExpand",true);
			}
			if( NOT propertyExists("filename") ){
				setProperty("filename",getName());
			}
			if( NOT propertyExists("fileEncoding") ){
				setProperty("fileEncoding","ISO-8859-1");
			}
			// Cleanup File Names
			setProperty("filename", REreplacenocase(getProperty("filename"), "[^0-9a-z]","","ALL") );

			// Setup the log file full path
			instance.logFullpath = getProperty("filePath");
			// Clean ending slash
			instance.logFullPath = reReplacenocase(instance.logFullPath,"[/\\]$","");
			// Concatenate Full Log path
			instance.logFullPath = instance.logFullpath & "/" & getProperty("filename") & ".log";

			// Do we expand the path?
			if( getProperty("autoExpand") ){
				instance.logFullPath = expandPath(instance.logFullpath);
			}

			//lock information
			instance.lockName = instance._hash & getname() & "logOperation";
			instance.lockTimeout = 25;

			return this;
		</cfscript>
	</cffunction>

	<!--- Get Lock Name --->
	<cffunction name="getlockname" access="public" returntype="any" output="false" hint="The file Lock name">
		<cfreturn instance.lockname>
	</cffunction>
	<cffunction name="getlockTimeout" access="public" returntype="any" output="false" hint="The lock timeout">
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
		<cfargument name="logEvent" type="any" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<cfscript>
			var loge = arguments.logEvent;
			var timestamp = loge.getTimestamp();
			var message = loge.getMessage();
			var entry = "";

			// Does file still exist?
			if( NOT fileExists( instance.logFullpath ) ){
				ensureDefaultLogDirectory();
				initLogLocation();
			}

			if( hasCustomLayout() ){
				entry = getCustomLayout().format(loge);
			}
			else{
				// Cleanup main message
				message = replace(message,'"','""',"all");
				message = replace(message,"#chr(13)##chr(10)#",'  ',"all");
				message = replace(message,chr(13),'  ',"all");
				if( len(loge.getExtraInfoAsString()) ){
					message = message & " " & loge.getExtraInfoAsString();
				}
				// Entry string
				entry = '"#severityToString(logEvent.getSeverity())#","#getname()#","#dateformat(timestamp,"MM/DD/YYYY")#","#timeformat(timestamp,"HH:MM:SS")#","#loge.getCategory()#","#message#"';
			}

			// Setup the real entry
			append(entry);
		</cfscript>
	</cffunction>

	<!--- get/set log full path --->
	<cffunction name="getlogFullpath" access="public" returntype="any" output="false" hint="Get the full log path used.">
		<cfreturn instance.logFullpath>
	</cffunction>

	<!--- Remove the log File --->
	<cffunction name="removeLogFile" access="public" hint="Removes the log file" output="false" returntype="void">
		<cfif fileExists( instance.logFullpath )>
			<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
				<cffile action="delete" file="#instance.logFullpath#">
			</cflock>
		</cfif>
	</cffunction>

	<!--- Init Log Location --->
	<cffunction name="initLogLocation" access="public" hint="Initialize the file log location if it does not exist." output="false" returntype="void">
		<cfset var fileObj = "">

		<!--- Create Log File if It does not exist and initialize it. --->
		<cfif not fileExists( instance.logFullpath )>
			<!--- Log File Setup --->
			<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfscript>
				// Double Lock
				if( not fileExists( instance.logFullpath ) ){
					// Create empty log file
					try{
						fileObj = createObject("java","java.io.File").init(JavaCast("string", instance.logFullpath )).createNewFile();
					}
					catch(Any e){
						$log("ERROR","Cannot create appender's: #getName()# log file. File #instance.logFullpath#. #e.message# #e.detail#");
					}
				}
			</cfscript>
			</cflock>
			<!--- Log First Entry --->
			<cfset append('"Severity","Appender","Date","Time","Category","Message"')>
		<cfelse>
			<cfscript>
			//Check if we can write
			fileObj = createObject("java","java.io.File").init(JavaCast("string",instance.logFullpath));
			if( NOT fileObj.canWrite() ){
				$log("ERROR","Cannot write to file: #instance.logFullpath# by appender #getName()#");
			}
			</cfscript>
		</cfif>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->



	<!--- append --->
	<cffunction name="append" output="false" access="private" returntype="void" hint="Append a message to a file">
		<cfargument name="message" required="true" hint="The message to append"/>

		<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cffile action="append"
					addnewline="true"
					file="#instance.logFullpath#"
					output="#arguments.message#"
					charset="#getProperty("fileEncoding")#">
		</cflock>
	</cffunction>

	<!--- Ensure directory --->
	<cffunction name="ensureDefaultLogDirectory" access="private" hint="Ensures the log directory." output="false" returntype="void">
		<cfset var dirPath = getDirectoryFrompath(instance.logFullpath)>

		<!--- Check if the directory already exists --->
		<cfif not directoryExists(dirPath)>
			<cfdirectory action="create" directory="#dirPath#">
		</cfif>
	</cffunction>


</cfcomponent>