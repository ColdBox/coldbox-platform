<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><cfoutput>#Event.getValue("title")#</cfoutput></title>
<style type="text/css">
<!--
.Titles {
	font:Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-weight: bold;
	color: #FFFFFF;
	background-color: #0066CC;
	padding: 5px 5px 5px 5px;
	height: 30px;
	text-align:center;
}
body{
	font:Arial, Helvetica, sans-serif;
	font-size: 12px;
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
}
/* Visual Button Links */
a.action {
	font-size:11px;
	font-weight: bold;
	font-family: Verdana, Arial, Helvetica, sans-serif;
	background:#FFCC00 url(images/bg_actions.gif) no-repeat scroll;
	color:#000000;
	cursor:pointer;
	display:block;
	margin:0pt 10px 0pt 0pt;
	text-align:center;
	text-decoration:none;
	height: 23px;
	width: 130px;
}
a.silver {
	background:#FFCC00 url(images/bg_actions_silver.gif) no-repeat scroll;
}
a.action span {
	display: block;
	padding: 5px;
	font-weight:bold;
}
a.action:hover {
	background:#C8E7FA url(images/bg_actions_hover.gif) no-repeat 100%;
}
a:link, a:visited{
	font-weight:bold;
	color: #0000ff;
}
a:hover{
	color: #E58108;
}
.style1 {
	font-size: 18px;
	color: #FFFFFF;
	font-family: Geneva, Arial, Helvetica, sans-serif;
}
.menubox{
background: #f5f5f5;
border-top: 1px solid #eaeaea;
border-left: 1px solid #eaeaea;
border-right: 2px solid #ddd;
font-family:Arial, Helvetica, sans-serif;
font-size:11px;
padding:5px;
}
.mainDiv{
border:2px outset #cccccc;
background: #f5f5f5;
width:800px;
padding:10px;
}
-->
</style>
</head>
<body>
<cfoutput>
<table width="100%" border="0" cellspacing="0" cellpadding="10" >

  <tr style="border-bottom:1px solid ##eaeaea">
    <td colspan="2" bgcolor="##0066CC"><span class="style1">#event.getvalue("title")#</span></td>
  </tr>
  <tr>
    <td  rowspan="2" align="center" valign="middle">
		#getPlugin("messagebox").renderit()#
		#renderView()#
	</td>
  </tr>
</table>
</cfoutput>
<p>&nbsp;</p>
<p align="center"><a href="http://www.luismajano.com/projects/coldbox"><img src="../../images/poweredby.png" border="0"></a></p>
</body>
</html>
