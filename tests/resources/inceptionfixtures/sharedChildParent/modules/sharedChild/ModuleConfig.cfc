/**
 * A nested module whose name is already known before its parent registers.
 * The parent must still track it, so the parent's activation cascade activates it.
 */
component {

	// Module Properties
	this.title   = "sharedChild";
	this.version = "1.0.0";

	function configure(){
	}

}
