/**
 * SSE Routing Tests — the toSSE() terminator and the format negotiation wiring.
 *
 * SSE is a BoxLang-only feature (see docs/specs/sse-streaming.md), so this whole suite is
 * excluded on any other engine, matching RouterAITest.cfc's pattern for toAi()/toMCP(). The
 * extension and media type alias assertions are, in principle, engine-agnostic routing table
 * concerns, but keeping the entire SSE test surface under one BoxLang gate is a simpler policy
 * than deciding file-by-file which parts "could" run elsewhere.
 */
component extends="coldbox.system.testing.BaseModelTest" skip="notBoxlang" {

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
		if ( notBoxlang() ) {
			return;
		}

		describe( "SSE format negotiation", function(){
			beforeEach( function( currentSpec ){
				variables.router = buildRouter();
			} );

			it( "registers sse as a valid extension", function(){
				expect( variables.router.isValidExtension( "sse" ) ).toBeTrue();
			} );

			it( "keeps every pre-existing extension valid", function(){
				// Assigned to a variable rather than calling .each() straight off the array
				// literal - chaining a member function directly onto a bracket literal breaks
				// the parser on Adobe ColdFusion 2023 (RouterAITest.cfc's already-working .each()
				// calls are all on variables, never literals).
				var preExistingExtensions = [
					"json",
					"jsont",
					"xml",
					"cfm",
					"cfml",
					"html",
					"htm",
					"rss",
					"pdf"
				];

				preExistingExtensions.each( ( ext ) => {
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
				// Built via concatenation rather than the literal wildcard media type string.
				// Writing the two characters that close a block comment anywhere in CFScript
				// source - even inside a string, or inside a line comment like this one - breaks
				// the parser on Adobe ColdFusion 2023, which appears to scan for comment
				// terminators without full context awareness.
				var wildcardMediaType     = "*" & "/" & "*";
				var mediaTypesWithNoAlias = [
					"application/json",
					"text/html",
					wildcardMediaType,
					""
				];

				mediaTypesWithNoAlias.each( ( mediaType ) => {
					expect( variables.router.getMimeExtensionAlias( mediaType ) ).toBeEmpty();
				} );
			} );

			it( "does not let sse shadow the formats a browser actually asks for", function(){
				// A browser's default Accept header must still resolve exactly as it did before.
				// Built via concatenation - see the comment above on why the literal wildcard
				// media type string is unsafe in CFScript source on Adobe ColdFusion 2023.
				var wildcardMediaType    = "*" & "/" & "*";
				var browserAccept        = "text/html,application/xhtml+xml,application/xml;q=0.9,#wildcardMediaType#;q=0.8";
				var browserAcceptEntries = browserAccept.listToArray();

				browserAcceptEntries.each( ( thisAccept ) => {
					expect( variables.router.getMimeExtensionAlias( thisAccept ) ).toBeEmpty();
				} );
			} );
		} );

		describe( "toSSE() terminator", function(){
			beforeEach( function( currentSpec ){
				variables.router = buildRouter();
			} );

			it( "registers a streaming route", function(){
				variables.router
					.route( "/events/heartbeat" )
					.toSSE( ( event, rc, prc, emitter ) => {
					} );

				var routes = variables.router.getRoutes();
				expect( routes ).toHaveLength( 1 );
				expect( routes[ 1 ].sse ).toBeTrue();
				expect( routes[ 1 ].pattern ).toInclude( "events/heartbeat" );
			} );

			it( "stores the streaming callback on the route", function(){
				variables.router.route( "/events" ).toSSE( ( event, rc, prc, emitter ) => "streamed" );

				var route = variables.router.getRoutes()[ 1 ];
				expect( isClosure( route.sseCallback ) || isCustomFunction( route.sseCallback ) ).toBeTrue();
			} );

			it( "inherits route modifiers like any other terminator", function(){
				variables.router
					.route( "/events/secure" )
					.withSSL()
					.header( "X-Stream", "yes" )
					.toSSE( ( event, rc, prc, emitter ) => {
					} );

				var route = variables.router.getRoutes()[ 1 ];
				expect( route.ssl ).toBeTrue();
				expect( route.headers ).toHaveKey( "X-Stream" );
			} );

			it( "resets the fluent route state so the next route starts clean", function(){
				variables.router
					.route( "/events" )
					.toSSE( ( event, rc, prc, emitter ) => {
					} );
				variables.router.route( "/plain", "main.index" );

				var routes = variables.router.getRoutes();
				expect( routes ).toHaveLength( 2 );

				var plainRoute = routes.filter( ( r ) => r.pattern.findNoCase( "plain" ) )[ 1 ];
				expect( plainRoute.sse ).toBeFalse();
			} );

			it( "rejects a callback that is not a closure", function(){
				expect( () => variables.router.route( "/events" ).toSSE( "not-a-closure" ) ).toThrow(
					"InvalidArgumentException"
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
