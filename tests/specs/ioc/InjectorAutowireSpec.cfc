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

			it( "wires an object the first time it is seen", function(){
				injector.autowire( widget );

				expect( isNull( widget.getDep() ) ).toBeFalse();
				expect(
					injector
						.getBinder()
						.getMapping( path )
						.isDiscovered()
				).toBeTrue();
			} );

			it( "wires an object whose mapping is already discovered", function(){
				injector.autowire( createObject( "component", "tests.resources.AlaCarteWidget" ) );
				injector.autowire( widget );

				expect( isNull( widget.getDep() ) ).toBeFalse();
			} );

			it( "wires an object whose mapping is registered but not processed yet", function(){
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

			it( "wires an object by target ID whose mapping is registered but not processed yet", function(){
				injector.registerNewInstance( path, path );

				injector.autowire( target = widget, targetID = path );

				expect( isNull( widget.getDep() ) ).toBeFalse();
			} );
		} );
	}

}
