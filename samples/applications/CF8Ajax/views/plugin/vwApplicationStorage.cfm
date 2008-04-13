<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	March 05 2008
Description :	Home Page.
----------------------------------------------------------------------->

<p>Here is values which we set in ehPlugin</p>
<cfdump var="#rc.plugin.getVar('MyTestComp')#" label="Stored CFC object in Application scope">

<!--- Clear All stored objects / values --->
<cfset rc.plugin.ClearAll() /><br /><br />

<!--- Get All stored objects/values --->
<cfdump var="#rc.plugin.exists('MyTestComp')#" label="this should be false now">

