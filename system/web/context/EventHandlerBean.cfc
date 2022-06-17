/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * I model a ColdBox Event Handler Execution
 */
component accessors="true" {

	/**
	 * Invocation path
	 */
	property name="invocationPath";
	/**
	 * The handler to execute
	 */
	property name="handler";
	/**
	 * The method to execute
	 */
	property name="method";
	/**
	 * The module assignment
	 */
	property name="module";
	/**
	 * Missing action method
	 */
	property name="missingAction";
	/**
	 * Private execution
	 */
	property name="isPrivate" type="boolean";
	/**
	 * View dispatching
	 */
	property name="viewDispatch" type="boolean";
	/**
	 * Action metadata
	 */
	property name="actionMetadata" type="struct";

	/**
	 * Handler metadata
	 */
	property name="handlerMetadata" type="struct";

	/************************************** CONSTRUCTOR *********************************************/

	/**
	 * Constructor
	 *
	 * @invocationPath The default invocation path
	 */
	function init( invocationPath = "" ){
		variables.invocationPath  = arguments.invocationPath;
		variables.handler         = "";
		variables.method          = "";
		variables.module          = "";
		variables.isPrivate       = false;
		variables.missingAction   = "";
		variables.viewDispatch    = false;
		variables.actionMetadata  = {};
		variables.handlerMetadata = {};

		return this;
	}

	/************************************** PUBLIC RETURN BACK SETTERS *********************************************/

	function setIsPrivate( required isPrivate ){
		variables.isPrivate = arguments.isPrivate;
		return this;
	}
	function setHandler( required handler ){
		variables.handler = arguments.handler;
		return this;
	}
	function setMethod( required method ){
		variables.method = arguments.method;
		return this;
	}
	function setModule( required module ){
		variables.module = arguments.module;
		return this;
	}
	function setMissingAction( required missingAction ){
		variables.missingAction = arguments.missingAction;
		return this;
	}
	function setViewDispatch( required viewDispatch ){
		variables.viewDispatch = arguments.viewDispatch;
		return this;
	}
	function setInvocationPath( required invocationPath ){
		variables.invocationPath = arguments.invocationPath;
		return this;
	}
	function setActionMetadata( required actionMetadata ){
		variables.actionMetadata = arguments.actionMetadata;
		return this;
	}
	function setHandlerMetadata( required handlerMetadata ){
		variables.handlerMetadata = arguments.handlerMetadata;
		return this;
	}

	/************************************** UTILITY METHODS *********************************************/

	/**
	 * This verifies if a specific action has been tagged with an annotation.
	 *
	 * @key The annotation key to verify
	 *
	 * @return True if the action has been annotated with the key, else false.
	 */
	boolean function actionMetadataExists( required key ){
		return variables.actionMetadata.keyExists( arguments.key );
	}

	/**
	 * Return the full action metadata structure or filter by key and default value if needed
	 *
	 * @key          The key to search for in the action metadata
	 * @defaultValue Default value to return if not found
	 *
	 * @return any
	 */
	function getActionMetadata( key, defaultValue = "" ){
		// If no key passed, then return full structure
		if ( isNull( arguments.key ) || !len( arguments.key ) ) {
			return variables.actionMetadata;
		}
		// Filter by key
		if ( structKeyExists( variables.actionMetadata, arguments.key ) ) {
			return variables.actionMetadata[ arguments.key ];
		}
		// Nothing found, just return the default value of empty string
		return arguments.defaultValue;
	}

	/**
	 * Return the full handler metadata structure or filter by key and default value if needed
	 *
	 * @key          The key to search for in the handler metadata
	 * @defaultValue Default value to return if not found
	 *
	 * @return any
	 */
	function getHandlerMetadata( key, defaultValue = "" ){
		// If no key passed, then return full structure
		if ( isNull( arguments.key ) || !len( arguments.key ) ) {
			return variables.handlerMetadata;
		}
		// Filter by key
		if ( structKeyExists( variables.handlerMetadata, arguments.key ) ) {
			return variables.handlerMetadata[ arguments.key ];
		}
		// Nothing found, just return the default value of empty string
		return arguments.defaultValue;
	}

	/**
	 * Verify if the metadata is loaded or not.
	 */
	boolean function isMetadataLoaded(){
		return !structIsEmpty( variables.handlerMetadata );
	}

	/**
	 * Get the full execution string
	 */
	function getFullEvent(){
		var event = variables.handler & "." & variables.method;
		if ( isModule() ) {
			return variables.module & ":" & event;
		}
		return event;
	}

	/**
	 * Get the runnable execution path
	 */
	function getRunnable(){
		return getInvocationPath() & "." & variables.handler;
	}

	/**
	 * Is this a module execution
	 */
	boolean function isModule(){
		return ( len( variables.module ) GT 0 );
	}

	/**
	 * Are we in missing action execution
	 */
	boolean function isMissingAction(){
		return ( len( variables.missingAction ) GT 0 );
	}

}
