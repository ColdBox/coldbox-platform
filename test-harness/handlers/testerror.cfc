component output="false" {

	function index( event, rc, prc ){
		// testing coldbox exception bean, this line will throw error
		event.getValuesss( "random" );
		return;
	}

	function expression( event, rc, prc ){
		event.setView( "testerror/expression" );
	}

}
