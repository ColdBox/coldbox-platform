<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : notify.cfm
	Author       : Raymond Camden 
	Created      : 04/20/06
	Last Updated : 
	History      : 
	
	This template simply sends the email out for an entry. We do a few sanity checks though:
	
	a) The entry's posted date must be within 2 minutes of now(). Why? In theory
	someone who knows the ID of an old entry and this url could use it to spam folks.
	By ensuring ...
	
	You know what. Screw that. I'm just going to add a mailed flag to entries. Why shouldn't I?
	
	I still need to ensure that posted is either now or before now (in case the cfhttp call is slowed
	down). I also need to check that released = 1
	
	Notice - this is run by CF. The human output is just for testing.
--->

<cfif not structKeyExists(url, "id")>
	<cfabort>
</cfif>

<cftry>
	<cfset entry = application.blog.getEntry(url.id)>
	<cfcatch>
		<cfoutput>Error getting entry.</cfoutput>
		<cfabort>
	</cfcatch>
</cftry>

<!--- is it released? --->
<cfif not entry.released>
	<cfoutput>Not released.</cfoutput>
	<cfabort>
</cfif>

<!--- was it already mailed? --->
<cfif entry.mailed>
	<cfoutput>Already mailed.</cfoutput>
	<cfabort>
</cfif>

<!--- is posted < now()? --->
<cfif dateCompare(entry.posted, now()) is 1>
	<cfoutput>This entry is in the future.</cfoutput>
	<cfabort>
</cfif>

<cfoutput>Yes, I will be emailing this.</cfoutput>
<cfset application.blog.mailEntry(url.id)>

<cfoutput>Clear the cache</cfoutput>
<cfmodule template="../tags/scopecache.cfm" scope="application" clearAll="true" />

<cfoutput>Now delete the scheduled task.</cfoutput>
<cfschedule action="delete" task="BlogCFC Notifier #url.id#">

<cfsetting enablecfoutputonly=false>
