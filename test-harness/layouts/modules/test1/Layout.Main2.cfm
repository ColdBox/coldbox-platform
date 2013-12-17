<cfset addAsset('includes/jquery-1.2.6.min.js')>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><cfoutput>#controller.getSetting("Codename",1)# #controller.getSetting("Version",1)#</cfoutput></title>
<link href="includes/style.css" rel="stylesheet" type="text/css" />
</head>
<body>
<table width="700" border="0" align="center" cellpadding="2" cellspacing="1" style="border: 1px solid #006699">
  <tr>
    <td width="77" height="30" align="center" bgcolor="#eeeeee" valign="top">
    <cfoutput>
    #renderView("navigation")#
    </cfoutput>
    </td>
    <td width="610" valign="top">
	<!--- Render the View Here --->
	<cfoutput>#renderView()#</cfoutput>
	</td>
  </tr>
</table>
<br /><br />
RC:
<cfdump var="#rc#" expand="false" />
</body>
</html>