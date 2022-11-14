/**
 * This delegate is useful to interact with the AsyncManager and most used functionality
 */
component singleton {

	property
		name    ="asyncManager"
		inject  ="wirebox:asyncManager"
		delegate="newFuture,arrayRange";

	/**
	 * Return the ColdBox Async Manager instance so you can do some async or parallel programming
	 *
	 * @return coldbox.system.async.AsyncManager
	 */
	function async(){
		return variables.asyncManager;
	}

}
