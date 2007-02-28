<cfprocessingdirective pageencoding="utf-8">
<!--- 
	Name         : error.cfm
	Author       : Raymond Camden 
	Created      : March 20, 2005
	Last Updated : June 22 2005
	History      : Show error if logged in. (rkc 4/4/05)
				   BD didn't like error.rootcause (rkc 5/27/05)
				   PaulH added locale strings (rkc 7/22/05)
	Purpose		 : Handles errors
--->

<!--- 
* No more error report, done automatically by coldbox
Send the error report --->
<!---<cfset blogConfig = application.blog.getProperties()> --->

<cfsavecontent variable="mail">
<cfoutput>
<link rel="stylesheet" href="includes/style.css" type="text/css" />
<link rel="stylesheet" href="includes/layout.css" type="text/css" />
#getResource("errorOccured")#:<br>
<table border="1" width="100%">
	<tr>
		<td width="100">#getResource("date")#:</td>
		<td>#dateFormat(now(),"m/d/yy")# #timeFormat(now(),"h:mm tt")#</td>
	</tr>
	<tr>
		<td>#getResource("scriptName")#:</td>
		<td>#cgi.script_name#?#cgi.query_string#</td>
	</tr>
	<tr>
		<td>#getResource("browser")#:</td>
		<td>#cgi.HTTP_USER_AGENT#</td>
	</tr>
	<tr>
		<td>#getResource("referer")#:</td>
		<td>#cgi.HTTP_REFERER#</td>
	</tr>
	<tr>
		<td>#getResource("message")#:</td>
		<td>#Context.getValue("ExceptionBean").getMessage()#</td>
	</tr>
	<tr>
		<td>Details:</td>
		<td>#Context.getValue("ExceptionBean").getDetail()#</td>
	</tr>
	<tr>
		<td>#getResource("type")#:</td>
		<td>#Context.getValue("ExceptionBean").getType()#</td>
	</tr>
	<tr>
		<td>Stack Trace:</td>
		<td>#Context.getValue("ExceptionBean").getStackTrace()#</td>
	</tr>
	<tr>
		<td>#getResource("tagContext")#:</td>
		<td><cfdump var="#Context.getValue("ExceptionBean").getTagcontext()#"></td>
	</tr>
</table>
</cfoutput>
</cfsavecontent>

<cfoutput>
<div class="date">#getResource("errorpageheader")#</div>
<div class="body">
<p>
#getResource("errorpagebody")#
</p>
<cfif isUserInRole("admin") or 1>
	<cfoutput>#mail#</cfoutput>
</cfif>
</div>
</cfoutput>
