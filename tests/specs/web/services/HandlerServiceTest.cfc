/**
 * Handler Service Tests
 */
component extends="tests.resources.BaseIntegrationTest" {

	function run( testResults, testBox ){
		describe( "Handler Service", () => {
			beforeEach( () => {
				setup();
				variables.handlerService = controller.getHandlerService();
			} );

			it( "can register handlers", () => {
				variables.handlerService.registerHandlers();

				var registered = getController().getSetting( "registeredHandlers" );
				expect( registered ).toBeStruct();
				expect( registered ).notToBeEmpty();

				var external = getController().getSetting( "registeredExternalHandlers" );
				expect( external ).toBeStruct();
				expect( external ).notToBeEmpty();
			} );

			it( "registered handlers include enrichment metadata", () => {
				variables.handlerService.registerHandlers();

				var registered = getController().getSetting( "registeredHandlers" );
				expect( registered ).toHaveKey( "main" );

				var mainHandler = registered[ "main" ];
				expect( mainHandler ).toHaveKey( "invocationPath" );
				expect( mainHandler ).toHaveKey( "runnable" );
				expect( mainHandler ).toHaveKey( "defaultEvent" );
				expect( mainHandler ).toHaveKey( "source" );
				expect( mainHandler ).toHaveKey( "moduleName" );

				expect( mainHandler.source ).toBe( "conventions" );
				expect( mainHandler.moduleName ).toBe( "" );
				expect( mainHandler.runnable ).toInclude( "main" );
				expect( mainHandler.defaultEvent ).toBe( "main.index" );
			} );

			it( "external handlers include enrichment metadata", () => {
				variables.handlerService.registerHandlers();

				var external = getController().getSetting( "registeredExternalHandlers" );
				expect( external ).toHaveKey( "ehTest" );

				var ehTestHandler = external[ "ehTest" ];
				expect( ehTestHandler ).toHaveKey( "invocationPath" );
				expect( ehTestHandler ).toHaveKey( "runnable" );
				expect( ehTestHandler ).toHaveKey( "defaultEvent" );
				expect( ehTestHandler ).toHaveKey( "source" );
				expect( ehTestHandler ).toHaveKey( "moduleName" );

				expect( ehTestHandler.source ).toBe( "external" );
				expect( ehTestHandler.moduleName ).toBe( "" );
				expect( ehTestHandler.defaultEvent ).toBe( "ehTest.index" );
			} );

			it( "module handlers include enrichment metadata", () => {
				var modules = getController().getSetting( "modules" );
				expect( modules ).toHaveKey( "resourcesTest" );

				var moduleHandlers = modules[ "resourcesTest" ].registeredHandlers;
				expect( moduleHandlers ).toBeStruct();
				expect( moduleHandlers ).toHaveKey( "Home" );

				var homeHandler = moduleHandlers[ "Home" ];
				expect( homeHandler ).toHaveKey( "invocationPath" );
				expect( homeHandler ).toHaveKey( "runnable" );
				expect( homeHandler ).toHaveKey( "defaultEvent" );
				expect( homeHandler ).toHaveKey( "source" );
				expect( homeHandler ).toHaveKey( "moduleName" );

				expect( homeHandler.source ).toBe( "module" );
				expect( homeHandler.moduleName ).toBe( "resourcesTest" );
				expect( homeHandler.runnable ).toInclude( "Home" );
				expect( homeHandler.defaultEvent ).toBe( "resourcesTest:Home.index" );
			} );

			it( "can recurse handler listings", () => {
				var path = expandPath( "/coldbox/test-harness/handlers" );
				makePublic( variables.handlerService, "getHandlerListing" );

				var handlers = variables.handlerService.getHandlerListing( path );
				expect( handlers ).toBeStruct();
				expect( handlers ).notToBeEmpty();
				expect( structCount( handlers ) ).toBeGT( 10 );

				// Verify structure includes metadata
				var firstKey = structKeyArray( handlers )[ 1 ];
				expect( handlers[ firstKey ] ).toHaveKey( "handler" );
				expect( handlers[ firstKey ] ).toHaveKey( "path" );
				expect( handlers[ firstKey ] ).toHaveKey( "extension" );
			} );

			it( "getHandlerListing returns struct with correct metadata", () => {
				var path = expandPath( "/coldbox/test-harness/handlers" );
				makePublic( variables.handlerService, "getHandlerListing" );

				var handlers = variables.handlerService.getHandlerListing( path );

				// Verify known handler exists
				expect( handlers ).toHaveKey( "main" );
				expect( handlers[ "main" ].handler ).toBe( "main" );
				expect( handlers[ "main" ].path ).toInclude( "main.cfc" );
				expect( handlers[ "main" ].extension ).toBe( "cfc" );
				expect( handlers[ "main" ].defaultEvent ).toBe( "main.index" );
			} );

			it( "uses registered handler default events for default action checks", () => {
				var context = getRequestContext();

				context.setValue( context.getEventName(), "main" );
				variables.handlerService.defaultActionCheck( context );
				expect( context.getCurrentEvent() ).toBe( "main.index" );

				context.setValue( context.getEventName(), "ehTest" );
				variables.handlerService.defaultActionCheck( context );
				expect( context.getCurrentEvent() ).toBe( "ehTest.index" );

				context.setValue( context.getEventName(), "resourcesTest:Home" );
				variables.handlerService.defaultActionCheck( context );
				expect( context.getCurrentEvent() ).toBe( "resourcesTest:Home.index" );
			} );

			it( "configures REST handler annotations as virtual inheritance", () => {
				var ehBean  = variables.handlerService.getHandlerBean( "restfulHandlerAnnotation.index" );
				var handler = variables.handlerService.newHandler( ehBean );
				var mapping = controller
					.getWireBox()
					.getBinder()
					.getMapping( ehBean.getRunnable() );

				expect( mapping.getVirtualInheritance() ).toBe( "coldbox.system.RestHandler" );
				expect( mapping.getExtraAttributes() ).toHaveKey( "restHandlerVirtualInheritanceConfigured" );
				expect( structKeyExists( handler, "restHandler" ) ).toBeTrue();
				expect( structKeyExists( handler, "aroundHandler" ) ).toBeTrue();
			} );

			describe( "Retrieve handler beans", () => {
				beforeEach( () => {
					variables.handlerService.setHandlerCaching( true );
				} );

				it( "with an invalid event", () => {
					var results = variables.handlerService.getHandlerBean( "invalid" );
					expect( results.getMethod() ).toBe( "onInvalidEvent" );
					expect( variables.handlerService.getHandlerBeanCacheDictionary() ).notToHaveKey( "invalid" );
				} );

				it( "with a valid handler event", () => {
					var results = variables.handlerService.getHandlerBean( "main.index" );
					expect( results.getMethod() ).toBe( "index" );
					expect( results.getHandler() ).toBe( "main" );
					expect( results.getFullEvent() ).toBe( "main.index" );
					expect( results.getRunnable() ).toBe( results.getHandlerRecord().runnable );
					expect( results.getDefaultEvent() ).toBe( results.getHandlerRecord().defaultEvent );
					expect( results.getHandlerSource() ).toBe( "conventions" );
					expect( variables.handlerService.getHandlerBeanCacheDictionary() ).toHaveKey( "main.index" );
				} );

				it( "with a valid external handler event", () => {
					var results = variables.handlerService.getHandlerBean( "ehTest.dspExternal" );
					expect( results.getMethod() ).toBe( "dspExternal" );
					expect( results.getHandler() ).toBe( "ehTest" );
					expect( results.getFullEvent() ).toBe( "ehTest.dspExternal" );
					expect( results.getRunnable() ).toBe( results.getHandlerRecord().runnable );
					expect( results.getDefaultEvent() ).toBe( results.getHandlerRecord().defaultEvent );
					expect( results.getHandlerSource() ).toBe( "external" );
					expect( variables.handlerService.getHandlerBeanCacheDictionary() ).toHaveKey( "ehTest.dspExternal" );
				} );

				it( "with a valid module Event", () => {
					var results = variables.handlerService.getHandlerBean( "resourcesTest:Home.index" );
					expect( results.getMethod() ).toBe( "index" );
					expect( results.getHandler() ).toBe( "Home" );
					expect( results.getModule() ).toBe( "resourcesTest" );
					expect( results.getFullEvent() ).toBe( "resourcesTest:Home.index" );
					expect( results.getRunnable() ).toBe( results.getHandlerRecord().runnable );
					expect( results.getDefaultEvent() ).toBe( results.getHandlerRecord().defaultEvent );
					expect( results.getHandlerSource() ).toBe( "module" );
					expect( variables.handlerService.getHandlerBeanCacheDictionary() ).toHaveKey(
						"resourcesTest:Home.index"
					);
				} );

				it( "with a valid view dispatch", () => {
					var results = variables.handlerService.getHandlerBean( "simpleview" );
					expect( results.getViewDispatch() ).toBe( true );
					expect( variables.handlerService.getHandlerBeanCacheDictionary() ).toHaveKey( "simpleview" );
				} );
			} );
		} );

		describe( "Hot-path caching optimizations", () => {
			beforeEach( () => {
				setup();
				variables.handlerService = controller.getHandlerService();
			} );

			it( "caches implicitViews setting in variables scope after configuration load", () => {
				// implicitViews must be a boolean cached from getSetting("ImplicitViews")
				expect( variables.handlerService.$getProperty( "implicitViews", "variables" ) ).toBeBoolean();
				expect( variables.handlerService.$getProperty( "implicitViews", "variables" ) ).toBeTrue();
			} );

			it( "isViewDispatch detects a view by extension without a filesystem call", () => {
				// simpleview exists — getHandlerBean triggers isViewDispatch internally
				// If the extension-check logic is wrong the viewDispatch flag won't be set
				var results = variables.handlerService.getHandlerBean( "simpleview" );
				expect( results.getViewDispatch() ).toBeTrue();
			} );

			it( "isViewDispatch returns false for an event with no matching view", () => {
				var results = variables.handlerService.getHandlerBean( "nonexistent_view_xyz" );
				expect( results.getViewDispatch() ).toBeFalse();
			} );
		} );
	}

}
