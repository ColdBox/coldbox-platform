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
				variables.response = new coldbox.system.web.context.Response();
			} );

			it( "can be created", function(){
				expect( variables.response ).toBeComponent();
			} );


			it( "can add messages", function(){
				variables.response.addMessage( "Hola" ).addMessage( "how are you?" );
				expect( variables.response.getMessagesString() ).toBe( "Hola, how are you?" );
				expect( variables.response.getMessagesString( "|" ) ).toBe( "Hola|how are you?" );
				expect( variables.response.hasMessages() ).toBeTrue();
				variables.response.clearMessages();
				expect( variables.response.hasMessages() ).toBeFalse();
				expect( variables.response.getMessages() ).toBeEmpty();
			} );

			it( "can add multiple messages fluently", function(){
				variables.response.addMessages( [ "First", "Second" ] ).withMessage( "Third" );

				expect( variables.response.getMessagesString() ).toBe( "First, Second, Third" );
			} );


			it( "can add headers", function(){
				variables.response.addHeader( "x-api-code", 0 );
				expect( variables.response.getHeaders().len() ).toBe( 1 );
				expect( variables.response.hasHeader( "X-API-CODE" ) ).toBeTrue();
				expect( variables.response.getHeader( "X-API-CODE" ) ).toBe( "0" );
				variables.response.setHeader( "X-API-CODE", "1" );
				expect( variables.response.getHeaders().len() ).toBe( 1 );
				expect( variables.response.getHeader( "x-api-code" ) ).toBe( "1" );
				variables.response.removeHeader( "X-API-CODE" ).setHeader( "X-Test", "yes" );
				expect( variables.response.hasHeader( "x-api-code" ) ).toBeFalse();
				variables.response.clearHeaders();
				expect( variables.response.getHeaders() ).toBeEmpty();
			} );

			it( "can set an ETag header fluently", function(){
				variables.response.withETag( "abc123" );
				expect( variables.response.getHeader( "ETag" ) ).toBe( """abc123""" );
			} );

			it( "can set a weak ETag header fluently", function(){
				variables.response.withETag( value = "abc123", weak = true );
				expect( variables.response.getHeader( "ETag" ) ).toBe( "W/""abc123""" );
			} );

			it( "replaces rather than duplicates an existing ETag header", function(){
				variables.response.withETag( "first" ).withETag( "second" );
				expect( variables.response.getHeaders().len() ).toBe( 1 );
				expect( variables.response.getHeader( "ETag" ) ).toBe( """second""" );
			} );

			it( "can set a Cache-Control header fluently", function(){
				variables.response.withCacheControl( { "public" : true, "max-age" : 60 } );
				// Directive order is not guaranteed - plain CFML structs are not guaranteed
				// insertion-ordered on every engine (Lucee in particular), and per RFC 9111
				// Cache-Control's directive order carries no semantic meaning anyway.
				var cacheControlHeader = variables.response.getHeader( "Cache-Control" );
				expect( cacheControlHeader ).toInclude( "public" );
				expect( cacheControlHeader ).toInclude( "max-age=60" );
			} );

			it( "defaults Cache-Control to no-cache", function(){
				variables.response.withCacheControl();
				expect( variables.response.getHeader( "Cache-Control" ) ).toBe( "no-cache" );
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
				variables.response
					.setError( false )
					.withData(
						{ today : now(), name : "luis" },
						"Created!",
						"/users/1"
					);

				expect( variables.response.isSuccess() ).toBeTrue();
				expect( variables.response.getError() ).toBeFalse();
				expect( variables.response.getData().name ).toBe( "luis" );
				expect( variables.response.getMessagesString() ).toBe( "Created!" );
				expect( variables.response.getLocation() ).toBe( "/users/1" );
			} );


			it( "can set error messages with accompanied data", function(){
				variables.response.setErrorMessage( "unit test", 400 );

				expect( variables.response.isError() ).toBeTrue();
				expect( variables.response.getMessagesString() ).toInclude( "unit test" );
				expect( variables.response.getStatusCode() ).toBe( 400 );
				expect( variables.response.isSuccess() ).toBeFalse();
			} );

			it( "can build success and failure responses fluently", function(){
				variables.response.success( { id : 1 }, "Created", "/users/1" ).withStatus( 201 );

				expect( variables.response.isSuccess() ).toBeTrue();
				expect( variables.response.getStatusCode() ).toBe( 201 );

				variables.response.failure( "Invalid", 422, { field : "email" } );
				expect( variables.response.isError() ).toBeTrue();
				expect( variables.response.getData().field ).toBe( "email" );
				expect( variables.response.getStatusCode() ).toBe( 422 );
			} );

			it( "can ignore status text updates", function(){
				variables.response.setStatusText();

				expect( variables.response.getStatusText() ).toBe( "Ok" );
			} );

			it( "can set status codes", function(){
				variables.response.setStatus( 201 );
				expect( variables.response.getStatusCode() ).toBe( 201 );
			} );

			it( "can set data with pagination with no pagination data", function(){
				variables.response.setDataWithPagination( { "results" : "luis" } );
				expect( variables.response.getData() ).toBe( "luis" );
				expect( variables.response.getPagination().page ).toBe( 1 );
			} );

			it( "can set data with pagination and pagination data", function(){
				variables.response.setDataWithPagination( { "results" : "luis", "pagination" : { "page" : 4 } } );
				expect( variables.response.getData() ).toBe( "luis" );
				expect( variables.response.getPagination().page ).toBe( 4 );
			} );
		} );
	}

}
