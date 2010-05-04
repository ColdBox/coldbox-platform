/**
 * @hint I will validate an social security number using ColdFusion's built in isValid method.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		
		if( len(arguments.prop.value) && !isValid("ssn",arguments.prop.value)){
			valid = false;
		}
		
		return valid;
	}

}