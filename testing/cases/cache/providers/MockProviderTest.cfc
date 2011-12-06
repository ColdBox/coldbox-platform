<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>

	function setup(){
		cp = getMockBox().createMock("coldbox.system.cache.providers.MockProvider").init();
		cp.configure();
	}
	
	function testMethods(){
		cp.set("test",1);
		assertEquals( 1, cp.get("test") );
		assertEquals( true, cp.lookup("test") );
		assertEquals( true, cp.lookupValue(1) );
		assertEquals( 1, cp.getSize() );
		cp.clearAll();
		assertEquals( 0, cp.getSize() );
		
		cp.set("test",1);
		cp.clear("test");
		assertEquals( 0, cp.getSize() );
		
	}


</cfscript>
</cfcomponent>