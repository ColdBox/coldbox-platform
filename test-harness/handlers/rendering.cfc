component output="false" singleton{

	this.allowedMethods = {
		"testHTTPMethod"  = "POST"
	};

	data = [
		{ id = createUUID(), name = "luis" },
		{ id = createUUID(), name = "lucas" },
		{ id = createUUID(), name = "fernando" }
	];

	// Default Action
	function index( event, rc, prc ){
		prc.data = variables.data;
		event.renderData( data=prc.data, formats="json,xml,wddx,pdf,html" );
	}

	function redirect( event, rc, prc ) {
		prc.data = variables.data;
		event.renderData(
			data = prc.data,
			formats = "json,html",
			formatsRedirect = { event = "Main.index" }
		);
	}

	function testHTTPMethod( event, rc, prc ){
		return "this should not fire";
	}

	function onInvalidHTTPMethod( faultAction, event, rc, prc ){
		return "Yep, onInvalidHTTPMethod works!";
	}

}