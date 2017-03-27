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

	/**
	* jsonprotected
	*/
	function jsonprotected( event, rc, prc ){
		prc.data = variables.data;
		event.renderData( data=prc.data, type="jsonp", jsonCallback="callback" );
	}

	/**
	* Returning `event` should work, but ignored by ColdBox, since the data for the rendering is inside of it.
	*/
	function returnEvent( event, rc, prc ){
		return event.setView( "main/index" )
			.setPrivateValue( "welcomeMessage", "I can return the event!" );
	}

	/**
	* renderingRegions
	*/
	function renderingRegions( event, rc, prc ){
		
		// Normal Rendering
		event.setView( 
			view 	= "rendering/withargs",
			args 	= { isWidget = true },
			name 	= "hola"
		);

		// Module Rendering
		event.setView( 
			view 	= "home/index",
			module 	= "inception",
			name 	= "module"
		);

		event.setView( "rendering/renderingRegions" );
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