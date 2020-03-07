component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.core.collections.ConcurrentProcessor" {

	function beforeAll(){
		super.setup();

		variables.hello = "Luis Majano";

		// model constructor
		model.init();
	}

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Concurrent Processor", function(){
			it( "can process a query", function(){
				var target = querySim(
					"id,name
				1 | luis
				2 | joe
				3 | anakin
				4 | joe2"
				);

				var innerValue = "InnerValue";

				model
					.setCollection( target )
					.each( function( item ){
						var threadName = createObject( "java", "java.lang.Thread" ).currentThread().getName();
						sleep( randRange( 400, 600 ) );
						createObject( "java", "java.lang.System" ).out.println(
							"Outer variables: #variables.hello# Inner: #innerValue# Processing #threadName# and #item.toString()#"
						);
					} );
			} );

			it( "can process a struct", function(){
				var target = {
					name : "luis",
					age  : "100",
					when : now()
				};

				model
					.setCollection( target )
					.each( function( item ){
						var threadName = createObject( "java", "java.lang.Thread" ).currentThread().getName();
						sleep( randRange( 400, 600 ) );
						createObject( "java", "java.lang.System" ).out.println(
							"Processing #threadName# and #item.toString()#"
						);
					} );
			} );

			it( "can process an array", function(){
				// createObject( "java", "java.lang.Thread" ).currentThread().getThreadGroup().getName()
				var target = [ 1, 2, 3, 4, 5, 6 ];

				model
					.setCollection( target )
					.each( function( item ){
						var threadName = createObject( "java", "java.lang.Thread" ).currentThread().getName();
						sleep( randRange( 400, 600 ) );
						createObject( "java", "java.lang.System" ).out.println(
							"Processing #threadName# and #item.toString()#"
						);
					} );
			} );
		} );
	}

}
