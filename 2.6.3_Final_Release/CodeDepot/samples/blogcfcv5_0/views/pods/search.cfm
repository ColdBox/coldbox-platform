<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : search.cfm
	Author       : Raymond Camden 
	Created      : October 29, 2003
	Last Updated : October 26, 2005
	History      : added processingdir (rkc 11/10/03)
				   point to index.cfm (rkc 8/5/05)
				   Change link (rkc 10/26/05)
	Purpose		 : Display search box
--->

<cfmodule template="../../tags/podlayout.cfm" title="#getResource("search")#">

	<cfoutput>
    <div class="center">
	<form action="#application.blog.getProperty("blogurl")#?mode=search" method="post" onsubmit="return(this.search.value.length != 0)">
	<p class="center"><input type="text" name="search"></p>
	</form>
	</cfoutput>
		
</cfmodule>
	
<cfsetting enablecfoutputonly=false>