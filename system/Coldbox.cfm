<cfsetting enablecfoutputonly="yes">
<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Template : coldbox.cfm
Author 	 :	Luis Majano
Date     :	October 1, 2005
Description :
	Please use the Application.cfc method instead. This file will be deprecated later on.

	Please view the quickstart guide if you have more questions.
---------------------------------------------------------------------->
<cfparam name="COLDBOX_CONFIG_FILE" 			default="" type="string">
<cfparam name="COLDBOX_APP_ROOT_PATH" 			default="#getDirectoryFromPath(getbaseTemplatePath())#" type="string">
<cfparam name="COLDBOX_APP_KEY" 				default="" type="string">
<cfparam name="COLDBOX_BOOTSTRAPPER_KEY"		default="cbBootstrap" type="string">
<cfparam name="COLDBOX_APP_MAPPING" 			default="" type="string">
	

<!--- Create the BootStrapper --->
<cfif NOT structKeyExists(application,COLDBOX_BOOTSTRAPPER_KEY) OR 
	  application[COLDBOX_BOOTSTRAPPER_KEY].isfwReinit()>
	
	<cflock name="coldbox.bootstrap_#hash(getBaseTemplatePath())#" type="exclusive" timeout="5" throwontimeout="true">
		<cfif NOT structKeyExists(application,COLDBOX_BOOTSTRAPPER_KEY) OR
			  application[COLDBOX_BOOTSTRAPPER_KEY].isfwReinit()>
				  
			<cfset structDelete(application,COLDBOX_BOOTSTRAPPER_KEY)>
			<cfset application[COLDBOX_BOOTSTRAPPER_KEY] = CreateObject("component","coldbox.system.Coldbox").init(COLDBOX_CONFIG_FILE,
																												   COLDBOX_APP_ROOT_PATH,
																												   COLDBOX_APP_KEY,
																												   COLDBOX_APP_MAPPING)>
			<!--- Load ColdBox --->
			<cfset application[COLDBOX_BOOTSTRAPPER_KEY].loadColdBox()>
		</cfif>
	</cflock>
	
</cfif>

<!--- Reference --->
<Cfset coldbox = application[COLDBOX_BOOTSTRAPPER_KEY]>

<!--- Reload Checks --->
<cfset coldbox.reloadChecks()>

<!--- Process Request --->
<cfset coldbox.processColdBoxRequest()>

<cfsetting enablecfoutputonly="no">