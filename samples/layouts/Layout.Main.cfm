<cfsetting enablecfoutputonly="yes">
<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title>ColdBox: A ColdFusion Framework : #getResource("samplesgallery")#</title>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
<meta name="description" content="Your website description goes here" />
<meta name="keywords" content="your,keywords,goes,here" />
<cfif false>
<link rel="stylesheet" href="../includes/andreas08.css" type="text/css" media="screen,projection" />
<cfelse>
<link rel="stylesheet" href="includes/andreas08.css" type="text/css" media="screen,projection" />
</cfif>
</head>

<body>
<div id="container" >

<div id="header">
<h1><img src="images/header.png" /></h1>
</div>

<div id="navigation">
<ul>
<li class="selected"><a href="#cgi.SCRIPT_NAME#">#getResource("sampleshome")#</a></li>
<li><a href="http://www.robgonda.com"  target="_blank">Rob Gonda's Blog</a></li>
<li><a href="http://www.camdenfamily.com/morpheus/blog/"  target="_blank">Ray Camden's Blog</a></li>
<li><a href="http://www.remotesynthesis.com/blog/" target="_blank">Remote Synthesis</a></li>
</ul>
<div align="right">
#getResource("changelanguage")#
<select name="locale" onChange="window.location='index.cfm?event=ehSamples.doChangeLocale&locale=' + this.value">
   	<option value="en_US" <cfif getPlugin("i18n").getfwLocale() eq "en_US">selected</cfif>>English</option>
   	<option value="es_SV" <cfif getPlugin("i18n").getfwLocale() eq "es_SV">selected</cfif>>Spanish</option>
</select>
</div>
</div>

<!--- Render View Here --->
#renderView()#
<!--- Render View Here --->

<div id="subcontent">
<div class="small box"><strong>#getResource("note")#: </strong>#getResource("notemessage")#</div>
<br>
<h2>Favorite Links</h2>
<ul class="menublock">
  <li><a href="http://www.luismajano.com">#getresource("mysite")#</a></li>
   <li><a href="http://www.amazon.com/o/registry/7DPYG3RZG3AF">#getresource("myamazonwishlist")#</a></li>
  <li><a href="http://www.luismajano.com/projects/coldbox" target="_blank">ColdBox #getresource("home")#</a></li>
  <li><a href="http://www.luismajano.com/forums/index.cfm?event=ehForums.dspForums&conferenceid=C6AFC876-EF7C-63FC-5955ECD6CA587480" target="_blank">ColdBox #getResource("forums")#</a></li>
  <li><a href="http://www.luismajano.com/blog/index.cfm?mode=cat&catid=C048ADD3-0C45-9C3D-A8F228EFB8C128DA" target="_blank">ColdBox Blog</a></li>
  <li><a href="http://www.luismajano.com/projects/coldbox/cfdocs/index.cfm" target="_blank">ColdBox API</a></li>
  <li><a href="http://trac.luismajano.com/coldbox" target="_blank">ColdBox Trac Site</a></li>
</ul>
<br>
<div id="searchbar">
  <h2>#getResource("searchblog")# </h2>
<form action="#getSetting("SearchURL")#" method="post" name="search">
<fieldset style="text-align:center">
<input type="search" value="#getresource("search")# #getresource("archives")#" name="search" id="search" alt="#getResource("searchblog")# "  onfocus="if (this.value == '#getresource("search")# #getresource("archives")#') {this.value = '';}" onblur="if (this.value == '') {this.value='#getresource("search")# #getresource("archives")#'}" size="20" />
<br /><br>
<input type="submit" value="#getResource("search")#" id="searchbutton" name="searchbutton" />
</fieldset>
</form>
</div>
<p align="center"><a href="http://www.luismajano.com/projects/coldbox"><img src="images/poweredby.png" border=0></a></p>

</div>

<div id="footer">
<p>&copy; 2005-2006 <a href="http://www.luismajano.com">ColdBox by Luis Majano </a> | Design by <a href="http://andreasviklund.com">Andreas Viklund</a></p>
</div>

</div>
</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="no">