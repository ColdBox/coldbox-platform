/**
 * Manage photos
 * It will be your responsibility to fine tune this template, add validations, try/catch blocks, logging, etc.
 */
component extends="coldbox.system.EventHandler" {

	// DI
	property name="photosService" inject="photosService@resourcesTest";

	// HTTP Method Security
	this.allowedMethods = {
		index  : "GET",
		new    : "GET",
		create : "POST,PUT",
		show   : "GET",
		edit   : "GET",
		update : "POST,PUT,PATCH",
		delete : "DELETE"
	};

	/**
	 * Param incoming format, defaults to `html`
	 */
	function preHandler( event, rc, prc ){
		event.paramValue( "format", "html" );
	}

	/**
	 * Display a list of photos
	 */
	function index( event, rc, prc ){
		prc.photos = photosService.list();
		event.setView( "photos/index" );
	}

	/**
	 * Return an HTML form for creating one photos
	 */
	function new( event, rc, prc ){
		event.setView( "photos/new" );
	}

	/**
	 * Create a photos
	 */
	function create( event, rc, prc ){
		return "photo created";
	}

	/**
	 * Show a photos
	 */
	function show( event, rc, prc ){
		event.paramValue( "id", 0 );

		event.setView( "photos/show" );
	}

	/**
	 * Edit a photos
	 */
	function edit( event, rc, prc ){
		event.paramValue( "id", 0 );

		event.setView( "photos/edit" );
	}

	/**
	 * Update a photos
	 */
	function update( event, rc, prc ){
		event.paramValue( "id", 0 );

		return "photo updated";
	}

	/**
	 * Delete a photos
	 */
	function delete( event, rc, prc ){
		event.paramValue( "id", 0 );
		return "photo deleted";
	}

}
