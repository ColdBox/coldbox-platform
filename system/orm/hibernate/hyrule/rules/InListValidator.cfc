/**
 * @hint I will validate that the data value is in the list that is provided.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;

		if(!listContainsNoCase(arguments.prop.inlist,arguments.prop.value)){
			valid = false;
		}

		return valid;
	}

}