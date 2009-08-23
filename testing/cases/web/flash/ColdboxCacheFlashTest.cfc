<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	function setup(){
		flash = getMockBox().createMock("coldbox.system.web.flash.ColdboxCacheFlash");
		mockController = getMockBox().createMock(className="coldbox.system.Controller",clearMethods=true);
		mockCache = getMockBox().createMock(className="coldbox.system.cache.CacheManager",clearMethods=true);
		mockController.$("getColdboxOCM",mockCache);
		
		flash.init(mockController);
		
		//test scope
		testscope = {test="luis",date=now()};
	}	
	function testClearFlash(){
		flash.$("flashExists",true);
		mockCache.$("clear");
		flash.clearFlash();
		assertTrue( arrayLen(mockCache.$callLog().clear) );
	}
	function testSaveFlash(){
		flash.$("getScope",testscope);
		mockCache.$("set",true);
		flash.saveFlash();
		assertTrue( arrayLen(mockCache.$callLog().set) );
	}
	function testFlashExists(){
		mockCache.$("lookup",true);
		assertTrue(flash.flashExists());
	}
	function testgetFlash(){
		flash.$("flashExists",false);
		assertEquals( flash.getFlash(), structnew());
		
		flash.$("flashExists",true);
		mockCache.$("get",testScope);
		assertEquals( flash.getFlash(), testScope);
		
	}
</cfscript>
</cfcomponent>