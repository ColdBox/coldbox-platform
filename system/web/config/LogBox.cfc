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
		logBox = {};
		
		// Define Appenders
		logBox.appenders = {
			console = { class="coldbox.system.logging.appenders.DummyAppender" }
		};
		
		// Root Logger
		logBox.root = {
			levelmax="OFF",
			levelMin="OFF",
			appenders="*"
		};
	}
</cfscript>
</cfcomponent>
