/**
 * Visualize system routes
 */
component{

	function index( event, rc, prc ){
		var oSES = getInterceptor( "SES" );

		prc.aRoutes          = oSES.getRoutes();
		prc.aModuleRoutes    = oSES.getModuleRoutingTable();
		prc.aNamespaceRoutes = oSES.getNamespaceRoutingTable();

		event.setView( "home/index" );
	}

}
