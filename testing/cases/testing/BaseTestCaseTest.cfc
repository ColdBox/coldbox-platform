<cfcomponent output="false" extends="mxunit.framework.TestCase">
<cfscript>

	function setup(){
		mockBox = createObject("component","coldbox.system.testing.MockBox").init();
		test = mockBox.createMock("coldbox.system.testing.BaseTestCase");
	}
	
	function testgetMockDatasource(){
		makePublic(test,"getMockDatasource");
		dsn = test.getMockDatasource(name="dbtest");
		assertTrue( isObject(dsn) );
		debug( dsn.getMemento() );
		assertEquals( "dbtest", dsn.getName() );
		assertEquals( "dbtest", dsn.getAlias() );
	}
	
	function testgetMockConfigBean(){
		makePublic(test,"getMockConfigBean");
		data = {
			today = now(),
			name = "Luis Majano",
			test = this
		};
		config = test.getMockConfigBean(data);
		assertTrue( isObject(config) );
		//debug( config.getConfigStruct() );
		assertEquals( data.today, config.getKey("today") );
		assertEquals( data.name , config.getKey("name") );
	}
		
</cfscript>
</cfcomponent>