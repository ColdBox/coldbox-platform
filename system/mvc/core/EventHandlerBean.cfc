/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Description :
	I model a ColdBox Event Handler
*/
component accessors="true"{ 

	property name="invocationPath";
	property name="handler";
	property name="method";
	property name="missingAction";
	property name="isPrivate" 		type="boolean";
	property name="viewDispatch" 	type="boolean";
	

	/************************************** CONSTRUCTOR *********************************************/	

	function init(invocationPath=""){
		variables.invocationPath 	= arguments.invocationPath;
		handler 					= "";
		method						= "";
		isPrivate					= false;
		missingAction				= "";
		viewDispatch				= false;
		
		return this;
	}

	/************************************** PUBLIC RETURN BACK SETTERS *********************************************/
	
	function setHandler(required handler){ variables.handler = arguments.handler; return this; }
	function setMethod(required method){ variables.method = arguments.method; return this; }
	function setMissingAction(required missingAction){ variables.missingAction = arguments.missingAction; return this; }
	
	/************************************** UTILITY METHODS *********************************************/
	
	function getFullEvent(){
		return getHandler() & "." & getMethod();
	}	
	
	function getRunnable(){
		return getInvocationPath() & "." & getHandler();
	}
	
	boolean function isMissingAction(){
		return ( len( getMissingAction() ) GT 0 );
	}

}