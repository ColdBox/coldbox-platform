/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Test-only login and logout endpoints for browser tests.
 * Every action answers a plain `404 Not Found` unless the request passes all the checks of the
 * security model documented in the module's ModuleConfig.cfc.
 */
component extends="coldbox.system.EventHandler" {

	// Only GET requests reach the actions
	this.allowedMethods = { login : "GET", logout : "GET" }

	/**
	 * Log in a user for a browser test by calling the `login` closure of the module settings
	 * with ( id, event, rc, prc ). Answers `OK` on success, else a plain `404 Not Found`.
	 *
	 * @event The request context
	 * @rc    The request collection, `id` is the user identifier from the route
	 * @prc   The private request collection
	 */
	function login( event, rc, prc ){
		var settings = getModuleSettings( "BrowserTesting" )
		if ( isAllowed( arguments.event, settings, "login" ) ) {
			var loginClosure = settings.login
			loginClosure(
				arguments.rc.id ?: "",
				arguments.event,
				arguments.rc,
				arguments.prc
			)
			respond( arguments.event, 200, "OK" )
		} else {
			respond( arguments.event, 404, "Not Found" )
		}
	}

	/**
	 * Log out the current user of a browser test by calling the `logout` closure of the module settings
	 * with ( event, rc, prc ). Answers `OK` on success, else a plain `404 Not Found`.
	 *
	 * @event The request context
	 * @rc    The request collection
	 * @prc   The private request collection
	 */
	function logout( event, rc, prc ){
		var settings = getModuleSettings( "BrowserTesting" )
		if ( isAllowed( arguments.event, settings, "logout" ) ) {
			var logoutClosure = settings.logout
			logoutClosure( arguments.event, arguments.rc, arguments.prc )
			respond( arguments.event, 200, "OK" )
		} else {
			respond( arguments.event, 404, "Not Found" )
		}
	}

	/**
	 * Does the request pass every check of the security model? The environment is `testing`, the module
	 * is enabled, the token is set and matches the request token, and the closure of the endpoint is set.
	 *
	 * @event      The request context
	 * @settings   The module settings
	 * @closureKey The setting that holds the closure of the endpoint: login or logout
	 *
	 * @return True when the endpoint may run
	 */
	private boolean function isAllowed(
		required event,
		required struct settings,
		required string closureKey
	){
		// Testing environment only
		if ( getSetting( "environment", "production" ) != "testing" ) {
			return false
		}
		// Explicitly enabled
		var enabled = arguments.settings.enabled ?: false
		if ( !isBoolean( enabled ) || !enabled ) {
			return false
		}
		// A token must be configured
		var token = arguments.settings.token ?: ""
		if ( !isSimpleValue( token ) || !len( token ) ) {
			return false
		}
		// The endpoint closure must be set
		var target = arguments.settings[ arguments.closureKey ] ?: ""
		if ( !isClosure( target ) && !isCustomFunction( target ) ) {
			return false
		}
		return tokensMatch( token, getRequestToken( arguments.event ) )
	}

	/**
	 * The token the request sent: the `X-Browser-Testing-Token` header, else the `token` request variable.
	 *
	 * @event The request context
	 *
	 * @return The request token, or an empty string when the request sent none
	 */
	private string function getRequestToken( required event ){
		var token = arguments.event.getHTTPHeader( "X-Browser-Testing-Token", "" )
		if ( !len( token ) ) {
			token = arguments.event.getValue( "token", "" )
		}
		return isSimpleValue( token ) ? token : ""
	}

	/**
	 * Compare two tokens in constant time: their SHA-256 hashes are compared with MessageDigest.isEqual(),
	 * so the comparison time does not depend on the token contents or length.
	 *
	 * @expected The configured token
	 * @actual   The request token
	 *
	 * @return True when both tokens are equal and the request token is not empty
	 */
	private boolean function tokensMatch( required string expected, required string actual ){
		if ( !len( arguments.actual ) ) {
			return false
		}
		return createObject( "java", "java.security.MessageDigest" ).isEqual(
			charsetDecode( hash( arguments.expected, "SHA-256" ), "utf-8" ),
			charsetDecode( hash( arguments.actual, "SHA-256" ), "utf-8" )
		)
	}

	/**
	 * Render a plain text response.
	 *
	 * @event      The request context
	 * @statusCode The HTTP status code
	 * @text       The response text
	 */
	private void function respond(
		required event,
		required numeric statusCode,
		required string text
	){
		arguments.event.renderData(
			type       = "plain",
			data       = arguments.text,
			statusCode = arguments.statusCode
		)
	}

}
