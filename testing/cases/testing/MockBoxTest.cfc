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
	
</cfscript>
</cfcomponent>