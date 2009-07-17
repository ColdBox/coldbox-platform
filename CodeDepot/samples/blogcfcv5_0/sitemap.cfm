<cfsetting enablecfoutputonly=true showdebugoutput=false>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : Google Sitemap
	Author       : Raymond Camden 
	Created      : Sometime in the past...
	Last Updated : November 28, 2005
	History      : 
	Purpose		 : Blog Google Sitemaps feed.
--->

<cfset params = structNew()>
<!--- Should be good for a while.... --->
<cfset params.maxEntries = 99999>
<cfset params.mode = "short">

<cfset entries = application.blog.getEntries(params)>

<cfset z = getTimeZoneInfo()>
<cfif not find("-", z.utcHourOffset)>
	<cfset utcPrefix = "-">
<cfelse>
	<cfset z.utcHourOffset = right(z.utcHourOffset, len(z.utcHourOffset) -1 )>
	<cfset utcPrefix = "+">
</cfif>

<cfset dateStr = dateFormat(entries.posted[1],"yyyy-mm-dd")>
<cfset dateStr = dateStr & "T" & timeFormat(entries.posted[1],"HH:mm:ss") & utcPrefix & numberFormat(z.utcHourOffset,"00") & ":00">

<cfcontent type="text/xml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.google.com/schemas/sitemap/0.84"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://www.google.com/schemas/sitemap/0.84
	http://www.google.com/schemas/sitemap/0.84/sitemap.xsd">
	<url>
		<loc>#application.rootURL#</loc>
    	<lastmod>#dateStr#</lastmod>
		<changefreq>hourly</changefreq>
		<priority>0.8</priority>
	</url> 
	</cfoutput> 
	<cfoutput query="entries">
		<cfset dateStr = dateFormat(posted,"yyyy-mm-dd")>
		<cfset dateStr = dateStr & "T" & timeFormat(posted,"HH:mm:ss") & utcPrefix & numberFormat(z.utcHourOffset,"00") & ":00">
		<url>
		<loc>#xmlFormat(application.blog.makeLink(id))#</loc>
		<lastmod>#dateStr#</lastmod>
		</url>
	</cfoutput>
<cfoutput>
</urlset> 
</cfoutput>