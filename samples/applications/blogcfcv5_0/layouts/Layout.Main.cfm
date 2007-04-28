<cfprocessingdirective pageencoding="utf-8">
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>#application.blog.getProperty("blogTitle")##Event.getValue("additionalTitle")#</title>
<!--- RBB 6/23/05: Push crawlers to follow links, but only index content on individual entry pages --->
<cfif Event.valueExists("mode") and Event.getValue("mode") is "entry">
<!--- index entry page --->
<meta name="robots" content="index,follow" />
<cfelse>
<!--- don't index other pages --->
<meta name="robots" content="noindex,follow" />	  
</cfif>
<meta name="title" content="#application.blog.getProperty("blogTitle")##Event.getValue("additionalTitle")#" />
<meta content="text/html; charset=UTF-8" http-equiv="content-type">
<meta name="description" content="#application.blog.getProperty("blogDescription")##Event.getValue("additionalTitle")#" />
<meta name="keywords" content="#application.blog.getProperty("blogKeywords")#">
<link rel="stylesheet" href="#application.rootURL#/includes/style.css" type="text/css" />
<link rel="stylesheet" href="#application.rooturl#/includes/layout.css" type="text/css" />
<!--- For Firefox --->
<link rel="alternate" type="application/rss+xml" title="RSS" href="#application.rooturl#/rss.cfm?mode=full" />
<script>			
	<!--- Normal use: #application.rooturl#/ --->
	function launchComment(id) {
		//Modified by LM to open in center
		var winl = (screen.width - 400) / 2;
		var wint = (screen.height - 350) / 2
		cWin = window.open("#application.rooturl#/?event=#Event.getValue("xehComments")#&id="+id,"cWin","width=545,height=500,menubar=yes,personalbar=no,dependent=true,directories=no,status=yes,toolbar=no,scrollbars=yes,resizable=yes,left=" + winl + ",top=" + wint);
	}
	function launchTrackback(id) {
		//Modified by LM to open in center
		var winl = (screen.width - 400) / 2;
		var wint = (screen.height - 350) / 2
		cWin = window.open("#application.rooturl#/?event=#Event.getValue("xehTrackbacks")#&id="+id,"cWin","width=545,height=500,menubar=yes,personalbar=no,dependent=true,directories=no,status=yes,toolbar=no,scrollbars=yes,resizable=yes,left=" + winl + ",top=" + wint);
	}
</script>
		
</head>

<body>
<div id="page">
	<div id="banner"><a href="#application.rootURL#">#application.blog.getProperty("blogTitle")#</a></div>
		<div id="content">	
			<div id="blogText">
			#getPlugin("messagebox").renderit()#
			<!--- Views Get Rendered HERE --->
			#renderView()#
			</div>
		</div>
	<div id="menu">
		#renderView("pods/search")#		
		#renderView("pods/calendar")#
		#renderView("pods/subscribe")#
		#renderView("pods/archives")#
		#renderView("pods/recent")#
		#renderView("pods/recentcomments")#
		#renderView("pods/rss")#
	</div>
	
	<div class="footerHeader"><a href="http://ray.camdenfamily.com/projects/blogcfc">BlogCFC</a> was created by <a href="http://ray.camdenfamily.com/">Raymond Camden</a>. This blog is running version #application.blog.getVersion()#. 
	<p align="center"><a href="http://www.luismajano.com/projects/coldbox"><img src="../../images/poweredby.png" border="0"></a></p>
	</div>
</div>

</body>
</html>
</cfoutput>