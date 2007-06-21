<cfsetting enablecfoutputonly="true">
<!-----------------------------------------------------------------------
Template :  index.cfm
Author 	 :	Luis Majano
Date     :	September 15, 2005
Description :
	This is the index file of your application. This template just needs
	a cfinclude to the frameworks coldbox file.

Modification History:

----------------------------------------------------------------------->

<cfinclude template="system/coldbox.cfm">

<cfdump var="#application.cbcontroller.getConfigSettings()#" label="App Config Settings">
<cfsetting enablecfoutputonly="false">