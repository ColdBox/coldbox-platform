component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "ColdBox Rendering", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			story( "ColdBox should render complex handler returns natively to JSON", function(){
				given( "A complex return data from a handler", function(){
					then( "it should render the data back in json", function(){
						var e = execute( route = "/actionRendering", renderResults = true );
						expect( e.getHandlerResults() ).toBeArray();
						expect( e.getRenderedContent() ).toBeJSON();
					} );
				} );
			} );

			story( "ColdBox action rendering should determine renderdata type using the handler `renderdata` annotation", function(){
				given( "A return data from a handler with a renderadata annotation of json", function(){
					then( "it should render the data back in json", function(){
						var e = execute( event = "actionRendering.asJSON", renderResults = true );
						debug( e.getRenderedContent() );
						expect( e.getRenderedContent() ).toBeJSON();
					} );
				} );
				given( "A return data from a handler with a renderadata annotation of xml", function(){
					then( "it should render the data back in xml", function(){
						var e = execute( event = "actionRendering.asXML", renderResults = true );
						expect( e.getRenderedContent() ).toBeTypeOf( "xml" );
					} );
				} );
			} );

			story( "I want to render jsonp", function(){
				given( "A jsonp type and `callback`", function(){
					then( "it should render with the appropriate application/javascript type", function(){
						var e = execute( event = "rendering.jsonprotected", renderResults = true );
						expect( e.getRenderedContent() ).toInclude( "callback" );
						expect( e.getRenderData().contentType ).toBe( "application/javascript" );
					} );
				} );
			} );

			story( "I want to return the `event` object in any handler", function(){
				given( "You return the `event` object", function(){
					then( "ColdBox should just ignore it as a return marshalling object", function(){
						var e = execute( event = "rendering.returnEvent", renderResults = true );
						expect( e.getRenderedContent() ).toInclude( "I can return the event!" );
					} );
				} );
			} );

			story( "I want to be able to render multiple rendering regions", function(){
				given( "a rendering region to setView()", function(){
					then( "it should render using only its name", function(){
						var e = execute( event = "rendering.renderingRegions", renderResults = true );
						expect( e.getRenderedContent() )
							.toInclude( "View with args: true" )
							.toInclude( "Welcome to my main inception module page!" );
					} );
				} );
				given( "an invalid rendering region to renderview", function(){
					then( "it should throw an exception", function(){
						expect( function(){
							controller.getRenderer().renderView( name = "invalid" );
						} ).toThrow( type = "InvalidRenderingRegion" );
					} );
				} );
			} );

			story( "I want to be able to render simple views from actions", function(){
				given( "a renderView() from an action", function(){
					then( "it should render the simple view with no name", function(){
						var e = execute( event = "rendering.normalRendering", renderResults = true );
						expect( e.getRenderedContent() ).toInclude( "simple view" );
					} );
				} );
			} );

			story( "I want to pass through rendering arguments to both layouts and views", function(){
				given( "a renderLayout() call with custom arguments", function(){
					then( "the view AND layout should receive them", function(){
						var e = execute( event = "rendering.renderLayoutWithArguments", renderResults = true );
						expect( e.getRenderedContent() ).toInclude( "abc123" );
					} );
				} );
			} );
		} );
	}

}
