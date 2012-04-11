<cfset addAsset('includes/jquery-1.2.6.min.js')>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><cfoutput>#controller.getSetting("Codename",1)# #controller.getSetting("Version",1)#</cfoutput></title>
<link href="includes/style.css" rel="stylesheet" type="text/css" />
</head>
<body>
<h1>Module Layout</h1>
<cfoutput>#renderView()#</cfoutput>
</body>
</html>