/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* The TestBox main base runner which has all the common methods needed for runner implementations.
*/ 
component{
		
	/************************************** UTILITY METHODS *********************************************/

	/**
	* Checks if the incoming labels are good for running
	* @incomingLabels.hint The incoming labels to test against this runner's labels.
	* @testResults.hint The testing results object
	*/
	boolean function canRunLabel( 
		required incomingLabels,
		required testResults
	){

		var labels = arguments.testResults.getLabels();

		// do we have labels applied?
		if( arrayLen( labels ) ){
			for( var thisLabel in labels ){
				// verify that a label exists, if it does, break, it matches the criteria, if no matches, then skip it.
				if( arrayFindNoCase( incomingLabels, thisLabel ) ){
					// match, so we can run it.
					return true;
				}
			}
			
			// if we get here, we have labels, but none matched.
			return false;
		}
		// we can run it.
		return true;
	}

	/**
	* Validate the incoming method name is a valid TestBox test method name
	* @methodName.hint The method name to validate
	*/
	boolean function isValidTestMethod( required methodName ) {
		// All test methods must start with the term, "test". 
		return( !! reFindNoCase( "^test", methodName ) );
	}
	
}