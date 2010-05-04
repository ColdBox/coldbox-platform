/**
 * @hint I will validate that a variable is a valid query using ColdFusion's built in isValid method.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		
		if(!isValid("query",arguments.prop.value)){
			valid = false;
		}
		
		return valid;
	}
}