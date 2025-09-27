/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * The system web renderer. In charge of location views/layouts and rendering them.
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component
	accessors   ="true"
	serializable="false"
	extends     ="coldbox.system.FrameworkSupertype"
	threadSafe
	singleton
{

	/****************************************************************
	 * DI *
	 ****************************************************************/

	property name="templateCache" inject="cachebox:template";

	/****************************************************************
	 * Rendering Properties *
	 ****************************************************************/

	// Location of layouts
	property name="layoutsConvention";
	// Location of external layouts
	property name="LayoutsExternalLocation";
	// Location of views
	property name="viewsConvention";
	// Location of external views
	property name="ViewsExternalLocation";
	// Location of application
	property name="appMapping";
	// Modules configuration
	property name="modulesConfig" type="struct";
	// Views Helper Setting
	property name="viewsHelper";
	// Internal locking name
	property name="lockName";
	// Discovery caching is tied to handlers for discovery.
	property name="isDiscoveryCaching";

	/**
	 * Constructor
	 */
	function init(){
		// Layouts + Views Reference Maps
		variables.layoutsRefMap = {};
		variables.viewsRefMap   = {};
		super.init();
		return this;
	}

	/****************************************************************
	 * Deprecated/Removed Methods *
	 ****************************************************************/

	function renderview(){
		variables.log.warn( "renderview() has been deprecated, please update your code to view()", callStackGet() );
		return this.view( argumentCollection = arguments );
	}
	function renderLayout(){
		variables.log.warn(
			"renderLayout() has been deprecated, please update your code to layout()",
			callStackGet()
		);
		return this.layout( argumentCollection = arguments );
	}
	function renderExternalView(){
		variables.log.warn(
			"renderExternalView() has been deprecated, please update your code to externalView()",
			callStackGet()
		);
		return this.externalView( argumentCollection = arguments );
	}

	/**
	 * This is the startup procedures for the renderer. This is called after all modules, interceptions and contributions have been done
	 * in order to allow for all chicken and the egg issues are not relevant.
	 */
	function startup(){
		// Set Conventions, Settings and Properties
		variables.layoutsConvention       = variables.controller.getColdBoxSetting( "layoutsConvention" );
		variables.viewsConvention         = variables.controller.getColdBoxSetting( "viewsConvention" );
		variables.appMapping              = variables.controller.getSetting( "AppMapping" );
		variables.viewsExternalLocation   = variables.controller.getSetting( "ViewsExternalLocation" );
		variables.layoutsExternalLocation = variables.controller.getSetting( "LayoutsExternalLocation" );
		variables.modulesConfig           = variables.controller.getSetting( "modules" );
		variables.viewsHelper             = variables.controller.getSetting( "viewsHelper" );
		variables.viewCaching             = variables.controller.getSetting( "viewCaching" );

		// Global View Helper
		if ( len( variables.viewsHelper ) ) {
			var viewHelperPath = "/#variables.appMapping#/#variables.viewsHelper.listFirst( "." )#";
			if ( fileExists( expandPath( viewHelperPath & ".cfm" ) ) ) {
				variables.viewsHelper = viewHelperPath & ".cfm";
			}
			if ( fileExists( expandPath( viewHelperPath & ".bxm" ) ) ) {
				variables.viewsHelper = viewHelperPath & ".bxm";
			}
		}

		// Template Cache & Caching Maps
		variables.lockName = "rendering.#variables.controller.getAppHash()#";

		// Discovery caching
		variables.isDiscoveryCaching = variables.controller.getSetting( "viewCaching" );

		// Load Application helpers
		loadApplicationHelpers();

		// Announce interception
		announce( "afterRendererInit", { variables : variables, this : this } );
	}

	/************************************** VIEW METHODS *********************************************/

	/**
	 * set the explicit view bit, used mostly internally
	 *
	 * @view          The name of the view to render
	 * @module        The name of the module this view comes from
	 * @args          The view/layout passthrough arguments
	 * @viewVariables The view variables in the variables scope
	 *
	 * @return Renderer
	 */
	function setExplicitView(
		required string view,
		module               = "",
		struct args          = {},
		struct viewVariables = {}
	){
		getRequestContext().setPrivateValue(
			"_explicitView",
			{
				"view"          : arguments.view,
				"module"        : arguments.module,
				"args"          : arguments.args,
				"viewVariables" : arguments.viewVariables
			}
		);
		return this;
	}

	/**
	 * get the explicit view bit
	 */
	function getExplicitView(){
		return getRequestContext().getPrivateValue( "_explicitView", {} );
	}

	/**
	 * Render out a view
	 *
	 * @view                   The the view to render, if not passed, then we look in the request context for the current set view.
	 * @args                   A struct of arguments to pass into the view for rendering, will be available as 'args' in the view.
	 * @module                 The module to render the view from explicitly
	 * @cache                  Cached the view output or not, defaults to false
	 * @cacheTimeout           The time in minutes to cache the view
	 * @cacheLastAccessTimeout The time in minutes the view will be removed from cache if idle or requested
	 * @cacheSuffix            The suffix to add into the cache entry for this view rendering
	 * @cacheProvider          The provider to cache this view in, defaults to 'template'
	 * @collection             A collection to use by this Renderer to render the view as many times as the items in the collection (Array or Query)
	 * @collectionAs           The name of the collection variable in the partial rendering.  If not passed, we will use the name of the view by convention
	 * @collectionStartRow     The start row to limit the collection rendering with
	 * @collectionMaxRows      The max rows to iterate over the collection rendering with
	 * @collectionDelim        A string to delimit the collection renderings by
	 * @prePostExempt          If true, pre/post view interceptors will not be fired. By default they do fire
	 * @name                   The name of the rendering region to render out, Usually all arguments are coming from the stored region but you override them using this function's arguments.
	 * @viewVariables          A struct of variables to incorporate into the view's variables scope.
	 *
	 * @throws ViewNotSetException If no view is set to render or none found
	 */
	function view(
		view                   = "",
		struct args            = getRequestContext().getCurrentViewArgs(),
		module                 = "",
		boolean cache          = false,
		cacheTimeout           = "",
		cacheLastAccessTimeout = "",
		cacheSuffix            = "",
		cacheProvider          = "template",
		collection,
		collectionAs               = "",
		numeric collectionStartRow = "1",
		numeric collectionMaxRows  = 0,
		collectionDelim            = "",
		boolean prePostExempt      = false,
		name,
		viewVariables = {}
	){
		var event             = getRequestContext();
		var viewCacheKey      = "";
		var viewCacheEntry    = "";
		var viewCacheProvider = variables.templateCache;
		var iData             = arguments;
		var explicitModule    = false;

		// Rendering Region call?
		if ( !isNull( arguments.name ) and len( arguments.name ) ) {
			arguments = incorporateRenderingRegion( arguments.name, event, arguments );
		}

		// Rendering an explicit view or do we need to get the view from the context or explicit context?
		if ( isNull( arguments.view ) || NOT len( arguments.view ) ) {
			var explicitView = getExplicitView();
			// Rendering an explicit Renderer view/layout combo?
			if ( explicitView.keyExists( "view" ) && explicitView.view.len() ) {
				// Populate from explicit notation
				arguments.view   = explicitView.view;
				arguments.module = explicitView.module;
				arguments.args.append( explicitView.args, false );
				arguments.viewVariables.append( explicitView.viewVariables, false );
				// clear the explicit view now that it has been used
				getRequestContext().removePrivateValue( "_explicitView" );
			}
			// Render the view in the context
			else {
				arguments.view = event.getCurrentView();
			}
		}

		// If no incoming explicit module call, default the value to the one in the request context for convenience
		if ( NOT len( arguments.module ) ) {
			// check for an explicit view module
			arguments.module = event.getCurrentViewModule();
			// if module is still empty check the event pattern
			// if no module is execution, this will be empty anyways.
			if ( NOT len( arguments.module ) ) {
				arguments.module = event.getCurrentModule();
			}
		} else {
			explicitModule = true;
		}

		// Do we have a view To render? Else throw exception
		if ( NOT len( arguments.view ) ) {
			throw(
				message = "The ""currentview"" variable has not been set, therefore there is no view to render.",
				detail  = "Please remember to use the 'event.setView()' method in your handler or pass in a view to render.",
				type    = "Renderer.ViewNotSetException"
			);
		}

		// Cleanup leading / in views, just in case
		arguments.view = reReplace( arguments.view, "^(\\|//)", "" );

		// Announce preViewRender interception
		if ( NOT arguments.prepostExempt ) {
			announce( "preViewRender", iData );
		}

		// Prepare caching arguments if doing implicit caching, and the view to render is the same as the implicitly cached.
		viewCacheEntry = event.getViewCacheableEntry();
		if ( event.isViewCacheable() AND ( arguments.view EQ viewCacheEntry.view ) ) {
			arguments.cache                  = true;
			arguments.cacheTimeout           = viewCacheEntry.timeout;
			arguments.cacheLastAccessTimeout = viewCacheEntry.lastAccessTimeout;
			arguments.cacheSuffix            = viewCacheEntry.cacheSuffix;
			arguments.cacheProvider          = viewCacheEntry.cacheProvider;
		}

		// Prepare caching key
		viewCacheKey = variables.templateCache.VIEW_CACHEKEY_PREFIX;
		// If we have a module, incorporate it
		if ( len( arguments.module ) ) {
			viewCacheKey &= arguments.module & ":";
		}
		// Incorporate view and suffix
		viewCacheKey &= arguments.view & arguments.cacheSuffix;

		// Are we caching?
		if ( arguments.cache && variables.viewCaching ) {
			// Which provider you want to use?
			if ( arguments.cacheProvider neq "template" ) {
				viewCacheProvider = getCache( arguments.cacheProvider );
			}
			// Try to get from cache
			iData.renderedView = viewCacheProvider.get( viewCacheKey );
			// Verify it existed
			if ( !isNull( local.iData.renderedView ) ) {
				// Post View Render Interception
				if ( NOT arguments.prepostExempt ) {
					announce( "postViewRender", local.iData );
				}
				// Return it
				return local.iData.renderedView;
			}
		}

		// No caching, just render
		// Discover and cache view/helper locations
		var viewLocations = discoverViewPaths(
			view           = arguments.view,
			module         = arguments.module,
			explicitModule = explicitModule
		);

		// Render collection views
		if ( !isNull( arguments.collection ) ) {
			// render collection in next context
			iData.renderedView = renderViewCollection(
				arguments.view,
				viewLocations.viewPath,
				viewLocations.viewHelperPath,
				arguments.args,
				arguments.collection,
				arguments.collectionAs,
				arguments.collectionStartRow,
				arguments.collectionMaxRows,
				arguments.collectionDelim,
				arguments.viewVariables
			);
		}
		// Render simple composite view
		else {
			local.iData.renderedView = renderViewComposite(
				arguments.view,
				viewLocations.viewPath,
				viewLocations.viewHelperPath,
				arguments.args,
				arguments.viewVariables
			);
		}

		// Post View Render Interception point
		if ( NOT arguments.prepostExempt ) {
			announce( "postViewRender", local.iData.append( { viewPath : viewLocations.viewPath } ) );
		}

		// Are we caching view
		if ( arguments.cache && variables.viewCaching ) {
			viewCacheProvider.set(
				viewCacheKey,
				local.iData.renderedView,
				arguments.cacheTimeout,
				arguments.cacheLastAccessTimeout
			);
		}

		// Return view content
		return local.iData.renderedView;
	}

	/**
	 * Render a view composed of collections, mostly used internally, use at your own risk.
	 */
	function renderViewCollection(
		view,
		viewPath,
		viewHelperPath,
		args,
		collection,
		collectionAs,
		numeric collectionStartRow = 1,
		numeric collectionMaxRows  = 0,
		collectionDelim            = "",
		viewVariables              = {}
	){
		var buffer = createObject( "java", "java.lang.StringBuilder" ).init();

		// Determine the collectionAs key
		if ( NOT len( arguments.collectionAs ) ) {
			arguments.collectionAs = listLast( arguments.view, "/" );
		}

		// Is this a query?
		if ( isQuery( arguments.collection ) ) {
			arguments.collection = arguments.collection.reduce( function( result, row ){
				arguments.result.append( arguments.row );
				return arguments.result;
			}, [] );
		}

		var records = arrayLen( arguments.collection );
		// is max rows passed?
		if ( arguments.collectionMaxRows NEQ 0 AND arguments.collectionMaxRows LTE records ) {
			records = arguments.collectionMaxRows;
		}
		// iterate and present
		for ( var x = arguments.collectionStartRow; x lte records; x++ ) {
			// prepend the delim
			if ( x NEQ arguments.collectionStartRow ) {
				buffer.append( arguments.collectionDelim );
			}

			// render item composite
			buffer.append(
				renderViewComposite(
					view          : arguments.view,
					viewPath      : arguments.viewPath,
					viewHelperPath: arguments.viewHelperPath,
					args          : arguments.args,
					viewVariables : arguments.viewVariables.append( {
						"_items"                   : records,
						"_counter"                 : x,
						"#arguments.collectionAs#" : arguments.collection[ x ]
					} )
				)
			);
		}
		return buffer.toString();
	}

	/**
	 * Render a view alongside its helpers, used mostly internally, use at your own risk.
	 *
	 * @view           The view name to render
	 * @viewPath       The path of the view to render
	 * @viewHelperPath The helpers for the view to load before it
	 * @args           The view arguments structure
	 * @variables      The struct of variables to incorporate into the view's `variables` scope
	 *
	 * @return The rendered view string
	 */
	private function renderViewComposite(
		view,
		viewPath,
		viewHelperPath,
		args,
		viewVariables = {}
	){
		var cbox_renderedView = "";
		var event             = getRequestContext();

		savecontent variable="cbox_renderedView" {
			cfmodule(
				template          = "RendererEncapsulator.cfm",
				view              = arguments.view,
				viewPath          = arguments.viewPath,
				viewHelperPath    = arguments.viewHelperPath,
				args              = arguments.args,
				rendererVariables = ( isNull( attributes.rendererVariables ) ? variables : attributes.rendererVariables ),
				event             = event,
				rc                = event.getCollection(),
				prc               = event.getPrivateCollection(),
				viewVariables     = arguments.viewVariables
			);
		}

		return cbox_renderedView;
	}

	/**
	 * Renders an external view anywhere that cfinclude works.
	 *
	 * @view                   The the view to render
	 * @args                   A struct of arguments to pass into the view for rendering, will be available as 'args' iview.
	 * @cache                  Cached the view output or not, defaults to false
	 * @cacheTimeout           The time in minutes to cache the view
	 * @cacheLastAccessTimeout The time in minutes the view will be removed from cache if idle or requested
	 * @cacheSuffix            The suffix to add into the cache entry for this view rendering
	 * @cacheProvider          The provider to cache this view in, defaults to 'template'
	 * @viewVariables          A struct of variables to incorporate into the view's variables scope.
	 */
	function externalView(
		required view,
		struct args            = getRequestContext().getCurrentViewArgs(),
		boolean cache          = false,
		cacheTimeout           = "",
		cacheLastAccessTimeout = "",
		cacheSuffix            = "",
		cacheProvider          = "template",
		viewVariables          = {}
	){
		var cbox_renderedView  = "";
		// Cache Entries
		var cbox_cacheKey      = "";
		var cbox_cacheEntry    = "";
		var cbox_cacheProvider = variables.templateCache;

		// Setup the cache key
		cbox_cacheKey = variables.templateCache.VIEW_CACHEKEY_PREFIX & "external-" & arguments.view & arguments.cacheSuffix;
		// Setup the cache provider
		if ( arguments.cacheProvider neq "template" ) {
			cbox_cacheProvider = getCache( arguments.cacheProvider );
		}
		// Try to get from cache
		cbox_renderedView = cbox_cacheProvider.get( cbox_cacheKey );
		if ( !isNull( local.cbox_renderedView ) ) {
			return cbox_renderedView;
		}

		// Not in cache, render it
		// Get view locations
		var viewLocations = discoverViewPaths(
			view           = arguments.view,
			module         = "",
			explicitModule = false
		);

		// Render External View
		cbox_renderedView = renderViewComposite(
			view           = view,
			viewPath       = viewLocations.viewPath,
			viewHelperPath = viewLocations.viewHelperPath,
			args           = args,
			renderer       = this,
			viewVariables  = arguments.viewVariables
		);

		// Are we caching it
		if ( arguments.cache && variables.viewCaching ) {
			cbox_cacheProvider.set(
				cbox_cacheKey,
				cbox_renderedView,
				arguments.cacheTimeout,
				arguments.cacheLastAccessTimeout
			);
		}
		return cbox_renderedView;
	}

	/************************************** LAYOUT METHODS *********************************************/

	/**
	 * Render a layout or a layout + view combo
	 *
	 * @layout        The layout to render out
	 * @module        The module to explicitly render this layout from
	 * @view          The view to render within this layout
	 * @args          An optional set of arguments that will be available to this layouts/view rendering ONLY
	 * @viewModule    The module to explicitly render the view from
	 * @prePostExempt If true, pre/post layout interceptors will not be fired. By default they do fire
	 * @viewVariables A struct of variables to incorporate into the view's variables scope.
	 */
	function layout(
		layout,
		module                = "",
		view                  = "",
		struct args           = getRequestContext().getCurrentViewArgs(),
		viewModule            = "",
		boolean prePostExempt = false,
		viewVariables         = {}
	){
		var event                  = getRequestContext();
		var cbox_locateUDF         = variables.locateLayout;
		var cbox_explicitModule    = false;
		var cbox_layoutLocationKey = "";
		var cbox_layoutLocation    = "";
		var iData                  = arguments;
		var explicitView           = getExplicitView();

		// Are we discovering implicit views: setting must be on and no view set.
		if ( shouldRenderImplicitView( arguments.view != "" ? arguments.view : event.getCurrentView() ) ) {
			discoverImplicitViews();
		}
		var cbox_implicitLayout = event.getCurrentLayout();
		var cbox_currentLayout  = cbox_implicitLayout;

		// Are we doing a nested view/layout explicit combo or already in its rendering algorithm?
		if (
			arguments.view.trim().len() AND
			(
				!explicitView.keyExists( "view" )
				OR
				explicitView.keyExists( "view" ) and arguments.view != explicitView.view
			)
		) {
			return controller
				.getRenderer()
				.setExplicitView(
					view         : arguments.view,
					module       : arguments.viewModule,
					args         : arguments.args,
					viewVariables: arguments.viewVariables
				)
				.layout( argumentCollection = arguments );
		}

		// If no passed layout, then get it from implicit values
		if ( isNull( arguments.layout ) ) {
			arguments.layout = cbox_implicitLayout;
		}

		// Are we in an explicit or current module call?
		if ( not len( arguments.module ) ) {
			arguments.module = event.getCurrentModule();
		} else {
			cbox_explicitModule = true;
		}
		// Choose location algorithm if in module mode
		if ( len( arguments.module ) ) {
			cbox_locateUDF = variables.locateModuleLayout;
		}

		// Announce
		if ( not arguments.prePostExempt ) {
			announce( "preLayoutRender", iData );
		}

		// Check explicit layout rendering
		if ( !isNull( arguments.layout ) ) {
			// Check if any length on incoming layout
			if ( len( arguments.layout ) ) {
				// Cleanup leading / in views, just in case
				arguments.layout   = reReplace( arguments.layout, "^(\\|/)", "" );
				cbox_currentLayout = arguments.layout;
			} else {
				cbox_currentLayout = "";
			}
		}

		// Discover the layout location + helpers
		var layoutLocations = discoverViewPaths(
			view          : cbox_currentLayout,
			module        : arguments.module,
			explicitModule: cbox_explicitModule,
			isLayout      : true
		);

		// If Layout is blank, then just delegate to the view
		// No layout rendering.
		if ( len( cbox_currentLayout ) eq 0 ) {
			iData.renderedLayout = this.view();
		} else {
			// Render the layout with it's helpers
			iData.renderedLayout = renderViewComposite(
				view          : cbox_currentLayout,
				viewPath      : layoutLocations.viewPath,
				viewHelperPath: layoutLocations.viewHelperPath,
				args          : args,
				viewVariables : arguments.viewVariables
			);
		}

		// Announce
		if ( not arguments.prePostExempt ) {
			announce( "postLayoutRender", iData.append( { viewPath : layoutLocations.viewPath } ) );
		}

		return iData.renderedLayout;
	}

	/**
	 * Locate a layout in the conventions system
	 *
	 * @layout The layout name
	 */
	function locateLayout( required layout ){
		// Remove extension: We need to test cfm vs bxm
		arguments.layout = reReplace( arguments.layout, "\.(cfm|bxm)$", "", "one" );

		// Default path is the conventions location
		var layoutPaths = [
			// Conventions location first
			"/#variables.appMapping#/#variables.layoutsConvention#/#arguments.layout#",
			// External location second
			"#variables.layoutsExternalLocation#/#arguments.layout#",
			// Application root last
			"/#variables.appMapping#/#arguments.layout#",
			// Absolute path last
			"#arguments.layout#"
		];

		// Try to locate the view
		for ( var thisLayoutPath in layoutPaths ) {
			thisLayoutPath = reReplace( thisLayoutPath, "//", "/", "all" );
			if ( fileExists( expandPath( thisLayoutPath & ".cfm" ) ) ) {
				return thisLayoutPath & ".cfm";
			}
			if ( fileExists( expandPath( thisLayoutPath & ".bxm" ) ) ) {
				return thisLayoutPath & ".bxm";
			}
		}

		// If all fails, return the path as is
		return arguments.layout;
	}

	/**
	 * Locate a layout in the module system
	 *
	 * @layout         The layout name
	 * @module         The name of the module we are searching for
	 * @explicitModule Are we locating explicitly or implicitly for a module layout
	 */
	function locateModuleLayout(
		required layout,
		module                 = "",
		boolean explicitModule = false
	){
		var event = getRequestContext();

		// Remove extension: We need to test cfm vs bxm
		arguments.layout = reReplace( arguments.layout, "\.(cfm|bxm)$", "", "one" );

		// Explicit Module layout lookup?
		if ( len( arguments.module ) and arguments.explicitModule ) {
			var explicitLayout = "#variables.modulesConfig[ arguments.module ].mapping#/#variables.modulesConfig[ arguments.module ].conventions.layoutsLocation#/#arguments.layout#";
			if ( fileExists( expandPath( explicitLayout & ".cfm" ) ) ) {
				return explicitLayout & ".cfm";
			}
			if ( fileExists( expandPath( explicitLayout & ".bxm" ) ) ) {
				return explicitLayout & ".bxm";
			}
			throw(
				message = "The layout [#arguments.layout#] was not found in the module path: [#explicitLayout#]",
				detail  = "Please verify the layout exists in the module.",
				type    = "Renderer.LayoutNotFoundException"
			)
		}

		// Declare Locations
		var moduleName             = event.getCurrentModule();
		var parentModuleLayoutPath = reReplace(
			"/#variables.appMapping#/#variables.layoutsConvention#/modules/#moduleName#/#arguments.layout#",
			"//",
			"/",
			"all"
		);
		var parentCommonLayoutPath = reReplace(
			"/#variables.appMapping#/#variables.layoutsConvention#/modules/#arguments.layout#",
			"//",
			"/",
			"all"
		);
		var moduleLayoutPath = "#variables.modulesConfig[ moduleName ].mapping#/#variables.modulesConfig[ moduleName ].conventions.layoutsLocation#/#arguments.layout#";

		// Check parent view order setup
		if ( variables.modulesConfig[ moduleName ].layoutParentLookup ) {
			// We check if layout is overridden in parent first.
			if ( fileExists( expandPath( parentModuleLayoutPath & ".cfm" ) ) ) {
				return parentModuleLayoutPath & ".cfm";
			}
			if ( fileExists( expandPath( parentModuleLayoutPath & ".bxm" ) ) ) {
				return parentModuleLayoutPath & ".bxm";
			}

			// Check if parent has a common layout override
			if ( fileExists( expandPath( parentCommonLayoutPath & ".cfm" ) ) ) {
				return parentCommonLayoutPath & ".cfm";
			}
			if ( fileExists( expandPath( parentCommonLayoutPath & ".bxm" ) ) ) {
				return parentCommonLayoutPath & ".bxm";
			}

			// Check module
			if ( fileExists( expandPath( moduleLayoutPath & ".cfm" ) ) ) {
				return moduleLayoutPath & ".cfm";
			}
			if ( fileExists( expandPath( moduleLayoutPath & ".bxm" ) ) ) {
				return moduleLayoutPath & ".bxm";
			}

			// Return normal layout lookup
			return locateLayout( arguments.layout );
		}

		// If we reach here then we are doing module lookup first then if not parent.
		if ( fileExists( expandPath( moduleLayoutPath & ".cfm" ) ) ) {
			return moduleLayoutPath & ".cfm";
		}
		if ( fileExists( expandPath( moduleLayoutPath & ".bxm" ) ) ) {
			return moduleLayoutPath & ".bxm";
		}

		// We check if layout is overridden in parent first.
		if ( fileExists( expandPath( parentModuleLayoutPath & ".cfm" ) ) ) {
			return parentModuleLayoutPath & ".cfm";
		}
		if ( fileExists( expandPath( parentModuleLayoutPath & ".bxm" ) ) ) {
			return parentModuleLayoutPath & ".bxm";
		}

		// Check if parent has a common layout override
		if ( fileExists( expandPath( parentCommonLayoutPath & ".cfm" ) ) ) {
			return parentCommonLayoutPath & ".cfm";
		}
		if ( fileExists( expandPath( parentCommonLayoutPath & ".bxm" ) ) ) {
			return parentCommonLayoutPath & ".bxm";
		}

		// Return normal layout lookup
		return locateLayout( arguments.layout );
	}

	/**
	 * Locate a view in the conventions or external paths
	 *
	 * @view The view to locate
	 */
	function locateView( required view ){
		// Remove extension: We need to test cfm vs bxm
		arguments.view = reReplace( arguments.view, "\.(cfm|bxm)$", "", "one" );

		// Default path is the conventions location, then the external location
		var viewPaths = [
			// Conventions location first
			"/#variables.appMapping#/#variables.viewsConvention#/#arguments.view#",
			// External location second
			"#variables.viewsExternalLocation#/#arguments.view#",
			// Application root
			"/#variables.appMapping#/#arguments.view#",
			// Absolute path last
			arguments.view
		];

		// Try to locate the view
		for ( var thisViewPath in viewPaths ) {
			thisViewPath = reReplace( thisViewPath, "//", "/", "all" );
			if ( fileExists( expandPath( thisViewPath & ".cfm" ) ) ) {
				return thisViewPath & ".cfm";
			}
			if ( fileExists( expandPath( thisViewPath & ".bxm" ) ) ) {
				return thisViewPath & ".bxm";
			}
		}

		// If all fails, return the path as is
		return arguments.view;
	}

	/**
	 * Locate a view in the module system
	 *
	 * @view           The view name
	 * @module         The name of the module we are searching for
	 * @explicitModule Are we locating explicitly or implicitly for a module layout
	 */
	function locateModuleView(
		required view,
		module                 = "",
		boolean explicitModule = false
	){
		// Remove extension: We need to test cfm vs bxm
		arguments.view = reReplace( arguments.view, "\.(cfm|bxm)$", "", "one" );

		// Explicit Module view lookup?
		if ( len( arguments.module ) and arguments.explicitModule ) {
			var explicitView = "#variables.modulesConfig[ arguments.module ].mapping#/#variables.modulesConfig[ arguments.module ].conventions.viewsLocation#/#arguments.view#";
			if ( fileExists( expandPath( explicitView & ".cfm" ) ) ) {
				return explicitView & ".cfm";
			}
			if ( fileExists( expandPath( explicitView & ".bxm" ) ) ) {
				return explicitView & ".bxm";
			}
			throw(
				message = "The view [#arguments.view#] was not found in the module path: [#explicitView#]",
				detail  = "Please verify the view exists in the module.",
				type    = "Renderer.ViewNotFoundException"
			)
		}

		// Declare Locations
		var moduleName           = arguments.module;
		var parentModuleViewPath = reReplace(
			"/#variables.appMapping#/#variables.viewsConvention#/modules/#moduleName#/#arguments.view#",
			"//",
			"/",
			"all"
		);
		var parentCommonViewPath = reReplace(
			"/#variables.appMapping#/#variables.viewsConvention#/modules/#arguments.view#",
			"//",
			"/",
			"all"
		);
		var moduleViewPath = "#variables.modulesConfig[ moduleName ].mapping#/#variables.modulesConfig[ moduleName ].conventions.viewsLocation#/#arguments.view#";

		// Check parent view order setup
		if ( variables.modulesConfig[ moduleName ].viewParentLookup ) {
			// We check if view is overridden in parent first.
			if ( fileExists( expandPath( parentModuleViewPath & ".cfm" ) ) ) {
				return parentModuleViewPath & ".cfm";
			}
			if ( fileExists( expandPath( parentModuleViewPath & ".bxm" ) ) ) {
				return parentModuleViewPath & ".bxm";
			}

			// Check if parent has a common view override
			if ( fileExists( expandPath( parentCommonViewPath & ".cfm" ) ) ) {
				return parentCommonViewPath & ".cfm";
			}
			if ( fileExists( expandPath( parentCommonViewPath & ".bxm" ) ) ) {
				return parentCommonViewPath & ".bxm";
			}

			// Check module for view
			if ( fileExists( expandPath( moduleViewPath & ".cfm" ) ) ) {
				return moduleViewPath & ".cfm";
			}
			if ( fileExists( expandPath( moduleViewPath & ".bxm" ) ) ) {
				return moduleViewPath & ".bxm";
			}

			// Return normal view lookup
			return locateView( arguments.view );
		}

		// If we reach here then we are doing module lookup first then if not the parent.
		if ( fileExists( expandPath( moduleViewPath & ".cfm" ) ) ) {
			return moduleViewPath & ".cfm";
		}
		if ( fileExists( expandPath( moduleViewPath & ".bxm" ) ) ) {
			return moduleViewPath & ".bxm";
		}

		// We check if view is overridden in parent first.
		if ( fileExists( expandPath( parentModuleViewPath & ".cfm" ) ) ) {
			return parentModuleViewPath & ".cfm";
		}
		if ( fileExists( expandPath( parentModuleViewPath & ".bxm" ) ) ) {
			return parentModuleViewPath & ".bxm";
		}

		// Check if parent has a common view override
		if ( fileExists( expandPath( parentCommonViewPath & ".cfm" ) ) ) {
			return parentCommonViewPath & ".cfm";
		}
		if ( fileExists( expandPath( parentCommonViewPath & ".bxm" ) ) ) {
			return parentCommonViewPath & ".bxm";
		}

		// Return normal view lookup
		return locateView( arguments.view );
	}

	/**
	 * Discover view+helper path locations.  The returned helper and view locations will have the appropriate extension.
	 *
	 * @view           The view to discover
	 * @module         The module address
	 * @explicitModule Is the module explicit or discoverable.
	 * @isLayout       Are we discovering a layout or a view
	 *
	 * @return struct  = { viewPath:string, viewHelperPath:string }
	 */
	function discoverViewPaths(
		required view,
		module,
		boolean explicitModule = false,
		boolean isLayout       = false
	){
		var locationKey = "#arguments.view#-#arguments.module#-#arguments.explicitModule#-#arguments.isLayout#";
		var results     = { "viewPath" : "", "viewHelperPath" : [] };
		// If you are in layout mode, then use the layout reference map, else use the view reference map
		var cacheMap    = arguments.isLayout ? variables.layoutsRefMap : variables.viewsRefMap;
		// The UDF is determined if you are in layout or view mode and if you are in module mode
		var locationUDF = len( arguments.module ) ? variables[
			arguments.isLayout ? "locateModuleLayout" : "locateModuleView"
		] : variables[ arguments.isLayout ? "locateLayout" : "locateView" ];

		// Check cached paths first
		if ( structKeyExists( cacheMap, locationKey ) AND variables.isDiscoveryCaching ) {
			return cacheMap[ locationKey ];
		}

		// If already a full path, then just return it
		// Else go locate it according to the locationUDF
		if ( fileExists( arguments.view ) ) {
			results.viewPath = arguments.view;
		} else {
			results.viewPath = locationUDF(
				arguments.view,
				arguments.module,
				arguments.explicitModule
			);
		}

		// Check for directory helper convention first
		var dPath = getDirectoryFromPath( results.viewPath );
		if ( fileExists( expandPath( dPath & listLast( dPath, "\/" ) & "Helper.cfm" ) ) ) {
			results.viewHelperPath.append( dPath & listLast( dPath, "\/" ) & "Helper.cfm" );
		}
		if ( fileExists( expandPath( dPath & listLast( dPath, "\/" ) & "Helper.bxm" ) ) ) {
			results.viewHelperPath.append( dPath & listLast( dPath, "\/" ) & "Helper.bxm" );
		}

		// Check for view helper convention second
		var vPath = results.viewPath.listFirst( "." );
		if ( fileExists( expandPath( vPath & "Helper.cfm" ) ) ) {
			results.viewHelperPath.append( vPath & "Helper.cfm" );
		}
		if ( fileExists( expandPath( vPath & "Helper.bxm" ) ) ) {
			results.viewHelperPath.append( vPath & "Helper.bxm" );
		}

		// Create the cache entry
		if ( NOT structKeyExists( cacheMap, locationKey ) ) {
			cacheMap[ locationKey ] = results;
		}

		return results;
	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Verifies if we should render the implicit view or not
	 */
	private boolean function shouldRenderImplicitView( required string view ){
		return variables.controller.getSetting( name = "ImplicitViews" ) && arguments.view.trim() == "";
	}

	/**
	 * Set's the view according to the executed event.
	 *
	 * @return Renderer
	 */
	private function discoverImplicitViews(){
		var event = getRequestContext();

		// Get and cleanup the current event to discover the view
		var cEvent = reReplaceNoCase( event.getCurrentEvent(), "^([^:.]*):", "" );

		// Implicit views
		if ( variables.controller.getSetting( name = "caseSensitiveImplicitViews", defaultValue = true ) ) {
			event.setView( replace( cEvent, ".", "/", "all" ) );
		} else {
			event.setView( lCase( replace( cEvent, ".", "/", "all" ) ) );
		}

		return this;
	}

	/**
	 * Incorporate a rendering region into the arguments struct
	 *
	 * @name  The name of the rendering region
	 * @event The request context
	 * @args  The arguments struct to incorporate the rendering region into
	 *
	 * @return The arguments processed
	 *
	 * @throws InvalidRenderingRegion - If the region name does not exist
	 */
	private function incorporateRenderingRegion( required name, required event, any args ){
		var regions = event.getRenderingRegions();
		// Verify Region
		if ( !structKeyExists( regions, arguments.name ) ) {
			throw(
				message = "Invalid rendering region: #arguments.name#",
				detail  = "Valid regions are: #structKeyList( regions )#",
				type    = "InvalidRenderingRegion"
			);
		}
		// Incorporate region data
		structAppend( arguments.args, regions[ arguments.name ] );
		// Clean yourself like a ninja
		structDelete( arguments.args, "name" );
		return arguments.args;
	}

}
