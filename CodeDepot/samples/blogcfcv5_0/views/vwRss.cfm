<cfsetting enablecfoutputonly=false showdebugoutput=false>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : RSS
	Author       : Raymond Camden 
	Created      : March 12, 2003
	Last Updated : May 5, 2006
	History      : Reset history for version 5.0
				 : Note that I'm not doing RSS feeds by day or month anymore, so that code is marked for removal (maybe)
				 : Added additionalTitle support for cats
	Purpose		 : Blog RSS feed.
--->

<cftry>
	<cfcontent type="text/xml"><cfoutput>#application.blog.generateRSS(mode=Event.getValue("mode"),params=Event.getValue("params"),version=Event.getValue("version"),additionalTitle=Event.getValue("additionalTitle"))#</cfoutput>
	<cfcatch>
		<cfset getPlugin("logger").logError("Rss Feed",cfcatch)>
		<!--- Logic is - if they filtered incorrectly, revert to default, if not, abort --->
		<cfif cgi.query_string neq "">
			<cflocation url="index.cfm?event=ehBlog.dspRss">
		<cfelse>
			<cfabort>
		</cfif>
	</cfcatch>
</cftry>

