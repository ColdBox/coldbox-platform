component extends="testbox.system.BaseSpec" {

	function run(){
		describe( "Bootstrap session start while the controller is not ready", function(){
			beforeEach( function(){
				variables.appKey     = "bootstrapSpec" & replace( createUUID(), "-", "", "all" )
				variables.pendingKey = "coldboxPendingSessionStart_" & appKey
				// a fail-fast closure keeps the reinit branch from writing a 503 header onto the runner response
				variables.bootstrap  = prepareMock(
					new coldbox.system.Bootstrap(
						"",
						expandPath( "/" ),
						appKey,
						"",
						function(){
						}
					)
				)
				bootstrap.$( "reloadChecks" )
				variables.interceptors = createStub().$( "announce" )
				variables.modules      = createStub().$( "loadMappings" )
				variables.controller   = createStub()
					.$( "getColdboxInitiated", false )
					.$( "getInterceptorService", interceptors )
					.$( "getModuleService", modules )
					.$( "getSetting", "Main.onSessionStart" )
					.$( "runEvent" )
				variables.priorReinit = application.fwReinit ?: false
			} );

			afterEach( function(){
				structDelete( application, appKey )
				structDelete( session, pendingKey )
				application.fwReinit = priorReinit
			} );

			it( "runs a session start at once when the controller is initiated and clears an earlier deferral", function(){
				application[ appKey ] = controller
				controller.$( "getColdboxInitiated", true )
				session[ pendingKey ] = true
				bootstrap.onSessionStart()
				expect( controller.$count( "runEvent" ) ).toBe( 1 )
				expect( interceptors.$count( "announce" ) ).toBe( 1 )
				expect( session.keyExists( pendingKey ) ).toBeFalse()

				bootstrap.onRequestStart( "probe.cfm" )
				expect( controller.$count( "runEvent" ) ).toBe( 1 )
			} );

			it( "defers a session start while no controller exists", function(){
				bootstrap.onSessionStart()
				expect( session[ pendingKey ] ).toBeTrue()
				expect( controller.$count( "runEvent" ) ).toBe( 0 )
			} );

			it( "defers a session start while a reinit rebuilds the controller and dispatches it exactly once", function(){
				application[ appKey ] = controller
				bootstrap.onSessionStart()
				expect( controller.$count( "runEvent" ) ).toBe( 0 )
				expect( interceptors.$count( "announce" ) ).toBe( 0 )

				controller.$( "getColdboxInitiated", true )
				bootstrap.onRequestStart( "probe.cfm" )
				bootstrap.onRequestStart( "probe.cfm" )
				expect( controller.$count( "runEvent" ) ).toBe( 1 )
				expect( interceptors.$count( "announce" ) ).toBe( 1 )
				expect( session.keyExists( pendingKey ) ).toBeFalse()
			} );

			it( "keeps a deferred session start across a request that fails fast during the reinit", function(){
				application[ appKey ] = controller
				bootstrap.onSessionStart()
				application.fwReinit = true
				expect( bootstrap.onRequestStart( "probe.cfm" ) ).toBeFalse()
				expect( session[ pendingKey ] ).toBeTrue()

				application.fwReinit = false
				controller.$( "getColdboxInitiated", true )
				bootstrap.onRequestStart( "probe.cfm" )
				expect( controller.$count( "runEvent" ) ).toBe( 1 )
				expect( session.keyExists( pendingKey ) ).toBeFalse()
			} );
		} );
	}

}
