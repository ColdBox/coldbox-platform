/**
 * I will validate a value is a binary object using ColdFusion's built in isValid method.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		if(!isValid("Binary",arguments.prop.value)){
			valid = false;
		}
		return valid;
	}

}