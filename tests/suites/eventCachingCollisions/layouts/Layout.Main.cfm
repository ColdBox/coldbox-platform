﻿<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Welcome to Coldbox!!</title>
<style>
	body {
	    font: 10pt verdana;
	    font-family: verdana;
	    padding: 0;
	    margin: 0;
	}
	a {
		color: #0087dd;
		background-color: inherit;
		text-decoration: none;
	}
	a:hover {
		color: #CC0001;
		background-color: inherit;
		border-bottom:1px dotted #009CFF;
	}
	a.selected{
		color: #CC0001;
		background-color: inherit;
		border-bottom:1px dotted #009CFF;
	}
	pre {
	     font-size: 80%;
	     padding: 10px;
	     border: 1px solid #EEEEEE;
	 }
	#infobox{
		border:1px solid #CCCCCC;
		padding:10px;
		background-color:#fffff0;
		margin:10px 25px 10px 25px;
	 }
	 td {
	     font: 10pt verdana;
	     font-family: verdana;
	     height: 100%;
	     padding: 10px;
	     margin: 0;
	 }
	 h2 {
	     width: 100%;
	     background-color: black;
	 	 margin: 0px;
	     color: #FFFFFF;
	     padding: 20px;
	 }
	 #sidebar {
	     border-left: 1px solid #DDDDDD;
	     width:250px;
	 }

	 #sidebar ul {
	     margin-left: 0;
	     padding-left: 0;
	 }

	 #sidebar ul h3 {
	     margin-top: 25px;
	     font-size: 16px;
	     padding-bottom: 10px;
	     border-bottom: 1px solid #ccc;
	 }

	 #sidebar li {
	     list-style-type: none;
	 }

	 #sidebar ul.links li {
	     margin-bottom: 5px;
	 }
</style>
</head>
<body>
<!--- Render The View. This is set wherever you want to render the view in your Layout. --->
<cfoutput>#view()#</cfoutput>
</body>
</html>
