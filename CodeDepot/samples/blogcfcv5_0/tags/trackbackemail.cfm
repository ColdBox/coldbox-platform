<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : trackbackemail.cfm
	Author       : Raymond Camden 
	Created      : September 27, 2005
	Last Updated : 
	History      : 
	Purpose		 : Handles just the email to notify us about TBs
--->

<!--- id of the TB --->
<cfparam name="attributes.trackback" type="uuid">

<cfset tb = application.blog.getTrackBack(attributes.trackback)>

<cfif structIsEmpty(tb)>
	<cfsetting enablecfoutputonly=false>
	<cfexit method="exitTag">	
</cfif>

<cftry>
	<cfset blogEntry = application.blog.getEntry(tb.entryid)>
	<cfcatch>
		<cfsetting enablecfoutputonly=false>
		<cfexit method="exitTag">	
	</cfcatch>
</cftry>

<!--- make TB killer link --->
<cfset tbKiller = application.rootURL & "/index.cfm?event=ehBlog.dspTrackback&kill=#attributes.trackback#">

<cfset subject = caller.getPlugin("resourceBundle").getResource("trackbackaddedtoentry") & ": " & application.blog.getProperty("blogTitle") & " / " & caller.getPlugin("resourceBundle").getResource("entry") & ": " & blogEntry.title>
<cfsavecontent variable="email">
<cfoutput>
#caller.getPlugin("resourceBundle").getResource("trackbackaddedtoblogentry")#:	#blogEntry.title#
#caller.getPlugin("resourceBundle").getResource("trackbackadded")#: 		#getPlugin("i18n").dateLocaleFormat(now())# / #getPlugin("i18n").timeLocaleFormat(now())#
#caller.getPlugin("resourceBundle").getResource("blogname")#:	 		#tb.blogname#
#caller.getPlugin("resourceBundle").getResource("title")#:	 			#tb.title#
URL:				#tb.posturl#
#caller.getPlugin("resourceBundle").getResource("excerpt")#:
#tb.excerpt#

#caller.getPlugin("resourceBundle").getResource("deletetrackbacklink")#:
#tbKiller#

------------------------------------------------------------
This blog powered by BlogCFC #application.blog.getVersion()#
Created by Raymond Camden (ray@camdenfamily.com)
</cfoutput>
</cfsavecontent>

<cfset addy = application.blog.getProperty("owneremail")>
<cfif application.blog.getProperty("mailserver") is "">
	<cfmail to="#addy#" from="#addy#" subject="#subject#">#email#</cfmail>
<cfelse>
	<cfmail to="#addy#" from="#addy#" subject="#subject#"
		server="#application.blog.getProperty("mailserver")#" username="#application.blog.getProperty("mailusername")#" password="#application.blog.getProperty("mailpassword")#">#email#</cfmail>
</cfif>

<cfsetting enablecfoutputonly=false>
<cfexit method="exitTag">