/**
 * A plain object with no base class or interface - used to prove that route-scoped middleware
 * (Router.middleware()) works by duck-typed method name, the same convention ColdBox interceptors
 * already use, not by inheritance.
 */
component accessors="true" {

	property name="wasCalled";
	property name="shortCircuit";

	function init(){
		variables.wasCalled    = false;
		variables.shortCircuit = false;
		return this;
	}

	function preProcess( event, rc, prc ){
		variables.wasCalled = true;
		if ( variables.shortCircuit ) {
			return true;
		}
	}

	function postProcess( event, rc, prc ){
		variables.wasCalled = true;
	}

}
