/**
 * A disabled nested module. Registration returns false, so the parent must not
 * list it as a child module nor attempt to activate it.
 */
component {

	// Module Properties
	this.title    = "disabledChild";
	this.version  = "1.0.0";
	this.disabled = true;

	function configure(){
	}

}
