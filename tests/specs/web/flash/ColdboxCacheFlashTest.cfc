component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.web.flash.ColdboxCacheFlash" {

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "ColdBox Cache Flash", function(){
			beforeEach( function(){
				setup();
				flash = model;

				// mocks
				session.sessionid = createUUID();
				mockController    = createMock( className = "coldbox.system.web.Controller", clearMethods = true );
				mockCache         = createMock(
					className    = "coldbox.system.cache.providers.CacheBoxProvider",
					clearMethods = true
				);
				mockController.$( "getCache", mockCache ).$( "settingExists", false );

				// Init Flash
				flash.init( mockController );
				obj = new coldbox.system.core.util.CFMLEngine();

				// test scope
				testscope = {
					test : { content : "luis", autoPurge : true, keep : true },
					date : { content : now(), autoPurge : true, keep : true },
					obj  : { content : obj, autoPurge : true, keep : true }
				};
			} );

			it( "can clear the flash scope", function(){
				flash.$( "flashExists", true );
				mockCache.$( "clear", true ).$( "get", testScope );
				flash.clearFlash();
				expect( arrayLen( mockCache.$callLog().clear ) ).toBeTrue();
			} );

			it( "can save the flash scope", function(){
				flash.$( "getScope", testscope );
				mockCache.$( "set", true );
				flash.saveFlash();
				expect( arrayLen( mockCache.$callLog().set ) ).toBeTrue();
			} );

			it( "can check if the flash scope exists", function(){
				mockCache.$( "lookup", true );
				expect( flash.flashExists() ).toBeTrue();
			} );

			it( "can get the flash scope", function(){
				mockCache.$( "get", testScope );
				flash.$( "flashExists", true );
				expect( flash.getFlash() ).toBe( testScope );
			} );
		} );
	}

}
