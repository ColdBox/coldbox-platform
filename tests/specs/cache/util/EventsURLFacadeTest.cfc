component extends="coldbox.system.testing.BaseModelTest" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
	}

	/**
	 * executes after all suites+specs in the run() method
	 */
	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Event URL Facade", function(){
			beforeEach( function( currentSpec ){
				variables.jTreeMap = createObject( "java", "java.util.TreeMap" );
				variables.cm       = createEmptyMock( "coldbox.system.cache.providers.MockProvider" );
				variables.cm.$( "getEventCacheKeyPrefix", "mock" );
				variables.facade = prepareMock( new coldbox.system.cache.util.EventURLFacade( cm ) ).$(
					"buildAppLink",
					"http://localhost/test-harness"
				);
			} );

			it( "can build a unique hash from a request context", function(){
				var routedStruct = { name : "luis" };
				/* Mocks */
				var context = createMock( "coldbox.system.web.context.RequestContext" )
					.setRoutedStruct( routedStruct )
					.setContext( { event : "main.index", id : "123" } );
				var testHash = facade.getUniqueHash( context );
				expect( testhash ).notToBeEmpty();
			} );

			it( "can build a hash from a querystring", function(){
				var args     = "id=1&name=luis";
				var testHash = facade.buildHash( args );

				var virtualRC = {};
				args.listToArray( "&" )
					.each( function( item ){
						virtualRC[ item.getToken( 1, "=" ).trim() ] = urlDecode( item.getToken( 2, "=" ).trim() );
					} );
				var myStruct = {
					"incomingHash" : hash( variables.jTreeMap.init( virtualRC ).toString() ),
					"cgihost"      : "http://localhost/test-harness"
				};

				expect( testHash ).toBe( hash( myStruct.toString() ) );
			} );

			it( "can build an event key", function(){
				/* Mocks */
				var context = createMock( "coldbox.system.web.context.RequestContext" );
				context.setRoutedStruct( { "name" : "majano" } ).setContext( { event : "main.index", id : "123" } );

				var testCacheKey = facade.buildEventKey( "unittest", "main.index", context );
				var uniqueHash   = facade.getUniqueHash( context );
				var targetKey    = cm.getEventCacheKeyPrefix() & "main.index-unittest-" & uniqueHash;

				expect( testCacheKey ).toBe( targetKey );
			} );

			it( "can build an event key with no context", function(){
				var args = "id=1";

				var testCacheKey = facade.buildEventKeyNoContext( "unittest", "main.index", args );
				var targetKey    = cm.getEventCacheKeyPrefix() & "main.index-unittest-" & facade.buildHash( args );

				expect( testCacheKey ).toBe( targetKey );
			} );
		} );
	}

}
