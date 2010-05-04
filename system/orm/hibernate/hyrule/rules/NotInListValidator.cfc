/**
 * @hint I will validate that the data value is not in the list that is provided.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		
		if(listContainsNoCase(arguments.prop.notInList,arguments.prop.value)){
			valid = false;
		}

		return valid;
	}

}