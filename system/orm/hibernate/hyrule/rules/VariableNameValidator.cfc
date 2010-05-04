/**
 * @hint I will validate that a variable is a valid UUID using ColdFusion's built in isValid method.
 */
component implements="IValidator" {
	
	public boolean function isValid(Struct prop){
		var valid = true;
		
		if( len(arguments.prop.value) && !isValid("variablename",arguments.prop.value)){
			valid = false;
		}
		
		return valid;
	}

}