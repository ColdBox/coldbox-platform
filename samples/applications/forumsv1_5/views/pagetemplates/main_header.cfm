<cfsetting enablecfoutputonly=true>
<!---
	Name         : main_header.cfm
	Author       : Raymond Camden 
	Created      : June 02, 2004
	Last Updated : November 22, 2005
	History      : Use meta tags (rkc 8/3/05)
	  			   Added rss auto stuff, by Tom Thomas (rkc 8/9/05)
	  			   Removed mappings (rkc 8/27/05)
	  			   Make login as smart as login on thread display (rkc 10/6/05)
	  			   login link was duping ref (rkc 10/8/05)
	  			   forgot to turn off cfoutputonly (rkc 11/22/05)
	Purpose		 : 
--->

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>#getValue("title")#</title>
	<link rel="stylesheet" type="text/css" href="stylesheets/style.css">
	<meta name="description" content="#getValue("title")#">
	<meta name="keywords" content="#replace(getValue("title")," : ", ",","all")#"> 
   	<cfif isDefined("request.conference")>
    <link rel="alternate" type="application/rss+xml" title="#request.conference.name# RSS" href="#application.settings.rooturl#rss.cfm?conferenceid=#request.conference.id#">
    </cfif>
</head>

<body>

<table width="750" cellpadding="0" cellspacing="4" border="0">
	<tr>
		<td><a href="index.cfm"><img src="images/Galleon.gif" alt="Galleon" width="99" height="19" border="0"></a></td>
		<td align="right">
		<span class="topMenu">
		<a href="index.cfm">Home</a> | 
		<a href="index.cfm?event=#getValue("xehProfile")#">Profile</a> | 
		<a href="index.cfm?event=#getValue("xehSearch")#">Search</a> | 
		<cfset thisPage = cgi.script_name & "?" & reReplace(cgi.query_string,"logout=1","")>
		
		<cfif not valueExists("ref")>
			<cfset link = "?event=#getValue("xehLogin")#&ref=#urlEncodedFormat(thisPage)#">
		<cfelse>
			<cfset link = "?event=#getValue("xehLogin")#&ref=#urlEncodedFormat(ref)#">
		</cfif>	
		<cfif request.udf.isLoggedOn()><a href="index.cfm?logout=1">Logout</a><cfelse><a href="#link#">Login</a></cfif>
		<cfif isDefined("request.conference")> | <a href="index.cfm?event=#getValue("xehRSS")#&conferenceid=#request.conference.id#">RSS</a></cfif>
		</span>
		</td>
	</tr>
	<tr bgcolor="##235577">
		<td colspan=2 height="1"><img src="images/shim.gif" height="1"></td>
	</tr>
	<tr>
		<td colspan=2>

		#renderView("tags/breadcrumbs")#

		</td>
	</tr>
	<tr>
		<td colspan=2>
</cfoutput>

<cfsetting enablecfoutputonly=false>

