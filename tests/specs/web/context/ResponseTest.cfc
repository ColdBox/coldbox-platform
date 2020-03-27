/**
 * My BDD Test
 */
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
		describe( "Response Object", function(){
			beforeEach( function( currentSpec ){
				response = new coldbox.system.web.context.Response();
			} );

			it( "can be created", function(){
				expect( response ).toBeComponent();
			} );


			it( "can add messages", function(){
				response.addMessage( "Hola" ).addMessage( " how are you?" );
				expect( response.getMessagesString() ).toBe( "Hola, how are you?" );
			} );


			it( "can add headers", function(){
				response.addHeader( "x-api-code", 0 );
				expect( response.getHeaders().len() ).toBe( 1 );
			} );


			it( "can handle pagination", function(){
				response.setPagination( 0, 100, 1, 1000, 10 );

				expect( response.getPagination() ).toBeStruct();
				expect( response.getPagination().offset ).toBe( 0 );
				expect( response.getPagination().maxRows ).toBe( 100 );
				expect( response.getPagination().page ).toBe( 1 );
				expect( response.getPagination().totalRecords ).toBe( 1000 );
				expect( response.getPagination().totalPages ).toBe( 10 );
			} );

			it( "can get a data packet", function(){
				response
					.setError( false )
					.setData( { today : now(), name : "luis" } )
					.addMessage( "Created!" );

				expect( response.getError() ).toBeFalse();
				expect( response.getData().name ).toBe( "luis" );
				expect( response.getMessagesString() ).toBe( "Created!" );
			} );
		} );
	}

}
