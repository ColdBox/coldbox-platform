<cfoutput>
<p><a href="index.cfm">#getresource("homebutton")#</a></p>
<p><a href="helloworld/index.cfm">#getresource("helloworld")#</a></p>
<p><a href="index.cfm?#getController().getSetting("eventName")#=log.ehTest.dspApi">Call Package Event</a></p>
<p><a href="index.cfm?fwreinit=1">RELOAD</a></p>
<p><a href="index.cfm?#getController().getSetting("eventName")#=testing">Error</a></p>
</cfoutput>