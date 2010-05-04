/**
 * I will validate an email address using ColdFusion's built in isValid method.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		if( len(arguments.prop.value) && !isValid("Email",arguments.prop.value)){
			valid = false;
		}
		return valid;
	}

}