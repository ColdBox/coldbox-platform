/**
 * SSEEmitter Tests — the ColdBox decorator over the BoxLang SSE emitter.
 *
 * SSE is a BoxLang-only feature (see docs/specs/sse-streaming.md), so this whole suite is
 * excluded on any other engine, matching the pattern already established in RouterAITest.cfc.
 * The decorator itself never touches the `SSE()` BIF - it just wraps whatever emitter it is
 * handed - but keeping the entire SSE test surface BoxLang-gated is a single, easy to reason
 * about policy rather than a per-file judgment call.
 */
component extends="coldbox.system.testing.BaseModelTest" skip="notBoxlang" {

	boolean function notBoxlang(){
		return !isBoxLang();
	}

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		variables.mockController = getMockController();
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		if ( notBoxlang() ) {
			return;
		}

		describe( "SSEEmitter", function(){
			beforeEach( function( currentSpec ){
				variables.mockEmitter = new coldbox.system.testing.mock.web.MockSSEEmitter();
				variables.emitter     = new coldbox.system.web.context.SSEEmitter(
					variables.mockEmitter,
					variables.mockController
				);
			} );

			it( "can be created and starts with an empty frame count", function(){
				expect( variables.emitter ).toBeComponent();
				expect( variables.emitter.getSentCount() ).toBe( 0 );
			} );

			describe( "open and closed state", function(){
				it( "reports open while the client is connected", function(){
					expect( variables.emitter.isOpen() ).toBeTrue();
					expect( variables.emitter.isClosed() ).toBeFalse();
				} );

				it( "inverts isOpen() once closed", function(){
					variables.emitter.close();
					expect( variables.emitter.isClosed() ).toBeTrue();
					expect( variables.emitter.isOpen() ).toBeFalse();
				} );

				it( "is safe to close more than once", function(){
					expect( () => variables.emitter.close().close() ).notToThrow();
					expect( variables.emitter.isClosed() ).toBeTrue();
				} );
			} );

			describe( "sending frames", function(){
				it( "sends a simple payload", function(){
					variables.emitter.send( "hello" );

					expect( variables.mockEmitter.getSentCount() ).toBe( 1 );
					expect( variables.mockEmitter.getFirstData() ).toBe( "hello" );
					expect( variables.emitter.getSentCount() ).toBe( 1 );
				} );

				it( "sends a named event", function(){
					variables.emitter.send( "tick", "heartbeat" );

					expect( variables.mockEmitter ).toHaveSentSSEEvent( "heartbeat" );
				} );

				it( "sends a named event with an id", function(){
					variables.emitter.send( "tick", "heartbeat", "42" );

					var frame = variables.mockEmitter.getSentEvents()[ 1 ];
					expect( frame.event ).toBe( "heartbeat" );
					expect( frame.id ).toBe( "42" );
				} );

				it( "passes complex payloads through untouched for the runtime to serialize", function(){
					variables.emitter.send( { "count" : 10, "label" : "ten" }, "tick" );

					var data = variables.mockEmitter.getFirstData();
					expect( data ).toBeStruct();
					expect( data.count ).toBe( 10 );
				} );

				it( "counts every frame it sends", function(){
					variables.emitter.send( "a" ).send( "b" ).send( "c" );

					expect( variables.emitter.getSentCount() ).toBe( 3 );
				} );

				it( "is fluent", function(){
					expect( variables.emitter.send( "a" ) ).toBe( variables.emitter );
				} );
			} );

			describe( "disconnect safety", function(){
				it( "silently drops sends after the client disconnects", function(){
					variables.emitter.send( "before" );
					variables.mockEmitter.simulateDisconnect();

					expect( () => variables.emitter.send( "after" ) ).notToThrow();
					expect( variables.mockEmitter.getSentCount() ).toBe( 1 );
					expect( variables.emitter.getSentCount() ).toBe( 1 );
				} );

				it( "does not increment the frame count for dropped sends", function(){
					variables.mockEmitter.simulateDisconnect();
					variables.emitter.send( "a" ).send( "b" );

					expect( variables.emitter.getSentCount() ).toBe( 0 );
				} );

				it( "drops comments after disconnect", function(){
					variables.mockEmitter.simulateDisconnect();
					variables.emitter.comment( "still there?" );

					expect( variables.mockEmitter.getComments() ).toBeEmpty();
				} );
			} );

			describe( "comments and keep-alives", function(){
				it( "sends a comment", function(){
					variables.emitter.comment( "ping" );

					expect( variables.mockEmitter.getComments() ).toInclude( "ping" );
				} );

				it( "sends a keep-alive heartbeat", function(){
					variables.emitter.heartbeat();

					expect( variables.mockEmitter.getComments() ).toInclude( "keep-alive" );
				} );

				it( "does not count comments as frames", function(){
					variables.emitter.comment( "ping" ).heartbeat();

					expect( variables.emitter.getSentCount() ).toBe( 0 );
				} );
			} );

			describe( "line ending normalization", function(){
				it( "normalizes CRLF to LF so Windows authored views do not leak carriage returns", function(){
					variables.emitter.send( "line one#chr( 13 )##chr( 10 )#line two" );

					var data = variables.mockEmitter.getFirstData();
					expect( data.find( chr( 13 ) ) ).toBe( 0 );
					expect( data ).toBe( "line one#chr( 10 )#line two" );
				} );

				it( "normalizes a bare CR to LF", function(){
					variables.emitter.send( "line one#chr( 13 )#line two" );

					expect( variables.mockEmitter.getFirstData() ).toBe( "line one#chr( 10 )#line two" );
				} );

				it( "preserves multi-line content rather than collapsing it", function(){
					variables.emitter.send( "a#chr( 13 )##chr( 10 )#b#chr( 13 )##chr( 10 )#c" );

					expect( variables.mockEmitter.getFirstData().listLen( chr( 10 ) ) ).toBe( 3 );
				} );

				it( "leaves complex payloads alone", function(){
					expect( () => variables.emitter.send( { "a" : 1 } ) ).notToThrow();
					expect( variables.mockEmitter.getFirstData() ).toBeStruct();
				} );
			} );

			describe( "sendIf()", function(){
				it( "sends when the condition is true", function(){
					variables.emitter.sendIf( true, "yes", "gated" );

					expect( variables.mockEmitter ).toHaveSentSSEEvent( "gated" );
				} );

				it( "does not send when the condition is false", function(){
					variables.emitter.sendIf( false, "no", "gated" );

					expect( variables.mockEmitter.getSentCount() ).toBe( 0 );
				} );
			} );

			describe( "sendError()", function(){
				it( "emits a conventional error frame", function(){
					variables.emitter.sendError( "Something broke", "E_BROKE" );

					expect( variables.mockEmitter ).toHaveSentSSEEvent( "error" );

					var data = variables.mockEmitter.getFirstData();
					expect( data.error ).toBe( "Something broke" );
					expect( data.code ).toBe( "E_BROKE" );
				} );

				it( "allows an empty code", function(){
					variables.emitter.sendError( "Something broke" );

					expect( variables.mockEmitter.getFirstData().code ).toBe( "" );
				} );
			} );

			describe( "rendering helpers", function(){
				beforeEach( function( currentSpec ){
					variables.mockRenderer = createStub()
						.$( "view", "<article>rendered view</article>" )
						.$( "layout", "<html>rendered layout</html>" );
					variables.mockController.$( "getRenderer", variables.mockRenderer );
				} );

				it( "renders a view and sends it as one frame", function(){
					variables.emitter.sendView(
						view  = "posts/_card",
						args  = { post : "one" },
						event = "newPost"
					);

					expect( variables.mockEmitter ).toHaveSentSSEEvent( "newPost" );
					expect( variables.mockEmitter.getFirstData() ).toBe( "<article>rendered view</article>" );
				} );

				it( "renders through the layout when one is given", function(){
					variables.emitter.sendView(
						view   = "posts/_card",
						layout = "Main",
						event  = "newPost"
					);

					expect( variables.mockEmitter.getFirstData() ).toBe( "<html>rendered layout</html>" );
				} );

				it( "renders a layout directly", function(){
					variables.emitter.sendLayout( layout = "Main", event = "page" );

					expect( variables.mockEmitter ).toHaveSentSSEEvent( "page" );
					expect( variables.mockEmitter.getFirstData() ).toBe( "<html>rendered layout</html>" );
				} );

				it( "does not render at all once the client has disconnected", function(){
					variables.mockEmitter.simulateDisconnect();
					variables.emitter.sendView( view = "posts/_card" );

					expect( variables.mockEmitter.getSentCount() ).toBe( 0 );
					expect( variables.mockRenderer.$never( "view" ) ).toBeTrue();
				} );
			} );

			describe( "sendData()", function(){
				it( "marshalls through the DataMarshaller", function(){
					var mockMarshaller = createStub().$( "marshallData", '{"ok":true}' );
					variables.mockController.$( "getDataMarshaller", mockMarshaller );

					variables.emitter.sendData( data = { ok : true }, type = "json", event = "payload" );

					expect( variables.mockEmitter ).toHaveSentSSEEvent( "payload" );
					expect( variables.mockEmitter.getFirstData() ).toBe( '{"ok":true}' );
				} );
			} );

			describe( "the toHaveSentSSEEvent matcher", function(){
				it( "can assert an exact frame count for an event name", function(){
					variables.emitter.send( "1", "tick" ).send( "2", "tick" );

					expect( variables.mockEmitter ).toHaveSentSSEEvent( "tick", 2 );
				} );
			} );
		} );
	}

}
