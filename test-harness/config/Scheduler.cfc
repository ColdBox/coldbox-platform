component {

	function configure(){

		task( "testharness-Heartbeat" )
			.call( function() {
				if ( randRange(1, 5) eq 1 ){
					throw( message = "I am throwing up randomly!", type="RandomThrowup" );
				}
				writeDump( var='====> I am in a test harness test schedule!', output="console" );
			}  )
				.every( "5", "seconds" )
				.before( function( task ) {
					writeDump( var='====> Running before the task!', output="console" );
				} )
				.after( function( task, results ){
					writeDump( var='====> Running after the task!', output="console" );
				} )
				.onFailure( function( task, exception ){
					writeDump( var='====> test schedule just failed!! #exception.message#', output="console" );
				} )
				.onSuccess( function( task, results ){
					writeDump( var="====> Test scheduler success : Stats: #task.getStats().toString()#", output="console" );
				} );

	}

}