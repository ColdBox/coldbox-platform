component extends="tests.resources.BaseIntegrationTest" {

	function run(){
		describe( "ColdBox Restful Handlers", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			it( "can handle vanilla restful execution with custom matchers", function(){
				var e        = this.get( "/restfulHandler" );
				var response = e.getResponse();

				expect( response.getError() ).toBeFalse( response.getMessagesString() );
				expect( response.getData().message ).toBe( "hello" );
				expect( response ).toHaveStatus( 200 );
			} );

			it( "can handle handler return results", function(){
				var e        = this.get( "/restfulHandler/returnData" );
				var response = e.getResponse();

				expect( response.getError() ).toBeFalse( response.getMessagesString() );
				expect( e.getRenderedContent() ).toBe( "hola" );
			} );

			it( "can handle explicit render data calls", function(){
				var e        = this.get( "/restfulHandler/renderdata" );
				var response = e.getResponse();

				expect( response.getError() ).toBeFalse( response.getMessagesString() );
				expect( e.getRenderedContent() ).toBeJson();
				expect( e.getRenderedContent() ).toInclude( "luis majano" );
			} );

			it( "can handle a set view", function(){
				var e        = this.get( "/restfulHandler/setview" );
				var response = e.getResponse();

				expect( response.getError() ).toBeFalse( response.getMessagesString() );
				expect( e.getRenderedContent() ).toInclude( "I am a simple view rendered at" );
			} );

			it( "can handle invalid credentials", function(){
				var e        = this.get( "/restfulHandler/invalidCredentials" );
				var response = e.getResponse();

				expect( response.getError() ).toBeTrue( response.getMessagesString() );
				expect( response.getStatusCode() ).toBe( 401 );
			} );

			it( "can handle ValidationException", function(){
				var e        = this.get( "/restfulHandler/ValidationException" );
				var response = e.getResponse();

				expect( response.getError() ).toBeTrue( response.getMessagesString() );
				expect( response.getStatusCode() ).toBe( 400 );
			} );

			it( "can handle EntityNotFound", function(){
				var e        = this.get( "/restfulHandler/EntityNotFound" );
				var response = e.getResponse();

				expect( response.getError() ).toBeTrue( response.getMessagesString() );
				expect( response.getStatusCode() ).toBe( 404 );
			} );

			it( "can handle RecordNotFound", function(){
				var e        = this.get( "/restfulHandler/RecordNotFound" );
				var response = e.getResponse();

				expect( response.getError() ).toBeTrue( response.getMessagesString() );
				expect( response.getStatusCode() ).toBe( 404 );
			} );
		} );
	}

}
