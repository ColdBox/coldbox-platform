component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Application configuration executor registration", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			story( "I want to register executors in my app config", function(){
				then( "it should register them upon startup", function(){
					var e = this.get( event = "main.index" );
					expect( getController().getSetting( "executors" ) ).notToBeEmpty();
					expect( getInstance( "AsyncManager@coldbox" ).hasExecutor( "simpleTaskRunner" ) ).toBeTrue();
					expect( getInstance( "AsyncManager@coldbox" ).hasExecutor( "scheduledTasks" ) ).toBeTrue();
				} );
			} );

			story( "I want to register executors in my ModuleConfig", function(){
				then( "it should register them upon startup", function(){
					expect( getController().getAsyncManager().hasExecutor( "resourcesPool" ) ).toBeTrue();
				} );
				then( "it should delete them upon unLoading", function(){
					expect( getController().getAsyncManager().hasExecutor( "resourcesPool" ) ).toBeTrue();
					getController().getModuleService().unload( "resourcesTest" );
					expect( getController().getAsyncManager().hasExecutor( "resourcesPool" ) ).toBeFalse();

					// Load it back up, we need it :)
					getController().getModuleService().registerAndActivateModule( "resourcesTest" );
					expect( getController().getAsyncManager().hasExecutor( "resourcesPool" ) ).toBeTrue();
				} );
			} );
		} );
	}

}
