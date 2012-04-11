<cfoutput>
<p><a href="#getSetting("sesbaseURL")#">#getresource("homebutton")#</a></p>

<p><a href="#event.buildLink('ehGeneral.dumpsettings')#" target="_blank">Dump Settings</a></p>

<p><a href="#event.buildLink('log.ehTest.dspApi')#">Call Package Event</a></p>
<p><a href="#getSetting("sesbaseURL")#?fwreinit=1">RELOAD</a></p>
<p><a href="#getSetting("sesbaseURL")#?#getController().getSetting("eventName")#=testing">Error</a></p>
<p><a href="#getSetting("sesbaseURL")#?#getController().getSetting("eventName")#=ehGeneral.testflash">Test Flash Persist</a></p>
<p><a href="#getSetting("sesbaseURL")#?#getController().getSetting("eventName")#=ehGeneral.purgeEvents">Purge All Events</a></p>
<hr>
<p><a href="#getSetting("sesbaseURL")#?#getController().getSetting("eventName")#=ehGeneral.dspFolderTester1">Test Folder Layout 1</a></p>
<p><a href="#getSetting("sesbaseURL")#?#getController().getSetting("eventName")#=ehGeneral.dspFolderTester2">Test Folder Layout 2</a></p>
<hr>
<p><a href="#getSetting("sesbaseURL")#?#getController().getSetting("eventName")#=ehTest.dspExternal">External Handler</a></p>
<p><a href="#getSetting("sesbaseURL")#?#getController().getSetting("eventName")#=ehGeneral.externalview">External View</a></p>
<p><a href="#getSetting("sesbaseURL")#?#getController().getSetting("eventName")#=ehSecure.dspUser">Security Int Test</a></p>
<p><a href="#getSetting("sesbaseURL")#?#getController().getSetting("eventName")#=default.implicit">Implicit Views</a></p>
<p><a href="#getSetting("sesbaseURL")#?#getController().getSetting("eventName")#=default.rss">RSS Reader</a></p>
<p><a href="#getSetting("sesbaseURL")#?#getController().getSetting("eventName")#=default.testroute">Test SetNextEvent Route</a></p>
<p><a href="#getSetting("sesbaseURL")#?#getController().getSetting("eventName")#=default">Default Handler</a></p>

<p><a href="#getSetting("sesbaseURL")#?#getController().getSetting("eventName")#=default.protect">PreHandler Protection</a></p>
<p><a href="#event.buildLink('ehGeneral.viewcaching')#">View Caching With Suffix</a></p>
</cfoutput>