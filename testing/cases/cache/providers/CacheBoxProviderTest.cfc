<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	Request service Test
----------------------------------------------------------------------->
<cfcomponent name="cacheTest" extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>

	function setup(){
		cache = getMockBox().createMock("coldbox.system.cache.providers.CacheBoxProvider").init();
	}
	
	function testConfigure(){
	
	}


</cfscript>
</cfcomponent>