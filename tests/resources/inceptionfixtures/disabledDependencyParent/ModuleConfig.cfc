/**
 * Fixture: a parent module that lists its own disabled nested child in this.dependencies.
 * Used to prove a declared dependency that is disabled still stops activation.
 */
component {

	// Module Properties
	this.title        = "disabledDependencyParent";
	this.version      = "1.0.0";
	this.dependencies = [ "disabledDependency" ];

	function configure(){
	}

}
