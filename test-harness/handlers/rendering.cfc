component output="false" singleton {

	this.allowedMethods = { "testHTTPMethod" : "POST" };

	data = [
		{ id : createUUID(), name : "luis" },
		{ id : createUUID(), name : "lucas" },
		{ id : createUUID(), name : "fernando" }
	];

	// Default Action
	function index( event, rc, prc ){
		prc.data = variables.data;
		event.renderData( data = prc.data, formats = "json,xml,wddx,pdf,html" );
	}

	/**
	 * jsonprotected
	 */
	function jsonprotected( event, rc, prc ){
		prc.data = variables.data;
		event.renderData(
			data         = prc.data,
			type         = "jsonp",
			jsonCallback = "callback"
		);
	}

	/**
	 * Returning `event` should work, but ignored by ColdBox, since the data for the rendering is inside of it.
	 */
	function returnEvent( event, rc, prc ){
		return event.setView( "main/index" ).setPrivateValue( "welcomeMessage", "I can return the event!" );
	}

	/**
	 * normalRendering
	 */
	function normalRendering( event, rc, prc ){
		return view( view = "simpleview" );
	}

	/**
	 * printable uses simple layout to display the request in one of two
	 * printable formats (html or pdf) base on rc.output value
	 */
	function printable( event , rc, prc ) {
		var test = layout( layout : "simple", view : "simpleview");
		event.renderData( data : test, type : "pdf" );
	}

	/**
	 * Render layout with arguments and passthrough
	 */
	function renderLayoutWithArguments( event, rc, prc ){
		return layout(
			view   = "viewWithArgs",
			layout = "Simple",
			args   = { data : "abc123" }
		);
	}

	/**
	 * Render Layout issue https://ortussolutions.atlassian.net/browse/COLDBOX-903
	 */
	function renderLayout903( event, rc, prc ){
		prc.welcomeMessage = layout( layout:"Main", view:"main/mailcontent" );
		event.setView( "main/index" );
	}


	/**
	 * renderingRegions
	 */
	function renderingRegions( event, rc, prc ){
		// Normal Rendering
		event.setView(
			view = "rendering/withargs",
			args = { isWidget : true },
			name = "hola"
		);

		// Module Rendering
		event.setView(
			view   = "home/index",
			module = "inception",
			name   = "module"
		);

		event.setView( "rendering/renderingRegions" );
	}

	function redirect( event, rc, prc ){
		prc.data = variables.data;
		event.renderData(
			data            = prc.data,
			formats         = "json,html",
			formatsRedirect = { event : "Main.index" }
		);
	}

	function testHTTPMethod( event, rc, prc ){
		return "this should not fire";
	}

	function onInvalidHTTPMethod( faultAction, event, rc, prc ){
		return "Yep, onInvalidHTTPMethod works!";
	}

	function renderingPdf( event, rc, prc ) {
		cfheader( name='content-disposition', value='attachment;filename="Delivered by Hand.pdf"' );

		event.renderData(
			data='Just some testing text, inline rendering PDF'
			,type='pdf'
			,pdfArgs={ pagetype:'A4', unit:'cm', margintop:'1', marginbottom:'1',marginleft:'1', marginright:'1' }
		);

		return;
	}

}
