/**
 * @hint validates that the value is all upercase
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;

		if(isSimpleValue(arguments.prop.value)){
			var upperCaseString = uCase(arguments.prop.value);
			if(compare(arguments.prop.value,upperCaseString) != 0){
				valid = false;
			}
		} else {
			valid = false;
		}

		return valid;
	}
}
