<cfsetting showdebugoutput="false">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
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
			<form name="frmSearch" style="padding:0px;margin:5px;" method="post" action="javascript:doFormEvent('#getValue("xehSearch")#','centercontent',document.frmSearch);">
				
				<input type="text" name="searchTerm" value="Search Keywords" onclick="this.value='';" style="font-size:9px" onBlur="this.value ==  '' ? this.value='Search Keywords' : this.value"/>
				<input type="submit" value="Search" style="font-size:9px" />
				<strong>ColdBox Reader Version: #getSetting("version")#</strong>
			</form>
			</div>
			
			<div style="float:right">
				<img src="images/ajax-loader.gif" style="margin-top:5px;display:none" id="loadingImage">
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
		<cfset writeOutput(getPlugin("messageBox").render())>
		</div>
		<cfset writeOutput(renderView())>
	</div>
	
	<div id="rightcontent">
		<div id="rightcontent1"></div>
		<div id="rightcontent2"></div>
	</div>
	
	<div id="bottombanner">
	<br />
	<p align="center"><a href="http://www.luismajano.com/projects/coldbox" target="_blank"><img src="../../images/poweredby.png" border="0"></a></p>
	<p align="center">ColdBoxReader is developed by <a href="http://www.wencho.net" target="_blank">Oscar Arevalo</a> & Luis Majano to showcase AJAX-style interaction using the ColdBox Framework
	</div>
</body>
</html>