component displayName="TestBox xUnit suite" labels="railo,cf"{

/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		application.salvador = 1;
	}

	function afterAll(){
		structClear( application );
	}

	function beforeEach(){
		request.foo = 1;
	}

	function afterEach(){
		structClear( request );
	}

/*********************************** Test Methods ***********************************/

	function testSkipped() skip{
		$assert.fail( "This Test should fail" );
	}

	boolean function isRailo(){
		return true;
	}

	function testSkippedWithConstraint() skip="isRailo"{
		$assert.fail( "This Test should fail" );
	}

	function testFails(){
		//$assert.fail( "This Test should fail" );
	}

	function testFailsShortcut() labels="railo"{
		//fail( "This Test should fail" );
	}

	function testAssert() {
		$assert.assert( application.salvador == 1 );
	}

	function testAssertShortcut() {
		assert( application.salvador == 1 );
	}

	function testisTrue() {
		$assert.isTrue( 1 );
	}

	function testisFalse() {
		$assert.isFalse( 0 );
	}

	function testisEqual() {
		$assert.isEqual( 0, 0 );
		$assert.isEqual( "hello", "HEllO" );
		$assert.isEqual( [], [] );
		$assert.isEqual( [1,2,3, {name="hello", test="this"} ], [1,2,3, {test="this", name="hello"} ] );
	}

	function testisNotEqual() {
		$assert.isNotEqual( this, new coldbox.system.testing.MockBox() );
		$assert.isNotEqual( "hello", "test" );
		$assert.isNotEqual( 1, 2 );
		$assert.isNotEqual( [], [1,3] );
	}

	function testisEqualWithCase() {
		$assert.isEqualWithCase( "hello", "hello" );
	}

	function testnullValue() {
		$assert.null( javaCast("null", "") );
	}

	function testNotNullValue() {
		$assert.notNull( 44 );
	}

	function testTypeOf() {
		$assert.typeOf( "array", [ 1,2 ] );
		$assert.typeOf( "boolean", false );
		$assert.typeOf( "component", this );
		$assert.typeOf( "date", now() );
		$assert.typeOf( "time", timeformat( now() ) );
		$assert.typeOf( "float", 1.1 );
		$assert.typeOf( "numeric", 1 );
		$assert.typeOf( "query", querySim( "id, name
			1 | luis") );
		$assert.typeOf( "string", "hello string" );
		$assert.typeOf( "struct", { name="luis", awesome=true } );
		$assert.typeOf( "uuid", createUUID() );
		$assert.typeOf( "url", "http://www.coldbox.org" );
	}

	function testNotTypeOf() {
		$assert.notTypeOf( "array", 1 );
		$assert.notTypeOf( "boolean", "hello" );
		$assert.notTypeOf( "component", {} );
		$assert.notTypeOf( "date", "monday" );
		$assert.notTypeOf( "time", "1");
		$assert.notTypeOf( "float", "Hello" );
		$assert.notTypeOf( "numeric", "eeww2" );
		$assert.notTypeOf( "query", [] );
		$assert.notTypeOf( "string", this );
		$assert.notTypeOf( "struct", [] );
		$assert.notTypeOf( "uuid", "123" );
		$assert.notTypeOf( "url", "coldbox" );
	}

	function testInstanceOf() {
		$assert.instanceOf( new coldbox.system.testing.MockBox(), "coldbox.system.testing.MockBox" );
	}

	function testNotInstanceOf() {
		$assert.notInstanceOf( this, "coldbox.system.testing.MockBox" );
	}

	function testMatch(){
		$assert.match( "This testing is my test", "(TEST)$" );
	}

	function testMatchWithCase(){
		$assert.match( "This testing is my test", "(test)$" );
	}

	function testNotMatch(){
		$assert.notMatch( "This testing is my test", "(hello)$" );
	}

	function testKey(){
		$assert.key( {name="luis", awesome=true}, "awesome" );
	}

	function testNotKey(){
		$assert.notKey( {name="luis", awesome=true}, "test" );
	}

	function testDeepKey(){
		$assert.deepKey( {name="luis", awesome=true, parent = { age=70 } }, "age" );
	}

	function testNotDeepKey(){
		$assert.notDeepKey( {name="luis", awesome=true, parent = { age=70 } }, "luis" );
	}

	function testLengthOf(){
		$assert.lengthOf( "heelo", 5 );
		$assert.lengthOf( [1,2], 2 );
		$assert.lengthOf( {name="luis"}, 1 );
		$assert.lengthOf( querySim( "id, name
			1 | luis"), 1 );

	}

	function testThrows(){
		$assert.throws(function(){
			var hello = invalidFunction();
		});
	}

	function testNotThrows(){
		$assert.notThrows(function(){
			var hello = 1;
		});
	}

/*********************************** NON-RUNNABLE Methods ***********************************/	

	function nonStandardNamesWillNotRun() {
		fail( "Non-test methods should not run" );
	}

	private function privateMethodsDontRun() {
		fail( "Private method don't run" );
	}

}