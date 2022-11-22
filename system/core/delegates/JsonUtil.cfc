/**
 * This delegate is useful to deal with opinionated json conversion for integration with JS libraries and more.
 */
component singleton {

	property
		name    ="util"
		inject  ="coldbox.system.core.util.Util"
		delegate="toJson,prettyJson,toPrettyJson";

	/**
	 * This function allows you to serialize simple or complex data so it can be used within HTML Attributes.
	 *
	 * @data The simple or complex data to bind to an HTML Attribute
	 */
	function forAttribute( required data ) cbMethod{
		arguments.data = ( isSimpleValue( arguments.data ) ? arguments.data : toJson( arguments.data ) );
		return encodeForHTMLAttribute( arguments.data );
	}

}
