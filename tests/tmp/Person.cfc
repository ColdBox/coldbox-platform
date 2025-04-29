/**
 * We use this class for testing serializations
 */
component accessors="true"{

	property String name;
	property String surname;
	property numeric age;
	property Date createdDate;
	property Date modifiedDate;
	property boolean isActive;
	property test;
	property system;

	function init(){
		variables.name = "John";
		variables.surname = "Doe";
		variables.age = 30;
		variables.createdDate = now();
		variables.modifiedDate = now();
		variables.isActive = true;
		variables.test = new User();

		variables.system = createObject( "java", "java.lang.System" );

		return this;
	}

}
