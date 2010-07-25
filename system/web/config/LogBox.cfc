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

It is configured to log up to INFO via ConsoleAppender
----------------------------------------------------------------------->
<cfcomponent output="false" hint="The default ColdBox LogBox Configuration Data Object">
<cfscript>
	/**
	* Configure LogBox, that's it!
	*/
	function configure(){
		logBox = {
			// Define Appenders
			appenders = {
				console = { 
					class="coldbox.system.logging.appenders.ConsoleAppender"
				}
			},
			// Root Logger
			root = { levelmax="INFO", levelMin="FATAL", appenders="*" }
		};
	}
</cfscript>
</cfcomponent>
