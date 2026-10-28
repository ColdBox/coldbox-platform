/**
 * Advice methods that must not be requestable as actions, next to normal actions.
 * Every method records itself in prc.ran so the specs can tell what executed.
 * Tested by tests/specs/integration/AdviceDispatchSpec.cfc
 */
component {

	/************************************** ADVICE *********************************************/

	function preHandler(
		event,
		rc,
		prc,
		action         = "",
		eventArguments = {}
	){
		// The framework passes the action when it runs this as advice
		record( prc, len( arguments.action ) ? "preHandler" : "preHandler:action" )
	}

	function postHandler(
		event,
		rc,
		prc,
		action         = "",
		eventArguments = {}
	){
		record( prc, "postHandler" )
	}

	function aroundHandler(
		event,
		rc,
		prc,
		targetAction,
		eventArguments = {}
	){
		record( prc, "aroundHandler" )
		return arguments.targetAction(
			event = arguments.event,
			rc    = arguments.rc,
			prc   = arguments.prc
		)
	}

	function preIndex( event, rc, prc ){
		record( prc, "preIndex" )
	}

	// Advice for view(): the framework runs it before every view() request
	function preview( event, rc, prc ){
		record( prc, "preview" )
	}

	/************************************** ACTIONS *********************************************/

	function index( event, rc, prc ){
		record( prc, "index" )
		event.renderData( type = "plain", data = "ADVICE-INDEX-OK" )
	}

	function view( event, rc, prc ){
		record( prc, "view" )
		event.renderData( type = "plain", data = "ADVICE-VIEW-OK" )
	}

	// Starts with "pre", but there is no flight() action, so this is a normal action
	function preflight( event, rc, prc ){
		record( prc, "preflight" )
		event.renderData( type = "plain", data = "ADVICE-PREFLIGHT-OK" )
	}


	/************************************** PRIVATE *********************************************/

	private function record( required prc, required name ){
		if ( !arguments.prc.keyExists( "ran" ) ) {
			arguments.prc.ran = []
		}
		arguments.prc.ran.append( arguments.name )
	}

}
