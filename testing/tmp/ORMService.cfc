/**
<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/10/2007
Description :
----------------------------------------------------------------------->
*/
component{

/* ----------------------------------- CONSTRUCTOR ------------------------------ */

	/**
	* constructor
	*/
	EntityService function init(){
		return this;
	}

/* ----------------------------------- PUBLIC ------------------------------ */

	/**
	* Get an entity's listing by lots of goodies
	*/
	any function list(required entityName, 
					   struct criteria=structnew(), 
					   string sortOrder="", 
					   numeric offset=0,
					   numeric maxResults=0,
					   boolean asQuery=true){
		var options = {};
		
		// Check options
		if( arguments.offset neq 0 ){
			options.offset = arguments.offset;
		}
		if( arguments.maxresults neq 0 ){
			options.maxresults = arguments.maxresults;
		}
		
		// Get listing
		var results = entityLoad(arguments.entityName, arguments.criteria, arguments.sortOrder, options);
		
		// Objects or Query?
		if( arguments.asQuery ){
			results = entityToQuery(results);
		}
		
		return results;
	}
	
	/** 
    * Get a new entity object
    */
	any function new(required entityName){
		return entityNew(arguments.entityName);
	}
	
	/** 
    * Get an entity with or without PK id's, but if not found, it will return a new entity.
	* the id argument can be a simple value or a structure for composite keys
    */
	any function get(required entityName,any id="") {
		// Check if PK sent, else return new entity
		if( isSimpleValue(arguments.id) and NOT len(arguments.id) ){
			return new(arguments.entityName);
		}
		// Retrieve by ID
		return entityLoadByPK(arguments.entityName, arguments.id);
	}
	
	/** 
    * Get an entity by criteria
    */
	any function getByCriteria(required entityName,required struct criteria) {
		// Retrieve by Criteria
		return entityLoad(arguments.entityName, arguments.criteria, true);
	}
	
	/** 
    * Delete an entity
    */
	void function delete(required any entity){
		transaction{
			entityDelete(arguments.entity);
		}
	}

	/** 
    * Save an entity using hibernate transactions
    */
	void function save(required any entity){
		transaction{
			entitySave(arguments.entity);
		}
	}
	
	/** 
    * evict an entity from session, the id can be a string or structure for the primary key
    */
	void function evict(required string entityName,any id){
		if( structKeyExists(arguments,"id") )
			ORMEvictEntity(arguments.entityName,arguments.id);
		else
			ORMEvictEntity(arguments.entityName);
	}
	
	/**
	* Facade to rethrowit, where is this Adobe?
	*/	
	private function rethrowit(e){
		throw(object=arguments.e);
	}
	
}