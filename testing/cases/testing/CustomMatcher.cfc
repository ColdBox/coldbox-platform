/**
* A custom matcher
*/
component{

	function toBeAwesome(){
		if( this.isNot )
			return false;
		else
			return true;
	}

	function toBeLuisMajano(){
		var results = ( this.actual == "Luis Majano" ? true : false ); 		

		if( this.isNot )
			return !results;
		else
			return results;
			
	}

}