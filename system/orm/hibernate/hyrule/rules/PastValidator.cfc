/**
 * @hint I will validate that a date is in past.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;

		if( isDate(arguments.prop.value) ){

			if( isDate(arguments.prop.past) ) {
				if(dateCompare(arguments.prop.value,arguments.prop.past) > 0){
					return false;
				}
			} else {
				if(dateCompare(arguments.prop.value,now()) != -1){
					return false;
				}
			}
		} else {
			valid = false;
		}

		return valid;
	}

	
}