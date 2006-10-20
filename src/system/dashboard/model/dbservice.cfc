<cfcomponent output="false" displayname="dbservice" hint="I am the Dashboard Service.">

	<!--- Constructor --->
	<cfset variables.instance = structnew()>
	
	<cffunction name="init" access="public" returntype="dbservice" output="false">
		<cfset instance.settings = CreateObject("component","settings").init()>
		<cfset instance.fwsettings = CreateObject("component","fwsettings").init()>
		<cfset instance.appGeneratorService = CreateObject("component","appGeneratorService").init()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="get" access="public" returntype="any" output="false">
		<cfargument name="model" required="true" type="string" >
		<cfreturn instance["#arguments.model#"]>
	</cffunction>
	
	<cffunction name="autoupdate" access="public" returntype="boolean" output="false">
		<cfargument name="updateType" 			required="true" type="string" >
		<cfargument name="dashboardSettings" 	required="true" type="query" >
		<cfargument name="frameworkSettings" 	required="true" type="struct" >
		<cfargument name="applicationSettings" 	required="true" type="struct" >
		<cfargument name="updateResults" 		required="true" type="struct" >
		<cfscript>
		var setupPacket = "";
		var setupSettings = structnew();
		var installFiles = "";
		var fs = arguments.frameworkSettings.OSFileSeparator;
		
		//Proxy settings
		SetupSettings.ProxyFlag = arguments.dashboardSettings["proxyflag"];
		SetupSettings.ProxyServer = arguments.dashboardSettings["proxyserver"];
		SetupSettings.ProxyPort = arguments.dashboardSettings["proxyport"];
		SetupSettings.ProxyUsername = arguments.dashboardSettings["proxyuser"];
		SetupSettings.ProxyPassword = arguments.dashboardSettings["proxypassword"];
		
		//Setup the Installation Type and global variables.
		SetupSettings.InstallationType = arguments.updatetype;
		SetupSettings.InstallerDir = expandPath(arguments.applicationSettings.InstallerDir);
		SetupSettings.UpdateTempDir = expandPath(arguments.applicationSettings.UpdateTempDir);
		
		//Framework installation
		if ( arguments.updatetype eq "framework"){
			//setup the data packet
			SetupSettings.UpdateFileURL = arguments.updateResults.coldboxDistro.updateURL;
			SetupSettings.UpdateFileSize = arguments.updateResults.coldboxDistro.filesize;
			SetupSettings.NewVersion = arguments.updateResults.coldboxDistro.version;
			SetupSettings.CurrentVersion = arguments.frameworkSettings.version;
			SetupSettings.DownloadedFileName = "coldbox_#SetupSettings.NewVersion#.zip";
			SetupSettings.BackupFileName = dateformat(now(),"mmm.dd.yy") & "." & timeFormat(now(),"HHmm") & "_coldbox_" & SetupSettings.CurrentVersion & ".zip";
			SetupSettings.BackupsPath = SetupSettings.UpdateTempDir & fs & "system" & fs & "dashboard" & fs & "backups";
			SetupSettings.TargetPath = arguments.frameworkSettings.FrameworkPath;	
		}
		if (arguments.updatetype eq "dashboard"){
			//setup the data packet
			SetupSettings.UpdateFileURL = arguments.updateResults.dashboardDistro.updateURL;
			SetupSettings.UpdateFileSize = arguments.updateResults.dashboardDistro.filesize;
			SetupSettings.NewVersion = arguments.updateResults.dashboardDistro.version;
			SetupSettings.CurrentVersion = arguments.applicationSettings.version;
			SetupSettings.DownloadedFileName = "dashboard_#SetupSettings.NewVersion#.zip";
			SetupSettings.BackupFileName = dateformat(now(),"mmm.dd.yy") & "-" & timeFormat(now(),"HHmm") & "_dashboard_" & SetupSettings.CurrentVersion & ".zip";
			SetupSettings.BackupsPath = SetupSettings.UpdateTempDir & fs & "dashboard" & fs & "backups";
			SetupSettings.TargetPath = expandPath(".");
		}
		</cfscript>
		
		<!--- Start the Installer --->
		<cfwddx action="cfml2wddx" input="#SetupSettings#" output="setupPacket">
		
		<!--- Create Install Directory, if it doesn't exist --->
		<cfif not directoryExists(SetupSettings.updateTempDir)>
			<cfdirectory action="create" directory="#SetupSettings.updateTempDir#" mode="777">
		</cfif>
		
		<cftry>
			<!--- Move installer Files to install dir --->
			<cfdirectory action="list" directory="#SetupSettings.installerDir#" name="installfiles">
			<cfloop query="installfiles">
				<cfif installFiles.type neq "Dir">
					<cffile action="copy"
							source="#SetupSettings.installerDir##fs##installfiles.name#"
							destination="#SetupSettings.UpdateTempDir##fs##installfiles.name#">
				</cfif>
			</cfloop>
		
			<cfcatch type="any">
				<cfdirectory action="delete" recurse="true" directory="#SetupSettings.updateTempDir#">
				<cfrethrow>
			</cfcatch>
		</cftry>
		
		<!--- Start Installler --->
		<cflocation url="#arguments.applicationSettings.UpdateTempDir#/installer.cfm?setuppacket=#wddxpacket#" addtoken="no">
			
	</cffunction>
	
	<cffunction name="sendbugreport" access="public" returntype="string" output="false">
		<cfargument name="requestCollection" required="true" type="any" >
		<cfargument name="fwSettings"		 required="true" type="any">
		<cfargument name="OS" 				 required="true" type="string">
		<!--- Send Bug Report. --->
		<cfset var myBugreport = "">
		<!--- Save the Report --->
		<cfsavecontent variable="mybugreport">
		<cfoutput>
		=========================================================
		_Bug Details_
		=========================================================
		Date: #dateFormat(now(),"mmmm dd, YYYY")#
		Time: #TimeFormat(now(), "long")#
		From: #arguments.requestCollection.name#
		Bug Report:
		#arguments.requestCollection.bugreport#
		=========================================================
		_ColdBox Details_
		=========================================================
		Version:    #arguments.fwSettings.version#
		Codename:   #arguments.fwSettings.codename#
		Suffix:     #arguments.fwSettings.suffix#
		O.S:        #arguments.OS#
		CF Engine:  #server.ColdFusion.ProductName#
		CF Version: #server.ColdFusion.ProductVersion#
		=========================================================
		</cfoutput>
		</cfsavecontent>
		<!--- Send the bug report --->
		<cfif len(trim(arguments.requestCollection.mailserver)) eq 0>
			<cfmail to="bugs@coldboxframework.com" 
					from="#arguments.requestCollection.email#" 
					subject="Bug Report" 
					username="#arguments.requestCollection.mailusername#" 
					password="#mailpassword#">
			#mybugreport#
			</cfmail>
		<cfelse>
			<cfmail to="bugs@coldboxframework.com" 
					from="#arguments.requestCollection.email#" 
					subject="Bug Report" 
					server="#arguments.requestCollection.mailserver#" 
					username="#arguments.requestCollection.mailusername#" 
					password="#arguments.requestCollection.mailpassword#">
			#mybugreport#
			</cfmail>
		</cfif>
		
		<cfreturn mybugreport>
	</cffunction>

</cfcomponent>