/**
 * I am a new handler
 */
component {

	function index( event, rc, prc ){
		var data = { name : "Luis Majano", when : now() };

		prc.threadInfo = announceInterception( state = "onCustomState", interceptData = data );

		event.setView( "iTest/index" );
	}

	function async( event, rc, prc ){
		var data = { name : "Luis Majano", when : now() };

		prc.threadInfo = announceInterception(
			state         = "onCustomState",
			interceptData = data,
			async         = true,
			asyncPriority = "High"
		);

		event.setView( "iTest/index" );
	}

	function asyncAllWithTimeout( event, rc, prc ){
		var data = { name : "Luis Majano", when : now() };

		prc.threadInfo = announceInterception(
			state            = "onCustomState",
			interceptData    = data,
			asyncAll         = true,
			asyncPriority    = "High",
			asyncJoinTimeout = "2000"
		);

		event.setView( "iTest/index" );
	}

	function asyncAll( event, rc, prc ){
		var data = { name : "Luis Majano", when : now() };

		prc.threadInfo = announceInterception(
			state         = "onCustomState",
			interceptData = data,
			asyncAll      = true,
			asyncPriority = "High"
		);

		event.setView( "iTest/index" );
	}

	function asyncAllNoJoin( event, rc, prc ){
		var data = { name : "Luis Majano", when : now() };

		prc.threadInfo = announceInterception(
			state         = "onCustomState",
			interceptData = data,
			asyncAll      = true,
			asyncAllJoin  = false,
			asyncPriority = "High"
		);

		event.setView( "iTest/index" );
	}

}
