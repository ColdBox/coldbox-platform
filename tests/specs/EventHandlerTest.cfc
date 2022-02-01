/**
 * My BDD Test
 */
component extends="coldbox.system.testing.BaseModelTest" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
		handler        = createMock( "coldbox.system.EventHandler" );
		mockController = createMock( "coldbox.system.web.Controller" );
		flashScope     = createEmptyMock( "coldbox.system.web.flash.MockFlash" );
		mockRS         = createEmptyMock( "coldbox.system.web.services.RequestService" ).$( "getFlashScope", flashScope );
		mockLogger     = createEmptyMock( "coldbox.system.logging.Logger" );
		mockLogBox     = createEmptyMock( "coldbox.system.logging.LogBox" ).$( "getLogger", mockLogger );
		mockCache      = createEmptyMock( "coldbox.system.cache.providers.CacheBoxColdBoxProvider" );
		mockCacheBox   = createEmptyMock( "coldbox.system.cache.CacheFactory" ).$( "getCache", mockCache );
		mockWireBox    = createEmptyMock( "coldbox.system.ioc.Injector" );

		mockController.$( "getRequestService", mockRS );

		mockController.setLogBox( mockLogBox );
		mockController.setWireBox( mockWireBox );
		mockController.setCacheBox( mockCacheBox );

		mockController
			.$( "getSetting" )
			.$args( "applicationHelper" )
			.$results( [
				"/tests/resources/mixins.cfm",
				"/tests/resources/mixins2"
			] )
			.$( "getSetting" )
			.$args( "AppMapping" )
			.$results( "/coldbox/testing" );

		mockCache.$( "getOrSet" ).$results( "/tests/resources/mixins.cfm", "/tests/resources/mixins2.cfm" );
		handler.init( mockController );
	}

	/**
	 * executes after all suites+specs in the run() method
	 */
	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Event Handler", function(){
			it( "can load up mixins in isolation", function(){
				expect( structKeyExists( handler, "mixinTest" ) ).toBeTrue();
				expect( structKeyExists( handler, "repeatThis" ) ).toBeTrue();
				expect( structKeyExists( handler, "add" ) ).toBeTrue();
			} );
		} );
	}

}
