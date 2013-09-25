component displayName="New TestBox assertions test"{

	function beforeTests(){
		application.salvador = 1;
	}

	function afterTests(){
		structClear( application );
	}

	function testAssert() {

		// Runs failure... if you uncomment any of the following.

		// assert( true == false );
		// assertIsValidEmail( "ben nadel" );
		// assertIsValidEmail( "ben@bennadel.com" );
		//fail('test');
		
		asssert( application.salvador == 1 );
	}

	function testThatRunsGood() {
		// Runs good...	
	}

	function nonStandardNamesWillNotRun() {
		fail( "Non-test methods should not run" );
	}


	private function privateMethodsDontRun() {
		fail( "Private method don't run" );
	}

}