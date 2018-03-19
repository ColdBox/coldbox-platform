
/**
* My Event Handler Hint
*/
component extends="coldbox.system.EventHandler"{

	/**
	* Index
	*/
	any function index( event, rc, prc ){
		event.setHTTPHeader( name="response", value="index" );
		return "index";
	}

	/**
	* options
	*/
	any function options( event, rc, prc ){
		return "options";
	}

}
