<cfcomponent output="false" extends="mxunit.framework.TestCase">
<cfscript>

	function setup(){
		mockBox = createObject("component","coldbox.system.testing.MockBox").init();
		test = mockBox.createMock("coldbox.system.testing.BaseTestCase");
	}
	
	function testGetMockRequestContext(){
		makePublic(test,"getMockRequestContext");
		rc = test.getMockRequestContext();
		assertTrue( isObject(rc) );
		
		rc = test.getMockRequestContext(true,'coldbox.testharness.model.myRequestContextDecorator');
		assertTrue( isObject(rc) );	
		
		rc = test.getMockRequestContext(false,'coldbox.testharness.model.myRequestContextDecorator');
		assertTrue( isObject(rc) );	
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
		
	function testgetMockRequestBuffer(){
		makePUblic( test, "getMockRequestBuffer");
		r = test.getMockRequestBuffer();
		assertEquals( "coldbox.system.core.util.RequestBuffer", getMetadata(r).name );
	}
	
	function testGetMockController(){
		makePUblic( test, "getMockController");
		r = test.getMockController();
		assertEquals( "coldbox.system.testing.mock.web.MockController", getMetadata(r).name );
	}
</cfscript>
</cfcomponent>