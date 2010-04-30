<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Description :
	The default ColdBox CacheBox configuration object that is used when the
	cache factory is created
----------------------------------------------------------------------->
<cfcomponent output="false" hint="The default ColdBox CacheBox configuration">
<cfscript>
	
	/**
	* Configure CacheBox, that's it!
	*/
	function configure(){
		
		// Default Cache Configuration
		cacheBox = {
		
		};
	}
	
</cfscript>
</cfcomponent>