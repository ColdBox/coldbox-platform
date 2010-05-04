/**
 * @hint
 */
component implements="IValidator" {

	public boolean function isValid(Struct prop){
		var valid = true;
		var min = listGetAt(arguments.prop.password,1);
		var max = listGetAt(arguments.prop.password,2);
		var level = "low";

		if(listLen(arguments.prop.password) == 3){
			level = listGetAt(arguments.prop.password,3);
		}

		// check the min and max
		if( len(arguments.prop.value) < min || len(arguments.prop.value) > max ) {
			return false;
		}

		// check the security level
		switch(level){
			case "low" : {
				// on low security level this is our only check
				if(arguments.prop.value == "password") {
					valid = false;
					break;
				}
				break;
			}
			case "medium" : {
				// on medium the password must contain letters and numbers
				if( arrayLen(reMatchNocase("[a-zA-Z]",arguments.prop.value)) == 0 || arrayLen(reMatchNocase("[0-9]",arguments.prop.value)) == 0 ){
					valid = false;
					break;
				}
				break;
			}
			case "high" : {			
				// on high the password must contain letters, numbers & special characters
				if( arrayLen(reMatchNocase("[a-zA-Z]",arguments.prop.value)) == 0 || arrayLen(reMatchNocase("[0-9]",arguments.prop.value)) == 0 || arrayLen(reMatchNoCase("[^\w]",arguments.prop.value)) == 0 ){
					valid = false;
					break;
				}
				break;
			}
		}

		return valid;
	}

}
