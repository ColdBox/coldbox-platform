component extends="BaseTest" {

/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeTests(){
		application.salvador = 1;
	}

	function afterTests(){
		structClear( application );
	}

	function setup(){
		request.foo = 1;
	}

	function teardown(){
		structClear( request );
	}

/*********************************** Test Methods ***********************************/
	
	function testFails(){
		fail( "This Test should fail" );
	}

	function testAssert() {
		assert( application.salvador == 1 );
		assertEquals( 1, request.foo );
	}

	function testAssertArrayEquals() {
		var today = now();
		assertArrayEquals( [1,2,3], [1,2,3] );
		assertArrayEquals( [1,2,3, today, { name="luis", awesome=true } ], [1,2,3, today, { name="luis", awesome=true } ] );
	}

	function testAssertEquals() {
		assertEquals(4, 4);
		assertEquals( { name="luis", awesome=true }, { name="luis", awesome=true } );
		assertEquals( "hello", "Hello" );
		assertArrayEquals( [1,2,3], [1,2,3] );
	}

	function testAssertEqualsCase() {
		assertEqualsCase( "hello", "hello" );
	}

	function testassertFalse() {
		assertFalse( false );
	}

	function testassertNotEquals() {
		assertNotEquals( "hello", "there" );
	}

	function testassertNotSame() {
		assertNotSame( this, createObject("component", "coldbox.system.testing.MockBox") );
	}

	function testassertQueryEquals() {
		var q1 = querySim( "id, name
			1 | luis majano
			2 | alexia majano
			3 | lucas majano");

		var q2 = querySim( "id, name
			1 | luis majano
			2 | alexia majano
			3 | lucas majano");

		assertQueryEquals( q1, q2 );
	}

	function testassertSame(){
		assertSame( this, this );
	}

	function testassertStructEquals() {
		assertSame( { name="luis", awesome=true }, { name="luis", awesome=true } );
	}

	function testAssertTrue() {
		assertTrue( true );
	}
	
	function nonStandardNamesWillNotRun() {
		fail( "Non-test methods should not run" );
	}

	function testDebug(){
		debug( "Hello from TestBox" );
	}

	/**
	* @mxunit:expectedException
	*/
	function testExpectedExceptionNoValue(){
		// This method should throw an invalid exception and pass
		throw( type="InvalidException", message="This test method should pass with an expected exception" );
	}

	/**
	* @mxunit:expectedException InvalidException
	*/
	function testExpectedExceptionWithValue(){
		// This method should throw an invalid exception and pass
		throw( type="InvalidException", message="This test method should pass with an expected exception of type InvalidException" );
	}

	function testExpectedExceptionFromMethodWithType(){
		expectedException( "InvalidException" );
		// This method should throw an invalid exception and pass
		throw( type="InvalidException", message="This test method should pass with an expected exception" );
	}

	function testExpectedExceptionFromMethodWithTypeAndRegex(){
		expectedException( "InvalidException", "(pass with an)" );
		// This method should throw an invalid exception and pass
		throw( type="InvalidException", message="This test method should pass with an expected exception" );
	}

	function testMakePublic(){
		t = new coldbox.testing.resources.test1();
		assertTrue( makePublic( t, "aPrivateMethod" ).aPrivateMethod() );
		assertTrue( makePublic( t, "aPrivateMethod", "funkyMethod" ).funkyMethod() );
	}

	private function privateMethodsDontRun() {
		fail( "Private method don't run" );
	}

}