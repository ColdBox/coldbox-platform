<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	March 05 2008
Description :	Home Page.
----------------------------------------------------------------------->

<h1>Session Storage Plugin:</h1>
<p>This is a plugin that enables the setting/getting of permanent variables in the session scope. (sessionstorage.cfc)</p>
<br />

<p>
	This here is dump of cfc object which are stored in Application-Scope. <br />
	<pre><cfset writeoutput("rc.plugin.getVar('MyTestComp')")></pre>
	<cfdump var="#rc.plugin.getVar('MyTestComp')#" label="Stored CFC object in Session scope">
</p>

<br /><br />

<p>
	Clear the Session-Scope Storage.<br />
	<pre><cfset writeoutput("rc.plugin.ClearAll()")></pre>
	<!--- Clear All stored objects / values --->
	<cfset rc.plugin.ClearAll() />
</p>

<br /><br />

<p>
	The values should be empty because we already have cleared the Session-Scope Storage.
	<br />
	<pre><cfset writeoutput("rc.plugin.exists('MyTestComp')")></pre>
	<!--- Get All stored objects/values --->
	<cfdump var="#rc.plugin.exists('MyTestComp')#" label="this should be false now">
</p>