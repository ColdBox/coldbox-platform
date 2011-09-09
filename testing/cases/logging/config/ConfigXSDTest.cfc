<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){	
		xsd = expandPath("/coldbox/system/logging/config/LogBoxConfig.xsd");
	}

	function testGoodXSD(){
		xml = xmlParse( expandPath("/coldbox/testing/cases/logging/config/samples/Sample.LogBox.xml") );
		
		results = xmlValidate(xml, xsd);
		
		debug(results);
		assertEquals( true, results.status);
		
	}
	
	function testBadXSD(){
		xml = xmlParse( expandPath("/coldbox/testing/cases/logging/config/samples/bad.logbox.xml") );
		
		results = xmlValidate(xml, xsd);
		
		debug(results);
		assertEquals( false, results.status);
		
	}
</cfscript>
</cfcomponent>