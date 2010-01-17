<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	  : Luis Majano
Date        : 06/20/2009
Description :
 Base Test case for Plugins
---------------------------------------------------------------------->
<cfcomponent name="BasePluginTest" 
			 output="false" 
			 extends="coldbox.system.testing.BaseTestCase"
			 hint="A base test for testing plugins">

	<cfscript>
		this.loadColdbox = false;	
	</cfscript>

</cfcomponent>