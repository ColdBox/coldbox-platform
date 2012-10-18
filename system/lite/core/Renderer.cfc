<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This is ColdBox's Renderer plugin.
----------------------------------------------------------------------->
component accessors="true" serializable="false" extends="coldbox.system.lite.FrameworkSupertype"{
	
	/************************************** PROPERTIES *********************************************/

	property name="controller";
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
		event 	= arguments.controller.getContext();

		// Create View Scopes
		rc 		= event.getCollection();
		prc 	= event.getCollection(private=true);

		return this;
	}

	/************************************** VIEW METHODS *********************************************/
	
	function setExplicitView(required view){
		explicitView = arguments.view;
		return this;
	}
	
	function renderView(view="", struct args={}, collection, collectionAs="", numeric collectionStartRow="1", numeric collectionMaxRows=0, collectionDelim="", boolean prePostExempt=false){
		var viewCacheKey 		= "";
		var viewCacheEntry 		= "";
		var viewCacheProvider 	= templateCache;
		var timerHash 			= 0;
		var iData 				= arguments;
		var viewLocations		= "";

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

		// Do we have a view To render? Else throw exception
		if( NOT len(arguments.view) ){
			throw(message="The ""currentview"" variable has not been set, therefore there is no view to render.",
				  detail="Please remember to use the 'event.setView()' method in your handler or pass in a view to render.",
				  type="Renderer.ViewNotSetException");
		}
		
		// Cleanup leading / in views, just in case
		arguments.view = reReplace( arguments.view, "^(\\|/)", "" );
		
		// Announce preViewRender interception
		if( NOT arguments.prepostExempt ){ announceInterception("preViewRender", iData); }

		// Prepare caching arguments if doing implicit caching, and the view to render is the same as the implicitly cached.
		viewCacheEntry = event.getViewCacheableEntry();
		if( event.isViewCacheable() AND (arguments.view EQ viewCacheEntry.view) ){
			arguments.cache						= true;
			arguments.cacheTimeout				= viewCacheEntry.timeout;
			arguments.cacheLastAccessTimeout	= viewCacheEntry.lastAccessTimeout;
			arguments.cacheSuffix 				= viewCacheEntry.cacheSuffix;
			arguments.cacheProvider				= viewCacheEntry.cacheProvider;
		}
		// Prepare caching key
		viewCacheKey = templateCache.VIEW_CACHEKEY_PREFIX & arguments.module & ":" & arguments.view & arguments.cacheSuffix;
		// Are we caching?
		if (arguments.cache){
			// Which provider you want to use?
			if( arguments.cacheProvider neq "template" ){
				viewCacheProvider = cacheBox.getCache( arguments.cacheProvider );
			}
			// Try to get from cache
			timerHash = debuggerService.timerStart("rendering Cached View [#arguments.view#.cfm] from '#arguments.cacheProvider# provider'");
			iData.renderedView = viewCacheProvider.get( viewCacheKey );
			// Verify it existed
			if( structKeyExists(iData, "renderedView") ){
				debuggerService.timerEnd( timerHash );
				// Post View Render Interception
				if( NOT arguments.prepostExempt ){ announceInterception("postViewRender", iData); }
				// Return it
				return iData.renderedView;
			}
		}

		// No caching, just render
		// Discover and cache view/helper locations
		viewLocations = discoverViewPaths(arguments.view,arguments.module,explicitModule);

		// Render View Composite or View Collection
		timerHash = debuggerService.timerStart("rendering View [#arguments.view#.cfm]");
		if( structKeyExists(arguments,"collection") ){
			// render collection in next context
			iData.renderedView = getPlugin("Renderer").renderViewCollection(arguments.view, viewLocations.viewPath, viewLocations.viewHelperPath, arguments.args, arguments.collection, arguments.collectionAs, arguments.collectionStartRow, arguments.collectionMaxRows, arguments.collectionDelim);
		}
		else{
			// render simple composite view
			iData.renderedView = renderViewComposite(arguments.view, viewLocations.viewPath, viewLocations.viewHelperPath, arguments.args);
		}
		debuggerService.timerEnd(timerHash);

		// Post View Render Interception point
		if( NOT arguments.prepostExempt ){ announceInterception("postViewRender", iData); }

		// Are we caching view
		if ( arguments.cache ){
			viewCacheProvider.set(viewCacheKey, iData.renderedView, arguments.cacheTimeout, arguments.cacheLastAccessTimeout);
		}

		// Return view content
		return iData.renderedView;
	}

	private function discoverViewPaths(view){
		var locationKey 	= arguments.view & arguments.module & arguments.explicitModule;
		var locationUDF 	= variables.locateView;
		var dPath			= "";
		var refMap			= "";

		// Check cached paths first --->
		lock name="#locationKey#.#lockName#" type="readonly" timeout="15" throwontimeout="true"{
			if( structkeyExists( controller.getSetting("viewsRefMap") ,locationKey) AND isDiscoveryCaching )
				return structFind( controller.getSetting("viewsRefMap"), locationKey);
			}
		}
			
		if (left(arguments.view, 1) EQ "/") {

			refMap = {
				viewPath = arguments.view,
				viewHelperPath = ""
			};

		} else { // view discovery based on relative path

			// module change mode
			if( len(arguments.module) ){ locationUDF = variables.locateModuleView; }

			// Locate the view to render according to discovery algorithm and create cache map
			refMap = {
				viewPath = locationUDF(arguments.view,arguments.module,arguments.explicitModule),
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

		// Lock and create view entry --->
		if( NOT structkeyExists( controller.getSetting("viewsRefMap") ,locationKey) )
			lock name="#locationKey#.#lockName#" type="exclusive" timeout="15" throwontimeout="true"{
				structInsert( controller.getSetting("viewsRefMap"), locationKey, refMap, true);
			}
		}

		return refMap;
    }

	function renderViewComposite(view, viewPath, viewHelperPath, args, collection, collectionAs, collectionStartRow=1, collectionMaxRows=0, collectionDelim=""){
	
		var buffer 	= createObject("java","java.lang.StringBuffer").init();
		var x 		= 1;
		var recLen 	= 0;

		// Determine the collectionAs key
		if( NOT len(arguments.collectionAs) ){
			arguments.collectionAs = listLast(arguments.view,"/");
		}

		// Array Rendering
		if( isArray(arguments.collection) ){
			recLen = arrayLen(arguments.collection);
			// is max rows passed?
			if( arguments.collectionMaxRows NEQ 0 AND arguments.collectionMaxRows LTE recLen){ recLen = arguments.collectionMaxRows; }
			// Create local marker
			variables._items	= recLen;
			// iterate and present
			for(x=arguments.collectionStartRow; x lte recLen; x++){
				// setup local cvariables
				variables._counter  = x;
				variables[ arguments.collectionAs ] = arguments.collection[x];
				// prepend the delim
				if ( x NEQ arguments.collectionStartRow ) {
					buffer.append( arguments.collectionDelim );
				}
				// render item composite
				buffer.append( renderViewComposite(arguments.view,arguments.viewPath,arguments.viewHelperPath,arguments.args) );
			}
			return buffer.toString();
		}

		// Query Rendering --->
		variables._items	= arguments.collection.recordCount;
		// Max Rows --->
		if( arguments.collectionMaxRows NEQ 0 AND arguments.collectionMaxRows LTE arguments.collection.recordCount)
			variables._items	= arguments.collectionMaxRows;
		}
		
		for(x=arguments.collectionStartRow; x lte (arguments.collectionStartRow+variables._items)-1; x++){
			// setup local cvariables
			variables._counter  = arguments.collection.currentRow;
			variables[ arguments.collectionAs ] = arguments.collection;
			// prepend the delim
			if ( variables._counter NEQ 1 ) {
				buffer.append( arguments.collectionDelim );
			}
			// render item composite
			buffer.append( renderViewComposite(arguments.view,arguments.viewPath,arguments.viewHelperPath,arguments.args) );
		}
				
		return buffer.toString();
    }
    
    function renderViewComposite(view, viewPath, viewHelperPath, args){
    	var cbox_renderedView = "";
		
		savecontent variable="cbox_renderedView"{if( len(arguments.viewHelperPath) AND NOT structKeyExists(renderedHelpers,arguments.viewHelperPath) ){ writeOutput( include "#arguments.viewHelperPath#" ); renderedHelpers[arguments.viewHelperPath]=true;</cfoutput></cfif><cfoutput><cfinclude template="#arguments.viewPath#.cfm"></cfoutput></cfsavecontent>

    	return cbox_renderedView;
    }

	function renderExternalView(view, struct args=event.getCurrentViewArgs()){
		var cbox_renderedView = "";
		// Cache Entries
		var cbox_cacheKey 		= "";
		var cbox_cacheEntry 	= "";
		var cbox_cacheProvider 	= templateCache;
		var viewLocations 		= "";

		// Setup the cache key
		cbox_cacheKey = templateCache.VIEW_CACHEKEY_PREFIX & "external-" & arguments.view & arguments.cacheSuffix;
		// Setup the cache provider
		if( arguments.cacheProvider neq "template" ){ cbox_cacheProvider = cacheBox.getCache( arguments.cacheProvider ); }
		// Try to get from cache
		cbox_timerHash 		= debuggerService.timerStart("rendering Cached External View [#arguments.view#.cfm] from '#arguments.cacheProvider#' provider");
		cbox_renderedView 	= cbox_cacheProvider.get(cbox_cacheKey);
		if( isDefined("cbox_renderedView") ){
			debuggerService.timerEnd( cbox_timerHash );
			return cbox_renderedView;
		}
		// Not in cache, render it
		cbox_timerHash = debuggerService.timerStart("rendering External View [#arguments.view#.cfm]");
		// Get view locations
		viewLocations = discoverViewPaths( arguments.view,"",false);
		// Render External View
		cbox_renderedView = renderViewComposite(view, viewLocations.viewPath, viewLocations.viewHelperPath, args);
			debuggerService.timerEnd(cbox_timerHash);
			// Are we caching it
			if( arguments.cache ){
				cbox_cacheProvider.set(cbox_cacheKey, cbox_renderedView, arguments.cacheTimeout, arguments.cacheLastAccessTimeout);
			}
			return cbox_renderedView;
	}
	
	/************************************** LAYOUT METHODS *********************************************/

	<!--- Render the layout --->
	<cffunction name="renderLayout" access="Public" hint="Renders the current layout + view Combinations if declared." output="false" returntype="any">
		<cfargument name="layout" 		type="any" 	required="false" hint="The explicit layout to use in rendering"/>
		<cfargument name="view"   		type="any" 	required="false" default="" hint="The view to render within this layout explicitly"/>
		<cfargument name="module" 		type="any"  required="false" default="" hint="Explicitly render a layout from this module by passing its module name"/>
		<cfargument name="args"   		type="any" 	required="false" default="#event.getCurrentViewArgs()#" hint="An optional set of arguments that will be available to this layouts/view rendering ONLY"/>
		<cfargument name="viewModule"   type="any" 	required="false" default="" hint="Explicitly render a view from this module"/>
		<cfargument name="prepostExempt" type="any"	required="false" default="false" 	hint="If true, pre/post layout interceptors will not be fired. By default they do fire" colddoc:generic="boolean">

		<cfset var cbox_currentLayout 		= implicitViewChecks()>
		<cfset var cbox_timerhash 			= "">
		<cfset var cbox_locateUDF 			= variables.locateLayout>
		<cfset var cbox_explicitModule  	= false>
		<cfset var cbox_layoutLocationKey 	= "">
		<cfset var cbox_layoutLocation		= "">
		<cfset var iData					= arguments>
		<cfset var viewLocations = "" />

		<!--- Are we doing a nested view/layout explicit combo or already in its rendering algorithm? --->
		<cfif len(trim(arguments.view)) AND arguments.view neq explicitView>
			<cfreturn getPlugin("Renderer").setExplicitView(arguments.view).renderLayout(argumentCollection=arguments)>
		</cfif>

		<!--- Module Default Value --->
		<cfif NOT len(arguments.module)>
			<cfset arguments.module = event.getCurrentModule()>
		<cfelse>
			<cfset cbox_explicitModule = true>
		</cfif>

		<!--- Check explicit layout rendering --->
		<cfif structKeyExists(arguments,"layout")>
			<!--- Check if any length on incoming layout --->
			<cfif len ( arguments.layout )>
				<!--- Cleanup leading / in views, just in case --->
				<cfset arguments.layout = reReplace( arguments.layout, "^(\\|/)", "" )>
				<cfset cbox_currentLayout = arguments.layout & ".cfm">
			<cfelse>
				<cfset cbox_currentLayout = "">
			</cfif>
		</cfif>

		<!--- Announce preLayoutRender interception --->
		<cfif NOT arguments.prepostExempt>
			<cfset announceInterception("preLayoutRender", iData)>
		</cfif>

		<!--- Choose location algorithm if in module mode --->
		<cfif len(arguments.module)>
			<cfset cbox_locateUDF = variables.locateModuleLayout>
		</cfif>

		<!--- Start Timer --->
		<cfset cbox_timerhash = debuggerService.timerStart("rendering Layout [#cbox_currentLayout#]")>

		<!--- If Layout is blank, then just delegate to the view --->
		<cfif len(cbox_currentLayout) eq 0>
			<cfset iData.renderedLayout = renderView( module = arguments.viewModule )>
		<cfelse>
			<!--- Layout location key --->
			<cfset cbox_layoutLocationKey = cbox_currentLayout & arguments.module & cbox_explicitModule>

			<!--- Check cached paths first --->
			<cfif structkeyExists( controller.getSetting("layoutsRefMap") ,cbox_layoutLocationKey) AND isDiscoveryCaching>
				<cflock name="#cbox_layoutLocationKey#.#lockName#" type="readonly" timeout="15" throwontimeout="true">
					<cfset cbox_layoutLocation = structFind( controller.getSetting("layoutsRefMap"), cbox_layoutLocationKey)>
				</cflock>
			<cfelse>
				<!--- Not found, cache it --->
				<cflock name="#cbox_layoutLocationKey#.#lockname#" type="exclusive" timeout="15" throwontimeout="true">
					<cfset cbox_layoutLocation = cbox_locateUDF(cbox_currentLayout,arguments.module,cbox_explicitModule)>
					<cfset structInsert( controller.getSetting("layoutsRefMap"), cbox_layoutLocationKey, cbox_layoutLocation, true)>
				</cflock>
			</cfif>

			<cfset viewLocations = discoverViewPaths( reverse ( listRest( reverse( cbox_layoutLocation ), ".")),arguments.module,cbox_explicitModule) />
			<!--- RenderLayout --->
			<cfset iData.renderedLayout = renderViewComposite(cbox_currentLayout, viewLocations.viewPath, viewLocations.viewHelperPath, args) />
		</cfif>

		<!--- Stop Timer --->
		<cfset debuggerService.timerEnd(cbox_timerhash)>

		<!--- Post Layout Render Interception point --->
		<cfif NOT arguments.prepostExempt>
			<cfset announceInterception("postLayoutRender", iData)>
		</cfif>

		<!--- Return Rendered Layout --->
		<cfreturn iData.renderedLayout>
	</cffunction>

	function locateLayout(required layout){
		// Default path is the conventions
		return "/#appMapping#/#layoutsConvention#/#arguments.layout#";
	}

	function locateView(required view){
		// Default path is the conventions
		return "/#appMapping#/#viewsConvention#/#arguments.view#";
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
	
	/**
	* Announce interceptions in the system
	*/
	private function announceInterception(required state, struct interceptData={}){
		controller.getWireBox().getEventManager().processState(argumentCollection=arguments);
	}
	
}