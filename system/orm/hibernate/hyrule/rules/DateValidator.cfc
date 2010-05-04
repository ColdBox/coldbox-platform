/**
 * I will validate that a variable is a valid date using ColdFusion's built in isValid method.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		if(!isValid("Date",arguments.prop.value)){
			valid = false;
		}
		return valid;
	}

}