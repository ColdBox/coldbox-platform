/**
 * I am a lazy object
 */
component accessors="true" singleton{

	// Observed properties
	property name="data" observed;
	property name="data2" observed="myObserver";

	property name="log";

	/**
	 * Constructor
	 */
	function init(){
		variables.log = [];
		return this;
	}

	function myObserver( newValue, oldValue, property ){
		variables.log.append( "my observer called: #arguments.toSTring()#" );
	}

	function dataObserver( newValue, oldValue, property ){
		variables.log.append( "data observer called: #arguments.toSTring()#" );
	}

}
