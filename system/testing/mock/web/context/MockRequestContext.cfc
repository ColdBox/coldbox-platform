/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A mock request context used for integration testing via TestBox
 */
component
	extends     ="coldbox.system.web.context.RequestContext"
	serializable=false
	accessors   ="true"
{

	/**
	 * Set an HTTP Header
	 *
	 * return RequestContext
	 *
	 * @statusCode.hint the status code
	 * @statusText.hint the status text
	 * @name.hint       The header name
	 * @value.hint      The header value
	 * @charset.hint    The charset to use, defaults to UTF-8
	 */
	function setHTTPHeader( statusCode, statusText = "", name, value = "" ){
		// status code?
		if ( structKeyExists( arguments, "statusCode" ) ) {
			setValue( "cbox_statusCode", arguments.statusCode );
		}
		// Name Exists
		else if ( structKeyExists( arguments, "name" ) ) {
			var headers                        = getValue( "cbox_headers", {} );
			headers[ lCase( arguments.name ) ] = arguments.value;
			setValue( "cbox_headers", headers );
		} else {
			throw(
				message = "Invalid header arguments",
				detail  = "Pass in either a statusCode or name argument",
				type    = "RequestContext.InvalidHTTPHeaderParameters"
			);
		}

		return this;
	}

	/**
	 * Set the request timeout for the request. In mock mode, we set it as a property
	 * and we ignore the setting
	 *
	 * @seconds The number of seconds as a time limit
	 *
	 * @return MockRequestContext
	 */
	MockRequestContext function setRequestTimeout( required numeric seconds ){
		variables.requestTimeout = arguments.seconds;
		return this;
	}

}
