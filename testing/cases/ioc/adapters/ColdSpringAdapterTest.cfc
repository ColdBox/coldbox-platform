<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>

	function setup(){
		adapter = getMockBox().createMock("coldbox.system.ioc.adapters.ColdSpringAdapter");
	}

	function creationTest(){
		adapter.init(definitionFile=expandPath('/coldbox/testing/cases/ioc/adapters/resources/coldspring.xml.cfm'));
		adapter.createFactory();
		
		assertEquals( false, adapter.containsBean('funkyObject') );
		assertEquals( true, adapter.containsBean('testService') );
		
		assertEquals( true, isObject(adapter.getBean('testService')) );
		
		parent = getMockBox().createMock("coldbox.system.ioc.adapters.ColdSpringAdapter");
		parent.init(definitionFile=expandPath('/coldbox/testing/cases/ioc/adapters/resources/coldspring.xml.cfm'));
		parent.createFactory();
		adapter.setParentFactory( parent.getFactory() );
		assertEquals( parent.getFactory(), adapter.getParentFactory() );
	}
</cfscript>	
</cfcomponent>