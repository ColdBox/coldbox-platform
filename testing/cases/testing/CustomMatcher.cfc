/**
* A custom matcher
*/
component{

	function toBeAwesome( expectation ){
		if( expectation.isNot )
			return false;
		else
			return true;
	}

	function toBeLuisMajano( expectation ){
		var results = ( expectation.actual == "Luis Majano" ? true : false ); 		

		if( expectation.isNot )
			return !results;
		else
			return results;
			
	}

}