<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>

	function setup(){
		adapter = getMockBox().createMock("coldbox.system.ioc.adapters.WireBoxAdapter");
	}

	function creationTest(){
		adapter.init(definitionFile="coldbox.testing.cases.ioc.adapters.resources.WireBox");
		adapter.createFactory();
		
		//assertEquals( false, adapter.containsBean('funkyObject') );
		assertEquals( true, adapter.containsBean('testService') );
		
		assertEquals( true, isObject(adapter.getBean('testService')) );
		
		parent = getMockBox().createMock("coldbox.system.ioc.adapters.WireBoxAdapter");
		parent.init(definitionFile="coldbox.testing.cases.ioc.adapters.resources.WireBox");
		parent.createFactory();
		adapter.setParentFactory( parent.getFactory() );
		assertEquals( parent.getFactory(), adapter.getParentFactory() );
	}

</cfscript>	
</cfcomponent>