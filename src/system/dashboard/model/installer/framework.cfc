<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	October 10, 2006
Description :
	Installer Implementation for the framework update.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="framework" hint="This cfc has the installation implementation for the framework update" extends="Implementation">

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="start" hint="Start the installation implementation for a framework install" access="public" output="false" returntype="Any">
		<!--- File Separator --->
		<cfset var FS = getSetupKey("FileSeparator")>
		<cfset var downloadedFileSize = 0>
		<cfset var rtnZip = "">
		<!--- ************************************************ --->
		<!--- DOWNLOAD UDPATE FILE 							   --->
		<!--- ************************************************ --->
		<cftry>
			<!--- Download File --->
			<cfhttp url="#getSetupKey('FrameworkUpdateFileURL')#"
					method="get"
					timeout="#getSetupKey('downloadTimeout')#"
					file="#getSetupKey('FrameworkUpdateFileName')#"
					path="#getSetupKey('updateTempDir')#" />
			<cfcatch type="any">
				<cfthrow message="Error downloading file from distribution URL.<br><br>#cfcatch.detail# #cfcatch.message#">
			</cfcatch>
		</cftry>

		<!--- ************************************************ --->
		<!--- COMPARE FILE SIZES 							   --->
		<!--- ************************************************ --->
		<cftry>
			<!--- Compare File Sizes--->
			<cfset downloadedFileSize = getFileSize("#getSetupKey('updateTempDir')##fs##getSetupKey('FrameworkUpdateFileName')#")>
			<cfif downloadedFileSize lt getSetupKey("FrameworkUpdateFileSize")>
				<!--- Delete File --->
				<cffile action="delete" file="#getSetupKey('updateTempDir')##fs##getSetupKey('FrameworkUpdateFileName')#">
				<cfthrow message="The file size of the downloaded file does not match the original file. Please verify that you can download this file.">
			</cfif>
			<cfcatch type="any">
				<cfthrow message="Error comparing update file size.<br><br>#cfcatch.detail# #cfcatch.message#">
			</cfcatch>
		</cftry>

		<!--- ************************************************ --->
		<!--- EXTRACT UPDATE FILE 							   --->
		<!--- ************************************************ --->
		<cftry>
			<!--- Extract File --->
			<cfinvoke component="#objZip#"
					  method="Extract"
					  returnvariable="rtnZip">
				<cfinvokeargument name="ZipFilePath" value="#getSetupKey('updateTempDir')##fs##getSetupKey('FrameworkUpdateFileName')#">
				<cfinvokeargument name="extractPath" value="#getSetupKey('updateTempDir')#">
			</cfinvoke>

			<cfcatch type="any">
				<cfthrow message="Error extracting update file.<br><br>#cfcatch.detail# #cfcatch.message#">
			</cfcatch>
		</cftry>

		<!--- ************************************************ --->
		<!--- COPY OVER PASSWORD FILE						   --->
		<!--- ************************************************ --->
		<cftry>
			<!--- Copy Over Password File to new system folder --->
			<cffile action="copy"
					source="#getSetupKey('PasswordFilePath')#"
					destination="#getSetupKey('PasswordFileDestination')#"
					nameconflict="overwrite"
					mode="777">

			<cfcatch type="any">
				<cfthrow message="Error copying existent password file.<br><br>#cfcatch.detail# #cfcatch.message#">
			</cfcatch>
		</cftry>

		<!--- ************************************************ --->
		<!--- BACKUP ORIGINAL INSTALLATION FILE				   --->
		<!--- ************************************************ --->
		<cftry>
			<!--- Check if backup folder exists --->
			<cfif not DirectoryExists("#getSetupKey('BackupsPath')#")>
				<cfdirectory action="create" directory="#getSetupKey('BackupsPath')#" mode="777">
			</cfif>
			<!--- Backup the original System Folder --->
			<cfset backupInstallation()>
			<cfcatch type="any">
				<cfthrow message="Error backing up existent ColdBox Installation.<br><br>#cfcatch.detail# #cfcatch.message#">
			</cfcatch>
		</cftry>

		<!--- ************************************************ --->
		<!--- REMOVE OLD SYSTEM 							   --->
		<!--- ************************************************ --->
		<cftry>
			<!--- Move Old System --->
			<cfdirectory action="delete"
						 directory="#getSetupKey('FrameworkPath')#"
						 recurse="yes">

			<!--- Copy New System --->
			<cffile action="move"
			        mode="777"
					source="#getSetupKey('updateTempDir')##FS#system"
					destination="#getSetupKey('ParentPath')#">

			<cfcatch type="any">
				<cfset setErrorMessage("A serious error occurred while moving the new system folder from the temporary install path.	A copy of the old system folder is now under _tempinstall directory along with the new system path.#cfcatch.Detail#<bR>#cfcatch.Message#")>
				<cfset variables.abortInstall = true>
			</cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>