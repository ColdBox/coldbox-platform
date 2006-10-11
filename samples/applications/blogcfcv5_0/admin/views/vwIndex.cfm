<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : /client/admin/index.cfm
	Author       : Raymond Camden
	Created      : 04/06/06
	Last Updated : 5/17/06
	History      : Added blog name (rkc 5/17/06)
--->

	<cfoutput>
	<p>
	Welcome to BlogCFC Administrator. You are running BlogCFC version #application.blog.getVersion()#. This blog is named
	#application.blog.getProperty("blogtitle")#.
	</p>
	#getPlugin("messagebox").renderit()#
	</cfoutput>


<cfsetting enablecfoutputonly=false>