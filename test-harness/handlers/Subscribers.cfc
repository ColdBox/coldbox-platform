component extends="coldbox.system.RestHandler"{

	function create( event, rc, prc ) {
		runEvent(
			event = "subscribers.save",
			prePostExempt = true, // required for private events
			private = true,
			eventArguments = { new: true }
		);
	}

	private function save( event, rc, prc, required boolean new ) {
		throw( "Validation Failed", "ValidationException", "Details go here" );
	}

}
