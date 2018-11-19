/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* The system web renderer
* @author Luis Majano <lmajano@ortussolutions.com>
*/
component singleton=true serializable=false extends="coldbox.system.FrameworkSupertype"{

	/************************************** CONSTRUCTOR *********************************************/

	/**
	 * @controller           The ColdBox main controller
	 * @controller.inject    coldbox
	 * @htmlHelper.inject    @htmlHelper
	 * @templateCache.inject cachebox:template
	 */
	function init( required controller, required htmlHelper, required templateCache ){
		variables.controller = arguments.controller;
		variables.logBox     = arguments.controller.getLogBox();
		variables.log        = variables.logBox.getLogger( this );
		variables.flash      = arguments.controller.getRequestService().getFlashScope();
		variables.cacheBox   = arguments.controller.getCacheBox();
		variables.wireBox    = arguments.controller.getWireBox();

		// Set Conventions, Settings and Properties
		variables.layoutsConvention       = variables.controller.getSetting( "layoutsConvention", true );
		variables.viewsConvention         = variables.controller.getSetting( "viewsConvention", true );
		variables.appMapping              = variables.controller.getSetting( "AppMapping" );
		variables.viewsExternalLocation   = variables.controller.getSetting( "ViewsExternalLocation" );
		variables.layoutsExternalLocation = variables.controller.getSetting( "LayoutsExternalLocation" );
		variables.modulesConfig           = variables.controller.getSetting( "modules" );
		variables.viewsHelper             = variables.controller.getSetting( "viewsHelper" );
		variables.viewCaching             = variables.controller.getSetting( "viewCaching" );
		variables.isDiscoveryCaching      = variables.viewCaching;
		variables.isViewsHelperIncluded   = false;
		variables.renderedHelpers         = {};
		variables.lockName                = "rendering.#variables.controller.getAppHash()#";
		variables.htmlHelper              = arguments.htmlHelper;
		variables.templateCache           = arguments.templateCache;

		// Verify View Helper Template extension + location
		if( len( variables.viewsHelper ) ){
			// extension detection
			variables.viewsHelper = ( listLast( variables.viewsHelper, "." ) eq "cfm" ? variables.viewsHelper : variables.viewsHelper & ".cfm" );
			// Append mapping to it.
			variables.viewsHelper = "/#variables.appMapping#/#variables.viewsHelper#";
		}

		if ( isLucee() ) {
			variables.cloneableRenderer = newRenderer();
			cfinclude( template="../includes/LuceeDuplicate.cfm" );
		}

		return this;
	}

	function getRenderer() {
		if ( isLucee()  ) {
			return cloneRenderer();
		} else {
			return newRenderer( true );
		}
	}

	private boolean function isLucee() {
		return StructKeyExists( server, "lucee" );
	}

	private any function newRenderer( boolean completeInit=false ) {
		var renderer = createObject( "Renderer" ).fasterInit(
			controller              = variables.controller,
			logBox                  = variables.logBox,
			log                     = variables.log,
			flash                   = variables.flash,
			cacheBox                = variables.cacheBox,
			wireBox                 = variables.wireBox,
			layoutsConvention       = variables.layoutsConvention,
			viewsConvention         = variables.viewsConvention,
			appMapping              = variables.appMapping,
			viewsExternalLocation   = variables.viewsExternalLocation,
			layoutsExternalLocation = variables.layoutsExternalLocation,
			modulesConfig           = variables.modulesConfig,
			viewsHelper             = variables.viewsHelper,
			viewCaching             = variables.viewCaching,
			htmlHelper              = variables.htmlHelper,
			templateCache           = variables.templateCache,
			lockName                = variables.lockName
		);

		if ( arguments.completeInit ) {
			var event = getRequestContext();

			renderer.setEvent( event );
			renderer.setRc( event.getCollection() );
			renderer.setPrc( event.getCollection( private=true ) );

			renderer.announceAfterRendererInit();
		}

		return renderer;
	}

	private any function cloneRenderer() {
		var cloned = LuceeDuplicate( objectToDuplicate=variables.cloneableRenderer, full=false );
		var event  = getRequestContext();

		cloned.setEvent( event );
		cloned.setRc( event.getCollection() );
		cloned.setPrc( event.getCollection( private=true ) );

		cloned.announceAfterRendererInit();

		return cloned;
	}

}
