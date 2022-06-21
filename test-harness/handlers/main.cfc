component {

	property name="asyncManager" inject="coldbox:asyncManager";

	this.allowedMethods = { "index" : "GET" };

	function testJsonRCPayload( event, rc, prc ){
		return rc;
	}

	function routeRunner( event, rc, prc ){
		return runRoute( "routeRunner", { id : 2, name : "unit test" } );
	}

	function routeRunnerWithCaching( event, rc, prc ){
		return runRoute(
			"routeRunner",
			{ id : 2, name : "unit test" },
			true,
			5
		);
	}

	function returnTest( event, rc, prc, name = "ColdBox" ){
		return "<h1>Welcome to #arguments.name#!</h1>";
	}

	function cachePanel( event, rc, prc ){
		event.setView( view = "main/cachePanel", noLayout = "true" );
	}

	function redirectTest( event, rc, prc ){
		return "Redirected correctly";
	}

	function index( event, rc, prc, name = "ColdBox" ){
		prc.welcomeMessage = "Welcome to #arguments.name#!";
		event.setView( "main/index" );
	}

	function routes( event, rc, prc ){
		var routingService = controller.getRoutingService();

		prc.aRoutes          = routingService.getRoutes();
		prc.aModuleRoutes    = routingService.getModuleRoutingTable();
		prc.aNamespaceRoutes = routingService.getNamespaceRoutingTable();

		event.setView( "main/routes" );
	}

	function testUnload( event, rc, prc ){
		controller.getModuleService().unload( "conventionsTest" );
		return "unloaded conventions";
	}

	function throwException( event, rc, prc ){
		throw( message : "Whoops!", type : "CustomException" );
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
		relocate( "main.index" );
	}

	function testPrivateActions( event, rc, prc ){
		event.setView( "main/testPrivateActions" );
	}

	function process( event, rc, prc ){
		log.info( "Processing data..." );
		sleep( randrange( 500, 1500 ) );
		log.info( "Processing data finished!" );
	}

	function badUrl( event, rc, prc ) cache="true" cacheTimeout="1"{
		event.setHTTPHeader( "404", "Not Found" );
		return "bad url";
	}


	/************************************** PRIVATE ACTIONS *********************************************/

	private function privateInfo( event, rc, prc ){
		prc.someinfo = "private actions rule";
	}

	/************************************** IMPLICIT ACTIONS *********************************************/

	function onAppInit( event, rc, prc ){
		listen( function(){
			log.info( "executing from closure listener");
		}, "preProcess" );
	}

	function onInvalidEvent( event, rc, prc ){
		event.renderData( data = "<h1>Invalid Page</h1>", statusCode = 404 );
	}

	function onRequestStart( event, rc, prc ){
	}

	function onRequestEnd( event, rc, prc ){
	}

	function onSessionStart( event, rc, prc ){
	}

	function onSessionEnd( event, rc, prc ){
		var sessionScope     = event.getValue( "sessionReference" );
		var applicationScope = event.getValue( "applicationReference" );
	}

	function onException( event, rc, prc ){
		// Grab Exception From request collection, placed by ColdBox
		var exceptionBean = event.getValue( name = "exception", private = true );
		// Place exception handler below:
		writedump( var="********** #exceptionBean.getMessage()#", output="console" );
	}

	function onMissingTemplate( event, rc, prc ){
		// Grab missingTemplate From request collection, placed by ColdBox
		var missingTemplate = event.getValue( "missingTemplate" );
	}

}
