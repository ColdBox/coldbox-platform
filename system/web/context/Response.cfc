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
	 * JSON Only: This parameter can be a Boolean value that specifies how to serialize ColdFusion queries or a string with possible values row, column, or struct
	 */
	property
		name   ="jsonQueryFormat"
		type   ="string"
		default="true";

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
		default="200";

	/**
	 * The status text of the response
	 */
	property
		name   ="statusText"
		type   ="string"
		default="OK";

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
	 * Helper Status Texts Lookups
	 */
	this.STATUS_TEXTS = {
		"100" : "Continue",
		"101" : "Switching Protocols",
		"102" : "Processing",
		"200" : "OK",
		"201" : "Created",
		"202" : "Accepted",
		"203" : "Non-authoritative Information",
		"204" : "No Content",
		"205" : "Reset Content",
		"206" : "Partial Content",
		"207" : "Multi-Status",
		"208" : "Already Reported",
		"226" : "IM Used",
		"300" : "Multiple Choices",
		"301" : "Moved Permanently",
		"302" : "Found",
		"303" : "See Other",
		"304" : "Not Modified",
		"305" : "Use Proxy",
		"307" : "Temporary Redirect",
		"308" : "Permanent Redirect",
		"400" : "Bad Request",
		"401" : "Unauthorized",
		"402" : "Payment Required",
		"403" : "Forbidden",
		"404" : "Not Found",
		"405" : "Method Not Allowed",
		"406" : "Not Acceptable",
		"407" : "Proxy Authentication Required",
		"408" : "Request Timeout",
		"409" : "Conflict",
		"410" : "Gone",
		"411" : "Length Required",
		"412" : "Precondition Failed",
		"413" : "Payload Too Large",
		"414" : "Request-URI Too Long",
		"415" : "Unsupported Media Type",
		"416" : "Requested Range Not Satisfiable",
		"417" : "Expectation Failed",
		"418" : "I'm a teapot",
		"421" : "Misdirected Request",
		"422" : "Unprocessable Entity",
		"423" : "Locked",
		"424" : "Failed Dependency",
		"426" : "Upgrade Required",
		"428" : "Precondition Required",
		"429" : "Too Many Requests",
		"431" : "Request Header Fields Too Large",
		"444" : "Connection Closed Without Response",
		"451" : "Unavailable For Legal Reasons",
		"499" : "Client Closed Request",
		"500" : "Internal Server Error",
		"501" : "Not Implemented",
		"502" : "Bad Gateway",
		"503" : "Service Unavailable",
		"504" : "Gateway Timeout",
		"505" : "HTTP Version Not Supported",
		"506" : "Variant Also Negotiates",
		"507" : "Insufficient Storage",
		"508" : "Loop Detected",
		"510" : "Not Extended",
		"511" : "Network Authentication Required",
		"599" : "Network Connect Timeout Error"
	};

	/**
	 * Constructor
	 */
	Response function init(){
		// Init properties
		variables.format          = "json";
		variables.data            = {};
		variables.error           = false;
		variables.binary          = false;
		variables.messages        = [];
		variables.location        = "";
		variables.jsonCallBack    = "";
		variables.jsonQueryFormat = "query";
		variables.contentType     = "";
		variables.statusCode      = 200;
		variables.statusText      = "OK";
		variables.responsetime    = 0;
		variables.headers         = [];

		variables.pagination = {
			"offset"       : 0,
			"maxRows"      : 0,
			"page"         : 1,
			"totalRecords" : 0,
			"totalPages"   : 1
		};

		return this;
	}

	/**
	 * Utility function to get the state of this object
	 */
	struct function getMemento(){
		return variables.filter( function( key, value ){
			return (
				!isNull( arguments.value ) && !isCustomFunction( arguments.value ) && !listFindNoCase(
					"this",
					key
				)
			);
		} );
	}

	/**
	 * Add some messages to the response
	 *
	 * @message Array or string of message to incorporate
	 */
	Response function addMessage( required any message ){
		if ( isSimpleValue( arguments.message ) ) {
			arguments.message = [ arguments.message ];
		}
		variables.messages.addAll( arguments.message );
		return this;
	}

	/**
	 * Get all messages as a string
	 */
	string function getMessagesString(){
		return getMessages().toList();
	}

	/**
	 * Add a header into the response
	 *
	 * @name  The header name ( e.g. "Content-Type" )
	 * @value The header value ( e.g. "application/json" )
	 */
	Response function addHeader( required string name, required string value ){
		arrayAppend( variables.headers, { name : arguments.name, value : arguments.value } );
		return this;
	}

	/**
	 * Set the pagination data
	 *
	 * @offset       The offset
	 * @maxRows      The max rows returned
	 * @page         The page number
	 * @totalRecords The total records found
	 * @totalPages   The total pages found
	 */
	Response function setPagination(
		numeric offset       = 0,
		numeric maxRows      = 0,
		numeric page         = 1,
		numeric totalRecords = 0,
		numeric totalPages   = 1
	){
		structAppend( variables.pagination, arguments, true );
		return this;
	}

	/**
	 * Returns a standard response formatted data packet using the information in the response
	 *
	 * @reset Reset the 'data' element of the original data packet
	 */
	struct function getDataPacket( boolean reset = false ){
		var packet = {
			"error"      : getError() ? true : false,
			"messages"   : getMessages(),
			"data"       : getData(),
			"pagination" : getPagination()
		};

		// Are we reseting the data packet
		if ( arguments.reset ) {
			packet.data = {};
		}

		return packet;
	}

	/**
	 * Sets the status code with a statusText for the API response
	 *
	 * @code The status code to be set
	 * @text The status text to be set
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function setStatus( required code, text ){
		if ( isNull( arguments.text ) OR !len( arguments.text ) ) {
			arguments.text = this.STATUS_TEXTS[ arguments.code ] ?: "";
		}

		variables.statusCode = arguments.code;
		variables.statusText = arguments.text;
		return this;
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
		variables.data = arguments.data[ arguments.resultsKey ];
		return setPagination( argumentCollection = arguments.data[ arguments.paginationKey ] ?: [] );
	}

	/**
	 * Sets the error message with a code for the API response
	 *
	 * @errorMessage The error message to set
	 * @statusCode   The status code to set, if any
	 * @statusText   The status text to set, if any
	 *
	 * @return Returns the Response object for chaining
	 */
	Response function setErrorMessage(
		required errorMessage,
		statusCode,
		statusText = ""
	){
		setError( true );
		addMessage( arguments.errorMessage );

		if ( !isNull( arguments.statusCode ) ) {
			setStatus( arguments.statusCode, arguments.statusText );
		}

		return this;
	}

}
