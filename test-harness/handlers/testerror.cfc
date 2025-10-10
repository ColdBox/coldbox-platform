component output="false" {

	/**
	 * Test error actions 🙃
	 * Esto es para probar utf8 mañana ümlau
	 */
	function index( event, rc, prc ){
		rc.nullTest = javacast( "null", "" );
		prc.nullTest = javacast( "null", "" );

		if( rc.core ?: false ){
			setSetting(
				"customErrorTemplate",
				"/coldbox/system/exceptions/BugReport.cfm"
			);
		}
		else if( rc.public ?: false ){
			setSetting(
				"customErrorTemplate",
				"/coldbox/system/exceptions/BugReport-Public.cfm"
			);
		}
		else if( rc.new ?: true ){
			setSetting(
				"customErrorTemplate",
				"/coldbox/system/exceptions/Whoops.cfm"
			);
		}

		//queryExecute( "select test from users where id = :id", { id :  0} );
		// testing coldbox exception bean, this line will throw error
		event.getValuesss( "random" );
		return;
	}

	function expression( event, rc, prc ){
		event.setView( "testerror/expression" );
	}

}
