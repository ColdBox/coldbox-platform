<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : archives.cfm
	Author       : Raymond Camden 
	Created      : October 29, 2003
	Last Updated : May 10, 2006
	History      : Use SES urls (rkc 4/18/06)
				 : Don't hide empty cats (rkc 5/10/06)
	Purpose		 : Display archives
--->

<cfmodule template="../../tags/scopecache.cfm" cachename="pod_archives" scope="application" timeout="#application.timeout#">

<cfmodule template="../../tags/podlayout.cfm" title="#getResource("archivesbysubject")#">

	<cfset cats = application.blog.getCategories()>
	<cfloop query="cats">
		<cfoutput><a href="#application.blog.makeCategoryLink(categoryid)#">#categoryName# (#entryCount#)</a> [<a href="#application.rootURL#/index.cfm?event=#Event.getValue("xehRSS")#&mode=full&mode2=cat&catid=#categoryid#">RSS</a>]<br></cfoutput>
	</cfloop>
	
</cfmodule>
	
</cfmodule>

<cfsetting enablecfoutputonly=false>