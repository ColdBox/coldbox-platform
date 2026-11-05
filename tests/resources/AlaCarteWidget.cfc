/**
 * A target for a-la-carte autowire specs, it has a single property injection
 */
component {

	property name="dep" inject="Dep";

	/**
	 * The injected dependency or null if nothing was injected
	 */
	function getDep(){
		return variables.dep ?: javacast( "null", "" );
	}

}
