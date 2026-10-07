/**
 * A scope must never hand an object to a second thread before its dependencies are wired.
 * Based on the specs contributed in https://github.com/ColdBox/coldbox-platform/pull/706
 */
component extends="testbox.system.BaseSpec" {

	function run(){
		describe( "Scopes under concurrent first requests", function(){
			beforeEach( function(){
				// unique names per spec: engines cache compiled classes by path
				variables.id         = left( replace( createUUID(), "-", "", "all" ), 10 )
				variables.fixtureDir = expandPath( "/tests/tmp/scopewiring/" )
				variables.prefix     = "tests.tmp.scopewiring"
				variables.injector   = ""
				variables.results    = {}
				if ( !directoryExists( fixtureDir ) ) {
					directoryCreate( fixtureDir )
				}
			} );

			afterEach( function(){
				if ( isObject( injector ) ) {
					injector.shutdown()
				}
				structDelete( application, "scopeWiring#id#" )
				structDelete( application, "wirebox:Slow#id#" )
				structDelete( application, "wirebox:Left#id#" )
				structDelete( application, "wirebox:Right#id#" )
				structDelete( application, "wirebox:Consumer#id#" )
				if ( directoryExists( fixtureDir ) ) {
					directoryDelete( fixtureDir, true )
				}
			} );

			// Singleton scope and the engine scopes (application, session, server) share the same wiring rules
			var scopeNames = [ "singleton", "application" ]
			scopeNames.each( function( scopeName ){
				describe( "#scopeName# scope", function(){
					it( "never hands an object to a second thread before its dependencies are wired", function(){
						newInjector(
							scopeName,
							{
								Slow     : "component { function init(){ application[ ""scopeWiring#id#"" ] = true; sleep( 1500 ); return this; } function value(){ return ""ready""; } }",
								Consumer : "component { property name=""slow"" inject=""id:Slow#id#""; function init(){ return this; } function probe(){ return slow.value(); } }"
							}
						)
						inThread( "first", "Consumer#id#" )
						// Consumer is stored and wiring once Slow starts building
						waitForFlag()
						inThread( "second", "Consumer#id#" )
						thread action="join" name="first#id#,second#id#" timeout="15000";

						expect( results.first ).toBe( "ready" )
						expect( results.second ).toBe( "ready" )
					} );

					it( "still resolves a circular dependency on the wiring thread", function(){
						newInjector(
							scopeName,
							{
								Left  : "component { property name=""right"" inject=""id:Right#id#""; function init(){ return this; } function name(){ return ""left""; } function probe(){ return right.name(); } }",
								Right : "component { property name=""left"" inject=""id:Left#id#""; function init(){ return this; } function name(){ return ""right""; } function probe(){ return left.name(); } }"
							}
						)

						expect( injector.getInstance( "Left#id#" ).probe() ).toBe( "right" )
						expect( injector.getInstance( "Right#id#" ).probe() ).toBe( "left" )
					} );

					it( "does not deadlock when two threads wire a circular pair from opposite ends", function(){
						newInjector(
							scopeName,
							{
								Left  : "component { property name=""right"" inject=""id:Right#id#""; function init(){ sleep( 700 ); return this; } function name(){ return ""left""; } function probe(){ return right.name(); } }",
								Right : "component { property name=""left"" inject=""id:Left#id#""; function init(){ sleep( 700 ); return this; } function name(){ return ""right""; } function probe(){ return left.name(); } }"
							}
						)
						var started = getTickCount()
						inThread( "left", "Left#id#" )
						inThread( "right", "Right#id#" )
						thread action="join" name="left#id#,right#id#" timeout="20000";

						expect( results.left ).toBe( "right" )
						expect( results.right ).toBe( "left" )
						// a lock-ordering deadlock would only resolve through the lock timeout
						expect( getTickCount() - started ).toBeLT( 10000 )
					} );
				} );
			} );
		} );
	}

	private function newInjector( required string scopeName, required struct fixtures ){
		for ( var name in arguments.fixtures ) {
			fileWrite( variables.fixtureDir & name & variables.id & ".cfc", arguments.fixtures[ name ] )
		}
		variables.injector = new coldbox.system.ioc.Injector( { scopeRegistration : { enabled : false } } )
		for ( var name in arguments.fixtures ) {
			variables.injector
				.getBinder()
				.map( name & variables.id )
				.to( "#variables.prefix#.#name##variables.id#" )
				.into( arguments.scopeName )
		}
	}

	private function inThread( required string name, required string alias ){
		thread
			name     ="#arguments.name##variables.id#"
			action   ="run"
			alias    ="#arguments.alias#"
			resultKey="#arguments.name#" {
			try {
				variables.results[ attributes.resultKey ] = variables.injector
					.getInstance( attributes.alias )
					.probe()
			} catch ( any e ) {
				variables.results[ attributes.resultKey ] = "ERR " & e.message
			}
		}
	}

	private function waitForFlag(){
		var deadline = getTickCount() + 10000
		while ( !structKeyExists( application, "scopeWiring#variables.id#" ) && getTickCount() < deadline ) {
			sleep( 20 )
		}
	}

}
