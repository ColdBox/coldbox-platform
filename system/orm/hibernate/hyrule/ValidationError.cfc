component accessors="true" hint="I am a an error of the busniss validation logic"
{
	property string class;
	property string validationLevel;  //values can be "Class" or "Property"
	property string property;
	property string validationType;
	property string message;
	
	public validationError function init(){
		return this;
	}
	
	public void function setValidationlevel(required string validationLevel){
		var level = lcase(arguments.validationLevel);
	
		if(level != 'property' && level != 'class') {
			throw(type="validationError",message="validationLevel must be either class or property");
		} 
		
		variables.validationLevel = arguments.validationLevel;
		
	}

}
