/**
* My Event Handler Hint
*/
component extends="coldbox.system.EventHandler"{
	
	// REST Allowed HTTP Methods Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'}
	this.allowedMethods = {
		"index" = "POST"
	};
	
	function onInvalidHTTPMethod( event, rc, prc, faultAction, eventArguments ){
		return "invalid http";
	}

	/**
	* Index
	*/
	any function index( event, rc, prc ){
		return "index";
	}
	
}