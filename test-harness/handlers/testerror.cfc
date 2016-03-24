component output="false"{

	function index( event, rc, prc ){
		// testing coldbox exception bean, this line will throw error
		event.getValuesss("random");
		return;
	}

}	