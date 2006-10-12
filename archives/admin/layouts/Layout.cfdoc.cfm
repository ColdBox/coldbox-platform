<cfif getValue("cfdoctype") eq "pdf">
	<cfset ext = "pdf">
<cfelse>
	<cfset ext = "swf">
</cfif>
<cfheader name="Content-Disposition" value="inline; filename=print.#ext#">
<cfdocument format="#getValue("cfdoctype")#" pagetype="letter">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link href="includes/style.css" rel="stylesheet" type="text/css" />
<title>ColdBox Dashboard</title>
</head>
<body>
<cfdocumentitem type="header" >
<font size="1">ColdBox: A ColdFusion Framework by Luis Majano (cfcoldbox@gmail.com)</font>
</cfdocumentitem>

<div style="background:url(images/logo_header.jpg);
background-repeat:no-repeat;
height: 102px;"></div>
<br>
<div>
	<div class="dashboardContent"><cfoutput>#renderView()#</cfoutput></div>
</div>
</body>
</html>

<cfdocumentitem type="footer">
<div align="right"><font size="1"><cfoutput>Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</cfoutput></font></div>
</cfdocumentitem>

</cfdocument>