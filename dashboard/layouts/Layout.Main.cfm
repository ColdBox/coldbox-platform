<cfsetting showdebugoutput="false">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<title>ColdBox Dashboard</title>
<link href="includes/style.css" rel="stylesheet" type="text/css" />
<script language="javascript" src="includes/dashboard.js"></script>
<script language="javascript" src="includes/jquery-latest.pack.js"></script>
<script language="javascript" src="includes/plugins/jqModal.js"></script>
<script language="javascript" src="includes/plugins/jqDnR.js"></script>
<script language="javascript" src="includes/plugins/jquery.block.js"></script>
</head>
<body>
<cfoutput>
<table width="100%" height="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td valign="top" height="700" align="center">
		<!--- Content --->
		<div id="content"></div>
		</td>
		<td class="sidemenu" valign="top">
		#renderView()#
		<!--- Render sidemenu tools --->
		#renderview("tags/sidemenu_tools")#
		</td>
	</tr>
</table>
</cfoutput>
</body>
</html>