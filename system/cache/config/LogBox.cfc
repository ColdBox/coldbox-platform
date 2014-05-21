<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The logging configuration object for CacheBox Standalone version.
	You can make changes here to determine how CacheBox logs information.  For more
	information about logBox visit: http://wiki.coldbox.org/wiki/LogBox.cfm

----------------------------------------------------------------------->
<cfcomponent output="false" hint="A LogBox Configuration Data Object for standalone version of CacheBox">
<cfscript>
	/**
	*  Configure logBox
	*/
	function configure(){
		logBox = {
			// Define Appenders
			appenders = {
				console = { 
					class="coldbox.system.logging.appenders.ConsoleAppender"
				},
				cflogs = {
					class="coldbox.system.logging.appenders.CFAppender",
					properties = { fileName="ColdBox-CacheBox"}
				}
			},
			// Root Logger
			root = { levelmax="INFO", appenders="*" }
		};
	}
</cfscript>
</cfcomponent>
