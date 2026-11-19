/**
 * A disabled nested module that its parent declares as a dependency.
 * Registration returns false, so activating the parent must fail.
 */
component {

	// Module Properties
	this.title    = "disabledDependency";
	this.version  = "1.0.0";
	this.disabled = true;

	function configure(){
	}

}
