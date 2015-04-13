/**
* ********************************************************************************
* Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ********************************************************************************
* HTTP Response model, spice up as needed
*/
component accessors="true" {

	property name="format" 			type="string" 		default="json";
	property name="data" 			type="any"			default="";
	property name="error" 			type="boolean"		default="false";
	property name="binary" 			type="boolean"		default="false";
	property name="messages" 		type="array";
	property name="location" 		type="string"		default="";
	property name="jsonCallback" 	type="string"		default="";
	property name="jsonQueryFormat" type="string"		default="query";
	property name="contentType" 	type="string"		default="";
	property name="statusCode" 		type="numeric"		default="200";
	property name="statusText" 		type="string"		default="OK";
	property name="errorCode"		type="numeric"		default="0";
	property name="responsetime"	type="numeric"		default="0";
	property name="cachedResponse" 	type="boolean"		default="false";
	property name="headers" 		type="array";

	/**
	* Constructor
	*/
	Response function init(){
		// Init complex properties
		variables.messages 	= [];
		variables.headers 	= [];

		return this;
	}

	/**
	* Add some messages
	* @message Array or string of message to incorporate
	*/
	function addMessage( required any message ){
		if( isSimpleValue( arguments.message ) ){ arguments.message = listToArray( arguments.message ); }
		variables.messages.addAll( arguments.message );
		return this;
	}

	/**
	* Add a header
	* @name header name
	* @value header value
	*/
	function addHeader( required string name, required string value ){
		arrayAppend( variables.headers, { name=arguments.name, value=arguments.value } );
		return this;
	}

	/**
	* Returns a standard response formatted data packet
	*/
	function getDataPacket() {
		return {
			"error" 		 = variables.error ? true : false,
			"errorcode"		 = variables.errorCode,
			"messages" 		 = variables.messages,
			"data" 			 = variables.data
		};
	}
}