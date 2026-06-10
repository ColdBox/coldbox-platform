/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Lazy request buffer for synchronous interceptor output.
 */
component accessors="false" {

	/**
	 * Get the underlying string builder, creating it only when output is produced.
	 */
	function get(){
		if ( isNull( variables.builder ) ) {
			variables.builder = createObject( "java", "java.lang.StringBuilder" ).init( "" )
		}

		return variables.builder
	}

	/**
	 * Clear any buffered output.
	 */
	function clear(){
		get().setLength( 0 )
		return this
	}

	/**
	 * Append content to the buffer.
	 */
	function append( required str ){
		get().append( arguments.str )
		return this
	}

	/**
	 * Get the current buffer length.
	 */
	function length(){
		return get().length()
	}

	/**
	 * Get the buffered output.
	 */
	function getString(){
		if ( !hasContent() ) {
			return ""
		}

		return variables.builder.toString()
	}

	/**
	 * Check if the underlying builder has been created.
	 */
	boolean function hasContent(){
		return !isNull( variables.builder )
	}

	/**
	 * Backwards-compatible struct-style builder check.
	 */
	boolean function keyExists( required key ){
		return compareNoCase( arguments.key, "builder" ) eq 0 AND hasContent()
	}

}
