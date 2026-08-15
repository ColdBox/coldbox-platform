/**
 * RequestContext SSE Tests — the streaming API surface on the request context.
 *
 * The `sse()` call itself needs a live BoxLang web response, so the suites that would open a
 * stream are skipped off BoxLang. Everything around it — the runtime guard, content
 * negotiation predicates, and module aware setting resolution — is asserted on every engine.
 */
component extends="coldbox.system.testing.BaseModelTest" {

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

		return prepareMock( new coldbox.system.web.context.RequestContext( props, mockController ) );
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		describe( "RequestContext SSE support", function(){
			describe( "runtime detection", function(){
				it( "reports support based purely on the server scope", function(){
					var event = buildContext();

					expect( event.isSSESupported() ).toBe( server.keyExists( "boxlang" ) );
				} );

				it( "throws a clear exception when streaming on a runtime without the BIF", function(){
					if ( isBoxLang() ) {
						return;
					}

					var event = buildContext();

					expect( () => event.sse( ( emitter ) => {} ) ).toThrow( "SSENotSupportedException" );
				} );

				it( "does not mark the request as SSE when the guard rejects it", function(){
					if ( isBoxLang() ) {
						return;
					}

					var event = buildContext();

					try {
						event.sse( ( emitter ) => {} );
					} catch ( SSENotSupportedException e ) {
					}

					expect( event.isSSE() ).toBeFalse();
					expect( event.isNoRender() ).toBeFalse();
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

		describe( "RequestContext SSE streaming", function(){
			// Opening a real stream needs a live BoxLang web response
			it( "takes over the response when a stream opens", function(){
				if ( notBoxlang() ) {
					return;
				}

				var event = buildContext();

				try {
					event.sse( ( emitter ) => emitter.close() );
				} catch ( any e ) {
					// A test harness has no real HTTP response to stream into. What matters is
					// that the request was flagged and rendering suppressed before the BIF ran.
				}

				expect( event.isSSE() ).toBeTrue();
				expect( event.isNoRender() ).toBeTrue();
			} );

			it( "discards any event cache entry so an empty response is never cached", function(){
				if ( notBoxlang() ) {
					return;
				}

				var event = buildContext();
				event.setEventCacheableEntry( { cachekey : "should-be-gone", provider : "template" } );

				try {
					event.sse( ( emitter ) => emitter.close() );
				} catch ( any e ) {
				}

				expect( event.getEventCacheableEntry() ).toBeEmpty();
			} );
		} );
	}

}
