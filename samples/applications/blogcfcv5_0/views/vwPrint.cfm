<!---
	Name         : c:\projects\blog\client\print.cfm
	Author       : Raymond Camden 
	Created      : 09/23/05
	Last Updated : 11/11/05
	History      : Changed request.rooturl to app.rooturl (rkc 11/11/05)
--->
<cfset entry = Event.getValue("entry")>

<cfheader name="Content-Disposition" value="inline; filename=print.pdf">
<cfdocument format="pdf">

	<cfoutput>
	<html>

	<style type="text/css">
	@import url(#application.rooturl#/includes/style.css);
	</style>
	
	<body style="background:##FFFFFF">
	<div id="page">
	<div id="content">
	<div id="blogText">
	</cfoutput>
	
	<cfdocumentitem type="header">
	<cfoutput>
	<div style="font-size: 8px; text-align: right;">
	#application.blog.getProperty("blogTitle")#: #entry.title#
	</div>	
	</cfoutput>
	</cfdocumentitem>

	<cfsavecontent variable="display">	
	<cfoutput>
	<h1>#entry.title#</h1>

	<div class="byline">#getResource("postedat")# : #getPlugin("i18n").dateLocaleFormat(entry.posted)# #getPlugin("i18n").timeLocaleFormat(entry.posted)# 
		<cfif len(entry.name)>| #getResource("postedby")# : #entry.name#</cfif><br />
		#getResource("relatedcategories")#:
		<cfloop item="cat" collection="#entry.categories#">
		#entry.categories[cat]#<cfif cat is not listLast(structKeyList(entry.categories))>,</cfif>
		</cfloop>
	</div>

	<div class="body">
	#application.blog.renderEntry(entry.body,true,entry.enclosure)#
	#application.blog.renderEntry(entry.morebody,true)#
	</div>
	</cfoutput>
	</cfsavecontent>
	
	<!--- 
	Older blog entries use class=code, so let's do a quick fix for them
	--->
	<cfset display = replace(display, "class=""code""", "class=""codePrint""", "all")>
	<cfoutput>#display#</cfoutput>

	<cfoutput>
	</div>
	</div>
	</div>
	
	</body>
	</html>
	</cfoutput>
	
</cfdocument>