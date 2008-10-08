<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : rss.cfm
	Author       : Raymond Camden 
	Created      : October 29, 2003
	Last Updated : June 23, 2005
	History      : history cleared for 4.0
	Purpose		 : Display rss box
--->

<cfset rssURL = application.rootURL & "/index.cfm?event=#Event.getValue("xehRSS")#">

<cfmodule template="../../tags/podlayout.cfm" title="RSS">

	<cfoutput>
	<p class="center">
	<a href="#rssURL#&mode=full"><img src="#application.rootURL#/images/rssbutton.gif" border="0"></a><br>
	</p>
	</cfoutput>
			
</cfmodule>
	
<cfsetting enablecfoutputonly=false>