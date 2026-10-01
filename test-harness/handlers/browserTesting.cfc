/**
 * Pages for the browser tests of tests/specs/browser
 */
component {

	/**
	 * Show a user: the users.show named route
	 */
	function user( event, rc, prc ){
		return "<h1>User #encodeForHTML( rc.id )#</h1>"
	}

	/**
	 * A login form, like an application login page: GET shows the form, POST logs the user in
	 */
	function login( event, rc, prc ){
		if ( event.getHTTPMethod() == "POST" ) {
			session.browserTestingUser = rc.user ?: ""
			relocate( "browserTesting.whoami" )
		}
		return "<form method=""post""><label for=""user"">User</label><input id=""user"" name=""user""><button type=""submit"">Sign in</button></form>"
	}

	/**
	 * Show who is logged in
	 */
	function whoami( event, rc, prc ){
		if ( len( session.browserTestingUser ?: "" ) ) {
			return "<h1>Logged in as #encodeForHTML( session.browserTestingUser )#</h1>"
		}
		return "<h1>Guest</h1>"
	}

}
