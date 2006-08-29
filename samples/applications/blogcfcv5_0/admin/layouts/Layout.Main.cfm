<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : /client/tags/adminlayout.cfm
	Author       : Raymond Camden
	Created      : 04/06/06
	Last Updated : 5/17/06
	History      : link to stats (rkc 5/17/06)
--->

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<link rel="stylesheet" type="text/css" href="#application.rooturl#/includes/admin.css" media="screen" />
<title>BlogCFC Administrator: #getValue("title")#</title>
</head>

<body>

<!--- TODO: Switch to request scope --->
<cfif isLoggedIn()>
<div id="menu">
<ul>
<li><a href="index.cfm">Home</a></li>
<li><a href="?event=ehAdmin.dspEntries">Entries</a></li>
<li><a href="?event=ehAdmin.dspCategories">Categories</a></li>
<li><a href="?event=ehAdmin.dspComments">Comments</a></li>
<li><a href="?reinit=1">Refresh Blog Cache</a></li>
<li><a href="?event=ehAdmin.dspSettings">Settings</a></li>
<li><a href="?event=ehAdmin.dspSubscribers">Subscribers</a></li>
<li><a href="?event=ehAdmin.dspTrackbacks">Trackbacks</a></li>
</ul>
<hr>
<ul>
<li><a href="../">Your Blog</a></li>
<li><a href="../" target="_new">Your Blog (New Window)</a></li>
<li><a href="?event=ehAdmin.dspStats">Your Blog Stats</a></li>
</ul>
<hr>
<ul>
<li><a href="?event=ehAdmin.doLogout">Logout</a></li>
</ul>
</div>
</cfif>

<div id="content">
	<div id="header">BlogCFC Administrator: #getValue("title")#</div>

	<!--- Content Goes Here --->
	#renderView()#
</div>

</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly=false>