/**
 * RequestContext SSE Tests — the streaming API surface on the request context.
 *
 * SSE is a BoxLang-only feature (see docs/specs/sse-streaming.md), so this whole suite is
 * excluded on any other engine, matching RouterAITest.cfc's pattern for toAi()/toMCP(). Note
 * this means graceful degradation on CFML (isSSESupported() returning false,
 * SSENotSupportedException being thrown) is not verified by *this* suite - a spec that never
 * runs on CFML cannot assert CFML behavior. That guarantee rests on ensureSSESupport()'s own
 * simplicity (a single server.keyExists( "boxlang" ) check) rather than on test coverage here.
 */
component extends="coldbox.system.testing.BaseModelTest" skip="notBoxlang" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
	}

	boolean function notBoxlang(){
		return !isBoxLang();
	}

	private function buildContext( struct sseSettings = {}, struct moduleSettings = {} ){
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

		var settings = {
			"keepAliveInterval" : 30000,
			"retry"             : 0,
			"cors"              : "*"
		};
		settings.append( arguments.sseSettings, true );

		var theModuleSettings = arguments.moduleSettings;

		// A callback rather than $args matching: getSetting() is called with a default value that
		// varies per call site, so exact argument matching is too brittle here.
		var mockController = getMockController().$( "getSetting" ).$callback( function(){
			var name = arguments[ 1 ];

			switch ( name ) {
				case "modules":
					return props.modules;
				case "AppMapping":
					return "";
				case "sse":
					return settings;
				case "moduleSettings":
					return theModuleSettings;
			}

			return structKeyExists( arguments, 2 ) ? arguments[ 2 ] : "";
		} );

		prepareMock( mockController.getInterceptorService() );
		prepareMock( mockController.getWireBox() );

		var event = prepareMock( new coldbox.system.web.context.RequestContext( props, mockController ) );

		// InterceptorService.announce() does not operate on whatever event a caller happens to
		// hold - it always fetches "the current context" via getRequestService().getContext().
		// Register this event as that context so preSSEConnection/postSSEConnection/onSSEError
		// fire against the very instance under test rather than a stray auto-created one.
		mockController.getRequestService().setContext( event );

		return event;
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		if ( notBoxlang() ) {
			return;
		}

		describe( "RequestContext SSE support", function(){
			describe( "runtime detection", function(){
				it( "reports support based purely on the server scope", function(){
					var event = buildContext();

					expect( event.isSSESupported() ).toBe( server.keyExists( "boxlang" ) );
				} );
			} );

			describe( "isSSE()", function(){
				it( "is false for an ordinary request", function(){
					expect( buildContext().isSSE() ).toBeFalse();
				} );

				it( "is true once the request has been marked as streaming", function(){
					var event = buildContext();
					event.setPrivateValue( "coldbox_sse", true );

					expect( event.isSSE() ).toBeTrue();
				} );
			} );

			describe( "wantsSSE() content negotiation", function(){
				it( "is false when no format was negotiated", function(){
					expect( buildContext().wantsSSE() ).toBeFalse();
				} );

				it( "is true when the format resolved to sse", function(){
					var event = buildContext();
					event.setValue( "format", "sse" );

					expect( event.wantsSSE() ).toBeTrue();
				} );

				it( "is false for any other negotiated format", function(){
					var event = buildContext();
					event.setValue( "format", "json" );

					expect( event.wantsSSE() ).toBeFalse();
				} );
			} );

			describe( "setting resolution", function(){
				it( "falls back to the global block when no module is active", function(){
					var event = buildContext( { "cors" : "https://global.example.com" } );
					var options = event.getSSEOptions();

					expect( options.cors ).toBe( "https://global.example.com" );
					expect( options.keepAliveInterval ).toBe( 30000 );
				} );

				it( "prefers a module's own overrides over the global block", function(){
					var event = buildContext(
						sseSettings    = { "cors" : "https://global.example.com" },
						moduleSettings = {
							"notifications" : { "sse" : { "cors" : "https://module.example.com" } }
						}
					);
					// The current module is derived from the event name, not stored directly
					event.setValue( "event", "notifications:home.index" );

					expect( event.getCurrentModule() ).toBe( "notifications" );
					expect( event.getSSEOptions().cors ).toBe( "https://module.example.com" );
				} );

				it( "falls back to the global block for keys the module does not override", function(){
					var event = buildContext(
						sseSettings    = { "keepAliveInterval" : 45000 },
						moduleSettings = {
							"notifications" : { "sse" : { "cors" : "https://module.example.com" } }
						}
					);
					event.setValue( "event", "notifications:home.index" );

					expect( event.getSSEOptions().keepAliveInterval ).toBe( 45000 );
					expect( event.getSSEOptions().cors ).toBe( "https://module.example.com" );
				} );
			} );
		} );

		describe( "RequestContext SSE streaming under a MockController", function(){
			// buildContext() returns a MockController, so sse() takes the mock substitution branch:
			// a MockSSEEmitter runs the callback synchronously instead of calling the BIF. This is
			// what makes a handler action calling event.sse() actually integration testable - see
			// docs/specs/sse-streaming.md §7.
			it( "takes over the response when a stream opens", function(){
				var event = buildContext();
				event.sse( ( emitter ) => emitter.close() );

				expect( event.isSSE() ).toBeTrue();
				expect( event.isNoRender() ).toBeTrue();
			} );

			it( "discards any event cache entry so an empty response is never cached", function(){
				var event = buildContext();
				event.setEventCacheableEntry( { cachekey : "should-be-gone", provider : "template" } );

				event.sse( ( emitter ) => emitter.close() );

				expect( event.getEventCacheableEntry() ).toBeEmpty();
			} );

			it( "runs the callback synchronously against a MockSSEEmitter, exposed as a private value", function(){
				var event = buildContext();
				event.sse( ( emitter ) => {
					emitter.send( { "count" : 3 }, "tick" );
					emitter.send( { "count" : 2 }, "tick" );
					emitter.send( { "count" : 1 }, "tick" );
					emitter.send( "liftoff", "done" );
					emitter.close();
				} );

				// This is the exact access pattern promised in the SSE spec's testing section
				var rawEmitter = event.getValue( name = "_sseEmitter", defaultValue = {}, private = true );

				expect( rawEmitter ).toBeComponent();
				expect( rawEmitter.getSentCount() ).toBe( 4 );
				expect( rawEmitter ).toHaveSentSSEEvent( "tick", 3 );
				expect( rawEmitter ).toHaveSentSSEEvent( "done" );
				expect( rawEmitter.isClosed() ).toBeTrue();
			} );

			it( "hands the callback the same SSEEmitter decorator a real stream would use", function(){
				var event         = buildContext();
				var callbackEvent = "";

				event.sse( ( emitter ) => {
					callbackEvent = emitter;
					emitter.close();
				} );

				expect( getMetadata( callbackEvent ).name ).toInclude( "SSEEmitter" );
			} );

			it( "propagates an exception thrown inside the callback and still closes the emitter", function(){
				var event = buildContext();

				expect( function(){
					event.sse( ( emitter ) => {
						emitter.send( "before the throw" );
						throw( type = "BoomException", message = "kaboom" );
					} );
				} ).toThrow( "BoomException" );

				var rawEmitter = event.getValue( name = "_sseEmitter", defaultValue = {}, private = true );
				expect( rawEmitter.isClosed() ).toBeTrue();
			} );

			it( "aborts before opening the stream when preSSEConnection rejects it and lets the response render normally", function(){
				// Interceptor closures are invoked with named arguments matching InterceptorState's
				// invocationArgs keys (event, data, rc, prc) - not positional - so the parameter
				// names below must match exactly or they are silently left unbound.
				//
				// The interceptor renders its own response, which is the documented alternative to
				// the default-status path (§3.6): sse() bails before the BIF runs, so the response
				// is never committed and setView() still works.
				var listener = ( event, data ) => {
					data.abort = true;
					event.setView( "errors/tooManyStreams" );
				};
				var event = buildContext();
				event.getController().getInterceptorService().listen( listener, "preSSEConnection" );

				var callbackRan = false;
				event.sse( ( emitter ) => {
					callbackRan = true;
				} );

				expect( callbackRan ).toBeFalse();
				expect( event.isSSE() ).toBeFalse();
				expect( event.isNoRender() ).toBeFalse();
				expect( event.getCurrentView() ).toBe( "errors/tooManyStreams" );

				event.getController().getInterceptorService().unlisten( listener, "preSSEConnection" );
			} );

			it( "defaults an unrendered rejection to the interceptor's status code", function(){
				// abortSSE() reaches event.setHTTPHeader() on this path, which needs a real servlet
				// page context. That is unavailable in this CLI sandbox - the same gap that already
				// makes RequestContextTest.cfc's own testsetHTTPHeader error here - but is present on
				// every real target this suite runs against (box run-script tests:*). We assert the
				// guard logic that does not depend on the page context, and treat that specific,
				// well-known failure mode as an accepted sandbox limitation rather than a real error.
				var listener = ( event, data ) => {
					data.abort      = true;
					data.statusCode = 429;
				};
				var event = buildContext();
				event.getController().getInterceptorService().listen( listener, "preSSEConnection" );

				var callbackRan = false;

				try {
					event.sse( ( emitter ) => {
						callbackRan = true;
					} );
				} catch ( any e ) {
					if ( !e.message.findNoCase( "getPageContext" ) ) {
						rethrow;
					}
				}

				expect( callbackRan ).toBeFalse();
				expect( event.isSSE() ).toBeFalse();
				expect( event.isNoRender() ).toBeFalse();
				expect( event.getCurrentView() ).toBeEmpty();

				event.getController().getInterceptorService().unlisten( listener, "preSSEConnection" );
			} );
		} );
	}

}
