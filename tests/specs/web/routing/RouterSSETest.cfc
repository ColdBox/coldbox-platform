/**
 * SSE Routing Tests — the toSSE() terminator and the format negotiation wiring.
 *
 * The extension and media type alias suites run everywhere, since they are pure routing table
 * concerns. Registering a toSSE() route is guarded on BoxLang and skipped elsewhere.
 */
component extends="coldbox.system.testing.BaseModelTest" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		variables.controller = createMock( "coldbox.system.web.Controller" )
			.init( expandPath( "/coldbox/test-harness" ), "cbController" )
			.setSetting( "AppMapping", "" )
			.setSetting( "RoutingAppMapping", "/" );
	}

	boolean function notBoxlang(){
		return !isBoxLang();
	}

	private function buildRouter(){
		return createMock( "coldbox.system.web.routing.Router" )
			.init()
			.setController( variables.controller )
			.setLogBox( variables.controller.getLogBox() )
			.setLog( variables.controller.getLogBox().getLogger( this ) )
			.setCacheBox( variables.controller.getCacheBox() )
			.setWireBox( variables.controller.getWireBox() );
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		describe( "SSE format negotiation", function(){
			beforeEach( function( currentSpec ){
				variables.router = buildRouter();
			} );

			it( "registers sse as a valid extension", function(){
				expect( variables.router.isValidExtension( "sse" ) ).toBeTrue();
			} );

			it( "keeps every pre-existing extension valid", function(){
				[ "json", "jsont", "xml", "cfm", "cfml", "html", "htm", "rss", "pdf" ].each( ( ext ) => {
					expect( variables.router.isValidExtension( ext ) ).toBeTrue();
				} );
			} );

			it( "maps the text/event-stream media type onto the sse extension", function(){
				expect( variables.router.getMimeExtensionAlias( "text/event-stream" ) ).toBe( "sse" );
			} );

			it( "matches the media type even when a quality factor is attached", function(){
				expect( variables.router.getMimeExtensionAlias( "text/event-stream;q=0.9" ) ).toBe( "sse" );
			} );

			it( "is case and whitespace insensitive", function(){
				expect( variables.router.getMimeExtensionAlias( " TEXT/Event-Stream " ) ).toBe( "sse" );
			} );

			it( "returns nothing for media types that have no alias", function(){
				[ "application/json", "text/html", "*/*", "" ].each( ( mediaType ) => {
					expect( variables.router.getMimeExtensionAlias( mediaType ) ).toBeEmpty();
				} );
			} );

			it( "does not let sse shadow the formats a browser actually asks for", function(){
				// A browser's default Accept header must still resolve exactly as it did before
				var browserAccept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";

				browserAccept
					.listToArray()
					.each( ( thisAccept ) => {
						expect( variables.router.getMimeExtensionAlias( thisAccept ) ).toBeEmpty();
					} );
			} );
		} );

		describe( "toSSE() terminator", function(){
			beforeEach( function( currentSpec ){
				variables.router = buildRouter();
			} );

			it( "registers a streaming route", function(){
				if ( notBoxlang() ) {
					return;
				}

				variables.router.route( "/events/heartbeat" ).toSSE( ( event, rc, prc, emitter ) => {} );

				var routes = variables.router.getRoutes();
				expect( routes ).toHaveLength( 1 );
				expect( routes[ 1 ].sse ).toBeTrue();
				expect( routes[ 1 ].pattern ).toInclude( "events/heartbeat" );
			} );

			it( "stores the streaming callback on the route", function(){
				if ( notBoxlang() ) {
					return;
				}

				variables.router.route( "/events" ).toSSE( ( event, rc, prc, emitter ) => "streamed" );

				var route = variables.router.getRoutes()[ 1 ];
				expect( isClosure( route.sseCallback ) || isCustomFunction( route.sseCallback ) ).toBeTrue();
			} );

			it( "inherits route modifiers like any other terminator", function(){
				if ( notBoxlang() ) {
					return;
				}

				variables.router
					.route( "/events/secure" )
					.withSSL()
					.header( "X-Stream", "yes" )
					.toSSE( ( event, rc, prc, emitter ) => {} );

				var route = variables.router.getRoutes()[ 1 ];
				expect( route.ssl ).toBeTrue();
				expect( route.headers ).toHaveKey( "X-Stream" );
			} );

			it( "resets the fluent route state so the next route starts clean", function(){
				if ( notBoxlang() ) {
					return;
				}

				variables.router.route( "/events" ).toSSE( ( event, rc, prc, emitter ) => {} );
				variables.router.route( "/plain", "main.index" );

				var routes = variables.router.getRoutes();
				expect( routes ).toHaveLength( 2 );

				var plainRoute = routes.filter( ( r ) => r.pattern.findNoCase( "plain" ) )[ 1 ];
				expect( plainRoute.sse ).toBeFalse();
			} );

			it( "rejects a callback that is not a closure", function(){
				if ( notBoxlang() ) {
					return;
				}

				expect( () => variables.router.route( "/events" ).toSSE( "not-a-closure" ) ).toThrow(
					"InvalidArgumentException"
				);
			} );

			it( "throws on a runtime that cannot stream", function(){
				if ( isBoxLang() ) {
					return;
				}

				expect( () => variables.router.route( "/events" ).toSSE( ( event, rc, prc, emitter ) => {} ) ).toThrow(
					"SSENotSupportedException"
				);
			} );
		} );

		describe( "route definition defaults", function(){
			it( "defaults every non streaming route to sse false", function(){
				var router = buildRouter();
				router.route( "/plain", "main.index" );

				var route = router.getRoutes()[ 1 ];
				expect( route ).toHaveKey( "sse" );
				expect( route ).toHaveKey( "sseCallback" );
				expect( route.sse ).toBeFalse();
				expect( route.sseCallback ).toBeEmpty();
			} );
		} );
	}

}
