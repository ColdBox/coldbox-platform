/**
 * Bootstrap specs
 */
component extends="testbox.system.BaseSpec" {

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		describe( "Bootstrap", function(){
			it( "can be created on every engine", function(){
				// Adobe CF refuses to compile the component if a property default is not a constant
				var bootstrap = new coldbox.system.Bootstrap( "", expandPath( "/coldbox/test-harness" ) );
				expect( bootstrap ).toBeComponent();
			} );

			it( "sets the appHash before loadColdBox() runs", function(){
				// reloadChecks() locks on appHash, and it can run before loadColdBox()
				var bootstrap = new coldbox.system.Bootstrap( "", expandPath( "/coldbox/test-harness" ) );
				expect( bootstrap.getAppHash() ).toBe(
					hash( getBaseTemplatePath() & application.applicationname )
				);
			} );
		} );
	}

}
