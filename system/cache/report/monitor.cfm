<cfsetting enablecfoutputonly="true">
<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	Custom tag for displaying CacheBox Cache reports.
	
ATTRIBUTES:
- cacheBox : An instance reference to the cacheBox factory to report on
- baseURL (optional) : An optional baseURL that will be used to post to this monitor on. Default is cgi.script_name
----------------------------------------------------------------------->

<!--- Leave on end --->
<cfif thisTag.ExecutionMode eq "end">
	<cfexit method="exittag">
</cfif>

<!--- Tag Attributes --->
<!--- CacheBox Factory --->
<cfparam name="attributes.cacheFactory" type="any" default="">
<!--- BaseURL --->
<cfparam name="attributes.baseURL" type="string" default="#cgi.script_name#">

<!--- Validate CacheBox --->
<cfif NOT isObject(attributes.cacheFactory)>
	<cfthrow message="Invalid Monitor Tag Usage: Missing 'CacheFactory' attribute"
			 detail="The 'CacheFactory' attribute must be set to the instance of cachebox to report on"
			 type="cachebox.monitor.InvalidMonitorUsage">
</cfif>

<!--- Create Report Handler --->
<cfset reportHandler = createObject("component","coldbox.system.cache.report.ReportHandler").init(attributes.cacheFactory,attributes.baseURL)>

<!--- Monitor Default URL Arguments --->
<cfparam name="url.debugPanel" 		default="cache">
<cfparam name="url.cbox_command" 	default="">
<cfparam name="url.cbox_cacheName" 	default="default">
<cfparam name="url.cbox_cacheEntry" default="">
<cfparam name="url.key"				default="">

<!--- Process incoming commands --->
<cfif reportHandler.processCommands()>
	<cfexit>
</cfif>

<!--- Render Report --->
<cfswitch expression="#debugPanel#">
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
		<cfset report = reportHandler.renderCacheDumper(cacheName=url.cbox_cacheName)>
	</cfcase>		
</cfswitch>

<!--- reset content --->
<cfif ajaxRender><cfcontent reset="true"></cfif>

<!--- output header assets --->
<cfsavecontent variable="reportHeader">
<style type="text/css"><cfinclude template="/coldbox/system/cache/report/assets/cachebox.css"></style>
<script type="text/javascript"><cfinclude template="/coldbox/system/cache/report/assets/cachebox.js"></script>
</cfsavecontent>
<cfhtmlhead text="#reportHeader#">

<!--- output rendered report --->
<cfoutput>#report#</cfoutput>
<cfsetting enablecfoutputonly="false">
<cfif ajaxRender><cfabort></cfif>