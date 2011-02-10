<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta name="author" content="Luis Majano & Design by Luka Cvrk (www.solucija.com)" />
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	<cfif event.isSES()>
		<base href="#getSetting('htmlBaseURL')#">
	</cfif>
	<!--- CSS --->
	<link rel="stylesheet" href="#event.getModuleRoot()#/includes/css/style.css" type="text/css" />
	<link rel="stylesheet" href="#event.getModuleRoot()#/includes/js/ratings/jquery.ratings.css" type="text/css" />
	<!--- Javascript --->
	<script type="text/javascript" src="#event.getModuleRoot()#/includes/js/jquery-latest.pack.js"></script>
	<script type="text/javascript" src="#event.getModuleRoot()#/includes/js/forgebox.js"></script>
	<script type="text/javascript" src="#event.getModuleRoot()#/includes/js/jquery.simplemodal-latest.min.js"></script>
	<script type="text/javascript" src="#event.getModuleRoot()#/includes/js/jquery.uidivfilter.js"></script>
	<script type="text/javascript" src="#event.getModuleRoot()#/includes/js/ratings/jquery.ratings.pack.js"></script>
	<title>The Awesome ForgeBox Module!</title>
</head>

<body>
	<div id="content">
		<h1>
			<img src="#event.getModuleRoot()#/includes/images/ColdBoxLogoSquare_125.png" height="100" alt="logo" />
		</h1>
		<ul id="top">
			<li><a <cfif rc.orderby eq "popular">class="current"</cfif> 
				 href="#event.buildLink('forgebox.manager.popular')#"><img src="#event.getModuleRoot()#/includes/images/popular.png" alt="popular" border="0" /> 
				 Most Popular</a></li>
			<li><a <cfif rc.orderby eq "new">class="current"</cfif>
				 href="#event.buildLink('forgebox.manager.new')#"><img src="#event.getModuleRoot()#/includes/images/label_new.png" alt="popular" border="0" />
				 New Stuff</a></li>
			<li><a <cfif rc.orderby eq "recent">class="current"</cfif>
				 href="#event.buildLink('forgebox.manager.recent')#"><img src="#event.getModuleRoot()#/includes/images/calendar_week.png" alt="popular" border="0" />
				 Newly Updated</a></li>
		</ul>
		
		<div id="intro">
			<p>
				<img src="#event.getModuleRoot()#/includes/images/ForgeBox.png" alt="forgebox" style="float:left;margin-right:5px" />
				Welcome to the ForgeBox Module! From here you can browse all of our online
				<a href="http://www.coldbox.org/forgebox" title="Go online!">ForgeBox Code Repository!</a> You can also choose to
				install any code entry into your running application.
			</p>
		</div>
		
		<!--- Main Render view --->
		#renderView()#
		
		<div id="footer">
			<p>Copyright <a href="http://www.coldbox.org/">ColdBox Platform</a></p>
			<p>Design: Luka Cvrk, <a title="Awsome Web Templates" href="http://www.solucija.com/">Solucija</a></p>
		</div>
	</div>
</body>
</html>
</cfoutput>