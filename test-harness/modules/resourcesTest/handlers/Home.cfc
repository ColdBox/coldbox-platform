/**
 * A normal ColdBox Event Handler
 */
component {

	property name="executor" inject="executor:resourcesPool";
	property name="resourcesPool" inject="executor";

	function index( event, rc, prc ){
		log.info( "Executor injected: #executor.getName()#" );
		log.info( "Executor injected: #resourcesPool.getName()#" );
		event.setView( "home/index" );
	}

}
