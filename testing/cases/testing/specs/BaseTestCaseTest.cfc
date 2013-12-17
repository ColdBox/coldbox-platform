<cfcomponent output="false" extends="coldbox.system.testing.BaseSpec">
<cfscript>

	function setup(){
		mockBox = createObject("component","coldbox.system.testing.MockBox").init();
		test = mockBox.createMock("coldbox.system.testing.BaseTestCase");
	}
	
	function testGetMockRequestContext(){
		makePublic(test,"getMockRequestContext");
		rc = test.getMockRequestContext();
		$assert.isTrue( isObject(rc) );
		
		rc = test.getMockRequestContext(true,'coldbox.test-harness.model.myRequestContextDecorator');
		$assert.isTrue( isObject(rc) );	
		
		rc = test.getMockRequestContext(false,'coldbox.test-harness.model.myRequestContextDecorator');
		$assert.isTrue( isObject(rc) );	
	}
	
	function testgetMockDatasource(){
		makePublic(test,"getMockDatasource");
		dsn = test.getMockDatasource(name="dbtest");
		$assert.isTrue( isObject(dsn) );
		debug( dsn.getMemento() );
		$assert.isEqual( "dbtest", dsn.getName() );
		$assert.isEqual( "dbtest", dsn.getAlias() );
	}
	
	function testgetMockConfigBean(){
		makePublic(test,"getMockConfigBean");
		data = {
			today = now(),
			name = "Luis Majano",
			test = this
		};
		config = test.getMockConfigBean(data);
		$assert.isTrue( isObject(config) );
		//debug( config.getConfigStruct() );
		$assert.isEqual( data.today, config.getKey("today") );
		$assert.isEqual( data.name , config.getKey("name") );
	}
		
	function testgetMockRequestBuffer(){
		makePUblic( test, "getMockRequestBuffer");
		r = test.getMockRequestBuffer();
		$assert.isEqual( "coldbox.system.core.util.RequestBuffer", getMetadata(r).name );
	}
	
	function testGetMockController(){
		makePUblic( test, "getMockController");
		r = test.getMockController();
		$assert.isEqual( "coldbox.system.testing.mock.web.MockController", getMetadata(r).name );
	}
</cfscript>
</cfcomponent>