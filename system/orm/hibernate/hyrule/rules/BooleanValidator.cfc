/**
 * I will validate that a variable is a valid boolean using ColdFusion's built in isValid method.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		if(!isValid("Boolean",arguments.prop.value)){
			valid = false;
		}
		return valid;
	}

}