/**
 * ********************************************************************************
 * Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ********************************************************************************
 * HTTP Response model used mostly for RESTFul services, but it can be used as a nice way to represent
 * responses in ColdBox
 */
component accessors="true" {

	/**
	 * The output format of the response, defaults to json
	 */
	property
		name   ="format"
		type   ="string"
		default="json";

	/**
	 * The data struct that will be used to marshall out the response
	 */
	property
		name   ="data"
		type   ="any"
		default="";

	/**
	 * The pagination struct if any
	 */
	property name="pagination" type="struct";

	/**
	 * A boolean error indicator
	 */
	property
		name   ="error"
		type   ="boolean"
		default="false";

	/**
	 * A binary indicator
	 */
	property
		name   ="binary"
		type   ="boolean"
		default="false";

	/**
	 * An array of messages to output if any
	 */
	property name="messages" type="array";

	/**
	 * The location header if any
	 */
	property
		name   ="location"
		type   ="string"
		default="";

	/**
	 * The json callback if any
	 */
	property
		name   ="jsonCallback"
		type   ="string"
		default="";

	/**
	 * The content type of the response
	 */
	property
		name   ="contentType"
		type   ="string"
		default="";

	/**
	 * The status code of the response
	 */
	property
		name   ="statusCode"
		type   ="numeric"
		default=200;

	/**
	 * Remove by ColdBox 9
	 *
	 * @deprecated The status text is not used in the servlet spec anymore.
	 */
	property
		name   ="statusText"
		type   ="string"
		default="Ok";

	/**
	 * The response time
	 */
	property
		name   ="responsetime"
		type   ="numeric"
		default="0";

	/**
	 * The headers to send with the response
	 */
	property name="headers" type="array";

	/**
	 * Constructor
	 */
	Response function init(){
		// Init properties
		variables.format       = "json"
		variables.data         = {}
		variables.error        = false
		variables.binary       = false
		variables.messages     = []
		variables.location     = ""
		variables.jsonCallBack = ""
		variables.contentType  = ""
		variables.statusCode   = 200
		variables.responsetime = 0
		variables.headers      = []

		variables.pagination = {
			"offset"       : 0,
			"maxRows"      : 0,
			"page"         : 1,
			"totalRecords" : 0,
			"totalPages"   : 1
		}

		return this
	}

	/**
	 * Utility function to get the state of this object
	 *
	 * @return Returns a struct of the current state of this object
	 */
	struct function getMemento(){
		return variables.filter( ( key, value ) => {
			return (
				!isNull( arguments.value ) && !isCustomFunction( arguments.value ) && !listFindNoCase(
					"this",
					key
				)
			)
		} )
	}

	/**
	 * Add some messages to the response
	 *
	 * @message Array or string of message to incorporate
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function addMessage( required any message ){
		if ( isSimpleValue( arguments.message ) ) {
			arguments.message = [ arguments.message ]
		}
		variables.messages.addAll( arguments.message )
		return this
	}

	/**
	 * Add multiple messages to the response
	 *
	 * @messages The messages to incorporate
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function addMessages( required array messages ){
		variables.messages.addAll( arguments.messages )
		return this
	}

	/**
	 * Remove all messages from the response
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function clearMessages(){
		variables.messages.clear()
		return this
	}

	/**
	 * Check whether the response contains messages
	 *
	 * @return True when the response contains at least one message
	 */
	boolean function hasMessages(){
		return !getMessages().isEmpty()
	}

	/**
	 * Get all messages as a string
	 *
	 * @delimiter The delimiter to use when joining the messages, defaults to a comma and space
	 *
	 * @return Returns a string of all messages joined by a comma
	 */
	string function getMessagesString( string delimiter = ", " ){
		return getMessages().toList( arguments.delimiter )
	}

	/**
	 * Add a header into the response
	 *
	 * @name  The header name ( e.g. "Content-Type" )
	 * @value The header value ( e.g. "application/json" )
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function addHeader( required string name, required string value ){
		arrayAppend( variables.headers, { "name" : arguments.name, "value" : arguments.value } )
		return this
	}

	/**
	 * Set a response header, replacing an existing header with the same name
	 *
	 * @name  The header name
	 * @value The header value
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function setHeader( required string name, required string value ){
		for ( var header in variables.headers ) {
			if ( header.name.equalsIgnoreCase( arguments.name ) ) {
				header.value = arguments.value
				return this
			}
		}

		return addHeader( argumentCollection = arguments )
	}

	/**
	 * Get a response header value by name
	 *
	 * @name The header name
	 *
	 * @return The header value, or an empty string when it does not exist
	 */
	string function getHeader( required string name ){
		for ( var header in variables.headers ) {
			if ( header.name.equalsIgnoreCase( arguments.name ) ) {
				return header.value
			}
		}

		return ""
	}

	/**
	 * Check whether a response header exists
	 *
	 * @name The header name
	 *
	 * @return True when the header exists
	 */
	boolean function hasHeader( required string name ){
		for ( var header in variables.headers ) {
			if ( header.name.equalsIgnoreCase( arguments.name ) ) {
				return true
			}
		}

		return false
	}

	/**
	 * Remove a response header by name
	 *
	 * @name The header name
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function removeHeader( required string name ){
		for ( var index = variables.headers.len(); index >= 1; index-- ) {
			if ( variables.headers[ index ].name.equalsIgnoreCase( arguments.name ) ) {
				variables.headers.deleteAt( index )
			}
		}

		return this
	}

	/**
	 * Remove all response headers
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function clearHeaders(){
		variables.headers.clear()
		return this
	}

	/**
	 * Set the pagination data
	 *
	 * @offset       The offset
	 * @maxRows      The max rows returned
	 * @page         The page number
	 * @totalRecords The total records found
	 * @totalPages   The total pages found
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function setPagination(
		numeric offset       = 0,
		numeric maxRows      = 0,
		numeric page         = 1,
		numeric totalRecords = 0,
		numeric totalPages   = 1
	){
		structAppend( variables.pagination, arguments, true )
		return this
	}

	/**
	 * Returns a standard response formatted data packet using the information in the response
	 *
	 * @reset Reset the 'data' element of the original data packet
	 *
	 * @return Returns a struct of the data packet: error, messages, data, pagination
	 */
	struct function getDataPacket( boolean reset = false ){
		var packet = {
			"error"      : getError() ? true : false,
			"messages"   : getMessages(),
			"data"       : getData(),
			"pagination" : getPagination()
		}

		// Are we reseting the data packet
		if ( arguments.reset ) {
			packet.data = {}
		}

		return packet
	}

	/**
	 * Sets the data for the API response
	 *
	 * @data     The data to be set
	 * @message  An optional message to be set with the data
	 * @location An optional location to be set with the data
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function setData(
		required any data,
		string message = "",
		string location = ""
	){
		variables.data = arguments.data

		if ( !arguments.message.trim().isEmpty() ) {
			addMessage( arguments.message )
		}

		if ( !arguments.location.trim().isEmpty() ) {
			variables.location = arguments.location
		}

		return this
	}

	/**
	 * Set response data using fluent naming
	 *
	 * @data     The data to be set
	 * @message  An optional message to be set with the data
	 * @location An optional location to be set with the data
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function withData(
		required any data,
		string message = "",
		string location = ""
	){
		return setData( argumentCollection = arguments )
	}

	/**
	 * Add a response message using fluent naming
	 *
	 * @message The message to incorporate
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function withMessage( required any message ){
		return addMessage( arguments.message )
	}

	/**
	 * Set the response status using fluent naming
	 *
	 * @code The status code to be set
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function withStatus( required code ){
		return setStatus( arguments.code )
	}

	/**
	 * Sets the status code for the API response
	 *
	 * @code The status code to be set
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function setStatus( required code ){
		variables.statusCode = arguments.code;
		return this;
	}

	/**
	 * Mark the response as successful and optionally set its data
	 *
	 * @data     The data to be set
	 * @message  An optional message to be set with the data
	 * @location An optional location to be set with the data
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function success(
		required any data,
		string message = "",
		string location = ""
	){
		setError( false )
		return setData( argumentCollection = arguments )
	}

	/**
	 * Mark the response as failed with a message, status, and optional data
	 *
	 * @message    The error message
	 * @statusCode The status code to set
	 * @data       The data to set
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function failure(
		required string message,
		numeric statusCode = 400,
		any data
	){
		return setErrorMessage(
			errorMessage = arguments.message,
			statusCode   = arguments.statusCode,
			data         = arguments.data
		)
	}

	/**
	 * Check whether the response is in an error state
	 *
	 * @return True when the response is marked as an error
	 */
	boolean function isError(){
		return getError()
	}

	/**
	 * Check whether the response has a successful HTTP status
	 *
	 * @return True for non-error 2xx and 3xx status codes
	 */
	boolean function isSuccess(){
		return !isError() && getStatusCode() >= 200 && getStatusCode() < 400
	}

	/**
	 * Sets the data and pagination from a struct with a `results` and `pagination` key.
	 *
	 * @data          The struct containing both 'results' and 'pagination' keys
	 * @resultsKey    The name of the key with the results.
	 * @paginationKey The name of the key with the pagination.
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function setDataWithPagination(
		data,
		resultsKey    = "results",
		paginationKey = "pagination"
	){
		variables.data = arguments.data[ arguments.resultsKey ]
		return setPagination( argumentCollection = arguments.data[ arguments.paginationKey ] ?: [] )
	}

	/**
	 * Sets the error message with a code for the API response
	 *
	 * @errorMessage The error message to set
	 * @statusCode   The status code to set, if any
	 * @data         The data to set, if any
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function setErrorMessage( required errorMessage, numeric statusCode=400, any data ){
		setError( true )
		addMessage( arguments.errorMessage )

		if ( !isNull( arguments.statusCode ) ) {
			setStatus( arguments.statusCode )
		}
		if ( !isNull( arguments.data ) ) {
			setData( arguments.data )
		}

		return this
	}

	/**
	 * This is a no-op since newer servlet specs do not support setting the status text
	 */
	Response function setStatusText(){
		return this
	}

}
