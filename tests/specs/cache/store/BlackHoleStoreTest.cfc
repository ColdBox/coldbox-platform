component extends="coldbox.system.testing.BaseModelTest" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Black Hole Store", function() {
			beforeEach( function(currentSpec) {
				mockProvider = createMock( "coldbox.system.cache.providers.MockProvider" ).init();
				store = createMock( "coldbox.system.cache.store.BlackHoleStore" ).init( mockProvider );
			} );

			it( "Can be created", function() {
				expect( store ).toBeComponent();
			} );
		} );
	}

}
