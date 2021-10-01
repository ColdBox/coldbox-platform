component extends="tests.resources.BaseIntegrationTest" {

	function run(){
		describe( "ColdBox REST", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			it( "can handle allowed HTTP methods in action annotations", function(){
				var event = this.POST( "main.actionAllowedMethod" );
				expect( event.getRenderedContent() ).toBe( "invalid http: main.actionAllowedMethod" );
			} );

			it( "can handle onInvalidHTTPMethod exceptions", function(){
				var event = this.GET( "rendering.testHTTPMethod" );
				expect( event.getValue( "cbox_rendered_content" ) ).toBe( "Yep, onInvalidHTTPMethod works!" );
			} );

			it( "can do json data renderings", function(){
				getRequestContext().setValue( "format", "json" );
				var event = execute( event = "rendering.index", renderResults = true );
				var prc   = event.getPrivateCollection();

				expect( prc.cbox_renderData ).toBeStruct();
				expect( prc.cbox_renderData.contenttype ).toMatch( "json" );
			} );

			it( "can redirect only for html formats with the `formatsRedirect` parameter", function(){
				getRequestContext().setValue( "format", "json" );
				var event = execute( event = "rendering.redirect", renderResults = true );
				var rc    = event.getCollection();
				var prc   = event.getCollection( private = true );
				expect( rc ).notToHaveKey( "relocate_event" );
				expect( prc.cbox_renderData ).toBeStruct();
				expect( prc.cbox_renderData.contenttype ).toMatch( "json" );

				getRequestContext().setValue( "format", "html" );
				var event = execute( event = "rendering.redirect", renderResults = true );
				var rc    = event.getCollection();
				expect( rc ).toHaveKey( "relocate_event" );
				expect( rc[ "relocate_event" ] ).toBe( "Main.index" );
			} );
		} );
	}

}
