<cfsetting enablecfoutputonly=true>
<!---
	Name         : admin_header.cfm
	Author       : Raymond Camden 
	Created      : June 02, 2004
	Last Updated : November 22, 2005
	History      : bogus (rkc 1/31/05)
				   Small formatting changes (rkc 8/29/05)
				   ditto (rkc 9/9/05)
				   turn off cfoutput (rkc 11/22/05)
	Purpose		 : 
--->

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>#Event.getValue("title")#</title>
	<link rel="stylesheet" type="text/css" href="../stylesheets/style.css">
</head>

<body>

<div class="adminAppTitle">Galleon Administrator</div>
<table width="100%" cellpadding="10" border="0">
	<tr valign="top">
		<td class="adminLeftMenu" width="150">
		<img src="/images/shim.gif" width="150" height="1">
		<b>Conference Options</b><br>
		<a href="?event=#Event.getValue("xehConferences")#">Conferences</a><br>
		<a href="?event=#Event.getValue("xehForums")#">Forums</a><br>
		<a href="?event=#Event.getValue("xehThreads")#">Threads</a><br>
		<a href="?event=#Event.getValue("xehMessages")#">Messages</a><br>
		<a href="?event=#Event.getValue("xehRanks")#">Ranks</a><br>
		<br>
		<b>Security Options</b><br>
		<a href="?event=#Event.getValue("xehUsers")#">User Editor</a><br>
		<br>
		<b>Stats</b><br>
		<a href="?event=#Event.getValue("xehStats")#">General Reporting</a><br>
		<a href="?event=#Event.getValue("xehSearchStats")#">Search Reporting</a><br>
		<br>
		<a href="index.cfm">Admin Home</a><br>
		<a href="../">Galleon Home</a><br>
		</td>
		<td width="100%">
		<h2>#Event.getValue("title")#</h2>
</cfoutput>

<cfsetting enablecfoutputonly=false>

