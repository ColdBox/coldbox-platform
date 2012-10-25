<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	this.loadColdBox = false;
	function setup(){
		flash = getMockBox().createMock("coldbox.system.web.flash.ClientFlash");
		mockController = getMockBox().createMock(className="coldbox.system.web.Controller");
		converter = getMockBox().createMock(className="coldbox.system.core.conversion.ObjectMarshaller").init();
		
		flash.init(mockController);
		
		obj = createObject("component","coldbox.system.core.cf.CFMLEngine").init();
		
		//test scope
		testscope = {
			test={content="luis",autoPurge=true,keep=true},
			date={content=now(),autoPurge=true,keep=true},
			obj={content=obj,autoPurge=true,keep=true}
		};
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
		
		client[flash.getFlashKey()] = converter.serializeObject( testscope );
		
		assertEquals( flash.getFlash(), testScope);
	}
</cfscript>
</cfcomponent>