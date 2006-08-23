<cfoutput>
	
<div id="content">
 	<h2>#getResource("welcometitle")#</h2>
	<p>#getResource("welcomemessage")#</p>

	<div class="splitcontentright">
		<h2>#getresource("aboutauthortitle")# </h2>
		<p>#getresource("aboutauthormessage")# </p>
	</div>
	
	<div class="splitcontentleft">
	<p>&nbsp;</p>
		<h2>#getresource("about")# ColdBox </h2>
		<p>#getResource("aboutcoldbox")# </p>
	</div>
		
	<div class="splitcontentright">
	<p>&nbsp;</p>
		<h2>#getresource("contributetitle")# </h2>
		<p>#getresource("contributemessage")#</p>
	</div>
	
	<div class="clear"><p>&nbsp;</p></div>
	
	<div>
		<h2>#getResource("includedexamples")#:</h2>

		<div class="boxscrolling">
		
		<h3>ColdBox Dashboard</h3>
		<p> #getresource("by")# Luis Majano<br />#getresource("coldboxdashboard")#
		<br />
		  <a href="system/admin/index.cfm" target="_blank">#getresource("open")# Dashboard</a><br />
		</p>
		
		
		<h3>BlogCFC</h3>
		<p> #getresource("by")# Raymond Camden<br />#getresource("needssetup")#
		<br />
		  <a href="applications/blogcfcv5.1/install" target="_blank">#getresource("openinstall")#</a><br />
		  <a href="applications/blogcfcv5.1/index.cfm" target="_blank">#getresource("open")# BlogCFC</a><br />
		</p>
		
		<h3>Galleon Forums</h3>
		<p> #getresource("by")# Raymond Camden<br />#getresource("needssetup")#
		<br />
		  <a href="applications/forumsv1.6/installation/" target="_blank">#getresource("openinstall")#</a><br />
		  <a href="applications/forumsv1.6/index.cfm" target="_blank">#getresource("open")# Galleon #getresource("forums")#</a><br />
		  <a href="applications/forumsv1.6/admin/index.cfm" target="_blank">#getresource("open")# #getresource("administrator")#</a><br />
		</p>
		
		<h3>Ajax RSS Reader</h3>
		<p> #getresource("by")# Oscar Arevalo<br />#getresource("coldboxreadermessage")#<bR>
		#getresource("needssetup")#
		<br />
		  <a href="applications/ColdBoxReader/install" target="_blank">#getresource("openinstall")#</a><br />
		  <a href="applications/ColdBoxReader/index.cfm" target="_blank">#getresource("opensample")#</a><br />
		</p>
		
		<h3>JavaLoader</h3>
		<p> #getresource("by")# Luis Majano
		  <br />#getresource("javaloadermessage")#<br>
		  #getresource("nosetup")# <br />
		  <a href="applications/javaloader/index.cfm" target="_blank">#getresource("opensample")#</a><br />
		</p>
		
		<h3>Hello World</h3>
		<p> #getresource("by")# Luis Majano
		  <br />
		  #getresource("nosetup")# <br />
		  <a href="applications/helloworld/index.cfm" target="_blank">#getresource("opensample")#</a><br />
		</p>
		
		<h3>News Web Service</h3>
		<p> #getresource("by")# Luis Majano
		  <br />
		  <a href="applications/NewsWebservice/index.cfm" target="_blank">#getresource("opensample")#</a><br />
		</p>
		
		<h3>Sample Login App</h3>
		<p> #getresource("by")# Luis Majano
		  <br />
		  #getresource("nosetup")# <br />
		  <a href="applications/sampleloginapp/index.cfm" target="_blank">#getresource("opensample")#</a><br />
		</p>
		
		<h3>UDF Library Usage</h3>
		<p> #getresource("by")# Luis Majano
		  <br />
		  #getresource("nosetup")# <br />
		  <a href="applications/udf_library_usage/index.cfm" target="_blank">#getresource("opensample")#</a><br />
		</p>
		
		</div>
	</div>
	
</div>

</cfoutput>
<cfsetting enablecfoutputonly="no">