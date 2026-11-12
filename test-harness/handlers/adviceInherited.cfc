/**
 * preview() with no view() action of its own: the inherited framework view() helper is not an action,
 * so preview() is a normal action, not advice.
 * Tested by tests/specs/integration/AdviceDispatchSpec.cfc
 */
component {

	function preview( event, rc, prc ){
		event.renderData( type = "plain", data = "INHERITED-PREVIEW-OK" )
	}

}
