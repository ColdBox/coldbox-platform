component{

	this.allowedMethods = {
		"index" = "GET"
	};

	function index( event, rc, prc ){
		prc.welcomeMessage = "Welcome to ColdBox!";
		event.setView("main/index");
	}

	function routes( event, rc, prc ){
		var SES = getInterceptor( "SES", true );

		prc.aRoutes          = getInterceptor( "SES", true ).getRoutes();
		prc.aModuleRoutes    = getInterceptor( "SES", true ).getModuleRoutingTable();
		prc.aNamespaceRoutes = getInterceptor( "SES", true ).getNamespaceRoutingTable();

		event.setView( "main/routes" );
	}

	function testUnload( event, rc, prc ){
		controller.getModuleService().unload( "conventionsTest" );
		return "unloaded conventions";
	}

	/**
	 * Global invalid http method handler
	 */
	function invalidHTTPMethod( event, rc, prc ){
		return "invalid http: #event.getCurrentEvent()#";
	}

	/**
	* actionAllowedMethod
	*/
	function actionAllowedMethod( event, rc, prc ) allowedMethods="GET"{
		return "Executed!";
	}

	// Do something
	function doSomething( event, rc, prc ){
		relocate("main.index");
	}

	function testPrivateActions( event, rc, prc ){
		event.setView( "main/testPrivateActions" );
	}

	/************************************** PRIVATE ACTIONS *********************************************/

 	private function privateInfo( event, rc, prc ){
		prc.someinfo = "private actions rule";
 	}

	/************************************** IMPLICIT ACTIONS *********************************************/

	function onAppInit( event, rc, prc ){

	}

	function onInvalidEvent( event, rc, prc ){
		event.renderData( data="<h1>Invalid Page</h1>" );
	}

	function onRequestStart( event, rc, prc ){

	}

	function onRequestEnd( event, rc, prc ){

	}

	function onSessionStart( event, rc, prc ){

	}

	function onSessionEnd( event, rc, prc ){
		var sessionScope = event.getValue("sessionReference");
		var applicationScope = event.getValue("applicationReference");
	}

	function onException( event, rc, prc ){
		//Grab Exception From request collection, placed by ColdBox
		var exceptionBean = event.getValue( name="exception", private=true );
		//Place exception handler below:

	}

	function onMissingTemplate( event, rc, prc ){
		//Grab missingTemplate From request collection, placed by ColdBox
		var missingTemplate = event.getValue("missingTemplate");

	}

}
