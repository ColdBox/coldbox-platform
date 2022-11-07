component
	extends="tests.resources.BaseIntegrationTest"
	autowire
	accessors="true"
	delegates="Population@cbDelegates"
{

	property name="popTest";

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Object Populator Delegate", function(){
			beforeEach( function( currentSpec ){
				setup();
			} );

			it( "can create the target with the populator", function(){
				expect( this ).toHaveKey( "populate,populateFromXml" );
			} );

			it( "can populate using the delegate", function(){
				variables.popTest = "";
				populate( { popTest : "unit test" } );
				expect( popTest ).toBe( "unit test" );
			} );
		} ); // end describe
	}

}
