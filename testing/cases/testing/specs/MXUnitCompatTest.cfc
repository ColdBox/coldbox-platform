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
	}

	function testAssertArrayEquals() {
		assertArrayEquals();
	}

	function testAssertEquals() {
		assertEquals();
	}

	function testassertEqualsCase() {
		assertEqualsCase();
	}

	function testassertFalse() {
		assertFalse();
	}

	function testassertNotEquals() {
		assertNotEquals();
	}

	function testassertNotSame() {
		assertNotSame();
	}

	function testassertQueryEquals() {
		assertQueryEquals();
	}

	function testassertSame() {
		assertSame();
	}

	function testassertStructEquals() {
		assertSame();
	}

	function testAssertTrue() {
		assertSame();
	}
	
	function nonStandardNamesWillNotRun() {
		fail( "Non-test methods should not run" );
	}

	function testDebug(){
		debug( "Hello from TestBox" );
	}

	function testExpectException(){
		expectException();
	}

	private function privateMethodsDontRun() {
		fail( "Private method don't run" );
	}

}