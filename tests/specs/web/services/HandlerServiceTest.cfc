/**
 * Handler Service Tests
 */
component extends="tests.resources.BaseIntegrationTest" {

	function run( testResults, testBox ){
		describe( "Handler Service", function(){
			beforeEach( function(){
				setup();
				variables.handlerService = controller.getHandlerService();
			} );

			it( "can register handlers", function(){
				variables.handlerService.registerHandlers();

				var registered = getController().getSetting( "registeredHandlers" );
				expect( registered ).toBeStruct();
				expect( registered ).notToBeEmpty();

				var external = getController().getSetting( "registeredExternalHandlers" );
				expect( external ).toBeStruct();
				expect( external ).notToBeEmpty();
			} );

			it( "registered handlers include enrichment metadata", function(){
				variables.handlerService.registerHandlers();

				var registered = getController().getSetting( "registeredHandlers" );
				expect( registered ).toHaveKey( "main" );

				var mainHandler = registered[ "main" ];
				expect( mainHandler ).toHaveKey( "invocationPath" );
				expect( mainHandler ).toHaveKey( "runnable" );
				expect( mainHandler ).toHaveKey( "source" );
				expect( mainHandler ).toHaveKey( "moduleName" );

				expect( mainHandler.source ).toBe( "conventions" );
				expect( mainHandler.moduleName ).toBe( "" );
				expect( mainHandler.runnable ).toInclude( "main" );
			} );

			it( "external handlers include enrichment metadata", function(){
				variables.handlerService.registerHandlers();

				var external = getController().getSetting( "registeredExternalHandlers" );
				expect( external ).toHaveKey( "ehTest" );

				var ehTestHandler = external[ "ehTest" ];
				expect( ehTestHandler ).toHaveKey( "invocationPath" );
				expect( ehTestHandler ).toHaveKey( "runnable" );
				expect( ehTestHandler ).toHaveKey( "source" );
				expect( ehTestHandler ).toHaveKey( "moduleName" );

				expect( ehTestHandler.source ).toBe( "external" );
				expect( ehTestHandler.moduleName ).toBe( "" );
			} );

			it( "module handlers include enrichment metadata", function(){
				var modules = getController().getSetting( "modules" );
				expect( modules ).toHaveKey( "resourcesTest" );

				var moduleHandlers = modules[ "resourcesTest" ].registeredHandlers;
				expect( moduleHandlers ).toBeStruct();
				expect( moduleHandlers ).toHaveKey( "Home" );

				var homeHandler = moduleHandlers[ "Home" ];
				expect( homeHandler ).toHaveKey( "invocationPath" );
				expect( homeHandler ).toHaveKey( "runnable" );
				expect( homeHandler ).toHaveKey( "source" );
				expect( homeHandler ).toHaveKey( "moduleName" );

				expect( homeHandler.source ).toBe( "module" );
				expect( homeHandler.moduleName ).toBe( "resourcesTest" );
				expect( homeHandler.runnable ).toInclude( "Home" );
			} );

			it( "can recurse handler listings", function(){
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

			it( "getHandlerListing returns struct with correct metadata", function(){
				var path = expandPath( "/coldbox/test-harness/handlers" );
				makePublic( variables.handlerService, "getHandlerListing" );

				var handlers = variables.handlerService.getHandlerListing( path );

				// Verify known handler exists
				expect( handlers ).toHaveKey( "main" );
				expect( handlers[ "main" ].handler ).toBe( "main" );
				expect( handlers[ "main" ].path ).toInclude( "main.cfc" );
				expect( handlers[ "main" ].extension ).toBe( "cfc" );
			} );

			it( "configures REST handler annotations as virtual inheritance", function(){
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

			describe( "Retrieve handler beans", function(){
				beforeEach( function(){
					variables.handlerService.setHandlerCaching( true );
				} );

				it( "with an invalid event", function(){
					var results = variables.handlerService.getHandlerBean( "invalid" );
					expect( results.getMethod() ).toBe( "onInvalidEvent" );
					expect( variables.handlerService.getHandlerBeanCacheDictionary() ).notToHaveKey( "invalid" );
				} );

				it( "with a valid handler event", function(){
					var results = variables.handlerService.getHandlerBean( "main.index" );
					expect( results.getMethod() ).toBe( "index" );
					expect( results.getHandler() ).toBe( "main" );
					expect( variables.handlerService.getHandlerBeanCacheDictionary() ).toHaveKey( "main.index" );
				} );

				it( "with a valid external handler event", function(){
					var results = variables.handlerService.getHandlerBean( "ehTest.dspExternal" );
					expect( results.getMethod() ).toBe( "dspExternal" );
					expect( results.getHandler() ).toBe( "ehTest" );
					expect( variables.handlerService.getHandlerBeanCacheDictionary() ).toHaveKey( "ehTest.dspExternal" );
				} );

				it( "with a valid module Event", function(){
					var results = variables.handlerService.getHandlerBean( "resourcesTest:Home.index" );
					expect( results.getMethod() ).toBe( "index" );
					expect( results.getHandler() ).toBe( "Home" );
					expect( results.getModule() ).toBe( "resourcesTest" );
					expect( variables.handlerService.getHandlerBeanCacheDictionary() ).toHaveKey(
						"resourcesTest:Home.index"
					);
				} );

				it( "with a valid view dispatch", function(){
					var results = variables.handlerService.getHandlerBean( "simpleview" );
					expect( results.getViewDispatch() ).toBe( true );
					expect( variables.handlerService.getHandlerBeanCacheDictionary() ).toHaveKey( "simpleview" );
				} );
			} );
		} );
	}

}
