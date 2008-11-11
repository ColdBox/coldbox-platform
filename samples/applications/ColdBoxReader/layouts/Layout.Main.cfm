<cfsetting showdebugoutput="false">
<cfset event.showdebugPanel("true")>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>ColdBoxReader: Shared Feed Reading</title>
	<link href="includes/style.css" rel="stylesheet" type="text/css">
	<script type="text/javascript" src="includes/prototype-1.4.js"></script>
	<script type="text/javascript" src="includes/main.js"></script>
</head>

<body>
	<div id="banner">

		<div style="float:right">
		    <div id="divAccountActions" align="center"></div>
		</div>

		<h1><img src="images/logo.png" align="absmiddle" border="0" width="57" height="57">&nbsp;<a href="index.cfm">ColdBoxReader</a>: Shared Feed Reading</h1>

		<div id="statusbar">
			<cfoutput>
			<div style="float:left;margin-left:10px">
			<form name="frmSearch" style="padding:0px;margin:5px;" method="post" action="javascript:doFormEvent('#Event.getValue("xehSearch")#','centercontent',document.frmSearch);">
				<img src="images/search.gif" align="absbottom">
				<input type="text" name="searchTerm" value="Search Keywords" onclick="this.value='';" style="font-size:9px" onBlur="this.value ==  '' ? this.value='Search Keywords' : this.value"/>
				<input type="submit" value="Search" style="font-size:9px" />
			</form>
			</div>

			<div style="float:right" id="loadingImage" class="hidelayer">
				<img src="images/ajax-loader.gif" style="margin-top:5px;">
			</div>

			<div style="float:right; margin-right: 10px;margin-top:8px;">
				<strong>ColdBox Reader: #getSetting("version")#</strong>
			</div>
			</cfoutput>
		</div>

	</div>

	<div id="leftcontent">
		<div id="leftcontent1"></div>
		<div id="leftcontent2"></div>
	</div>

	<div id="centercontent">
		<div style="margin-bottom: 3px;">
			<cfset writeOutput(getPlugin("messageBox").renderit())>
		</div>
		<!--- Render the main view here. --->
		<cfset writeOutput(renderView())>
	</div>

	<div id="rightcontent">
		<div id="rightcontent1"></div>
		<div id="rightcontent2"></div>
	</div>


	<div class="footer" id="footer">
		<div style="float:right;margin-right:5px;margin-top:-5px;">
		<img src="images/orange_arrows_down.gif" align="absmiddle" border="0" title="Hide Footer"><a href="##" onClick="toggleFooter()" title="Hide Footer">Hide Footer</a>
		</div>
		<p align="center"><a href="http://www.luismajano.com/projects/coldbox" target="_blank"><img src="../../images/poweredby.png" border="0"></a></p>
		<p align="center">ColdBoxReader is developed by <a href="http://www.wencho.net" target="_blank">Oscar Arevalo</a> & Luis Majano to showcase AJAX-style interaction using the ColdBox Framework
	</div>

	<div class="hidelayer" id="footer_small">
		<div style="margin-left:10px; float:left"><cfoutput><strong>ColdBox Reader #getSetting("version")#</strong></cfoutput></div>
		<div style="float:right;margin-right:5px;margin-top:-5px;">
		<img src="images/orange_arrows_up.gif" align="absmiddle" border="0" title="Show Footer"><a href="##" onClick="toggleFooter()" title="Show Footer">Show Footer</a>
		</div>
	</div>


</body>
</html>