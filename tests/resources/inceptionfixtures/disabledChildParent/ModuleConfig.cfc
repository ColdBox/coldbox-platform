/**
 * Fixture: a parent module with one nested (inception) child module that is disabled.
 * Used to prove the activation cascade still works when a child never registers.
 */
component {

	// Module Properties
	this.title   = "disabledChildParent";
	this.version = "1.0.0";

	function configure(){
	}

}
