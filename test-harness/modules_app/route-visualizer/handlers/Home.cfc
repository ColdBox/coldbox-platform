/**
 * Visualize system routes
 */
component{

	function index( event, rc, prc ){
		if( wirebox.containsInstance( name="router@coldbox" ) ){
			var oRouter = getInstance( "router@coldbox" );
		} else {
			var oRouter = getInterceptor( "SES" );
		}

		prc.aRoutes          = oRouter.getRoutes();
		prc.aModuleRoutes    = oRouter.getModuleRoutingTable();
		prc.aNamespaceRoutes = oRouter.getNamespaceRoutingTable();

		event.setView( "home/index" );
	}

}
