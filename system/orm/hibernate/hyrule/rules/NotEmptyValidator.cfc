/**
 * I will validate that a value is not empty.
 *
 * @param NotEmpty
 * @return boolean
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;

		/**
		 *	Simple data types
		 *		Strings | Lists | Booleans | Numbers | Date/Time | UUID | Binary
		 *	Complex Data Types
		 *		Queries | Arrays | Structures | Objects
		 */
		if(isSimpleValue(arguments.prop.value)) {
			// if the argument is false we don't want to strip whitespace, else strip it
			if( isBoolean(arguments.prop.notempty) && !arguments.prop.notempty ){
				if(!len(arguments.prop.value)){
					valid = false;
				}
			} else {
				if(!len(trim(arguments.prop.value))){
					valid = false;
				}
			}
		} else {

			if( isArray(arguments.prop.value) && arrayIsEmpty(arguments.prop.value) ){
				valid = false;
			}

			if( isStruct(arguments.prop.value) && structIsEmpty(arguments.prop.value) ){
				valid = false;
			}

			if( isQuery(arguments.prop.value) && arguments.prop.value.recordCount == 0 ) {
				valid = false;
			}

		}

		return valid;
	}

}
