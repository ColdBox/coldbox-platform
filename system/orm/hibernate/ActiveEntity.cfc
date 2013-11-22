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
		super.init( argumentCollection=arguments );

		return this;
	}

	/**
    * Save an entity using hibernate transactions or not. You can optionally flush the session also
    * @entity.hint You can optionally pass in an entity, else this active entity is saved
    * @forceInsert.hint Force insert on the save
    * @flush.hint Flush the session or not, default is false
    * @transactional.hint Use transactions or not, it defaults to true
    */
	any function save(any entity, boolean forceInsert=false, boolean flush=false, boolean transactional=getUseTransactions()){
		if( !structKeyExists(arguments,"entity") ){
			arguments.entity = this;
		}

		return super.save( argumentCollection=arguments );
	}

	/**
    * Delete an entity. The entity argument can be a single entity
	* or an array of entities. You can optionally flush the session also after committing
	* Transactions are used if useTransactions bit is set or the transactional argument is passed
    * @entity.hint You can optionally pass in an entity, else this active entity is saved
    * @flush.hint Flush the session or not, default is false
    * @transactional.hint Use transactions or not, it defaults to true
    */
	any function delete(any entity, boolean flush=false,boolean transactional=getUseTransactions()){
		if( !structKeyExists(arguments,"entity") ){
			arguments.entity = this;
		}
		return super.delete( argumentCollection=arguments );
	}

	/**
    * Refresh the state of the entity
    * @entity.hint The argument can be one persistence entity or an array of entities
    */
	any function refresh(any entity){
		var objects = arrayNew(1);

		if( structKeyExists(arguments,"entity") ){
			if( isArray(arguments.entity) ){
				objects = arguments.entity;
			}
			else{
				arrayAppend(objects, arguments.entity);
			}
		}

		arrayAppend(objects, this);

		return super.refresh(objects);
	}

	/**
    * Merge an entity or array of entities back into the session
    * @entity.hint The argument can be one persistence entity or an array of entities
    */
	any function merge(any entity){
		var objects = arrayNew(1);

		if( structKeyExists(arguments,"entity") ){
			if( isArray(arguments.entity) ){
				objects = arguments.entity;
			}
			else{
				arrayAppend(objects, arguments.entity);
			}
		}

		arrayAppend(objects, this);

		return super.merge(objects);
	}

	/**
    * Evict entity objects from session, if no arguments, then the entity evicts itself
	* @entity.hint The argument can be one persistence entity or an array of entities
    */
	any function evict(any entity){
		var objects = arrayNew(1);

		if( structKeyExists(arguments,"entity") ){
			if( isArray(arguments.entity) ){
				objects = arguments.entity;
			}
			else{
				arrayAppend(objects, arguments.entity);
			}
		}

		arrayAppend(objects, this);

		return super.evictEntity(objects);
	}

	/**
    * Simple map to property population for entities
	* @memento.hint	The map/struct to populate the entity with
	* @scope.hint Use scope injection instead of setter injection, no need of setters, just tell us what scope to inject to
	* @trustedSetter.hint Do not check if the setter exists, just call it, great for usage with onMissingMethod() and virtual properties
	* @include.hint A list of keys to include in the population ONLY
	* @exclude.hint A list of keys to exclude from the population
    */
	any function populate(any target=this,
						  required struct memento,
						  string scope="",
					 	  boolean trustedSetter=false,
						  string include="",
						  string exclude="",
						  boolean ignoreEmpty=false,
						  string nullEmptyInclude="",
						  string nullEmptyExclude="",
						  boolean composeRelationships=true){
		return beanPopulator.populateFromStruct( argumentCollection=arguments );
	}
	
	/**
    * Simple map to property population for entities with structure key prefixes
	* @memento.hint	The map/struct to populate the entity with
	* @scope.hint Use scope injection instead of setter injection, no need of setters, just tell us what scope to inject to
	* @trustedSetter.hint Do not check if the setter exists, just call it, great for usage with onMissingMethod() and virtual properties
	* @include.hint A list of keys to include in the population ONLY
	* @exclude.hint A list of keys to exclude from the population
	* @prefix.hint The prefix used to filter, Example: 'user' would apply to the following formfield: 'user_id' and 'user_name' but not 'address_id' 
    */
	any function populateWithPrefix(any target=this,
						  required struct memento,
						  string scope="",
					 	  boolean trustedSetter=false,
						  string include="",
						  string exclude="",
						  boolean ignoreEmpty=false,
						  string nullEmptyInclude="",
						  string nullEmptyExclude="",
						  boolean composeRelationships=true,
						  required string prefix){
		return beanPopulator.populateFromStructWithPrefix( argumentCollection=arguments );
	}

	/**
	* Populate from JSON, for argument definitions look at the populate method
	* @JSONString.hint	The JSON packet to use for population
	* @scope.hint Use scope injection instead of setter injection, no need of setters, just tell us what scope to inject to
	* @trustedSetter.hint Do not check if the setter exists, just call it, great for usage with onMissingMethod() and virtual properties
	* @include.hint A list of keys to include in the population ONLY
	* @exclude.hint A list of keys to exclude from the population
	*/
	any function populateFromJSON(any target=this,
								  required string JSONString,
								  string scope="",
								  boolean trustedSetter=false,
								  string include="",
								  string exclude="",
						   	 	  boolean ignoreEmpty=false,
						  		  string nullEmptyInclude="",
						  		  string nullEmptyExclude="",
						  		  boolean composeRelationships=true){
		return beanPopulator.populateFromJSON( argumentCollection=arguments );
	}

	/**
	* Populate from XML, for argument definitions look at the populate method. <br/>
	* @root.hint The XML root element to start from
	* @xml.hint	The XML string or packet or XML object to populate from
	* @scope.hint Use scope injection instead of setter injection, no need of setters, just tell us what scope to inject to
	* @trustedSetter.hint Do not check if the setter exists, just call it, great for usage with onMissingMethod() and virtual properties
	* @include.hint A list of keys to include in the population ONLY
	* @exclude.hint A list of keys to exclude from the population
	*/
	any function populateFromXML(any target=this,
								 required string xml,
								 string root="",
								 string scope="",
								 boolean trustedSetter=false,
								 string include="",
								 string exclude="",
						   	     boolean ignoreEmpty=false,
						  		 string nullEmptyInclude="",
						  		 string nullEmptyExclude="",
						  		 boolean composeRelationships=true){
		return beanPopulator.populateFromXML( argumentCollection=arguments );
	}

	/**
	* Populate from Query, for argument definitions look at the populate method. <br/>
	* @qry.hint The query to use for population
	* @rowNumber.hint	The row number to use for population
	* @scope.hint Use scope injection instead of setter injection, no need of setters, just tell us what scope to inject to
	* @trustedSetter.hint Do not check if the setter exists, just call it, great for usage with onMissingMethod() and virtual properties
	* @include.hint A list of keys to include in the population ONLY
	* @exclude.hint A list of keys to exclude from the population
	*/
	any function populateFromQuery(any target=this,
								   required any qry,
								   numeric rowNumber=1,
								   string scope="",
								   boolean trustedSetter=false,
								   string include="",
								   string exclude="",
						  		   boolean ignoreEmpty=false,
						  		   string nullEmptyInclude="",
						  		   string nullEmptyExclude="",
						  		   boolean composeRelationships=true){
		return beanPopulator.populateFromQuery( argumentCollection=arguments );
	}

	/**
	* Validate the ActiveEntity with the coded constraints -> this.constraints, or passed in shared or implicit constraints
	* The entity must have been populated with data before the validation
	* @fields.hint One or more fields to validate on, by default it validates all fields in the constraints. This can be a simple list or an array.
	* @constraints.hint An optional shared constraints name or an actual structure of constraints to validate on.
	* @locale.hint An optional locale to use for i18n messages
	* @excludeFields.hint An optional list of fields to exclude from the validation.
	*/
	boolean function isValid(string fields="*", any constraints="", string locale="", string excludeFields=""){
		// validate wirebox
		if( !structKeyExists(variables,"wirebox") OR !isObject(variables.wirebox) ){
			throw(message="WireBox reference does not exist in this entity",detail="WireBox entity injection must be enabled in order to use the validation features",type="ActiveEntity.ORMEntityInjectionMissing");
		}

		// Get validation manager
		var validationManager = wirebox.getInstance("WireBoxValidationManager");
		// validate constraints
		var thisConstraints = "";
		if( structKeyExists(this,"constraints") ){ thisConstraints = this.constraints; }
		// argument override
		if( !isSimpleValue(arguments.constraints) OR len(arguments.constraints) ){
			thisConstraints = arguments.constraints;
		}

		// validate and save results in private scope
		validationResults = validationManager.validate(target=this, fields=arguments.fields, constraints=thisConstraints, locale=arguments.locale, excludeFields=arguments.excludeFields);

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