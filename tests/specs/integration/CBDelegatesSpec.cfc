/*******************************************************************************
 *	Test for custom WireBox DSLs
 *******************************************************************************/
component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "ColdBox Delegates", function(){
			beforeEach( function( currentSpec ){
				setup();
			} );

			it( "can build the routable delegates", function(){
				var result  = controller.getWirebox().getInstance( "Routable" );
				var methods = "getHTMLBaseURL,getHTMLBasePath,getSESBasePath,getSESBaseURL,route,buildLink,getPath,getUrl";

				for ( var thisMethod in methods ) {
					expect( result ).toHaveKey( thisMethod );
				}
			} );
		} );
	}

}
