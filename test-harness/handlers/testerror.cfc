component output="false" {

	function index( event, rc, prc ){
		if( rc.core ?: false ){
			setSetting(
				"customErrorTemplate",
				"/coldbox/system/includes/BugReport.cfm"
			);
		}
		if( rc.new ?: false ){
			setSetting(
				"customErrorTemplate",
				"/coldbox/system/includes/Whoops.cfm"
			);
		}
		// testing coldbox exception bean, this line will throw error
		event.getValuesss( "random" );
		return;
	}

	function expression( event, rc, prc ){
		event.setView( "testerror/expression" );
	}

}
