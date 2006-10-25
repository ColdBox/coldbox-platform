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
		
		<div class="box">
			<strong>#getResource("Tip")#</strong>: #getResource("TipMessage")# :<br>
			<div align="center">
				<input type="button" name="reinitbutton" value="#getResource("ReinitButton")#" onClick="window.location='index.cfm?fwreinit=true'">
			</div>
		</div>
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
		<font color="##53231d">#getResource("portMessage")#</font>
		<br />
		  <a href="#getSetting("blogcfcApp")#/install" target="_blank">#getresource("openinstall")#</a><br />
		  <a href="#getSetting("blogcfcApp")#/index.cfm" target="_blank">#getresource("open")# BlogCFC</a><br />
		</p>
		
		<h3>Galleon Forums</h3>
		<p> #getresource("by")# Raymond Camden<br />#getresource("needssetup")#
		<br />
		<font color="##53231d">#getResource("portMessage")#</font>
		<br />
		  <a href="#getSetting("forumsApp")#/installation/" target="_blank">#getresource("openinstall")#</a><br />
		  <a href="#getSetting("forumsApp")#/index.cfm" target="_blank">#getresource("open")# Galleon #getresource("forums")#</a><br />
		  <a href="#getSetting("forumsApp")#/admin/index.cfm" target="_blank">#getresource("open")# #getresource("administrator")#</a><br />
		</p>
		
		<h3>Ajax RSS Reader</h3>
		<p> #getresource("by")# Oscar Arevalo<br />#getresource("coldboxreadermessage")#<bR>
		#getresource("needssetup")#
		<br />
		  <a href="#getSetting("ColdboxReaderApp")#/install" target="_blank">#getresource("openinstall")#</a><br />
		  <a href="#getSetting("ColdboxReaderApp")#/index.cfm" target="_blank">#getresource("opensample")#</a><br />
		</p>
		
		<h3>Illidium cfc Code Generator</h3>
		<p> #getresource("by")# Brian Rinaldi<br />#getresource("needssetup")#
		<br />
		<font color="##53231d">#getResource("portMessage")#</font>
		<br />
		  <a href="#getSetting("cfcGeneratorApp")#/install" target="_blank">#getresource("openinstall")#</a><br />
		  <a href="#getSetting("cfcGeneratorApp")#/index.cfm" target="_blank">#getresource("open")# cfcGenerator</a><br />
		</p>
		
		<h3>Hello World</h3>
		<p> #getresource("by")# Luis Majano
		  <br />
		  #getresource("nosetup")# <br />
		  <a href="applications/helloworld/index.cfm" target="_blank">#getresource("opensample")#</a><br />
		</p>
		
		<h3>JavaLoader</h3>
		<p> #getresource("by")# Luis Majano
		  <br />#getresource("javaloadermessage")#<br>
		  #getresource("nosetup")# <br />
		  <a href="applications/javaloader/index.cfm" target="_blank">#getresource("opensample")#</a><br />
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
		
		<h3>i18N Sample Gallery</h3>
		<p> #getresource("by")# Paul Hastings & Luis Majano
		  <br />
		  #getresource("nosetup")# <br />
		  <a href="applications/i18NSample/index.cfm" target="_blank">#getresource("opensample")#</a><br />
		</p>
		
		
		</div>
		
		<h2>ColdBox #getResource("LogFile")#:</h2>
		
		<div class="boxscrolling">
		#htmlCodeFormat(getValue("LogFileContents"))#
		</div>
		
	</div>
	
</div>

</cfoutput>
<cfsetting enablecfoutputonly="no">