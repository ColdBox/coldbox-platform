component extends="testbox.system.BaseSpec" {

	function run(){
		describe( "Bootstrap onSessionStart", function(){
			beforeEach( function(){
				variables.appKey       = "bootstrapSpec" & replace( createUUID(), "-", "", "all" )
				variables.bootstrap    = new coldbox.system.Bootstrap( "", expandPath( "/" ), appKey )
				variables.interceptors = createStub().$( "announce" )
				variables.controller   = createStub()
					.$( "getColdboxInitiated", false )
					.$( "getInterceptorService", interceptors )
					.$( "getSetting", "Main.onSessionStart" )
					.$( "runEvent" )
			} );

			afterEach( function(){
				structDelete( application, appKey )
			} );

			it( "does nothing while the controller is not in application scope", function(){
				bootstrap.onSessionStart()
				expect( controller.$count( "runEvent" ) ).toBe( 0 )
			} );

			it( "does nothing while the controller is not initiated, as during a reinit", function(){
				application[ appKey ] = controller
				bootstrap.onSessionStart()
				expect( interceptors.$count( "announce" ) ).toBe( 0 )
				expect( controller.$count( "runEvent" ) ).toBe( 0 )
			} );

			it( "runs the session start once the controller is initiated", function(){
				application[ appKey ] = controller
				controller.$( "getColdboxInitiated", true )
				bootstrap.onSessionStart()
				expect( interceptors.$count( "announce" ) ).toBe( 1 )
				expect( controller.$count( "runEvent" ) ).toBe( 1 )
			} );
		} );
	}

}
