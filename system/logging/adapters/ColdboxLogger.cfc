<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	This the main coldbox logger adapter
----------------------------------------------------------------------->
<cfcomponent name="ColdboxLogger" output="false" extends="coldbox.system.logging.AbstractLoggingAdapter" hint="The main Coldbox logging adapter" >

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- Constructor --->
	<cffunction name="init" access="public" returntype="ColdboxLogger" hint="Constructor" output="false">
		<cfargument name="controller" type="coldbox.system.Controller" required="true" hint="The coldbox main controller">
		<cfscript>
			super.init(arguments.controller);
			
			/* Available valid severities */
			instance.validSeverities = "information|fatal|warning|error|debug";
			
			/* Log Levels */
			instance.logLevels = structnew();
			instance.logLevels["debug"] = 4;
			instance.logLevels["information"] = 3;
			instance.logLevels["warning"] = 2;
			instance.logLevels["error"] = 1;
			instance.logLevels["fatal"] = 0;
			
			/* Lock Information */
			instance.lockName = instance.controller.getAppHash() & "_LOGGER_OPERATION";
			instance.lockTimeout = 30;
			
			/* Return this implementation */	
			return this;
		</cfscript>
	</cffunction>
	
	<!--- Init Log Location --->
	<cffunction name="initLogLocation" access="public" hint="Initialize the ColdBox log location." output="false" returntype="void">
		<cfset var FileWriter = "">
		<cfset var InitString = "">
		<cfset var oFileUtilities = "">

		<!--- Log Location Variables Setup --->
		<cfset ensureLogLocations()>
		
		<!--- Create Log File if It does not exist and initialize it. --->
		<cfif not fileExists(getLogFullPath())>
			<!--- Log File Setup --->
			<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
				<!--- Create Log File if It does not exist and initialize it. --->
				<cfif not fileExists(getLogFullPath())>
					<cfset oFileUtilities = getPlugin("Utilities")>
					<cftry>
						<!--- Create Log File --->
						<cfset oFileUtilities.createFile(getLogFullPath())>
						<!--- Check if we can write to the file --->
						<cfif not oFileUtilities.FileCanWrite(getLogFullPath())>
							<cfthrow type="ColdBox.plugins.logger.LogFileNotWritableException" message="The log file: #getLogFullPath()# is not a writable file. Please check your operating system's permissions.">
						</cfif>
						<cfcatch type="any">
							<cfthrow type="ColdBox.plugins.logger.CreatingLogFileException" message="An error occurred creating the log file at #getLogFullPath()#." detail="#cfcatch.Detail#<br>#cfcatch.message#">
						</cfcatch>
					</cftry>
	
					<cftry>
						<!---
							Log Format
							"[severity]" "[ThreadID]" "[Date]" "[Time]" "[Application]" "[Message]"
						--->
						<cfset InitString = '"Severity","ThreadID","Date","Time","Application","Message"' & chr(13) & chr(10) & formatLogEntry("information","The log file has been initialized successfully by ColdBox.","Log file: #getLogFullPath()#; Encoding: #getSetting("LogFileEncoding",1)#")>
						
						<cffile action="append" 
								addnewline="true" 
								file="#getlogFullPath()#" 
								output="#InitString#"
								charset="#getSetting("LogFileEncoding",1)#">
								
						<cfcatch type="any">
							<cfthrow type="ColdBox.plugins.logger.WritingFirstEntryException" message="An error occurred writing the first entry to the log file." detail="#cfcatch.Detail#<br>#cfcatch.message#">
						</cfcatch>
					</cftry>
	
				</cfif>			
			</cflock>
		</cfif>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->


<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- ensureLogLocations --->
	<cffunction name="ensureLogLocations" output="false" access="public" returntype="void" hint="Ensure log locations are set in instance correctly">
		<cfif instance.isLoggerInitialized eq false>
			<cflock name="#instance.lockName#.ensureLogLocation" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
				<cfif instance.isLoggerInitialized eq false>
					<!--- Setup Log Location Variables --->
					<cfset setupLogLocationVariables()>
					<!--- Logger Initialized Now --->
					<cfset instance.isLoggerInitialized = true>
				</cfif>
			</cflock>
		</cfif>
	</cffunction>
	
	<!--- Setup Log Location Variables --->
	<cffunction name="setupLogLocationVariables" access="private" hint="Setup the log location variables." output="false" returntype="void">
		<!--- The Default Full log directory path --->
		<cfset var DefaultLogDirectory = getSetting("ApplicationPath",1) & getSetting("DefaultLogDirectory",1)>
		<!--- The absolute test Path --->
		<cfset var absTestPath = getPlugin("Utilities").getAbsolutePath(getSetting("ColdboxLogsLocation"))>
		<!--- The local relative test path --->
		<cfset var TestPath = getSetting("ApplicationPath",1) & getSetting("ColdboxLogsLocation")>
		<!--- Test EstablishedLogLocationpath --->
		<cfset var EstablishedLogLocationpath = "">
		
		<!--- Test for no setting defined, but logging enabled. --->
		<cfif getSetting("ColdboxLogsLocation") eq "">
			<cfset createDefaultLogDirectory()>
			<cfset EstablishedLogLocationpath = DefaultLogDirectory>
		<!--- Test for local relative test path --->
		<cfelseif directoryExists( TestPath )>
			<cfset EstablishedLogLocationpath = TestPath>
		<cfelseif directoryExists(absTestPath)>
			<cfset EstablishedLogLocationpath = absTestPath>
		<!--- AbsPath did not exist --->
		<cfelse>
			<cfdirectory action="create" directory="#absTestPath#">
			<cfset EstablishedLogLocationpath = absTestPath>
		</cfif>
		
		<!--- Fix Log Location for last /\--->
		<cfif right(EstablishedLogLocationpath,1) neq getSetting("OSFileSeparator",1)>
			<cfset EstablishedLogLocationpath = EstablishedLogLocationpath & getSetting("OSFileSeparator",1)>
		</cfif>
		
		<!--- Finalize the path --->
		<cfset EstablishedLogLocationpath = EstablishedLogLocationpath & getLogFileName() & ".log">
		
		<!--- Then set the complete log path and save. --->
		<cfset setSetting("ExpandedColdboxLogsLocation", EstablishedLogLocationpath)>
		<cfset setlogFullPath(EstablishedLogLocationpath)>
	</cffunction>

</cfcomponent>