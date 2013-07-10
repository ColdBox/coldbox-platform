/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Description :
	This is ColdBox's Renderer plugin.
**/
component accessors="true" serializable="false" extends="coldbox.system.mvc.FrameworkSupertype"{
	
	/************************************** PROPERTIES *********************************************/

	property name="layoutsConvention";
	property name="viewsConvention";
	property name="appMapping";
	property name="explicitView";
	property name="renderedHelpers";
	property name="lockName";
	property name="isDiscoveryCaching";
	property name="event";
	property name="rc";
	property name="prc";
	
	/************************************** CONSTRUCTOR *********************************************/
	
	function init(required controller){
		// store Controller
		variables.controller = arguments.controller;

		// Set Conventions
		layoutsConvention 		= "layouts";
		viewsConvention 		= "views";
		appMapping 				= controller.getSetting("AppMapping");
		explicitView 			= "";

		// Template Cache & Caching Maps
		renderedHelpers			= {};
		lockName				= "rendering.#controller.getAppHash()#";

		// Discovery caching is tied to handlers for discovery.
		isDiscoveryCaching		= controller.getSetting("handlerCaching");

		// Set event scope, we are not caching, so it is threadsafe.
		event = arguments.controller.getContext();

		// Create View Scopes
		rc 	= event.getCollection();
		prc = event.getCollection(private=true);

		return this;
	}

	/************************************** VIEW METHODS *********************************************/
	
	function setExplicitView(required view){
		explicitView = arguments.view;
		return this;
	}
	
	function renderView(view="", struct args={}, collection, collectionAs="", numeric collectionStartRow="1", numeric collectionMaxRows=0, collectionDelim="", boolean prePostExempt=false){
		// Rendering an explicit view or do we need to get the view from the context or explicit context?
		if( NOT len( arguments.view ) ){
			// Rendering an explicit Renderer view/layout combo?
			if( len( explicitView ) ){
				arguments.view = explicitView;
				// clear the explicit view now that it has been used
				setExplicitView("");
			}
			// Render the view in the context
			else{ arguments.view = event.getCurrentView(); }
		}

		// Do we have a view to render? Else throw exception
		if( NOT len(arguments.view) ){
			throw(message="The ""currentview"" variable has not been set, therefore there is no view to render.",
				  detail="Please remember to use the 'event.setView()' method in your handler or pass in a view to render.",
				  type="Renderer.ViewNotSetException");
		}
		
		// Cleanup leading / in views, just in case
		arguments.view = reReplace( arguments.view, "^(\\|/)", "" );
		
		// Discover and cache view/helper locations
		var viewLocations = discoverViewPaths( arguments.view );

		// Render View Composite or View Collection
		if( structKeyExists(arguments,"collection") ){
			// render collection in next context
			var sRenderedView = controller.getRenderer().renderViewCollection(arguments.view, viewLocations.viewPath, viewLocations.viewHelperPath, arguments.args, arguments.collection, arguments.collectionAs, arguments.collectionStartRow, arguments.collectionMaxRows, arguments.collectionDelim);
		}
		else{
			// render simple composite view
			var sRenderedView = renderViewComposite(arguments.view, viewLocations.viewPath, viewLocations.viewHelperPath, arguments.args);
		}

		// Return view content
		return sRenderedView;
	}

	private function discoverViewPaths(required view){
		var locationKey 	= arguments.view;
		var dPath			= "";
		var refMap			= "";

		// Check cached paths first --->
		lock name="#locationKey#.#lockName#" type="readonly" timeout="15" throwontimeout="true"{
			if( structkeyExists( controller.getSetting("viewsRefMap") ,locationKey ) AND isDiscoveryCaching ){
				return structFind( controller.getSetting("viewsRefMap"), locationKey);
			}
		}
			
		if( left( arguments.view, 1 ) EQ "/" ){

			refMap = {
				viewPath = arguments.view,
				viewHelperPath = ""
			};

		} 
		else{ // view discovery based on relative path

			// Locate the view to render according to discovery algorithm and create cache map
			refMap = {
				viewPath = locateView( arguments.view ),
				viewHelperPath = ""
			};

		}

		// Check for view helper convention
		dPath = getDirectoryFromPath( refMap.viewPath );
		if( fileExists(expandPath( refMap.viewPath & "Helper.cfm")) ){
			refMap.viewHelperPath = refMap.viewPath & "Helper.cfm";
		}
		// Check for directory helper convention
		else if( fileExists( expandPath( dPath & listLast(dPath,"/") & "Helper.cfm" ) ) ){
			refMap.viewHelperPath = dPath & listLast(dPath,"/") & "Helper.cfm";
		}

		// Lock and create view entry
		if( NOT structkeyExists( controller.getSetting("viewsRefMap") ,locationKey) ){
			lock name="#locationKey#.#lockName#" type="exclusive" timeout="15" throwontimeout="true"{
				structInsert( controller.getSetting("viewsRefMap"), locationKey, refMap, true);
			}
		}

		return refMap;
    }
    
    
	function renderViewCollection(view, viewPath, viewHelperPath, args, collection, collectionAs, numeric collectionStartRow=1, numeric collectionMaxRows=0, collectionDelim=""){
		var buffer 	= createObject("java","java.lang.StringBuilder").init();
		var x 		= 1;
		var recLen 	= 0;

		// Determine the collectionAs key
		if( NOT len( arguments.collectionAs ) ){
			arguments.collectionAs = listLast( arguments.view, "/" );
		}

		// Array Rendering
		if( isArray( arguments.collection ) ){
			recLen = arrayLen( arguments.collection );
			// is max rows passed?
			if( arguments.collectionMaxRows NEQ 0 AND arguments.collectionMaxRows LTE recLen ){ recLen = arguments.collectionMaxRows; }
			// Create local marker
			variables._items	= recLen;
			// iterate and present
			for(x=arguments.collectionStartRow; x lte recLen; x++){
				// setup local cvariables
				variables._counter  = x;
				variables[ arguments.collectionAs ] = arguments.collection[ x ];
				// prepend the delim
				if ( x NEQ arguments.collectionStartRow ) {
					buffer.append( arguments.collectionDelim );
				}
				// render item composite
				buffer.append( renderViewComposite( arguments.view, arguments.viewPath, arguments.viewHelperPath, arguments.args ) );
			}
			return buffer.toString();
		}

		// Query Rendering
		variables._items = arguments.collection.recordCount;
		// Max Rows
		if( arguments.collectionMaxRows NEQ 0 AND arguments.collectionMaxRows LTE arguments.collection.recordCount){
			variables._items = arguments.collectionMaxRows;
		}
		
		for(x=arguments.collectionStartRow; x lte ( arguments.collectionStartRow+variables._items )-1; x++){
			// setup local cvariables
			variables._counter  = arguments.collection.currentRow;
			variables[ arguments.collectionAs ] = arguments.collection;
			// prepend the delim
			if ( variables._counter NEQ 1 ) {
				buffer.append( arguments.collectionDelim );
			}
			// render item composite
			buffer.append( renderViewComposite( arguments.view, arguments.viewPath, arguments.viewHelperPath, arguments.args) );
		}
				
		return buffer.toString();
    }
    
     function renderViewComposite(view, viewPath, viewHelperPath, args){
    	var cbox_renderedView = "";
		
		savecontent variable="cbox_renderedView"{
			if( len( arguments.viewHelperPath ) AND NOT structKeyExists( renderedHelpers,arguments.viewHelperPath ) ){
				include "#arguments.viewHelperPath#";
				renderedHelpers[arguments.viewHelperPath] = true;
			}
			//writeOutput( include "#arguments.viewPath#.cfm" );
			include "#arguments.viewPath#.cfm";
		}

    	return cbox_renderedView;
    }
    
    function renderExternalView(required view, struct args=event.getCurrentViewArgs()){
		// Get view locations
		var viewLocations = discoverViewPaths( arguments.view, "", false );
		// Render External View
		return renderViewComposite( view, viewLocations.viewPath, viewLocations.viewHelperPath, args );
	}
	
	/************************************** LAYOUT METHODS *********************************************/
	
	function renderLayout(layout, view="", struct args=event.getCurrentViewArgs(), boolean prePostExempt=false){
		var cbox_currentLayout 		= implicitViewChecks();
		var cbox_layoutLocationKey 	= "";
		var cbox_layoutLocation		= "";

		// Are we doing a nested view/layout explicit combo or already in its rendering algorithm?
		if( len( trim( arguments.view ) ) AND arguments.view neq explicitView ){
			return controller.getRenderer().setExplicitView( arguments.view ).renderLayout(argumentCollection=arguments);
		}

		// Check explicit layout rendering
		if( structKeyExists(arguments,"layout") ){
			// Check if any length on incoming layout
			if( len ( arguments.layout ) ){
				// Cleanup leading / in views, just in case
				arguments.layout = reReplace( arguments.layout, "^(\\|/)", "" );
				cbox_currentLayout = arguments.layout & ".cfm";
			}
			else{
				cbox_currentLayout = "";
			}
		}

		// If Layout is blank, then just delegate to the view
		if( len( cbox_currentLayout ) eq 0 ){
			var renderedLayout = renderView();
		}
		else{
			// Layout location key
			cbox_layoutLocationKey = cbox_currentLayout;

			// Check cached paths first
			if( structkeyExists( controller.getSetting("layoutsRefMap"), cbox_layoutLocationKey ) AND isDiscoveryCaching ){
				lock name="#cbox_layoutLocationKey#.#lockName#" type="readonly" timeout="15" throwontimeout="true"{
					cbox_layoutLocation = structFind( controller.getSetting("layoutsRefMap"), cbox_layoutLocationKey );
				}
			}
			else{
				lock name="#cbox_layoutLocationKey#.#lockname#" type="exclusive" timeout="15" throwontimeout="true"{
					cbox_layoutLocation = locateLayout( cbox_currentLayout );
					structInsert( controller.getSetting("layoutsRefMap"), cbox_layoutLocationKey, cbox_layoutLocation, true);
				}
			}

			var viewLocations = discoverViewPaths( reverse ( listRest( reverse( cbox_layoutLocation ), "." ) ) );
			// RenderLayout
			var renderedLayout = renderViewComposite( cbox_currentLayout, viewLocations.viewPath, viewLocations.viewHelperPath, args );
		}

		return renderedLayout;
	}

	function locateLayout(required layout){
		// Default path is the conventions
		return "#( len( appMapping) ? "/" & appMapping : "")#/#layoutsConvention#/#arguments.layout#";
	}

	function locateView(required view){
		// Default path is the conventions
		return "#( len( appMapping) ? "/" & appMapping : "")#/#viewsConvention#/#arguments.view#";
	}

	/************************************** PRIVATE *********************************************/
	
	private function implicitViewChecks(){
		var layout = event.getCurrentLayout();
		var cEvent = event.getCurrentEvent();

		// Is implicit views enabled?
		if( not controller.getSetting(name="ImplicitViews") ){ return layout; }

		// Cleanup for modules
		cEvent = reReplaceNoCase(cEvent,"^([^:.]*):","");

		//Check if no view set?
		if( NOT len( event.getCurrentView() ) ){

			// Implicit views
			if( controller.getSetting(name="caseSensitiveImplicitViews", defaultValue=false) ){
				event.setView( replace(cEvent,".","/","all") );
			}
			else{
				event.setView( lcase(replace(cEvent,".","/","all")) );
			}

			// reset layout according to newly set views;
			layout = event.getCurrentLayout();
		}

		return layout;
	}
   
}