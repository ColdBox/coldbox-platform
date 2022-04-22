component extends="coldbox.system.remote.ColdboxProxy"{

	remote string function echo(){
		return "hello";
	}

	remote string function yourRemoteCall() {
		//  Set the event to execute
		arguments.event = "";

		//  Call to process a coldbox event cycle, always check the results as they might not exist.
		var results = super.process( argumentCollection = arguments );

		if( !isNull( results ) ){
			return results;
		}
	}

}
