/**
 * I will validate that a variable is a valid array using ColdFusion's built in isValid method.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		if( !isValid('Array',arguments.prop.value)){
			valid = false;
		}
		return valid;
	}

}