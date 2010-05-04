/**
 * I will validate that a value passes our max checks based on the max key.
 *
 * @param max
 * @return boolean
 */
component implements="IValidator" extends="BaseObject" {

	public boolean function isValid(Struct prop) {
		var valid = true;
		var max = arguments.prop.max;

		switch( getType(arguments.prop.value) ) {
			case "Numeric" : {
				if(arguments.prop.value > max) {
					valid = false;
				}
				break;
			}
			case "Date" : {
				if( dateCompare(arguments.prop.value,max) == 1 ) {
					valid = false;
				}
				break;
			}
			case "String" : {
				if( len(arguments.prop.value) > max ) {
					valid = false;
				}
				break;
			}
			case "Array" : {
				if( arrayLen(arguments.prop.value) > max ) {
					valid = false;
				}
				break;
			}
			case "Struct" : {
				if( structCount(arguments.prop.value) > max ) {
					valid = false;
				}
				break;
			}
			case "Query" : {
				if( arguments.prop.value.recordCount > max ) {
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