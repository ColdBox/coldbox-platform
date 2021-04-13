/**
 * This class manages Scheduler cfc's that represent collection of scheduled tasks.
 *
 * It can also be linked to a ColdBox instance to enhance the schedulers and tasks so they can work within a ColdBox context
 */
component accessors="true" singleton {

	/**
	 * --------------------------------------------------------------------------
	 * Properties
	 * --------------------------------------------------------------------------
	 */

	/**
	 * A collection of schedulers this manager manages
	 */
	property name="schedulers" type="struct";

	/**
	 * The async manager link
	 */
	property name="asyncManager";

	/**
	 * Constructor
	 *
	 * @asyncManager The async manager we are linked to
	 */
	function init( required asyncManager ){
		// The async manager
		variables.asyncManager = arguments.asyncManager;
		// The collection of tasks we will run
		variables.schedulers   = structNew( "ordered" );

		return this;
	}

	/**
	 * Register a new scheduler in this manager by name and cfc instantiation path
	 *
	 * @name The name of the scheduler
	 * @path The instantiation path to the cfc that represents the scheduler or empty to use the default core scheduler class
	 *
	 * @return The created and registered scheduler Object
	 */
	Scheduler function registerScheduler( required name, path = "" ){
		// Build it
		var oScheduler = (
			variables.asyncManager.hasColdBox() ? buildColdBoxScheduler( argumentCollection = arguments ) : buildSimpleScheduler(
				argumentCollection = arguments
			)
		);
		// Register it
		variables.schedulers[ arguments.name ] = oScheduler;
		// Return it
		return oScheduler;
	}

	private function buildSimpleScheduler( required name, required path ){
	}

	private function buildColdBoxScheduler( required name, required path ){
	}

	/**
	 * Verify if a scheduler has been registered
	 *
	 * @name The name of the scheduler
	 */
	boolean function hasScheduler( required name ){
		return variables.schedulers.keyExists( arguments.name );
	}

	/**
	 * Remove a scheduler from this manager
	 *
	 * @name The name of the scheduler
	 *
	 * @return True if removed, else if not found or not removed
	 */
	boolean function removeScheduler( required name ){
		if ( hasScheduler( arguments.name ) ) {
			variables.schedulers[ arguments.name ].shutdown();
			structDelete( variables.schedulers, arguments.name );
			return true;
		}

		return false;
	}

}
