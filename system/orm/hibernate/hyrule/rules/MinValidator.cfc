/**
 * I will validate that a value passes our min checks based on the min key.
 *
 * @param Min
 * @return boolean
 */
component implements="IValidator" extends="BaseObject" {

	public boolean function isValid(Struct prop) {
		var valid = true;
		var min = arguments.prop.min;

		switch( getType(arguments.prop.value) ) {
			case "Numeric" : {
				if(arguments.prop.value < min) {
					valid = false;
				}
				break;
			}
			case "Date" : {
				if( dateCompare(arguments.prop.value,min) == -1 ) {
					valid = false;
				}
				break;
			}
			case "String" : {
				if( len(arguments.prop.value) < min ) {
					valid = false;
				}
				break;
			}
			case "Array" : {
				if( arrayLen(arguments.prop.value) < min ) {
					valid = false;
				}
				break;
			}
			case "Struct" : {
				if( structCount(arguments.prop.value) < min ) {
					valid = false;
				}
				break;
			}
			case "Query" : {
				if( arguments.prop.value.recordCount < min ) {
					valid = false;
				}
				break;
			}
			default : {
				valid = false;
				break;
			}
		}

		return valid;
	}


}