<cfcomponent output="false" extends="coldbox.system.testing.BaseTestCase">
<cfscript>

	function setup(){
		test = getMockBox().createEmptyMock("coldbox.testing.cases.testing.Test");
	}
	
	function testVerifyCallCount(){
		test.$("displayData",queryNew(''));
		assertTrue( test.$verifyCallCount(0) );
		assertFalse( test.$verifyCallCount(1) );
		
		test.displayData();
		assertEquals(true,  test.$verifyCallCount(1));
		
		test.displayData();
		test.displayData();
		test.displayData();
		assertEquals(true,  test.$verifyCallCount(4));
		assertEquals(true,  test.$verifyCallCount(4,"displayData"));
	}
	
	function testMockMethodCallCount(){
		test.$("displayData",queryNew(''));
		test.$("getLuis",1);
		
		assertEquals(0, test.$count("displayData") );
		assertEquals(-1, test.$count("displayData2") );
		
		test.displayData();
		
		assertEquals(1, test.$count("displayData") );
		
		test.getLuis();test.getLuis();
		assertEquals(3, test.$count() );
	}
	
	function testMethodArgumentSignatures(){
		//1: Mock with positional and all calls should validate.
		test.$("getSetting").$args("test","23").$results("UnitTest");
	
		// Test positional
		results = test.getSetting("test","23");
		assertEquals( "UnitTest", results );
		// Test name-value pairs
		results = test.getSetting(name="test",testArg="23");
		assertEquals( "UnitTest", results );
		// Test argCollection
		args = {name="test", testArg="23"};
		results = test.getSetting(argumentCollection=args);
		assertEquals( "UnitTest", results );
		
		
		//2. Mock with named values and all calls should validate.
		test.$("getSetting").$args(name="test",testArg="23").$results("UnitTest2");
	
		// Test positional
		results = test.getSetting("test","23");
		assertEquals( "UnitTest2", results );
		// Test name-value pairs
		results = test.getSetting(name="test",testArg="23");
		assertEquals( "UnitTest2", results );
		// Test argCollection
		args = {name="test", testArg="23"};
		results = test.getSetting(argumentCollection=args);
		assertEquals( "UnitTest2", results );
		
		//3. Mock with argument Collections
		args = {name="test", testArg="23"};
		test.$("getSetting").$args(argumentCollection=args).$results("UnitTest3");
	
		// Test positional
		results = test.getSetting("test","23");
		assertEquals( "UnitTest3", results );
		// Test name-value pairs
		results = test.getSetting(name="test",testArg="23");
		assertEquals( "UnitTest3", results );
		// Test argCollection
		args = {name="test", testArg="23"};
		results = test.getSetting(argumentCollection=args);
		assertEquals( "UnitTest3", results );
		
	}
	
</cfscript>
</cfcomponent>