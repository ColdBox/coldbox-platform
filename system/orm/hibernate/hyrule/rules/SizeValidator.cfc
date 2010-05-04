/**
 * @hint I will validate the size of a list, array or structure.
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		var min = listFirst(arguments.prop.size);
		var max = listLast(arguments.prop.size);

		if(isSimpleValue(arguments.prop.value)){
			if(listLen(arguments.prop.value) < min || listLen(arguments.prop.value) > max){
				valid = false;
			}
		}
		
		if(isArray(arguments.prop.value)){
			if(arrayLen(arguments.prop.value) < min || arrayLen(arguments.prop.value) > max){
				valid = false;
			}
		}
		
		if(isStruct(arguments.prop.value)){
			if(structCount(arguments.prop.value) < min || structCount(arguments.prop.value) > max){
				valid = false;
			}
		}

		return valid;
	}

}