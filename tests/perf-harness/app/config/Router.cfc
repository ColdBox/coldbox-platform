/**
 * Performance harness router — five measurable test scenarios.
 */
component {

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
