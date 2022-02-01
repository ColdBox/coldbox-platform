component accessors="true"{

	// Level 1 child injector
	property name="childValue" inject="wirebox:child:myChild";
	// Level 2 child injector
	property name="testValue" inject="wirebox:child:myChild:childValue";

	function init(){
		return this;
	}

}