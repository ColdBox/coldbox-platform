<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	March 05 2008
Description :	Home Page.
----------------------------------------------------------------------->

<h1>Cookie Storage Plugin:</h1>
<p>This is a plugin that enables the setting/getting of permanent variables in the cookie scope. (cookiestorage.cfc)</p>
<br />
<p>
coldbox.xml.cfm these setting should be there to activate the encryption in cookiestore plugin.<br />
<cfsavecontent variable="hText">
<!-- whether to encrypt the values or not -->
<Setting name="cookiestorage_encryption" value="true"/>
<!-- The encryption seed to use. Else, use a default one (Not Recommened) -->
<Setting name="cookiestorage_encryption_seed" value="MyCF8AjaxKey"/>
<!-- The encryption algorithm to use (According to CFML Engine) -->
<Setting name="cookiestorage_encryption_algorithm" value="CFMX_COMPAT"/>
</cfsavecontent>
<pre>
	<cfset writeoutput(htmlEditFormat(hText)) />
</pre>
</p>

<p>
	This here is dump of struct which was stored in Cookie-Scope. <br />
	<pre><cfset writeoutput("rc.plugin.getVar('UserInfo')")></pre>
	<cfdump var="#rc.plugin.getVar('UserInfo')#" label="Stored CF-Struct in Cookie scope">
	<cfoutput>#RepeatString('<br />',4)#</cfoutput>
	<h3>A simple value stored in cookie.</h3><hr>
	<cfoutput><strong> "" #rc.plugin.getVar('SimpleValue')# "" </strong></cfoutput>
</p>

<br /><br />

<p>
	Clear the Cookie-Scope Storage.<br />
	<pre><cfset writeoutput("rc.plugin.deleteVar('UserInfo')")></pre>
	<!--- Clear All stored objects / values --->
	<cfset rc.plugin.deleteVar('UserInfo') />
	
	<cfset rc.plugin.deleteVar('SimpleValue') />
</p>

<br /><br />

<p>
	The values should be empty because we already have cleared/deleted the cookie.
	<br />
	<pre><cfset writeoutput("rc.plugin.exists('UserInfo')")></pre>
	<!--- Get All stored objects/values --->
	<cfdump var="#rc.plugin.exists('MyTestComp')#" label="this should be false now">
</p>