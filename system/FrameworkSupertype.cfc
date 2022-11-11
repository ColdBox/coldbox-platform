/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Base class for all things Box
 * The Majority of contributions comes from its delegations
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component
	serializable="false"
	accessors   ="true"
	delegates   ="Async@coreDelegates,
				Interceptor@cbDelegates,
				Settings@cbDelegates,
				Flow@coreDelegates,
				Env@coreDelegates,
				JsonUtil@coreDelegates,
				Population@cbDelegates,
				Rendering@cbDelegates"
{

	/****************************************************************
	 * DI *
	 ****************************************************************/

	property
		name    ="cachebox"  
		inject  ="cachebox"
		delegate="getCache";
	property
		name    ="controller"
		inject  ="coldbox" 
		delegate="locateFilePath,locateDirectoryPath,persistVariables,relocate,runEvent,runRoute";
	property name="flash"  inject="coldbox:flash";
	property name="logBox" inject="logbox";
	property name="log"    inject="logbox:logger:{this}";
	property
		name    ="wirebox"
		inject  ="wirebox"
		delegate="getInstance";

	/**
	 * Constructor
	 */
	function init(){
		return this;
	}

	/****************************************************************
	 * Deprecated/Removed Methods *
	 ****************************************************************/

	function renderview() cbMethod{
		throw(
			type    = "DeprecatedMethod",
			message = "This method has been deprecated, please use 'view()` instead"
		);
	}
	function renderLayout() cbMethod{
		throw(
			type    = "DeprecatedMethod",
			message = "This method has been deprecated, please use 'layout()` instead"
		);
	}
	function renderExternalView() cbMethod{
		throw(
			type    = "DeprecatedMethod",
			message = "This method has been deprecated, please use 'externalView()` instead"
		);
	}
	function announceInterception() cbMethod{
		throw(
			type    = "DeprecatedMethod",
			message = "This method has been deprecated, please use 'announce()` instead"
		);
	}

	/**
	 * Retrieve the request context object
	 *
	 * @return coldbox.system.web.context.RequestContext
	 */
	function getRequestContext() cbMethod{
		return variables.controller.getRequestService().getContext();
	}

	/**
	 * Get the RC or PRC collection reference
	 *
	 * @private The boolean bit that says give me the RC by default or true for the private collection (PRC)
	 *
	 * @return The requeted collection
	 */
	struct function getRequestCollection( boolean private = false ) cbMethod{
		return getRequestContext().getCollection( private = arguments.private );
	}

	/**
	 * Get an interceptor reference
	 *
	 * @interceptorName The name of the interceptor to retrieve
	 *
	 * @return Interceptor
	 */
	function getInterceptor( required interceptorName ) cbMethod{
		return variables.controller.getInterceptorService().getInterceptor( argumentCollection = arguments );
	}

	/**
	 * Redirect back to the previous URL via the referrer header, else use the fallback
	 *
	 * @fallback The fallback event or uri if the referrer is empty, defaults to `/`
	 */
	function back( fallback = "/" ) cbMethod{
		var event = getRequestContext();
		relocate( URL = event.getHTTPHeader( "referer", event.buildLink( arguments.fallback ) ) );
	}


	/****************************************** UTILITY METHODS ******************************************/

	/**
	 * Add a js/css asset(s) to the html head section. You can also pass in a list of assets. This method
	 * keeps track of the loaded assets so they are only loaded once
	 *
	 * @asset The asset(s) to load, only js or css files. This can also be a comma delimited list.
	 */
	string function addAsset( required asset ) cbMethod{
		return getInstance( "@HTMLHelper" ).addAsset( argumentCollection = arguments );
	}

	/**
	 * Injects a UDF Library (*.cfc or *.cfm) into the target object.  It does not however, put the mixins on any of the cfc scopes. Therefore they can only be called internally
	 *
	 * @udflibrary The UDF library to inject
	 *
	 * @return FrameworkSuperType
	 *
	 * @throws UDFLibraryNotFoundException - When the requested library cannot be found
	 */
	any function includeUDF( required udflibrary ) cbMethod{
		// Init the mixin location and caches reference
		var defaultCache     = getCache( "default" );
		var mixinLocationKey = hash( variables.controller.getAppHash() & arguments.udfLibrary );

		var targetLocation = defaultCache.getOrSet(
			// Key
			"includeUDFLocation-#mixinLocationKey#",
			// Producer
			function(){
				var appMapping      = variables.controller.getSetting( "AppMapping" );
				var UDFFullPath     = expandPath( udflibrary );
				var UDFRelativePath = expandPath( "/" & appMapping & "/" & udflibrary );

				// Relative Checks First
				if ( fileExists( UDFRelativePath ) ) {
					targetLocation = "/" & appMapping & "/" & udflibrary;
				}
				// checks if no .cfc or .cfm where sent
				else if ( fileExists( UDFRelativePath & ".cfc" ) ) {
					targetLocation = "/" & appMapping & "/" & udflibrary & ".cfc";
				} else if ( fileExists( UDFRelativePath & ".cfm" ) ) {
					targetLocation = "/" & appMapping & "/" & udflibrary & ".cfm";
				} else if ( fileExists( UDFFullPath ) ) {
					targetLocation = "#udflibrary#";
				} else if ( fileExists( UDFFullPath & ".cfc" ) ) {
					targetLocation = "#udflibrary#.cfc";
				} else if ( fileExists( UDFFullPath & ".cfm" ) ) {
					targetLocation = "#udflibrary#.cfm";
				} else {
					throw(
						message = "Error loading UDF library: #udflibrary#",
						detail  = "The UDF library was not found.  Please make sure you verify the file location.",
						type    = "UDFLibraryNotFoundException"
					);
				}
				return targetLocation;
			},
			// Timeout: 1 week
			10080
		);

		// Include the UDF
		include targetLocation;

		return this;
	}

	/**
	 * Load the global application helper libraries defined in the applicationHelper Setting of your application.
	 * This is called by the framework ONLY! Use at your own risk
	 *
	 * @force Used when called by a known virtual inheritance family tree.
	 *
	 * @return FrameworkSuperType
	 */
	any function loadApplicationHelpers( boolean force = false ) cbMethod{
		if ( structKeyExists( this, "$super" ) && !arguments.force ) {
			return this;
		}

		// Inject global helpers
		var helpers = variables.controller.getSetting( "applicationHelper" );

		for ( var thisHelper in helpers ) {
			includeUDF( thisHelper );
		}

		return this;
	}

}
