/**
 * I am a new handler
 */
component {

	function index( event, rc, prc ){
		var data = { name : "Luis Majano", when : now() };

		prc.threadInfo = announce( "onCustomState", data );

		event.setView( "iTest/index" );
	}

	function async( event, rc, prc ){
		var data = { name : "Luis Majano", when : now() };

		prc.threadInfo = announce(
			state         = "onCustomState",
			data = data,
			async         = true,
			asyncPriority = "High"
		);

		event.setView( "iTest/index" );
	}

	function asyncAllWithTimeout( event, rc, prc ){
		var data = { name : "Luis Majano", when : now() };

		prc.threadInfo = announce(
			state            = "onCustomState",
			data    = data,
			asyncAll         = true,
			asyncPriority    = "High",
			asyncJoinTimeout = "2000"
		);

		event.setView( "iTest/index" );
	}

	function asyncAll( event, rc, prc ){
		var data = { name : "Luis Majano", when : now() };

		prc.threadInfo = announce(
			state         = "onCustomState",
			data = data,
			asyncAll      = true,
			asyncPriority = "High"
		);

		event.setView( "iTest/index" );
	}

	function asyncAllNoJoin( event, rc, prc ){
		var data = { name : "Luis Majano", when : now() };

		prc.threadInfo = announce(
			state         = "onCustomState",
			data = data,
			asyncAll      = true,
			asyncAllJoin  = false,
			asyncPriority = "High"
		);

		event.setView( "iTest/index" );
	}

}
