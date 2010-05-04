/**
 * @hint I will validate that a variable is a valid struct using ColdFusion's built in isValid method.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		
		if(!isValid("Struct",arguments.prop.value)){
			valid = false;
		}
		
		return valid;
	}

}