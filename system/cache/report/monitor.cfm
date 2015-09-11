<cfsetting enablecfoutputonly="true">
<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	Custom tag for displaying CacheBox Cache reports.
	
ATTRIBUTES:
- cacheBox : An instance reference to the cacheBox factory to report on
- baseURL (optional='default') : An optional baseURL that will be used to post to this monitor on. Default is cgi.script_name
- skin (optional='default') : The skin to render the report in, it uses 'default' skin by default.
----------------------------------------------------------------------->

<!--- Leave on end --->
<cfif thisTag.ExecutionMode eq "end">
	<cfsetting enablecfoutputonly="false">
	<cfexit method="exittag">
</cfif>

<!--- Tag Attributes --->

<!--- CacheBox Factory --->
<cfparam name="attributes.cacheFactory" 	type="any" default="">
<!--- BaseURL --->	
<cfparam name="attributes.baseURL" 			type="string" default="#cgi.script_name#">
<!--- Skin To Use --->
<cfparam name="attributes.skin"				type="string" default="default">
<!--- Enable Monitor --->
<cfparam name="attributes.enableMonitor"	type="boolean" default="true">
<!--- Expanded Panel or Not --->
<cfparam name="attributes.expandedPanel"	type="boolean" default="true">

<!--- Validate CacheBox --->
<cfif NOT isObject(attributes.cacheFactory)>
	<cfthrow message="Invalid Monitor Tag Usage: Missing 'CacheFactory' attribute"
			 detail="The 'CacheFactory' attribute must be set to the instance of cachebox to report on"
			 type="cachebox.monitor.InvalidMonitorUsage">
</cfif>

<!--- Create Report Handler --->
<cfset reportHandler = createObject("component","coldbox.system.cache.report.ReportHandler").init(attributes.cacheFactory,
																								   attributes.baseURL,
																								   attributes.skin,
																								   attributes,
																								   caller)>

<!--- Monitor's Default URL Arguments --->
<cfparam name="url.debugPanel" 			default="cache">
<cfparam name="url.cbox_command" 		default="">
<cfparam name="url.cbox_cacheName" 		default="default">
<cfparam name="url.cbox_cacheEntry" 	default="">
<cfparam name="url.cbox_cacheMonitor" 	default="false">

<!--- Process incoming commands --->
<cfif reportHandler.processCommands(command=url.cbox_command,
								    cacheName=url.cbox_cacheName,
								    cacheEntry=url.cbox_cacheEntry)>
	<!--- Command executed, abort anything else after this point --->
	<cfcontent reset="true">
	<cfsetting showdebugoutput="false">
	<cfoutput>true</cfoutput>
	<cfsetting enablecfoutputonly="false">
	<cfabort>
</cfif>

<!--- Render Reports According To Panel Requested --->
<cfswitch expression="#url.debugPanel#">
	<cfcase value="cache">
		<cfset ajaxRender = false>
		<cfset report = reportHandler.renderCachePanel()>
	</cfcase>
	<cfcase value="cacheReport">
		<cfset ajaxRender = true>
		<cfset report = reportHandler.renderCacheReport(cacheName=url.cbox_cacheName)>
	</cfcase>
	<cfcase value="cacheContentReport">
		<cfset ajaxRender = true>
		<cfset report = reportHandler.renderCacheContentReport(cacheName=url.cbox_cacheName)>
	</cfcase>
	<cfcase value="cacheViewer">
		<cfset ajaxRender = true>
		<cfset report = reportHandler.renderCacheDumper(cacheName=url.cbox_cacheName,cacheEntry=url.cbox_cacheEntry)>
	</cfcase>		
</cfswitch>

<!--- Ajax Rendering --->
<cfif ajaxRender>
	<cfsetting showdebugoutput="false">
	<cfcontent reset="true">
	<cfoutput>#report#</cfoutput>
	<cfsetting enablecfoutputonly="false">
	<cfabort>
</cfif>

<!--- output header assets --->
<cfsavecontent variable="reportHeader"><cfoutput>
<style type="text/css"><cfinclude template="/coldbox/system/cache/report/skins/#attributes.skin#/cachebox.css"></style>
<script type="text/javascript"><cfinclude template="/coldbox/system/cache/report/skins/#attributes.skin#/cachebox.js"></script>
</cfoutput></cfsavecontent>
<cfhtmlhead text="#reportHeader#">

<!--- output rendered report --->
<cfoutput>#report#</cfoutput>
<cfsetting enablecfoutputonly="false">
