/**
<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano
Description :

This is a helper ORM service that will help you abstract some complexities
when dealing with CF's ORM via Hibernate.  You can use this service in its
concrete form or you can inherit from it and extend it.

This ORM service can also announce its own interceptions whenever certain things
happen in its internal methods and thus allowing the usage of ColdBox interceptor
knowledge instead of hibernate knowledge.

It also allows you to add callback methods to entities and the service will call
them on certain actions or methods as they occurr.


----------------------------------------------------------------------->
*/
component accessors="true"{

	/**
	* The queryCacheRegion name property for all query caching in the service
	*/
	property name="queryCacheRegion" type="string" default="ORMService.defaultCache";
	
	/**
	* The bit that tells the service to enable query caching, disabled by default
	*/
	property name="useQueryCaching" type="boolean" default="false";
	
/* ----------------------------------- DEPENDENCIES ------------------------------ */
	
	property name="logBox" 				inject="logBox";
	property name="interceptorService"  inject="coldbox:interceptorService";
	property name="beanFactory"			inject="coldbox:plugin:BeanFactory";

/* ----------------------------------- CONSTRUCTOR ------------------------------ */

	/**
	* Constructor
	*/
	ORMService function init(){
		return this;
	}

	/**
	* Prepare the class for operation
	*/
	void function onDIComplete(){
		// Setup the class logger
		log = logBox.getLogger(this);
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
	* Clear the session removes all the entities that are loaded or created in the session.
	* This clears the first level cache and removes the objects that are not yet saved to the database.
	* @tested true
	*/
	void function clear(){
		ORMClearSession();
	}
	
	/**
	* Checks if the session contains dirty objects that are awaiting persistence
	* @tested true
	*/
	boolean function isDirty(){
		return ORMGetSession().isDirty();
	}
	
	/**
	* Checks if the current session contains the passed in entity
	* @tested true
	*/
	boolean function sessionContains(required any entity){
		var ormSession = ORMGetSession();
		// weird CFML thing
		return ormSession.contains(arguments.entity);
	}
	
	/**
	* Information about the first-level (session) cache for the current session
	* @tested true
	*/
	struct function getSessionStatistics(){
		var stats   = ormGetSession().getStatistics();
		var results = {
			collectionCount = stats.getCollectionCount(),
			collectionKeys  = stats.getCollectionKeys().toString(),
			entityCount	    = stats.getEntityCount(),
			entityKeys		= stats.getEntityKeys().toString()
		};
		
		return results;
	}
	
	/** 
    * Get a new entity object by entity name
	* @tested true
    */
	any function new(required entityName){
		return entityNew(arguments.entityName);
	}
	
	/** 
    * Get an entity with or without PK id's, but if not found, it will return a new entity.
	* the id argument can be a simple value or a structure for composite keys
	* @tested true
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
    * Get a single entity by criteria
	* @tested true
    */
	any function getByCriteria(required entityName,required struct criteria) {
		// Retrieve by Criteria
		return entityLoad(arguments.entityName, arguments.criteria, true);
	}
	
	/** 
    * Delete an entity using hibernate transactions. The entity argument can be a single entity
	* or an array of entities 
	* You can optionally flush the session also
	* @tested true
    */
	void function delete(required any entity,boolean flush=false){
		var tx 		= ORMGetSession().beginTransaction();
		var objects = arrayNew(1);
		var objLen  = 0;
		
		try{
			if( not isArray(arguments.entity) ){
				arrayAppend(objects, arguments.entity);
			}
			else{
				objects = arguments.entity;
			}
			
			objLen = arrayLen(objects);
			for(var x=1; x lte objLen; x++){
				entityDelete( objects[x] );
			}
			
			tx.commit();
		}
		catch(Any e){
			tx.rollback();
			throw(e);
		}
		// Auto Flush
		if( arguments.flush ){ ORMFlush(); }
	}
	
	/**
	* Delete using an entity name and an incoming id
	*/
	void function deleteByID(required string entityName, required any id, boolean flush=false){
		delete( get(argumentCollection=arguments) );
	}

	/**
	* Delete by using an HQL query and iterating via the results, it is not performing a delete query.
	*/
	void function deleteByQuery(required string query, any params, boolean unique=false, struct queryOptions=structnew(), boolean flush=false ){
		var objects = arrayNew(1);
		 
		// Query
		if( structKeyExists(arguments, "params") ){
			objects = ORMExecuteQuery(arguments.query, arguments.params, arguments.unique, arguments.queryOptions);
		}
		else{
			objects = ORMExecuteQuery(arguments.query, arguments.unique, arguments.queryOptions);
		}
		 
		delete( objects, arguments.flush );
	}

	/** 
    * Save an entity using hibernate transactions. You can optionally flush the session also
    */
	void function save(required any entity, boolean forceInsert=false, boolean flush=false){
		var tx = ORMGetSession().beginTransaction();
		
		try{
			entitySave(arguments.entity, arguments.forceInsert);
			
			tx.commit();
		}
		catch(Any e){
			tx.rollback();
			throw(e);
		}
		// Auto Flush
		if( arguments.flush ){ ORMFlush(); }
	}
	
	/** 
    * Evict an entity from session, the id can be a string or structure for the primary key
	* You can also pass in a collection name to evict from the collection
    */
	void function evict(required string entityName,string collectionName, any id){
		
		//Collection?
		if( structKeyExists(arguments,"collectionName") ){
			if( structKeyExists(arguments,"id") )
				ORMEvictCollection(arguments.entityName,arguments.collectionName, arguments.id);
			else
				ORMEvictCollection(arguments.entityName,arguments.collectionName);
		}
		// Single Entity
		else{
			if( structKeyExists(arguments,"id") )
				ORMEvictEntity(arguments.entityName,arguments.id);
			else
				ORMEvictEntity(arguments.entityName);
		}
	}
	
	/** 
    * Evict all queries in the default cache or the cache region passed
    */
	void function evictQueries(string cacheName){
		if( structKeyExists(arguments,"cacheName") )
			ORMEvictQueries(arguments.cacheName);
		else
			ORMEvictQueries();
	}
	
	/**
	* Facade to rethrowit, where is this Adobe?
	*/	
	private function rethrowit(e){
		throw(object=arguments.e);
	}
	
}