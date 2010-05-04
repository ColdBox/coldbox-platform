/**
 * @hint I will validate that a value falls in between a range.
 * @output false
 *
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		var min = listFirst(arguments.prop.range);
		var max = listLast(arguments.prop.range);

		// date range
		if(isDate(arguments.prop.value)){		
			if(dateCompare(min,arguments.prop.value) != -1 || dateCompare(max,arguments.prop.value) != 1){
				valid = false;
			}
		}

		// numeric range
		if(isNumeric(arguments.prop.value)){				
			if(arguments.prop.value <= min || arguments.prop.value >= max){
				valid = false;
			}
		}
		
		// length of a string (numbers+dates are simple values so make sure its not a number)
		if(isSimpleValue(arguments.prop.value) && !isNumeric(arguments.prop.value) && !isDate(arguments.prop.value) ){
			if(len(arguments.prop.value) <= min || len(arguments.prop.value) >= max){
				valid = false;
			}
		}
		
		return valid;
	}

}