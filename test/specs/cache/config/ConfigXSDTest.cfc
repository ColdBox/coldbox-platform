<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){	
		cacheboxXSD = expandPath("/coldbox/system/cache/config/CacheBoxConfig.xsd");
	}

	function testGoodXSD(){
		xml = xmlParse( expandPath("/coldbox/testing/cases/cache/config/samples/Sample.CacheBox.xml") );
		
		results = xmlValidate(xml, cacheboxXSD);
		
		debug(results);
		assertEquals( true, results.status);
		
	}
	
	function testBadXSD(){
		xml = xmlParse( expandPath("/coldbox/testing/cases/cache/config/samples/Bad.CacheBox.xml") );
		
		results = xmlValidate(xml, cacheboxXSD);
		
		debug(results);
		assertEquals( false, results.status);
		
	}
</cfscript>
</cfcomponent>