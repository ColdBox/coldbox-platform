/**
 * Main handler for performance test scenarios.
 */
component extends="coldbox.system.EventHandler" {

	property name="userService"    inject="UserService";
	property name="productService" inject="ProductService";

	// Baseline — no DI usage, no view, minimal processing
	function health( event, rc, prc ){
		return "ok"
	}

	// Simple view — renders main/index with layout
	function index( event, rc, prc ){
		prc.message   = "ColdBox Performance Harness"
		prc.timestamp = now()
		prc.version   = getColdBoxSetting( "version", "unknown" )
		event.setView( "main/index" )
	}

	// Complex view — resolves two model dependencies, loops data
	function complex( event, rc, prc ){
		prc.users    = userService.getUsers( 10 )
		prc.products = productService.getProducts( 5 )
		event.setView( "main/complex" )
	}

}
