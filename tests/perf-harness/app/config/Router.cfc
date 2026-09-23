/**
 * Performance harness router — five measurable test scenarios.
 */
component {

	/**
	 * ColdBox hook: called by RoutingService instead of reading CGI.PATH_INFO.
	 * When the Tuckey URL rewriter does a forward(), the original request URI
	 * is in the javax.servlet.forward.request_uri attribute; CGI.PATH_INFO is empty.
	 * This provider extracts the original path and strips the app sub-path prefix.
	 */
	function pathInfoProvider( event ){
		var forwardURI = getPageContext().getRequest().getAttribute( "javax.servlet.forward.request_uri" )
		if ( !isNull( forwardURI ) && len( forwardURI ) ) {
			return reReplaceNoCase( forwardURI, "^/tests/perf-harness/(be-app|stable-app)", "" )
		}
		return CGI.PATH_INFO
	}

	function configure(){
		// Health check — minimal response, no DI, no view
		route( "/perf/health" ).to( "Main.health" )

		// Simple view — renders view + layout
		route( "/perf/view" ).to( "Main.index" )

		// JSON API — DI injection + renderData
		route( "/perf/api" ).to( "Api.list" )

		// Complex view — multiple model injections + data loop
		route( "/perf/complex" ).to( "Main.complex" )

		// Module request — full HMVC module routing
		route( "/perf/module" ).to( "perf-module:Items.index" )

		// Default convention routing
		route( "/:handler/:action?" ).end()
	}

}
