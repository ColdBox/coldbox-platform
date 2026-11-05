/**
 * Specs for the a-la-carte autowire() of the injector
 */
component extends="tests.resources.BaseIntegrationTest" {

	this.loadColdBox = false;

	function run( testResults, testBox ){
		describe( "Injector a-la-carte autowire()", function(){
			beforeEach( function( currentSpec ){
				injector = new coldbox.system.ioc.Injector( { scopeRegistration : { enabled : false } } );
				injector
					.getBinder()
					.map( "Dep" )
					.toValue( { name : "dep" } );
				widget = createObject( "component", "tests.resources.AlaCarteWidget" );
				path   = injector
					.getUtility()
					.getInheritedMetaData( widget, injector.getBinder().getStopRecursions() )
					.path;
			} );

			story( "I want to wire an object that has no mapping yet", function(){
				given( "an object the injector has never seen", function(){
					then( "it injects its dependencies and discovers its mapping", function(){
						injector.autowire( widget );

						expect( isNull( widget.getDep() ) ).toBeFalse();
						expect(
							injector
								.getBinder()
								.getMapping( path )
								.isDiscovered()
						).toBeTrue();
					} );
				} );
			} );

			story( "I want to wire an object whose mapping already exists", function(){
				given( "a mapping that was already discovered", function(){
					then( "it injects its dependencies", function(){
						injector.autowire( createObject( "component", "tests.resources.AlaCarteWidget" ) );
						injector.autowire( widget );

						expect( isNull( widget.getDep() ) ).toBeFalse();
					} );
				} );

				given( "a mapping another thread registered but has not processed yet", function(){
					then( "it processes the mapping and injects its dependencies", function(){
						// The state a second thread sees when a first one has registered the mapping but has not processed it
						injector.registerNewInstance( path, path );
						expect(
							injector
								.getBinder()
								.getMapping( path )
								.isDiscovered()
						).toBeFalse();

						injector.autowire( widget );

						expect( isNull( widget.getDep() ) ).toBeFalse();
						expect(
							injector
								.getBinder()
								.getMapping( path )
								.isDiscovered()
						).toBeTrue();
					} );
				} );

				given( "a target ID and a mapping that is registered but not processed yet", function(){
					then( "it processes the mapping and injects its dependencies", function(){
						injector.registerNewInstance( path, path );

						injector.autowire( target = widget, targetID = path );

						expect( isNull( widget.getDep() ) ).toBeFalse();
					} );
				} );
			} );
		} );
	}

}
