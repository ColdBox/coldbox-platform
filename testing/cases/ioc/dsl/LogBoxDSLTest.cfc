<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		mockLogger = getMockBox().createEmptyMock("coldbox.system.logging.Logger").$("canDebug",true).$("debug").$("error").$("canWarn",true).$("warn");
		mockRoot   = getMockBox().createEmptymock("coldbox.system.logging.Logger");
		mockLogBox = getMockBox().createEmptyMock("coldbox.system.logging.LogBox")
			.$("getLogger", mockLogger)
			.$("getRootLogger", mockRoot);
		mockInjector = getMockBox().createEmptyMock("coldbox.system.ioc.Injector")
			.$("getLogbox", mockLogBox.$("getLogger", mockLogger) )
			.$("getLogBox", mockLogBox );
			
		builder = getMockBox().createMock("coldbox.system.ioc.dsl.LogBoxDSL").init( mockInjector );
	}
	
	function testProcess(){
		// logbox
		def = {dsl="logbox"};
		r = builder.process(def);
		assertEquals( mockLogBox, r);
		
		// logbox:root
		def = {dsl="logbox:root"};
		r = builder.process(def);
		assertEquals( mockRoot, r);
		
		// logbox:logger with name
		def = {dsl="logbox:logger",name="myHello"};
		r = builder.process(def);
		assertEquals( mockLogger, r);
		//debug(mockLogBox.$callLog().getLogger);
		callArgs = mockLogBox.$callLog().getLogger[2];
		assertEquals( "myHello", callArgs.1 );
		
		// logbox:logger:custom
		def = {dsl="logbox:logger:hello"};
		r = builder.process(def);
		assertEquals( mockLogger, r);
		
		// logbox:logger:{this}
		def = {dsl="logbox:logger:{this}"};
		r = builder.process(def, this);
		callArgs = mockLogBox.$callLog().getLogger[4];
		assertEquals( this, callArgs.1 );
		//debug( mockLogBox.$callLog().getLogger[3] );
	}
	
	
</cfscript>
</cfcomponent>