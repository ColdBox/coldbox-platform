<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>

	function setup(){
		adapter = getMockBox().createMock("coldbox.system.ioc.adapters.LightWireAdapter");
	}

	function creationTest(){
		adapter.init(definitionFile="coldbox.testing.cases.ioc.adapters.resources.BeanConfig");
		adapter.createFactory();
		
		assertEquals( false, adapter.containsBean('funkyObject') );
		assertEquals( true, adapter.containsBean('testService') );
		
		assertEquals( true, isObject(adapter.getBean('testService')) );
		
		parent = getMockBox().createMock("coldbox.system.ioc.adapters.LightWireAdapter");
		parent.init(definitionFile="coldbox.testing.cases.ioc.adapters.resources.BeanConfig");
		parent.createFactory();
		adapter.setParentFactory( parent.getFactory() );
		assertEquals( parent.getFactory(), adapter.getParentFactory() );
	}
	
	function creationXMLTest(){
		adapter.init(definitionFile=expandPath('/coldbox/testing/cases/ioc/adapters/resources/coldspring.xml.cfm'));
		adapter.createFactory();
		
		assertEquals( false, adapter.containsBean('funkyObject') );
		assertEquals( true, adapter.containsBean('testService') );
		
		assertEquals( true, isObject(adapter.getBean('testService')) );
	}
</cfscript>	
</cfcomponent>