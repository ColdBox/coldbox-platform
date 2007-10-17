<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This is the Application.cfc for usage withing the ColdBox Framework.
	Make sure that it extends the coldbox object:
	coldbox.system.coldbox
	
	So if you have refactored your framework, make sure it extends coldbox.
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.coldbox" output="false">
<cfprocessingdirective suppresswhitespace="true">
	
	<!--- APPLICATION CFC PROPERTIES --->
	<cfset this.name =  hash(getCurrentTemplatePath())>
	<cfset this.sessionManagement = true>
	<cfset this.sessionTimeout = createTimeSpan(0,0,30,0)>
	<cfset this.setClientCookies = true>
	
	<!--- COLDBOX PROPERTIES --->
	<cfset COLDBOX_CONFIG_FILE = "">
	
	<!--- on Application Start --->
	<cffunction name="onApplicationStart" returnType="boolean" output="false">
		<cfscript>
			//Load ColdBox
			loadColdBox();
			return true;
		</cfscript>
	</cffunction>
	
	<!--- on Request Start --->
	<cffunction name="onRequestStart" returnType="boolean" output="true">
		<!--- ************************************************************* --->
		<cfargument name="targetPage" type="string" required="true" />
		<!--- ************************************************************* --->
		<cfsetting enablecfoutputonly="yes">
		
		<!--- Process A ColdBox Request Only --->
		<cfif findNoCase('index.cfm', listLast(arguments.targetPage, '/'))>
			<cfset processColdBoxRequest()>
		</cfif>
		
		<!--- WHATEVER YOU WANT BELOW --->
		
		<cfsetting enablecfoutputonly="no">
		<cfreturn true>
	</cffunction>
	
	<!--- on Application End --->
	<cffunction name="onApplicationEnd" returnType="void"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="applicationScope" type="struct" required="true">
		<!--- ************************************************************* --->
		<!--- WHATEVER YOU WANT BELOW --->
	</cffunction>
	
	<!--- on Session Start --->
	<cffunction name="onSessionStart" returnType="void" output="false">
		<!--- DO NOT MODIFY THE FOLLOWING --->
		<cfset super.onSessionStart()>
		<!--- WHATEVER YOU WANT BELOW --->
	</cffunction>
	
	<!--- on Session End --->
	<cffunction name="onSessionEnd" returnType="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="sessionScope" type="struct" required="true">
		<cfargument name="appScope" 	type="struct" required="false">
		<!--- ************************************************************* --->
		<!--- DO NOT MODIFY THE FOLLOWING --->
		<cfset super.onSessionEnd(arguments=argumentCollection)>
		<!--- WHATEVER YOU WANT BELOW --->
	</cffunction>

</cfprocessingdirective>
</cfcomponent>