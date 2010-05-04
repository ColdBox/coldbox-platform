/**
 * I will validate that a variable is a valid GUID using ColdFusion's built in isValid method.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		if( len(arguments.prop.value) && !isValid("GUID",arguments.prop.value)){
			valid = false;
		}
		return valid;
	}

}