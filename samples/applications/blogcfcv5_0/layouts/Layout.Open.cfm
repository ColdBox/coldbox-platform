<cfprocessingdirective pageencoding="utf-8">
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" />

<html>
<head>
	<title>#application.blog.getProperty("blogTitle")# : #Event.getValue("additionalTitle")#</title>
	<link rel="stylesheet" href="#application.rootURL#/includes/style.css" type="text/css"/>
</head>

<body style="background:##ffffff;">
#renderView()#
</body>
</html>
</cfoutput>
