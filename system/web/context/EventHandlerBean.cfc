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

	/**
	 * Registered handler metadata
	 */
	property name="handlerRecord" type="struct";

	/**
	 * Precalculated runnable execution path
	 */
	property name="runnable";

	/**
	 * Precalculated full event string
	 */
	property name="fullEvent";

	/**
	 * Precalculated default event string
	 */
	property name="defaultEvent";

	/**
	 * Registered handler source
	 */
	property name="handlerSource";

	/************************************** CONSTRUCTOR *********************************************/

	/**
	 * Constructor
	 *
	 * @invocationPath The default invocation path
	 */
	function init( invocationPath = "" ){
		variables.invocationPath  = arguments.invocationPath
		variables.handler         = ""
		variables.method          = ""
		variables.module          = ""
		variables.isPrivate       = false
		variables.missingAction   = ""
		variables.viewDispatch    = false
		variables.actionMetadata  = {}
		variables.handlerMetadata = {}
		variables.handlerRecord   = {}
		variables.runnable        = ""
		variables.fullEvent       = ""
		variables.defaultEvent    = ""
		variables.handlerSource   = ""

		return this
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
		var annotations = variables.actionMetadata.keyExists( "annotations" ) ? variables.actionMetadata.annotations : variables.actionMetadata
		return annotations.keyExists( arguments.key )
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
		var annotations = variables.actionMetadata.keyExists( "annotations" ) ? variables.actionMetadata.annotations : variables.actionMetadata;
		if ( structKeyExists( annotations, arguments.key ) ) {
			return annotations[ arguments.key ];
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
		return !structIsEmpty( variables.handlerMetadata )
	}

	/**
	 * Get the full execution string
	 */
	function getFullEvent(){
		if ( len( variables.fullEvent ) ) {
			return variables.fullEvent
		}

		var event = variables.handler & "." & variables.method
		if ( isModule() ) {
			return variables.module & ":" & event
		}
		return event
	}

	/**
	 * Get the runnable execution path
	 */
	function getRunnable(){
		if ( len( variables.runnable ) ) {
			return variables.runnable
		}

		return getInvocationPath() & "." & variables.handler
	}

	/**
	 * Set the invocation path and invalidate derived runnable paths.
	 *
	 * @invocationPath The invocation path
	 *
	 * @return EventHandlerBean
	 */
	function setInvocationPath( required invocationPath ){
		variables.invocationPath = arguments.invocationPath
		variables.runnable       = ""

		return this
	}

	/**
	 * Set the handler and invalidate derived event/runnable paths.
	 *
	 * @handler The handler to execute
	 *
	 * @return EventHandlerBean
	 */
	function setHandler( required handler ){
		variables.handler   = arguments.handler
		variables.runnable  = ""
		variables.fullEvent = ""

		return this
	}

	/**
	 * Set the method and invalidate derived event paths.
	 *
	 * @method The method to execute
	 *
	 * @return EventHandlerBean
	 */
	function setMethod( required method ){
		variables.method    = arguments.method
		variables.fullEvent = ""

		return this
	}

	/**
	 * Set the module and invalidate derived event paths.
	 *
	 * @module The module assignment
	 *
	 * @return EventHandlerBean
	 */
	function setModule( required module ){
		variables.module    = arguments.module
		variables.fullEvent = ""

		return this
	}

	/**
	 * Apply a registered handler record to the bean.
	 *
	 * @handlerRecord The registered handler metadata
	 *
	 * @return EventHandlerBean
	 */
	function setHandlerRecord( required struct handlerRecord ){
		variables.handlerRecord = arguments.handlerRecord

		if ( structKeyExists( arguments.handlerRecord, "handler" ) ) {
			variables.handler = arguments.handlerRecord.handler
		}

		if ( structKeyExists( arguments.handlerRecord, "invocationPath" ) ) {
			variables.invocationPath = arguments.handlerRecord.invocationPath
		}

		if ( structKeyExists( arguments.handlerRecord, "runnable" ) ) {
			variables.runnable = arguments.handlerRecord.runnable
		} else {
			variables.runnable = ""
		}

		if ( structKeyExists( arguments.handlerRecord, "defaultEvent" ) ) {
			variables.defaultEvent = arguments.handlerRecord.defaultEvent
		} else {
			variables.defaultEvent = ""
		}

		if ( structKeyExists( arguments.handlerRecord, "source" ) ) {
			variables.handlerSource = arguments.handlerRecord.source
		} else {
			variables.handlerSource = ""
		}

		variables.fullEvent = ""

		return this
	}

	/**
	 * Is this a module execution
	 */
	boolean function isModule(){
		return ( len( variables.module ) GT 0 )
	}

	/**
	 * Are we in missing action execution
	 */
	boolean function isMissingAction(){
		return ( len( variables.missingAction ) GT 0 )
	}

}
