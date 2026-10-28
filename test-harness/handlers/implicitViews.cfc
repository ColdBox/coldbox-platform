/**
 * Actions for the implicit view specs in tests/specs/integration/ImplicitViewsSpec.cfc
 */
component {

	// Sets no view: views/implicitViews/withView.cfm renders implicitly
	function withView( event, rc, prc ){
	}

	// Sets no view: the only matching template is implicitViews/noView.cfm in the app root
	function noView( event, rc, prc ){
	}

	// Selects the app root template explicitly, which is still allowed
	function explicitRoot( event, rc, prc ){
		event.setView( "implicitViews/noView" )
	}

}
