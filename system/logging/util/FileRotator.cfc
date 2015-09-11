<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	A File Rotator
----------------------------------------------------------------------->
<cfcomponent name="FileRotator"
			 output="false"
			 hint="This is a simple file rotator">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- Constructor --->
	<cffunction name="init" access="public" returntype="FileRotator" hint="Constructor" output="false">
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Check Rotations --->
	<cffunction name="checkRotation" access="public" hint="Checks the log file size. If greater than framework's settings, then zip and rotate." output="false" returntype="void">
		<cfargument name="appender" type="coldbox.system.logging.AbstractAppender" required="true" default="" hint="The appender to rotate with"/>
		<cfset var oAppender = arguments.appender>
		<cfset var zipFileName = "">
		<cfset var qArchivedLogs = "">
		<cfset var archiveToDelete = "">
		<cfset var fileName = oAppender.getProperty("fileName")>
		<cfset var logFullPath = oAppender.getLogFullPath()>

		<!--- Verify FileSize --->
		<cfif getFileSize(logFullPath) gt (oAppender.getProperty("fileMaxSize") * 1024)>
			<!--- How Many Log Files Do we Have --->
			<cfdirectory action="list"
				 filter="#fileName#*.zip"
				 name="qArchivedLogs"
				 directory="#getDirectoryFromPath(logFullPath)#"
				 sort="DATELASTMODIFIED" >

			<!--- Zip Log File --->
			<cflock name="#oAppender.getlockName()#" type="exclusive" timeout="#oAppender.getlockTimeout()#" throwontimeout="true">
				<!--- Should I remove log Files --->
				<cfif qArchivedLogs.recordcount gte oAppender.getProperty("fileMaxArchives")>
					<cfset ArchiveToDelete = qArchivedLogs.directory[1] & "/" & qArchivedLogs.name[1] >
					<!--- Remove the oldest one --->
					<cffile action="delete" file="#ArchiveToDelete#">
				</cfif>
				<!--- Set the name of the archive --->
				<cfset zipFileName = getDirectoryFromPath(logFullPath) & fileName & "." & dateformat(now(),"yyyymmdd") & "." & timeformat(now(),"HHmmss") & ".zip">
				<!--- Zip it --->
				<cfzip action="zip"
					   file="#zipFileName#"
					   overwrite="true"
					   storepath="false"
					   recurse="false"
					   source="#logFullPath#">
			</cflock>

			<!--- Clean & reinit Log File --->
			<cfset oAppender.removeLogFile()>

			<!--- Reinit The log File --->
			<cfset oAppender.initLoglocation()>
		</cfif>
	</cffunction>

	<!--- Check File Size --->
	<cffunction name="getFileSize" access="public" returntype="string" output="false" hint="Get the filesize of a file.">
		<!--- ************************************************************* --->
		<cfargument name="filename"   type="string" required="yes">
		<cfargument name="sizeFormat" type="string" required="no" default="bytes" hint="Available formats: [bytes][kbytes][mbytes][gbytes]">
		<!--- ************************************************************* --->
		<cfscript>
		var objFile = createObject("java","java.io.File").init(JavaCast("string",arguments.filename));
		if ( arguments.sizeFormat eq "bytes" )
			return objFile.length();
		if ( arguments.sizeFormat eq "kbytes" )
			return (objFile.length()/1024);
		if ( arguments.sizeFormat eq "mbytes" )
			return (objFile.length()/(1048576));
		if ( arguments.sizeFormat eq "gbytes" )
			return (objFile.length()/1073741824);
		</cfscript>
	</cffunction>

</cfcomponent>