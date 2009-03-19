<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	Simple File Logger
----------------------------------------------------------------------->
<cfcomponent name="SimpleLogger" 
			 extends="coldbox.system.logging.AbstractLogger" 
			 output="false"
			 hint="This is a simple implementation of a logger that is file based.">
			 
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- Constructor --->
	<cffunction name="init" access="public" returntype="SimpleLogger" hint="Constructor" output="false">
		<cfargument name="name"  type="string" required="true" hint="The logger identification name">
		<cfscript>
			/* Super init it */
			super.init(argumentCollection=arguments);
			
			/* Available valid severities For Simple Logger */
			instance.validSeverities = "information|fatal|warning|error|debug";
			
			/* Log Levels For This Implementation */
			instance.logLevels = structnew();
			instance.logLevels["trace"] 		= 5;
			instance.logLevels["debug"] 		= 4;
			instance.logLevels["information"] 	= 3;
			instance.logLevels["warning"] 		= 2;
			instance.logLevels["error"] 		= 1;
			instance.logLevels["fatal"] 		= 0;
			
			/* Lock Information */
			instance.lockName = instance._hash & "_LOGGER_OPERATION";
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
			 

</cfcomponent>