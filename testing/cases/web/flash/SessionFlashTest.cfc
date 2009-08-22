<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	function setup(){
		flash = getMockBox().createMock("coldbox.system.web.flash.SessionFlash");
		mockController = getMockBox().createMock(className="coldbox.system.Controller");
		flash.init(mockController);
		
		//test scope
		testscope = {test="luis",date=now()};
	}	
	function teardown(){ 
		structClear(session);
	}
	function testIsStorageAttached(){
		makePublic(flash,"isStorageAttached");
		assertFalse(flash.isStorageAttached());
		
		session[flash.getFlashKey()] = structnew();
		assertTrue(flash.isStorageAttached());
	}
	function testEnsureStorage(){
		makePublic(flash,"ensureStorage");
		storage = flash.ensurestorage();
		assertTrue( structIsEmpty(storage) );
	}
	function testGetScope(){
		//mock not attached
		flash.$("isStorageAttached",false);
		assertEquals( flash.getScope(), structnew());
		// not mock true;
		flash.$("isStorageAttached",true);
		session[flash.getFlashKey()] = testScope;
		assertEquals( flash.getScope(), testscope );
	}
	function testScopeMethods(){
		// test init states
		assertTrue( flash.isEmpty() );
		assertEquals( flash.size(), 0);
		// put objects
		flash.put("name","luis majano");
		flash.put("tester",structnew());
		flash.put("obj",this);
		// assert them
		assertEquals( flash.size(),3);
		assertFalse( flash.isEmpty() );
		// Exists
		assertTrue( flash.exists("name") );
		assertTrue( flash.exists("tester") );
		assertTrue( flash.exists("obj") );
		// Get Keys
		assertTrue( len(flash.getKeys()) );
		// Get's
		assertEquals( flash.get("name"), "luis majano");
		assertEquals( flash.get("tester"), structnew());
		assertEquals( flash.get("obj"), this);
		assertEquals( flash.get("obj2",this), this);
		// remove
		flash.remove("name");
		assertfalse( flash.exists("name") );
		// clear
		flash.clear();
		assertTrue( flash.isEmpty() );
		
		// put all
		flash.putAll(testscope);
		assertTrue( flash.exists("test") );
		assertTrue( flash.exists("date") );
		
	}
</cfscript>
</cfcomponent>