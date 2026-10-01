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
	 * Show who is logged in through the BrowserTesting module login closure
	 */
	function whoami( event, rc, prc ){
		if ( structKeyExists( session, "browserTestingUser" ) ) {
			return "<h1>Logged in as #encodeForHTML( session.browserTestingUser )#</h1>"
		}
		return "<h1>Guest</h1>"
	}

}
