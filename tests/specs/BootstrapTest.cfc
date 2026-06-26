component extends="coldbox.system.testing.BaseModelTest" {

	function run( testResults, testBox ){
		describe( "Bootstrap", function(){
			beforeEach( function(){
				param name="application.applicationname" default="cbtestharness"

				structDelete( application, "cbController" )
				structDelete( application, "fwReinit" )
				structDelete( request, "cb_requestContext" )
				structDelete( url, "fwreinit" )
			} )

			afterEach( function(){
				structDelete( application, "cbController" )
				structDelete( application, "fwReinit" )
				structDelete( request, "cb_requestContext" )
				structDelete( url, "fwreinit" )
			} )

			it( "initializes appHash before loadColdBox runs", function(){
				var bootstrap = createMock( "coldbox.system.Bootstrap" ).init(
					"/cbtestharness/config/Coldbox.cfc",
					expandPath( "/coldbox/test-harness" ),
					"cbController"
				)

				expect( bootstrap.getAppHash() ).toBe( hash( getBaseTemplatePath() & application.applicationname ) )
			} )

			it( "can enter reloadChecks before loadColdBox initializes the framework", function(){
				var bootstrap = createMock( "coldbox.system.Bootstrap" ).init(
					"/cbtestharness/config/Coldbox.cfc",
					expandPath( "/coldbox/test-harness" ),
					"cbController"
				)
				var mockController = createEmptyMock( "coldbox.system.web.Controller" )

				mockController
					.$( "getColdboxInitiated" )
					.$results( false, true )
					.$( "getSetting" )
					.$args( "Wirebox" )
					.$results( { singletonReload : false } )
					.$( "getSetting" )
					.$args( "HandlersIndexAutoReload" )
					.$results( false )

				application.cbController = mockController

				bootstrap
					.$( "locateAppKey", "cbController" )
					.$( "isfwReinit", false )

				bootstrap.reloadChecks()

				expect( bootstrap.getAppHash() ).notToBeEmpty()
			} )
		} )
	}

}
