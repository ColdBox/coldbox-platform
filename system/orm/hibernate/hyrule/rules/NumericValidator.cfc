/**
 * @hint I will validate a value is a numeric value using ColdFusion's built in isValid method.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		
		if(!isValid('Numeric',arguments.prop.value)){
			valid = false;
		}
		
		return valid;
	}

}