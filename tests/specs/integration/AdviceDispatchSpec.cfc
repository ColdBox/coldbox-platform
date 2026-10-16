/**
 * Advice methods (preHandler, postHandler, aroundHandler, pre/post/around{Action}) can't be requested as the action.
 * Fixture: test-harness/handlers/adviceDispatch.cfc
 */
component extends="tests.resources.BaseIntegrationTest" {

	function run(){
		describe( "Advice methods requested as actions", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request
				setup()
			} )

			var adviceEvents = [
				"adviceDispatch.preHandler",
				"adviceDispatch.postHandler",
				"adviceDispatch.aroundHandler",
				"adviceDispatch.preIndex",
				"adviceDispatch.PREINDEX",
				"adviceDispatch.preview"
			]

			for ( var adviceEvent in adviceEvents ) {
				it(
					title = "rejects #adviceEvent# as an invalid event",
					data  = { event : adviceEvent },
					body  = function( data ){
						var e   = execute( event = data.event, renderResults = true )
						var prc = e.getPrivateCollection()

						expect( prc.invalidevent ?: "" ).toBe( data.event )
						expect( e.getStatusCode() ).toBe( 404 )
						expect( e.getRenderedContent() ).toInclude( "Invalid Page" )
						// Nothing in the advice handler ran
						expect( prc.keyExists( "ran" ) ).toBeFalse()
					}
				)
			}

			it( "runs a normal action with its automatic advice", function(){
				var e = execute( event = "adviceDispatch.index", renderResults = true )

				expect( e.getRenderedContent() ).toInclude( "ADVICE-INDEX-OK" )
				expect( e.getPrivateValue( "ran" ).toList() ).toBe( "preHandler,preIndex,aroundHandler,index,postHandler" )
			} )

			it( "still runs preview() as advice for view()", function(){
				var e = execute( event = "adviceDispatch.view", renderResults = true )

				expect( e.getRenderedContent() ).toInclude( "ADVICE-VIEW-OK" )
				expect( e.getPrivateValue( "ran" ).toList() ).toBe( "preHandler,preview,aroundHandler,view,postHandler" )
			} )

			it( "runs an action that starts with pre but advises no action", function(){
				var e = execute( event = "adviceDispatch.preflight", renderResults = true )

				expect( e.getRenderedContent() ).toInclude( "ADVICE-PREFLIGHT-OK" )
				expect( e.getPrivateValue( "ran" ).toList() ).toBe( "preHandler,aroundHandler,preflight,postHandler" )
			} )

			it( "lets handler code run an advice method with runEvent()", function(){
				var e = execute( event = "adviceDispatch.internalAdvice", renderResults = true )

				expect( e.getRenderedContent() ).toInclude( "ADVICE-INTERNAL-OK" )
				expect( e.getPrivateValue( "ran" ).toList() ).toBe(
					"preHandler,aroundHandler,internalAdvice,preHandler:action,postHandler"
				)
			} )
		} )
	}

}
