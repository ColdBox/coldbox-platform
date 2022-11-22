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
	threadSafe
{

	/****************************************************************
	 * Handler Properties *
	 ****************************************************************/

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
	this.allowedMethods       = {};

	/**
	 * Constructor
	 */
	function init() cbMethod{
		super.init();
		return this;
	}

	/**
	 * Fires when all DI has been completed. We use a different name so we don't collide with onDIComplete()
	 *
	 * @onDIComplete
	 */
	function onHandlerDIComplete() cbMethod{
		// Load global UDF Libraries into target
		loadApplicationHelpers();
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
