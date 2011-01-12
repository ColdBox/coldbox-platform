<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
This is the Default ColdBox LogBox Configuration for immediate operation 
of ColdBox once it loads.  Once the configuration file is read then the
LogBox instance is reconfigured with the user settings, if used at all.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="The default ColdBox LogBox Configuration Data Object">
<cfscript>
	/**
	* Configure LogBox, that's it!
	*/
	function configure(){
		// Have to do it cf7 style until we kill it in 3.1
		logBox = structnew();
		
		// Define Appenders
		logBox.appenders = structnew();
		logBox.appenders.console.class="coldbox.system.logging.appenders.DummyAppender";
		
		// Root Logger
		logBox.root = structnew();
		logBox.root.levelmax="OFF";
		logBox.root.levelMin="OFF";
		logBox.root.appenders="*";		
	}
</cfscript>
</cfcomponent>
