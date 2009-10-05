<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	function setup(){
		flash = getMockBox().createMock("coldbox.system.web.flash.ClientFlash");
		mockController = getMockBox().createMock(className="coldbox.system.web.Controller");
		converter = getMockBox().createMock(className="coldbox.system.core.util.conversion.ObjectMarshaller").init();
		flash.init(mockController);
		obj = createObject("component","coldbox.system.core.util.CFMLEngine").init();
		//test scope
		testscope = {test="luis",date=now(),obj=obj};
	}	
	function teardown(){ 
		structClear(client);
	}
	function testClearFlash(){
		client[flash.getFlashKey()] = converter.serializeObject(testscope);
		flash.clearFlash();
		assertFalse( structKeyExists(client,flash.getFlashKey()) );
	}
	function testSaveFlash(){
		flash.$("getScope",testscope);
		flash.saveFlash();
		assertTrue( len(client[flash.getFlashKey()]) );
	}
	function testFlashExists(){
		assertFalse( flash.flashExists() );
		client[flash.getFlashKey()] = "NADA";
		assertTrue( flash.flashExists() );
	}
	function testgetFlash(){
		assertEquals( flash.getFlash(), structNew());
		
		client[flash.getFlashKey()] = converter.serializeObject(testscope);
		assertEquals( flash.getFlash(), testScope);
	}
</cfscript>
</cfcomponent>