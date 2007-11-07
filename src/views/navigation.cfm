<cfoutput>
<p><a href="index.cfm">#getresource("homebutton")#</a></p>
<p><a href="helloworld/index.cfm">#getresource("helloworld")#</a></p>
<p><a href="index.cfm?#getController().getSetting("eventName")#=log.ehTest.dspApi">Call Package Event</a></p>
<p><a href="index.cfm?fwreinit=1">RELOAD</a></p>
<p><a href="index.cfm?#getController().getSetting("eventName")#=testing">Error</a></p>
<p><a href="index.cfm?#getController().getSetting("eventName")#=ehGeneral.doColdboxFactoryTests">ColdBox Factory Tests</a></p>
<p><a href="index.cfm?#getController().getSetting("eventName")#=ehGeneral.testflash">Test Flash Persist</a></p>
<hr>
<p><a href="index.cfm?#getController().getSetting("eventName")#=ehGeneral.dspFolderTester1">Test Folder Layout 1</a></p>
<p><a href="index.cfm?#getController().getSetting("eventName")#=ehGeneral.dspFolderTester2">Test Folder Layout 2</a></p>
<hr>
<p><a href="index.cfm?#getController().getSetting("eventName")#=ehTest.dspExternal">External Handler</a></p>
</cfoutput>