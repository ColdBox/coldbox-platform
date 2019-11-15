component{

	function init( target, future ){
		variables.target = arguments.target;
		variables.future = arguments.future;
		return this;
	}

	function uncaughtException( t, e ){
		variables.target( arguments.t, arguments.e, variables.future );
	}

}