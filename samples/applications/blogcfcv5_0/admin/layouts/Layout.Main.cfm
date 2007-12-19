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
<title>BlogCFC Administrator: #Event.getValue("title")#</title>
</head>

<body>

<!--- TODO: Switch to request scope --->
<cfif isLoggedIn()>
<div id="menu">
<ul>
<li><a href="index.cfm">Home</a></li>
<li><a href="?event=#Event.getValue("xehEntries")#">Entries</a></li>
<li><a href="?event=#Event.getValue("xehCategories")#">Categories</a></li>
<li><a href="?event=#Event.getValue("xehComments")#">Comments</a></li>
<li><a href="?reinit=1">Refresh Blog Cache</a></li>
<li><a href="?event=#Event.getValue("xehSettings")#">Settings</a></li>
<li><a href="?event=#Event.getValue("xehSubscribers")#">Subscribers</a></li>
<li><a href="?event=#Event.getValue("xehTrackbacks")#">Trackbacks</a></li>
</ul>
<hr>
<ul>
<li><a href="../">Your Blog</a></li>
<li><a href="../" target="_new">Your Blog (New Window)</a></li>
<li><a href="?event=#Event.getValue("xehStats")#">Your Blog Stats</a></li>
</ul>
<hr>
<ul>
<li><a href="?event=#Event.getValue("xehLogout")#">Logout</a></li>
</ul>
</div>
</cfif>

<div id="content">
	<div id="header">BlogCFC Administrator: #Event.getValue("title")#</div>
	<!--- Content Goes Here --->
	#renderView()#
</div>

</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly=false>