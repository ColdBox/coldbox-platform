component accessors="true"{

	property name="name";
	property name="email";
				
				
	function init( name="luis", email="lmajano@ortussolutions.com" ){
		variables.name = arguments.name;
		variables.email = arguments.email;
		return this;
	}
}