<cfsetting enablecfoutputonly=true>
<!---
	Name         : datatable.cfm
	Author       : Raymond Camden 
	Created      : June 02, 2004
	Last Updated : September 9, 2005
	History      : JS fix (7/23/04)
				   Minor formatting updates (rkc 8/29/05)
				   finally add sorting (rkc 9/9/05)
	Purpose		 : A VERY app specific datable tag. 
--->

<!--- Includes have a different render scope, need to scope the controller --->
<cfset controller = caller.controller>


<cfparam name="attributes.data" type="query">
<cfparam name="attributes.linkcol" default="#listFirst(attributes.data.columnList)#">
<cfparam name="attributes.linkval" default="id">
<cfparam name="attributes.list" default="#attributes.data.columnList#">
<cfif not controller.valueExists("dir")>
	<cfset controller.setValue("dir","asc")>
</cfif>
<cfif not controller.valueExists("page")>
	<cfset controller.setValue("page",1)>
</cfif>

<cfif controller.getValue("dir") is not "asc" and controller.getValue("dir") is not "desc">
	<cfset controller.setValue("dir", "asc")>
</cfif>

<cfif len(trim(controller.getValue("sort"))) and len(trim(controller.getValue("dir")))>
	<cfquery name="attributes.data" dbtype="query">
	select 	*
	from	attributes.data
	order by 	#controller.getValue("sort")# #controller.getValue("dir")#
	</cfquery>
</cfif>

<cfif not isNumeric(controller.getValue("page",1)) or controller.getValue("page",1) lte 0>
	<cfset controller.setValue("page", 1)>
</cfif>

<cfif controller.valueExists("msg")>
	<cfoutput>
	<p>
	<b>#controller.getValue("msg")#</b>
	</p>
	</cfoutput>
</cfif>

<cfscript>
function displayHeader(col) { 
	if(col is "readonly") return "Read Only";
	if(col is "datecreated") return "Date Created";
	if(col is "messagecount") return "Posts";
	if(col is "lastpost") return "Last Post";
	if(col is "postcount") return "Number of Posts";
	if(col is "emailaddress") return "Email Address";
	if(col is "threadname") return "Thread";
	if(col is "sendnotifications") return "Send Notifications";
	if(col is "forumname") return "Forum";
	if(col is "conferencename") return "Conference";
	if(col is "minposts") return "Minimum Number of Posts";
	else if(len(col) is 1) return uCase(col);
	else return ucase(left(col,1)) & right(col, len(col)-1);
}
</cfscript>

<cfoutput>
<script>
function checksubmit() {
	if(document.listing.mark.length == null) {
		if(document.listing.mark.checked) {
			document.listing.submit();
			return;
		}
	}

	for(i=0; i < document.listing.mark.length; i++) {
		if(document.listing.mark[i].checked) document.listing.submit();
	}
}
</script>

<cfif attributes.data.recordCount gt application.settings.perpage>
	<p align="right">
	[[
	<cfif controller.getValue("page",1) gt 1>
		<a href="#cgi.script_name#?page=#controller.getValue("page",1)-1#&sort=#urlEncodedFormat(controller.getValue("sort"))#&dir=#controller.getValue("dir")#">Previous</a>
	<cfelse>
		Previous
	</cfif>
	--
	<cfif controller.getValue("page",1) * application.settings.perpage lt attributes.data.recordCount>
		<a href="#cgi.script_name#?page=#controller.getValue("page")+1#&sort=#urlEncodedFormat(controller.getValue("sort"))#&dir=#controller.getValue("dir")#">Next</a>
	<cfelse>
		Next
	</cfif>
	]]
	</p>
</cfif>

<p>
<form name="listing" action="#cgi.script_name#" method="post">
<input type="hidden" name="event" value="#controller.getValue("event")#">
<table width="100%" cellspacing=0 cellpadding=5 class="adminListTable">
	<tr class="adminListHeader">
		<td>&nbsp;</td>
		<cfloop index="c" list="#attributes.list#">
			<cfif controller.getValue("sort") is c and controller.getValue("dir") is "asc">
				<cfset dir = "desc">
			<cfelse>
				<cfset dir = "asc">
			</cfif>
			<td class="adminListHeaderText">
			<!--- static rewrites of a few of the columns --->
			<a href="#cgi.script_name#?event=#controller.getValue("event")#&page=#controller.getValue("page")#&sort=#urlEncodedFormat(c)#&dir=#dir#">#displayHeader(c)#</a>
			</td>
		</cfloop>
	</tr>
</cfoutput>

<cfif attributes.data.recordCount>
	<cfoutput query="attributes.data" startrow="#(controller.getValue("page")-1)*application.settings.perpage + 1#" maxrows="#application.settings.perpage#">
		<cfset theLink = attributes.editlink & "?id=#id#">
		<tr class="adminList#currentRow mod 2#">
			<td width="20"><input type="checkbox" name="mark" value="#attributes.data[attributes.linkval][currentRow]#"></td>
			<cfloop index="c" list="#attributes.list#">
				<cfset value = attributes.data[c][currentRow]>
				<cfif c is "readonly" or c is "active" or c is "sendnotifications" or c is "sticky">
					<cfset value = yesNoFormat(value)>
				<cfelseif c is "datecreated" or c is "posted" or c is "lastpost">
					<cfset value = dateFormat(value,"mm/dd/yy") & " " & timeFormat(value,"h:mm tt")>
				</cfif>
				<cfif value is "">
					<cfset value = "&nbsp;">
				</cfif>
				<td>
				<cfif c is attributes.linkcol>
				<a href="#attributes.editlink#&id=#attributes.data[attributes.linkval][currentRow]#">#value#</a>
				<cfelse>
				#value#
				</cfif>
				</td>
			</cfloop>
		</tr>
	</cfoutput>
<cfelse>

</cfif>

<cfoutput>
</table>
</form>
</p>

<p align="right">
[<a href="#attributes.editlink#&id=0">Add #attributes.label#</a>] [<a href="javascript:checksubmit()">Delete Selected</a>]
</p>
</cfoutput>

<cfsetting enablecfoutputonly=false>

<cfexit method="EXITTAG">