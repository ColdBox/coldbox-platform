<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : podlayout.cfm
	Author       : Raymond Camden 
	Created      : October 29, 2003
	Last Updated : July 22, 2005
	History      : PaulH added cfproc (rkc 7/22/05)
	Purpose		 : Pod Layout
--->

<cfparam name="attributes.title">

<cfif thisTag.executionMode is "start">

	<cfoutput>
	<div class="rightMenu">
	<div class="menuTitle">#attributes.title#</div>
	<div class="menuBody">
	</cfoutput>		

<cfelse>

	<cfoutput>
	</div>
	</div>
	</cfoutput>

</cfif>

<cfsetting enablecfoutputonly=false>