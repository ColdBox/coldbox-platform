<cfsetting enablecfoutputonly="true">
<cfoutput>FW Startup Time: #request.fwLoadTIme# ms   #request.fwLoadTime/1000# s<br></cfoutput>

<cfdump var="#application.cbcontroller.getConfigSettings()#" label="App Config Settings" expand="false">
<cfdump var="#application.cbcontroller.getColdboxSettings()#" label="App Config Settings" expand="false">

<cfsetting enablecfoutputonly="false">