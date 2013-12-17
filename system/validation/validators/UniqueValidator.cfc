/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Validates if the field has a unique value in the database, this only applies to ORM objects
*/
component accessors="true" implements="coldbox.system.validation.validators.IValidator" singleton{

	property name="name";
	property name="ORMService";

	UniqueValidator function init(){
		name 		= "Unique";
		ORMService 	= new coldbox.system.orm.hibernate.BaseORMService();
		return this;
	}

	/**
	* Will check if an incoming value validates
	* @validationResult.hint The result object of the validation
	* @target.hint The target object to validate on
	* @field.hint The field on the target object to validate on
	* @targetValue.hint The target value to validate
	* @validationData.hint The validation data the validator was created with
	*/
	boolean function validate(required coldbox.system.validation.result.IValidationResult validationResult, required any target, required string field, any targetValue, any validationData){

		// return true if not unique, nothing needed to check
		if( !arguments.validationData ){ return true; }

		// null checks
		if( isNull( arguments.targetValue ) ){
			var args = {message="The '#arguments.field#' value is null",field=arguments.field,validationType=getName(),validationData=arguments.validationData};
			validationResult.addError( validationResult.newError(argumentCollection=args) );
			return false;
		}

		// Only validate simple values and if they have length, else ignore.
		if( isSimpleValue( arguments.targetValue ) AND len( trim( arguments.targetValue ) ) ){
			// process entity setups.
			var entityName 		= ORMService.getEntityGivenName( arguments.target );
			var identityField 	= ORMService.getKey( entityName );
			var identityValue 	= evaluate( "arguments.target.get#identityField#()" );

			// create criteria for uniqueness
			var c = ORMService.newCriteria( entityName )
				.isEq( field, arguments.targetValue );

			// validate with ID? then add to restrictions
			if( !isNull( identityValue ) ){
				c.ne( identityField, identityValue );
			}

			// validate uniqueness
			if( c.count() GT 0 ){
				var args = {message="The '#arguments.field#' value is not unique in the database",field=arguments.field,validationType=getName(),validationData=arguments.validationData};
				validationResult.addError( validationResult.newError(argumentCollection=args) );
				return false;
			}
		}

		return true;
	}

	/**
	* Get the name of the validator
	*/
	string function getName(){
		return name;
	}

}