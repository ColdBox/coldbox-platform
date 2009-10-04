<cfoutput>
<h2><img src="includes/images/coldbox.png" class="middle" style="padding-right:10px" alt="ColdBox" /> #rc.welcomeMessage#</h2>

<div id="content">
	<h3>Getting Started</h3>
	<p>
	You have just auto-generated your application and are ready to customize your application.  This application template
	is used for building and monitoring remote applications built using Flex/Air or any other remote technology.
	</p>
	<p>
	If you do not see the ColdBox Debugger below this message, then you might not be in Debug Mode.  The application must be placed
	in debug mode either globally (<em>DebugMode</em> setting in the coldbox configuration file) or individually by using the 
	ColdBox URL action: <i>index.cfm?debugmode=true&debugpass={your debug password here}</i>.
	</p>
	<p style="text-align: center">
		<input type="button" value="Turn Debug Mode On" onClick="window.location='index.cfm?debugmode=true&debugpass=#getSetting('DebugPassword')#'" />
		&nbsp;
		<input type="button" value="Turn Debug Mode Off" onClick="window.location='index.cfm?debugMode=false&debugpass=#getSetting('DebugPassword')#'"/>
	</p>
</div>
</cfoutput>