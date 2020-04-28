component output="false" {

	function index( event, rc, prc ){
		if( rc.core ?: false ){
			setSetting(
				"customErrorTemplate",
				"/coldbox/system/exceptions/BugReport.cfm"
			);
		}
		if( rc.new ?: true ){
			setSetting(
				"customErrorTemplate",
				"/coldbox/system/exceptions/Whoops.cfm"
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
