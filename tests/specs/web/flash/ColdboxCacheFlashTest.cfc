component extends="coldbox.system.testing.BaseTestCase"{

	this.loadColdBox = false;
	
	function setup(){

		// mocks
		url.cfid = 123;
		url.cftoken = createUUID();

		flash = getMockBox().createMock("coldbox.system.web.flash.ColdboxCacheFlash");
		mockController = getMockBox().createMock(className="coldbox.system.web.Controller",clearMethods=true);
		mockCache = getMockBox().createMock(className="coldbox.system.cache.providers.CacheBoxProvider",clearMethods=true);
		mockController.$("getCache",mockCache).$("settingExists",false);

		flash.init(mockController);
		obj = createObject("component","coldbox.system.core.util.CFMLEngine").init();

		//test scope
		testscope = {
			test={content="luis",autoPurge=true,keep=true},
			date={content=now(),autoPurge=true,keep=true},
			obj={content=obj,autoPurge=true,keep=true}
		};
	}
	function testClearFlash(){
		flash.$("flashExists",true);
		mockCache.$("clear").$("get",testScope);
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
		mockCache.$("get",testScope);
		flash.$("flashExists",true);
		assertEquals( flash.getFlash(), testScope);

	}

}