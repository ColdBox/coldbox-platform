/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A buffer object that lives in the request scope. It switches its implementation depending on the JDK its running on.
*/
component accessors="true"{



	/**
	 * Constructor
	 */
	function init(){
		// 
		variables.BUFFER_KEY = "_cbox_request_buffer";
		// class id code
		variables.classID = createObject( "java", "java.lang.System" ).identityHashCode( this );

		return this;
	}

	/**
	 * Clear the buffer
	 * 
	 * @return RequestBuffer
	 */
	function clear(){
		var oBuffer = getBufferObject();
		oBuffer.delete( 0, oBuffer.length() );
		return this;
	}

	/**
	 * Append to the buffer
	 * 
	 * @str The string to append
	 * 
	 * @return RequestBuffer
	 */
	function append(){
		getBufferObject().append( arguments.str );
		return this;
	}

	/**
	 * Get buffer length
	 */
	numeric function length(){
		return getBufferObject().length();
	}

	/**
	 * Get buffer string content
	 */
	function getString(){
		return getBufferObject().toString();
	}
	
	/**
	 * Checks if the buffer has been created or not
	 */
	boolean function isBufferInScope(){
		return request.keyExists( variables.BUFFER_KEY );
	}
	
	/**
	 * Get or construct the request buffer object.
	 */
	function getBufferObject(){
		if( !isBufferInScope() ){
			lock name="#variables.classID#.#variables.BUFFER_KEY#" type="exclusive" timeout="10" throwontimeout="true"{
				if( !isBufferInScope() ){
					request[ variables.BUFFER_KEY ] = createObject( "java", "java.lang.StringBuilder" ).init( '' );
				}
			}
		}

		return request[ variables.BUFFER_KEY ];
	}

}