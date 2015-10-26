/**
********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* I model a ColdBox Event Handler
*/
component accessors="true"{ 

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
	property name="isPrivate" 		type="boolean";
	/**
	* View dispatching
	*/
	property name="viewDispatch" 	type="boolean";
	
	/************************************** CONSTRUCTOR *********************************************/	

	/**
	* Constructor
	* @invocationPath.hint The default invocation path
	*/
	function init( invocationPath="" ){
		variables.invocationPath 	= arguments.invocationPath;
		handler 					= "";
		method						= "";
		module 						= "";
		isPrivate					= false;
		missingAction				= "";
		viewDispatch				= false;
		
		return this;
	}

	/************************************** PUBLIC RETURN BACK SETTERS *********************************************/
	
	function setHandler( required handler ){ variables.handler = arguments.handler; return this; }
	function setMethod( required method ){ variables.method = arguments.method; return this; }
	function setModule( required module ){ variables.module = arguments.module; return this; }
	function setMissingAction( required missingAction ){ variables.missingAction = arguments.missingAction; return this; }
	function setViewDispatch( required viewDispatch ){ variables.viewDispatch = arguments.viewDispatch; return this; }
	function setInvocationPath( required invocationPath ){ variables.invocationPath = arguments.invocationPath; return this; }
	
	/************************************** UTILITY METHODS *********************************************/
	
	/**
	* Get the full execution string
	*/
	function getFullEvent(){
		var event = variables.handler & "." & variables.method;
		if( isModule() ){
			return variables.module  & ":" & event;
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