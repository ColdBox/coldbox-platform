/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Base class for all event handlers
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component
	extends     ="coldbox.system.FrameworkSupertype"
	serializable="false"
	accessors   ="true"
{

	// Controller Reference
	property name="controller";
	// LogBox reference
	property name="logBox";
	// Pre-Configured Log Object
	property name="log";
	// Flash Reference
	property name="flash";
	// CacheBox Reference
	property name="cachebox";
	// WireBox Reference
	property name="wirebox";

	// event cache suffix
	this.event_cache_suffix   = "";
	// pre handler only except lists
	this.prehandler_only      = "";
	this.prehandler_except    = "";
	// post handler only except lists
	this.posthandler_only     = "";
	this.posthandler_except   = "";
	// around handler only except lists
	this.aroundhandler_only   = "";
	this.aroundHandler_except = "";
	// HTTP allowed methods
	this.allowedMethods       = structNew();

	/**
	 * Constructor
	 *
	 * @controller The ColdBox controller
	 *
	 * @return EventHandler
	 */
	function init( required controller ) cbMethod{
		// Register Controller
		variables.controller = arguments.controller;
		// Register LogBox
		variables.logBox     = arguments.controller.getLogBox();
		// Register Log object
		variables.log        = variables.logBox.getLogger( this );
		// Register Flash RAM
		variables.flash      = arguments.controller.getRequestService().getFlashScope();
		// Register CacheBox
		variables.cacheBox   = arguments.controller.getCacheBox();
		// Register WireBox
		variables.wireBox    = arguments.controller.getWireBox();
		// Load global UDF Libraries into target
		loadApplicationHelpers();

		return this;
	}

	/**
	 * Verifies if an action exists in the current event handler, public or private
	 *
	 * @action The action to verify that it exists and it is a function
	 */
	boolean function _actionExists( required action ) cbMethod{
		return (
			( structKeyExists( this, arguments.action ) AND isCustomFunction( this[ arguments.action ] ) )
			OR
			(
				structKeyExists( variables, arguments.action ) AND isCustomFunction(
					variables[ arguments.action ]
				)
			)
		);
	}

	/**
	 * Return action metadata in the current event handler, public or private
	 *
	 * @action The action to get the metadata from
	 */
	struct function _actionMetadata( required action ) cbMethod{
		return getMetadata( variables[ arguments.action ] );
	}

	/**
	 * _privateInvoker for private events
	 *
	 * @method        The method to execute
	 * @argCollection The arguments to execute the method with.
	 */
	any function _privateInvoker( required method, required argCollection ) cbMethod{
		var _targetAction  = variables[ arguments.method ];
		var _targetResults = _targetAction( argumentCollection = arguments.argCollection );
		if ( !isNull( local._targetResults ) ) {
			return _targetResults;
		}
	}

}
