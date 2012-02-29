/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Description :

This Active Entity object allows you to enhance your ORM entities with virtual service methods
and make it follow more of an Active Record pattern, but not really :)

It just allows you to operate on entity and related entity objects much much more easily.

If you have enabled WireBox entity injection, then you will get an added validation features:

boolean function isValid(fields="*",constraints="",locale=""){}
coldbox.system.validation.result.IValidationResult function getValidationResults(){}

These methods are only active if WireBox entity injection is available.


*/
component extends="coldbox.system.orm.hibernate.VirtualEntityService" accessors="true"{
	
	/**
	* WireBox entity injector, only injected if ORM entity injection is available.
	*/
	property name="wirebox" inject="wirebox" persistent="false";
	
	/**
	* Active Entity Constructor, if you override it, make sure you call super.init()
	* @queryCacheRegion.hint The query cache region to use if not we will use one for you
	* @useQueryCaching.hint Enable query caching for this entity or not, defaults to false
	* @eventHandling.hint Enable event handling for new() and save() operations, defaults to true
	* @useTransactions.hint Enable transactions for all major operations, defaults to true
	* @defaultAsQuery.hint What should be the default return type query or arrays for list opertions, defaults to true
	*/
	function init(string queryCacheRegion, boolean useQueryCaching,	boolean eventHandling, boolean useTransactions,	boolean defaultAsQuery){
		var md 		= getMetadata( this );
		
		// find entity name on md?
		if( structKeyExists(md,"entityName") ){
			arguments.entityName = md.entityName;
		}
		// else default to entity CFC name
		else{
			arguments.entityName = listLast( md.name, "." );
		}
		// query cache region just in case
		if( !structKeyExists(arguments,"queryCacheRegion") ){
			arguments.queryCacheRegion = "#arguments.entityName#.activeEntityCache";
		}
		// datasource
		arguments.datasource = new coldbox.system.orm.hibernate.util.ORMUtilFactory().getORMUtil().getEntityDatasource( this );
		
		// init the super class with our own arguments
		super.init(argumentCollection=arguments);
		
		return this;
	}
	
	/**
	* Validate the ActiveEntity with the coded constraints -> this.constraints, or passed in shared or implicit constraints
	* The entity must have been populated with data before the validation
	* @fields.hint One or more fields to validate on, by default it validates all fields in the constraints. This can be a simple list or an array.
	* @constraints.hint An optional shared constraints name or an actual structure of constraints to validate on.
	* @locale.hint An optional locale to use for i18n messages
	*/
	boolean function isValid(string fields="*", any constraints="", string locale=""){
		// validate wirebox
		if( !structKeyExists(variables,"wirebox") OR !isObject(variables.wirebox) ){
			throw(message="WireBox reference does not exist in this entity",detail="WireBox entity injection must be enabled in order to use the validation features",type="ActiveEntity.ORMEntityInjectionMissing");
		}
		
		// Get validation manager
		var validationManager = wirebox.getInstance( "WireBoxValidationManager" );
		// validate constraints
		var thisConstraints = "";
		if( structKeyExists(this,"constraints") ){ thisConstraints = this.constraints; }
		// argument override
		if( !isSimpleValue(arguments.constraints) OR len(arguments.constraints) ){
			thisConstraints = arguments.constraints;
		}		
		// validate and save results in private scope
		validationResults = validationManager.validate(this, arguments.fields, thisConstraints, arguments.locale);
		// return it
		return ( !validationResults.hasErrors() );
	}
	
	/**
	* Get the validation results object.  This will be an empty validation object if isValid() has not being called yet.
	*/
	coldbox.system.validation.result.IValidationResult function getValidationResults(){
		if( structKeyExists(variables,"validationResults") ){
			return validationResults;
		}
		return new coldbox.system.validation.result.ValidationResult();
	}
	
}