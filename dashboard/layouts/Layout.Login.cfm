<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<title>ColdBox Dashboard Login</title>
<link href="includes/style.css" rel="stylesheet" type="text/css" />
<script language="javascript" src="includes/dashboard.js"></script>
<script language="javascript" src="includes/jquery-latest.pack.js"></script>
<script language="javascript" src="includes/plugins/jqModal.js"></script>
<script language="javascript" src="includes/plugins/jqDnR.js"></script>
<script language="javascript" src="includes/plugins/jquery.block.js"></script>
</head>

<body onload="framebuster()">

<div class="headerbar">
  <div class="logo"></div>
</div>

<div class="statusbar">

	<div id="myloader" style="display: none">
		<div class="myloader"><img src="images/ajax-loader.gif" width="220" height="19" align="absmiddle" title="Loading..." /></div>
	</div>

</div>

<cfoutput>#renderView()#</cfoutput>

</body>
</html>