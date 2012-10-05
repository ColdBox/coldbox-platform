<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	this.loadColdBox = false;
	function setup(){
		flash = getMockBox().createMock("coldbox.system.web.flash.ClusterFlash");
		mockController = getMockBox().createMock(className="coldbox.system.web.Controller",clearMethods=true);
		mockController.$("getAppHash",hash(now()));
		flash.init(mockController);
		
		//test scope
		testscope = {
			test={content="luis",autoPurge=true,keep=true},
			date={content=now(),autoPurge=true,keep=true}
		};
	}	
	function teardown(){ 
		//structClear(cluster);
	}
	function testClearFlash(){
		cluster[flash.getFlashKey()] = testscope;
		flash.clearFlash();
		assertTrue( structIsEmpty(cluster[flash.getFlashKey()]));
	}
	function testSaveFlash(){
		flash.$("getScope",testscope);
		flash.saveFlash();
		assertEquals( cluster[flash.getFlashKey()], testscope );
	}
	function testFlashExists(){
		assertFalse( flash.flashExists() );
		cluster[flash.getFlashKey()] = testscope;
		assertTrue( flash.flashExists() );
	}
	function testgetFlash(){
		assertEquals( flash.getFlash(), structNew());
		
		cluster[flash.getFlashKey()] = testscope;
		assertEquals( flash.getFlash(), testScope);
	}
</cfscript>
</cfcomponent>