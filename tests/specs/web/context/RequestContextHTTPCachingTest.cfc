/**
 * RequestContext HTTP Caching Tests — the conditional-GET primitives from
 * docs/specs/http-caching.md §3.1.
 *
 * Pure HTTP header logic with no runtime dependency, so - unlike the SSE suites - this runs on
 * every engine, not just BoxLang.
 */
component extends="coldbox.system.testing.BaseModelTest" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
	}

	private function buildContext(){
		var props = {
			defaultLayout     : "Main.cfm",
			defaultView       : "",
			folderLayouts     : structNew(),
			viewLayouts       : structNew(),
			eventName         : "event",
			sesBaseURL        : "http://localhost/index.cfm",
			registeredLayouts : structNew(),
			modules           : {}
		};

		var mockController = getMockController();
		prepareMock( mockController.getInterceptorService() );
		prepareMock( mockController.getWireBox() );

		return prepareMock( new coldbox.system.web.context.RequestContext( props, mockController ) );
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		describe( "RequestContext HTTP caching", function(){
			describe( "etag()", function(){
				it( "sets the ETag header and returns false when there is no If-None-Match", function(){
					var event = buildContext();
					event.$( "getHTTPMethod", "GET" );
					event
						.$( "getHTTPHeader" )
						.$args( "If-None-Match", "" )
						.$results( "" );
					event.$( "setHTTPHeader" );
					event.$( "noExecution" );

					var result = event.etag( "abc123" );

					expect( result ).toBeFalse();
					expect( event.$never( "noExecution" ) ).toBeTrue();
					var headerCalls = event.$callLog().setHTTPHeader;
					expect( headerCalls ).toHaveLength( 1 );
					expect( headerCalls[ 1 ].name ).toBe( "ETag" );
					expect( headerCalls[ 1 ].value ).toBe( """abc123""" );
				} );

				it( "quotes weak etags with a W/ prefix", function(){
					var event = buildContext();
					event.$( "getHTTPMethod", "GET" );
					event
						.$( "getHTTPHeader" )
						.$args( "If-None-Match", "" )
						.$results( "" );
					event.$( "setHTTPHeader" );

					event.etag( value = "abc123", weak = true );

					expect( event.$callLog().setHTTPHeader[ 1 ].value ).toBe( "W/""abc123""" );
				} );

				it( "short-circuits with a 304 and no body when If-None-Match matches", function(){
					var event = buildContext();
					event.$( "getHTTPMethod", "GET" );
					event
						.$( "getHTTPHeader" )
						.$args( "If-None-Match", "" )
						.$results( """abc123""" );
					event.$( "setHTTPHeader" );
					event.$( "noExecution" );

					var result = event.etag( "abc123" );

					expect( result ).toBeTrue();
					expect( event.$once( "noExecution" ) ).toBeTrue();
					var headerCalls = event.$callLog().setHTTPHeader;
					expect( headerCalls ).toHaveLength( 2 );
					expect( headerCalls[ 2 ].statusCode ).toBe( 304 );
				} );

				it( "never short-circuits an unsafe HTTP method even on a match", function(){
					var event = buildContext();
					event.$( "getHTTPMethod", "POST" );
					event
						.$( "getHTTPHeader" )
						.$args( "If-None-Match", "" )
						.$results( """abc123""" );
					event.$( "setHTTPHeader" );
					event.$( "noExecution" );

					var result = event.etag( "abc123" );

					expect( result ).toBeFalse();
					expect( event.$never( "noExecution" ) ).toBeTrue();
				} );

				it( "treats HEAD as a safe method", function(){
					var event = buildContext();
					event.$( "getHTTPMethod", "HEAD" );
					event
						.$( "getHTTPHeader" )
						.$args( "If-None-Match", "" )
						.$results( """abc123""" );
					event.$( "setHTTPHeader" );
					event.$( "noExecution" );

					expect( event.etag( "abc123" ) ).toBeTrue();
				} );
			} );

			describe( "lastModified()", function(){
				it( "sets Last-Modified and returns false when there is no If-Modified-Since", function(){
					var event = buildContext();
					event.$( "getHTTPMethod", "GET" );
					event
						.$( "getHTTPHeader" )
						.$args( "If-Modified-Since", "" )
						.$results( "" );
					event.$( "setHTTPHeader" );
					event.$( "noExecution" );

					var result = event.lastModified( now() );

					expect( result ).toBeFalse();
					expect( event.$never( "noExecution" ) ).toBeTrue();
					expect( event.$callLog().setHTTPHeader[ 1 ].name ).toBe( "Last-Modified" );
				} );

				it( "short-circuits when If-Modified-Since is at or after the resource's timestamp", function(){
					var event           = buildContext();
					var resourceDate    = dateAdd( "h", -1, now() );
					var clientKnowsAsOf = event.toHTTPDate( now() );
					event.$( "getHTTPMethod", "GET" );
					event
						.$( "getHTTPHeader" )
						.$args( "If-Modified-Since", "" )
						.$results( clientKnowsAsOf );
					event.$( "setHTTPHeader" );
					event.$( "noExecution" );

					var result = event.lastModified( resourceDate );

					expect( result ).toBeTrue();
					expect( event.$once( "noExecution" ) ).toBeTrue();
				} );

				it( "does not short-circuit when the resource changed after If-Modified-Since", function(){
					var event           = buildContext();
					var resourceDate    = now();
					var clientKnowsAsOf = event.toHTTPDate( dateAdd( "h", -1, now() ) );
					event.$( "getHTTPMethod", "GET" );
					event
						.$( "getHTTPHeader" )
						.$args( "If-Modified-Since", "" )
						.$results( clientKnowsAsOf );
					event.$( "setHTTPHeader" );
					event.$( "noExecution" );

					var result = event.lastModified( resourceDate );

					expect( result ).toBeFalse();
					expect( event.$never( "noExecution" ) ).toBeTrue();
				} );

				it( "ignores a non-date If-Modified-Since rather than throwing", function(){
					var event = buildContext();
					event.$( "getHTTPMethod", "GET" );
					event
						.$( "getHTTPHeader" )
						.$args( "If-Modified-Since", "" )
						.$results( "not-a-date" );
					event.$( "setHTTPHeader" );
					event.$( "noExecution" );

					expect( () => event.lastModified( now() ) ).notToThrow();
					expect( event.$never( "noExecution" ) ).toBeTrue();
				} );
			} );

			describe( "cacheControl()", function(){
				it( "assembles boolean directives as bare tokens and others as key=value", function(){
					var event = buildContext();
					event.$( "setHTTPHeader" );

					event.cacheControl( { "public" : true, "max-age" : 60 } );

					// Directive order is not guaranteed - plain CFML structs are not guaranteed
					// insertion-ordered on every engine (Lucee in particular), and per RFC 9111
					// Cache-Control's directive order carries no semantic meaning anyway.
					var headerCall = event.$callLog().setHTTPHeader[ 1 ];
					expect( headerCall.name ).toBe( "Cache-Control" );
					expect( headerCall.value ).toInclude( "public" );
					expect( headerCall.value ).toInclude( "max-age=60" );
				} );

				it( "defaults to no-cache", function(){
					var event = buildContext();
					event.$( "setHTTPHeader" );

					event.cacheControl();

					expect( event.$callLog().setHTTPHeader[ 1 ].value ).toBe( "no-cache" );
				} );

				it( "is fluent", function(){
					var event = buildContext();
					event.$( "setHTTPHeader" );

					expect( event.cacheControl() ).toBe( event );
				} );
			} );

			describe( "toHTTPDate()", function(){
				it( "matches the RFC 7231 example date exactly", function(){
					var event          = buildContext();
					// The canonical example from RFC 7231 §7.1.1.1
					var rfcExampleDate = createDateTime( 1994, 11, 6, 8, 49, 37 );

					expect( event.toHTTPDate( rfcExampleDate ) ).toBe( "Sun, 06 Nov 1994 08:49:37 GMT" );
				} );
			} );

			describe( "isNoExecution()", function(){
				it( "is false by default", function(){
					expect( buildContext().isNoExecution() ).toBeFalse();
				} );

				it( "is true after noExecution() runs", function(){
					var event = buildContext();
					event.noExecution();

					expect( event.isNoExecution() ).toBeTrue();
				} );

				it( "becomes true as a side effect of a matching etag() call", function(){
					var event = buildContext();
					event.$( "getHTTPMethod", "GET" );
					event
						.$( "getHTTPHeader" )
						.$args( "If-None-Match", "" )
						.$results( """abc123""" );
					event.$( "setHTTPHeader" );

					event.etag( "abc123" );

					expect( event.isNoExecution() ).toBeTrue();
				} );
			} );
		} );
	}

}
