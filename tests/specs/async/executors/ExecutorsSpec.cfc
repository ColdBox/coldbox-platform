/**
 * My BDD Test
 */
component extends="tests.specs.async.BaseAsyncSpec" {

	variables.javaMajorVersion = createObject( "java", "java.lang.System" )
		.getProperty( "java.version" )
		.listFirst( "." )

	variables.javaMajorVersion = createObject( "java", "java.lang.System" )
		.getProperty( "java.version" )
		.listFirst( "." )

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Executors", () => {
			beforeEach( ( currentSpec ) => {
		describe( "Executors", () => {
			beforeEach( ( currentSpec ) => {
				executors = new coldbox.system.async.executors.ExecutorBuilder();
			} );

			it( "can be created", () => {
			it( "can be created", () => {
				expect( executors ).toBeComponent();
			} );

			story( "Ability to create different supported executors", () => {
				it( "can create a cached pool executor", () => {
					var executor = executors.newCachedThreadPool();
			story( "Ability to create different supported executors", () => {
				it( "can create a cached pool executor", () => {
					var executor = executors.newCachedThreadPool();
					expect( executor.isTerminated() ).toBeFalse();
				} );
				it( "can create a cached executor", () => {
				it( "can create a cached executor", () => {
					var executor = executors.newCachedThreadPool();
					expect( executor.isTerminated() ).toBeFalse();
				} );
				it( "can create a fixed pool executor", () => {
					var executor = executors.newFixedThreadPool( 10 );
					expect( executor.isTerminated() ).toBeFalse();
				} );
				it( "can create a scheduled pool executor", () => {
					var executor = executors.newScheduledThreadPool( 5 );
					expect( executor.isTerminated() ).toBeFalse();
				} );
				it( "can create a work_stealing thread executor with no parallelism", () => {
					var executor = executors.newWorkStealingPoolExecutor();
					expect( executor.isTerminated() ).toBeFalse();
				} );
				it( "can create a work_stealing thread executor with some parallelism", () => {
					var executor = executors.newWorkStealingPoolExecutor( 4 );
					expect( executor.isTerminated() ).toBeFalse();
				} );
				// Skip on Adobe as their dumb reflection does not support virtual threads
				it(
					title: "can create a virtual thread executor",
					skip : (
						(
							server.keyExists( "coldfusion" ) && server.coldfusion.productName.findNoCase( "ColdFusion" )
						) ||
						( variables.javaMajorVersion < 21 )
					),
					body: () => {
						var executor = executors.newVirtualThreadExecutor();
						expect( executor.isTerminated() ).toBeFalse();
					}
				);
			} );
		} );
	}

}
