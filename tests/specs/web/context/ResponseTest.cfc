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


			it( "can set error messages with accompanied data", function(){
				response.setErrorMessage( "unit test", 400 );

				expect( response.getError() ).toBeTrue();
				expect( response.getMessagesString() ).toInclude( "unit test" );
				expect( response.getStatusCode() ).toBe( 400 );
				expect( response.getStatusText() ).toBe( "Bad Request" );
			} );

			it( "can set error messages with accompanied code and text", function(){
				response.setErrorMessage( "unit test", 400, "error baby" );

				expect( response.getError() ).toBeTrue();
				expect( response.getMessagesString() ).toInclude( "unit test" );
				expect( response.getStatusCode() ).toBe( 400 );
				expect( response.getStatusText() ).toBe( "error baby" );
			} );

			it( "can set status with default code texts", function(){
				response.setStatus( 400 );

				expect( response.getStatusCode() ).toBe( 400 );
				expect( response.getStatusText() ).toBe( "Bad Request" );
			} );

			it( "can set status with set code texts", function(){
				response.setStatus( 400, "error baby" );

				expect( response.getStatusCode() ).toBe( 400 );
				expect( response.getStatusText() ).toBe( "error baby" );
			} );


			it( "can set data with pagination with no pagination data", function(){
				response.setDataWithPagination( { "results" : "luis" } );
				expect( response.getData() ).toBe( "luis" );
				expect( response.getPagination().page ).toBe( 1 );
			} );

			it( "can set data with pagination and pagination data", function(){
				response.setDataWithPagination( { "results" : "luis", "pagination" : { "page" : 4 } } );
				expect( response.getData() ).toBe( "luis" );
				expect( response.getPagination().page ).toBe( 4 );
			} );
		} );
	}

}
