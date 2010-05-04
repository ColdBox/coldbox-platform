component accessors="true" hint="I hold the results of a call to the HyRule validator server validate function." {

	property name="errors" type="array";

	public validationResult function init(){
		setErrors([]);
		return this;
	}
	
	public boolean function hasErrors() {
		return (ArrayLen(getErrors()) > 0); 
	}
	
	public array function getErrors(){
		return variables.errors;
	}
	
	public void function addError(required string class,required string validationlevel,required string property,required string validationType,required string message){
		var validationError = new validationError();
		
		validationError.setClass(arguments.class);
		validationError.setValidationlevel(arguments.validationlevel);
		validationError.setProperty(arguments.property);
		validationError.setvalidationType(arguments.validationType);
		validationError.setMessage(arguments.message);
		
		ArrayAppend(variables.errors,validationError);
	}

}
