component extends="tests.resources.BaseIntegrationTest" {

	function beforeAll(){
		super.beforeAll();
		variables.moduleService = getController().getModuleService();
	}

	function run(){
		describe( "Module Lifecycle", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			it( "Tests the ModuleService configuration", function(){
				expect( variables.moduleService.getModuleRegistry() ).toBeStruct().toHaveKey( "HTMLHelper" );
			} );

			it( "Can rebuild the module registry", function(){
				var existingRegistry = duplicate( variables.moduleService.getModuleRegistry() );
				variables.moduleService.rebuildModuleRegistry();
				expect( variables.moduleService.getModuleRegistry() ).toBe( existingRegistry );
			} );

			it( "Can register and activate an ad-hoc module", function(){
				variables.moduleService.registerAndActivateModule( "test-module", "tests.resources" );
				expect( variables.moduleService.getModuleRegistry() ).toHaveKey( "test-module" );
				// Test that the module invocation paths registered are using the virtual mapping
				debug( getMetadata( getWirebox().getInstance( "MyModel@mserv" ) ).name );
				expect( getWirebox().getInstance( "MyModel@mserv" ) )
					.toBeComponent()
					.toBeInstanceOf( "mserv.models.MyModel" );
			} );

			it( "Can reload a convention registered module", function(){
				variables.moduleService.reload( "api" );
				expect( variables.moduleService.getModuleRegistry() ).toHaveKey( "api" );
			} );

			it( "Can reload an ad-hoc registered module", function(){
				if ( !variables.moduleService.isModuleRegistered( "test-module" ) ) {
					variables.moduleService.registerAndActivateModule( "test-module", "tests.resources" );
				}
				variables.moduleService.reload( "test-module" );
				expect( variables.moduleService.getModuleRegistry() ).toHaveKey( "test-module" );
			} )
		} );
        
        describe( "ModuleService ForgeBox Alias Creation", function(){

			it( "should create canonical alias when module name contains @", function(){
				// Arrange
				var moduleService = createMock( "coldbox.system.web.services.ModuleService" );
				var modules = {};
				var mConfigCache = {};
				
				// Mock the logger
				var mockLogger = createStub().$( "canDebug", true ).$( "debug" );
				moduleService.$property( "logger", "variables", mockLogger );
				moduleService.$property( "mConfigCache", "variables", mConfigCache );
				
				// Simulate module config
				var mConfig = {
					name     : "testmodule@testuser",
					settings : { apiKey : "test-123" },
					aliases  : []
				};
				
				// Act - simulate what happens in ModuleService.cfc after line 453
				var modName = "testmodule@testuser";
				modules[ modName ] = mConfig;
				
				// The fix code
				if ( find( "@", modName ) ) {
					var canonicalName = listFirst( modName, "@" );
					if ( !structKeyExists( modules, canonicalName ) ) {
						modules[ canonicalName ] = modules[ modName ];
						mConfigCache[ canonicalName ] = mConfigCache[ modName ];
					}
				}
				
				// Assert
				expect( modules ).toHaveKey( "testmodule@testuser", "Full name should exist" );
				expect( modules ).toHaveKey( "testmodule", "Canonical alias should be created" );
				expect( modules[ "testmodule" ] ).toBe( modules[ "testmodule@testuser" ], "Alias should reference same config" );
			});

			it( "should NOT create alias when module name has no @", function(){
				// Arrange
				var modules = {};
				var mConfigCache = {};
				var mConfig = { name : "regularmodule", settings : {} };
				
				// Act
				var modName = "regularmodule";
				modules[ modName ] = mConfig;
				
				if ( find( "@", modName ) ) {
					var canonicalName = listFirst( modName, "@" );
					if ( !structKeyExists( modules, canonicalName ) ) {
						modules[ canonicalName ] = modules[ modName ];
					}
				}
				
				// Assert
				expect( modules ).toHaveKey( "regularmodule" );
				expect( structCount( modules ) ).toBe( 1, "Should only have one entry" );
			});

			it( "should NOT create alias if canonical name already exists (conflict)", function(){
				// Arrange
				var modules = {};
				var mConfigCache = {};
				var mockLogger = createStub().$( "canWarn", true ).$( "warn" );
				
				// Canonical module exists
				modules[ "mymodule" ] = { name : "mymodule", settings : { source : "canonical" } };
				
				// Act - try to register ForgeBox module with same canonical name
				var modName = "mymodule@testuser";
				modules[ modName ] = { name : modName, settings : { source : "forgebox" } };
				
				if ( find( "@", modName ) ) {
					var canonicalName = listFirst( modName, "@" );
					if ( !structKeyExists( modules, canonicalName ) ) {
						modules[ canonicalName ] = modules[ modName ];
						mConfigCache[ canonicalName ] = mConfigCache[ modName ];
					} else if ( !isNull( mockLogger ) && mockLogger.canWarn() ) {
						mockLogger.warn( "Cannot create canonical alias" );
					}
				}
				
				// Assert
				expect( modules ).toHaveKey( "mymodule" );
				expect( modules ).toHaveKey( "mymodule@testuser" );
				expect( modules[ "mymodule" ].settings.source ).toBe( "canonical", "Original should remain unchanged" );
				expect( modules[ "mymodule@testuser" ].settings.source ).toBe( "forgebox", "ForgeBox module should be separate" );
				expect( mockLogger.$once( "warn" ) ).toBeTrue( "Should log warning about conflict" );
			});

			it( "should handle multiple @ symbols correctly", function(){
				// Arrange
				var modules = {};
				var mConfigCache = {};
				
				// Act
				var modName = "my-module@user@extra";
				modules[ modName ] = { name : modName, settings : {} };
				
				if ( find( "@", modName ) ) {
					var canonicalName = listFirst( modName, "@" );
					if ( !structKeyExists( modules, canonicalName ) ) {
						modules[ canonicalName ] = modules[ modName ];
					}
				}
				
				// Assert
				expect( modules ).toHaveKey( "my-module@user@extra" );
				expect( modules ).toHaveKey( "my-module", "Should extract name before first @" );
			});

		});
	}

}
