/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A utility Facade to help in storing data in multiple CF Storages
 */
component {

	// Static list of valid scopes
	variables.SCOPES = "application|client|cookie|session|server|request";

	/**
	 * Constructor
	 */
	function init(){
		return this;
	}

	/**
	 * Store a value in a scope
	 *
	 * @key   The key
	 * @value The value
	 * @scope The ColdFusion Scope
	 */
	function put( required key, required value, required scope ){
		var scopePointer              = getScope( arguments.scope );
		scopePointer[ arguments.key ] = arguments.value;
		return this;
	}

	/**
	 * Delete a value in a scope
	 *
	 * @key   The key
	 * @scope The ColdFusion Scope
	 */
	boolean function delete( required key, required scope ){
		return structDelete(
			getScope( arguments.scope ),
			arguments.key,
			true
		);
	}

	/**
	 * Get a value in a scope
	 *
	 * @key          The key
	 * @scope        The CF Scope
	 * @defaultValue The default value
	 */
	function get( required key, required scope, defaultValue ){
		// Do stupid ACF Hack due to choking on `default` argument.
		if ( structKeyExists( arguments, "default" ) ) {
			arguments.defaultValue = arguments.default;
		}

		if ( exists( arguments.key, arguments.scope ) ) {
			return structFind( getscope( arguments.scope ), arguments.key );
		} else if ( structKeyExists( arguments, "defaultValue" ) ) {
			return arguments.defaultValue;
		}

		throw(
			type    = "ScopeStorage.KeyNotFound",
			message = "The key #arguments.key# does not exist in the #arguments.scope# scope."
		);
	}

	/**
	 * Check if a key exists
	 *
	 * @key   The key
	 * @scope The CF Scope
	 */
	boolean function exists( required key, required scope ){
		return structKeyExists( getScope( arguments.scope ), arguments.key );
	}

	/**
	 * Get a scope reference
	 *
	 * @scope The CF Scope
	 */
	any function getScope( required scope ){
		scopeCheck( arguments.scope );

		switch ( arguments.scope ) {
			case "session": {
				return ( getApplicationMetadata().sessionManagement ? session : {} );
			}
			case "application": {
				return ( isDefined( "application" ) ? application : {} );
			};
			case "server":
				return server;
			case "client":
				return client;
			case "cookie":
				return cookie;
			case "request":
				return request;
		}
	}

	/**
	 * Shortcut to get Session
	 */
	any function getSession(){
		return getScope( "session" );
	}

	/**
	 * Shortcut to get Application
	 */
	any function getApplication(){
		return getScope( "application" );
	}

	/**
	 * Shortcut to get Client
	 */
	any function getClient(){
		return getScope( "client" );
	}

	/**
	 * Shortcut to get Server
	 */
	any function getServer(){
		return getScope( "server" );
	}

	/**
	 * Shortcut to get cookie
	 */
	any function getCookie(){
		return getScope( "cookie" );
	}

	/**
	 * Check if a scope is valid, else throws exception
	 *
	 * @scope The CF Scope
	 */
	any function scopeCheck( required scope ){
		if ( NOT reFindNoCase( "^(#variables.SCOPES#)$", arguments.scope ) ) {
			throw(
				type    = "ScopeStorage.InvalidScope",
				message = "Invalid CF Scope, valid scopes are #variables.SCOPES#"
			);
		}
	}

}
