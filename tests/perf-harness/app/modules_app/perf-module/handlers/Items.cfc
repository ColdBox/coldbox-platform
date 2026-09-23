/**
 * Module handler — returns item list as JSON.
 */
component extends="coldbox.system.EventHandler" {

	property name="itemService" inject="ItemService@perf-module";

	function index( event, rc, prc ){
		event.renderData(
			type = "json",
			data = {
				status  : "success",
				module  : "perf-module",
				count   : 10,
				items   : itemService.getItems( 10 )
			}
		)
	}

}
