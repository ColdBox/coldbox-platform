/*******************************************************************************
 *	Integration Test as BDD
 *
 *	Extends the integration class: coldbox.system.testing.BaseTestCase
 *
 *	so you can test your ColdBox application headlessly. The 'appMapping' points by default to
 *	the '/root' mapping created in the test folder Application.cfc.  Please note that this
 *	Application.cfc must mimic the real one in your root, including ORM settings if needed.
 *
 *	The 'execute()' method is used to execute a ColdBox event, with the following arguments
 *	* event : the name of the event
 *	* private : if the event is private or not
 *	* prePostExempt : if the event needs to be exempt of pre post interceptors
 *	* eventArguments : The struct of args to pass to the event
 *	* renderResults : Render back the results of the event
 *******************************************************************************/
component extends="tests.resources.BaseIntegrationTest"{

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		// do your own stuff here
	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Event Execution System", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			story( "I want to execute private event actions", function(){
				given( "a private event string: main.testPrivateActions", function(){
					then( "it should execute it privately", function(){
						var e = execute(
							event         = "main.testPrivateActions",
							renderResults = true
						);
						expect( e.getRenderedContent() ).toInclude( "Private actions rule" );
					} );
				} );
			} );

			story( "I want to execute a localized onInvalidHTTPMethod", function(){
				given( "an invalid HTTP method", function(){
					then( "it should fire the localized onInvalidHTTPMethod", function(){
						// Execute
						var e = this.GET( "rendering.testHTTPMethod" );
						expect( e.getRenderedContent() ).toInclude(
							"Yep, onInvalidHTTPMethod works!"
						);
					} );
				} );
			} );

			story( "I want to execute a global invalid http method", function(){
				given( "an invalid HTTP Method with no localized onInvalidHTTPMethod action", function(){
					then( "it should fire the global invalid http handler", function(){
						// Mock to invalid HTTP method
						prepareMock( getRequestContext() ).$( "getHTTPMethod", "DELETE" );
						// Execute
						var e = execute(
							event         = "main.index",
							renderResults = true
						);
						expect( e.getRenderedContent() ).toInclude( "invalid http: main.index" );
						expect( e.getStatusCode() ).toBe( 405 );
					} );
				} );
			} );

			story( "I want to execute a global invalid event handler", function(){
				given( "an invalid event", function(){
					then( "it should fire the global invalid event handler", function(){
						var e = execute(
							event         = "does.not.exist",
							renderResults = true
						);
						expect( e.getStatusCode() ).toBe( 404 );
					} );
				} );
			} );

			story( "I want the onException to have a default status code of 500", function(){
				given( "an event that fires an exception", function(){
					then( "it should default the status code to 500", function(){
						expect( function(){
							var e = execute(
								event                 = "main.throwException",
								renderResults         = true,
								withExceptionHandling = true
							);
						} ).toThrow();
						expect( getNativeStatusCode() ).toBe( 500 );
					} );
				} );
			} );

			story( "I want to run named routes via runRoute()", function(){
				given( "a valid route and params with no caching", function(){
					then( "it should execute the route event", function(){
						var event = execute(
							event         = "main.routeRunner",
							renderResults = true
						);
						expect( event.getRenderedContent() ).toInclude( "unit test!" );
					} );
				} );
				given( "a valid route and params with caching", function(){
					then( "it should execute the route event", function(){
						var cache = getCache( "template" );
						cache.clearAll();
						var event = execute(
							event         = "main.routeRunnerWithCaching",
							renderResults = true
						);
						expect( event.getRenderedContent() ).toInclude( "unit test!" );
						expect( cache.getSize() ).toBeGTE( 1 );
					} );
				} );
			} );

			story( "I want to run a route and inspect it's record and meta", function(){
				given( "A route with meta", function(){
					then( "I should be able to retrieve it", function(){
						var event = this.GET( "/photos" );
						expect( event.getCurrentRouteRecord().pattern ).toBe( "photos/" );
						expect( event.getCurrentRouteMeta().secure ).toBeTrue();
					} );
				} );
			} );
		} );
	}

	private function getNativeStatusCode(){
		if ( structKeyExists( server, "lucee" ) ) {
			return getPageContext().getResponse().getStatus();
		} else {
			return getPageContext()
				.getResponse()
				.getResponse()
				.getStatus();
		}
	}

}
