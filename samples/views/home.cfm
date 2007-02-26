<cfoutput>
	
<div id="content">
 	<h2>#getResource("welcometitle")#</h2>
	<p>#getResource("welcomemessage")#</p>

	<div class="splitcontentright">
		<h2>#getresource("aboutauthortitle")# </h2>
		<p>#getresource("aboutauthormessage")# </p>
	</div>
	
	<div class="splitcontentleft">
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
	
	<div >
		<h2>#getResource("includedexamples")#:</h2>

		<div id="mytabs" style="margin:0px">
			
			<ul class="anchors" style="margin:0px">
                <li><a href="##section-1">#getResource("tab_noinstall")#</a></li>
                <li><a href="##section-2">#getResource("tab_install")#</a></li>
            </ul>
			
			
			<div id="section-1" >
				<div class="boxscrolling">
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
			</div>
			
			<div id="section-2" >
				<div class="boxscrolling">
				<h3>Ajax ColdBoxReader</h3>
				<p> #getresource("by")# Oscar Arevalo<br />#getresource("coldboxreadermessage")#<bR>
				#getresource("needssetup")#
				<br />
				  <a href="#getSetting("ColdboxReaderApp")#/install/install.txt?TB_iframe=true&height=550&width=800" class="thickbox" title="Install.txt">Install.txt</a><br />
				  <a href="#getSetting("ColdboxReaderApp")#/install?TB_iframe=true&height=550&width=800" class="thickbox" title="Install Folder">#getresource("openinstall")#</a><br />
				  <a href="#getSetting("ColdboxReaderApp")#/index.cfm" target="_blank">#getresource("opensample")#</a><br />
				</p>
				
				<h3>Illidium cfc Code Generator</h3>
				<p> #getresource("by")# Brian Rinaldi<br />#getresource("needssetup")#
				<br />
				<font color="##53231d">#getResource("portMessage")#</font>
				<br />
				  <a href="#getSetting("cfcGeneratorApp")#/install/readme.txt?TB_iframe=true&height=550&width=800" class="thickbox" title="Readme.txt">Readme.txt</a><br />
				  <a href="#getSetting("cfcGeneratorApp")#/index.cfm" target="_blank">#getresource("open")# cfcGenerator</a><br />
				</p>
				
				<h3>BlogCFC</h3>
				<p> #getresource("by")# Raymond Camden<br />#getresource("needssetup")#
				<br />
				<font color="##53231d">#getResource("portMessage")#</font>
				<br />
				  <a href="#getSetting("blogcfcApp")#/install/readme.txt?TB_iframe=true&height=550&width=800" class="thickbox" title="Readme.txt">Readme.txt</a><br />
				  <a href="#getSetting("blogcfcApp")#/install?TB_iframe=true&height=550&width=800" class="thickbox" title="Install Folder">#getresource("openinstall")#</a><br />
				  <a href="#getSetting("blogcfcApp")#/index.cfm" target="_blank">#getresource("open")# BlogCFC</a><br />
				</p>
				
				<h3>Galleon Forums</h3>
				<p> #getresource("by")# Raymond Camden<br />#getresource("needssetup")#
				<br />
				<font color="##53231d">#getResource("portMessage")#</font>
				<br />
				  <a href="#getSetting("forumsApp")#/installation/readme.txt?TB_iframe=true&height=550&width=800" class="thickbox" title="Readme.txt">Readme.txt</a><br />
				  <a href="#getSetting("forumsApp")#/installation/?TB_iframe=true&height=550&width=800" class="thickbox" title="Install Folder">#getresource("openinstall")#</a><br />
				  <a href="#getSetting("forumsApp")#/index.cfm" target="_blank">#getresource("open")# Galleon #getresource("forums")#</a><br />
				  <a href="#getSetting("forumsApp")#/admin/index.cfm" target="_blank">#getresource("open")# #getresource("administrator")#</a><br />
				</p>
				</div>
			</div>
		</div>
		
		<h2>ColdBox #getResource("LogFile")#: 
			<a href="##?TB_inline&height=550&width=800&inlineId=logFileContents" class="thickbox" title="#getResource("LogFile")#"><input type="button" value="#getResource("open")# Log" id="logbutton" name="logbutton" /></a>
		</h2>
		
		<div class="boxscrolling" id="logFileContents">
		#htmlCodeFormat(requestContext.getValue("LogFileContents"))#
		</div>
		
	</div>
	
</div>

</cfoutput>
<cfsetting enablecfoutputonly="no">