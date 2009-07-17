<cfsetting enablecfoutputonly=true showdebugoutput=false>
<!---
	Name         : rss.cfm
	Author       : Raymond Camden 
	Created      : July 5, 2004
	Last Updated : August 3, 2005
	History      : Support for UUID (rkc 1/27/05)
				   You can't have 2 or more of the same link, so I add r=X to make it unique. Thanks to Tom Thomas for finding this bug (rkc 8/3/05)
	Purpose		 : Displays RSS for a Conference
--->
<!--- Set References --->
<cfset data = Event.getValue("rssdata")>

<cfcontent type="text/xml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>

<rdf:RDF 
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns##"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns="http://purl.org/rss/1.0/"
>

	<channel rdf:about="#application.settings.rootURL#">
	<title>Galleon Forums : Conference : #request.conference.name#</title>
	<description>Conference : #request.conference.name# : #request.conference.description#</description>
	<link>#application.settings.rootURL#</link>
	
	<items>
		<rdf:Seq>
			<cfloop query="data">
			<rdf:li rdf:resource="#application.settings.rootURL#index.cfm?event=ehForums.dspMessages#xmlFormat("&threadid=#threadid#")##xmlFormat("&r=#currentRow#")#" />
			</cfloop>
		</rdf:Seq>
	</items>
	
	</channel>

	<cfloop query="data">
		<cfset dateStr = dateFormat(posted,"yyyy-mm-dd")>
		<cfset z = getTimeZoneInfo()>
		<cfset dateStr = dateStr & "T" & timeFormat(posted,"HH:mm:ss") & "-" & numberFormat(z.utcHourOffset,"00") & ":00">
	
		<item rdf:about="#application.settings.rootURL#index.cfm?event=ehForums.dspMessages#xmlFormat("&threadid=#threadid#")##xmlFormat("&r=#currentRow#")#">
		<title>#xmlFormat(title)#</title>
		<description>#xmlFormat(body)#</description>
		<link>#application.settings.rootURL#index.cfm?event=ehForums.dspMessages#xmlFormat("&threadid=#threadid#")##xmlFormat("&r=#currentRow#")#</link>
		<dc:date>#dateStr#</dc:date>
		<dc:subject>#thread#</dc:subject>
		</item>
	</cfloop>
	
</rdf:RDF>
</cfoutput>
<cfsetting enablecfoutputonly=false>