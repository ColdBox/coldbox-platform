/**
 * I will validate that a date is in the future when being compared to a start date.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		
		if( isDate(arguments.prop.value) ){
			if( isDate(arguments.prop.future) ) {
				if(dateCompare(arguments.prop.value,arguments.prop.future) != 1){
					return false;
				}
			} else {
				// if there is not a valid date to compare to assume we are comparing to now()
				if(dateCompare(arguments.prop.value,now()) != 1){
					return false;
				}
			}
		} else {
			valid = false;
		}

		return valid;
	}

}