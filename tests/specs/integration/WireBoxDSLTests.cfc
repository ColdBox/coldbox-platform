/*******************************************************************************
 *	Test for custom WireBox DSLs
 *******************************************************************************/
component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "WireBox custom DSL", function(){
			beforeEach( function( currentSpec ){
				setup();
			} );

			it( "can handle box setting namespace", function(){
				// box namespace === coldbox namespace
				var coldboxresult = controller.getWirebox().getInstance( dsl = "coldbox:setting:appName" );
				var boxresult     = controller.getWirebox().getInstance( dsl = "box:setting:appName" );

				expect( boxresult ).toBe( coldboxresult );
			} );

			it( "can handle 2 stage moduleconfig namespace", function(){
				var result = controller.getWirebox().getInstance( dsl = "box:moduleconfig" );

				expect( result ).toBeStruct();
			} );

			it( "can handle 4 stage module settings namespace", function(){
				var result = controller.getWirebox().getInstance( dsl = "box:moduleSettings:HTMLHelper:CSS_Path" );

				expect( result ).toBeString();
			} );

			it( "can handle 3 stage configSettings namespace", function(){
				var result = controller.getWirebox().getInstance( dsl = "box:configSettings:appName" );

				expect( result ).toBeString();
			} );
		} );
	}

}
