﻿component{

	// Default Action
	function index(event,rc,prc){
		prc.welcomeMessage = "Welcome to ColdBox!";
		event.setView("main/index");
	}

	/**
	* sayHello
	*/
	function sayHello( event, rc, prc ){
		return "<h1>Hola From ColdBox</h1>";
	}

	/**
	* restful
	*/
	function restful( event, rc, prc ){
		param name="rc.format" default="json";

		var data = [
			{ id = createUUID(), name = "random #randRange( 1, 999 )#" },
			{ id = createUUID(), name = "random #randRange( 1, 999 )#" },
			{ id = createUUID(), name = "random #randRange( 1, 999 )#" },
			{ id = createUUID(), name = "random #randRange( 1, 999 )#" },
			{ id = createUUID(), name = "random #randRange( 1, 999 )#" }
		];
		event.renderData( data=data, formats="xml,json" );
	}


	/************************************** IMPLICIT ACTIONS *********************************************/

	function onAppInit(event,rc,prc){

	}

	function onRequestStart(event,rc,prc){

	}

	function onRequestEnd(event,rc,prc){

	}

	function onSessionStart(event,rc,prc){

	}

	function onSessionEnd(event,rc,prc){
		var sessionScope = event.getValue("sessionReference");
		var applicationScope = event.getValue("applicationReference");
	}

	function onException(event,rc,prc){
		//Grab Exception From private request collection, placed by ColdBox Exception Handling
		var exception = prc.exception;
		//Place exception handler below:

	}

	function onMissingTemplate(event,rc,prc){
		//Grab missingTemplate From request collection, placed by ColdBox
		var missingTemplate = event.getValue("missingTemplate");

	}

}
