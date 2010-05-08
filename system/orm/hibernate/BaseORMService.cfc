/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author      :	Luis Majano
Description :

This is a helper ORM service that will help you abstract some complexities
when dealing with CF's ORM via Hibernate.  You can use this service in its
concrete form or you can inherit from it and extend it.

TODO:
- Add dynamic findBy methods
- Add dynamic countBy methods
- Add dynamic getBy methods
- Dynamic entity methods for the following methods:
   - new{entityName}()
   - exists{entityName}()
   - get{entityName}()
   - getAll{entityName}()
   - count{entityName}()
- Add find methods by criteria with projections
- Add validations maybe via Hyrule, but more implicit and mixin methods
- Add dml style batch updates
----------------------------------------------------------------------->
*/
component accessors="true"{

	/**
	* The queryCacheRegion name property for all query caching produced in this service
	*/
	property name="queryCacheRegion" type="string" default="ORMService.defaultCache";

	/**
	* The bit that tells the service to enable query caching, disabled by default
	*/
	property name="useQueryCaching" type="boolean" default="false";

/* ----------------------------------- DEPENDENCIES ------------------------------ */



/* ----------------------------------- CONSTRUCTOR ------------------------------ */

	/**
	* Constructor
	*/
	BaseORMService function init(string queryCacheRegion="ORMService.defaultCache", boolean useQueryCaching=false){
		// setup properties
		setQueryCacheRegion( arguments.queryCacheRegion );
		setUseQueryCaching( arguments.useQueryCaching );
		return this;
	}

/* ----------------------------------- PUBLIC ------------------------------ */


	/**
	* Create a virtual abstract service for a specfic entity.
	*/
	any function createService(required string entityName, 
							   boolean useQueryCaching=getUseQueryCaching(), 
							   string queryCacheRegion=getQueryCacheRegion()) {
								   
		return  CreateObject("component", "coldbox.system.orm.hibernate.VirtualEntityService").init(argumentCollection=arguments);
	}

	/**
	* List all of the instances of the passed in entity class name. You can pass in several optional arguments like
	* a struct of filtering criteria, a sortOrder string, offset, max, ignorecase, and timeout.
	* Caching for the list is based on the useQueryCaching class property and the cachename property is based on
	* the queryCacheRegion class property.
	* @tested true
	*/
	any function list(required string entityName,
					  struct criteria=structnew(),
					  string sortOrder="",
					  numeric offset=0,
					  numeric max=0,
					  numeric timeout=0,
					  boolean ignoreCase=false,
					  boolean asQuery=true){
		var options = {};

		// Setup listing options
		if( arguments.offset neq 0 ){
			options.offset = arguments.offset;
		}
		if( arguments.max neq 0 ){
			options.maxresults = arguments.max;
		}
		if( arguments.timeout neq 0 ){
			options.timeout = arguments.timeout;
		}

		// Caching?
		if( getUseQueryCaching() ){
			options.cacheName  = getQueryCacheRegion();
			options.cacheable  = true;
		}

		// Sort Order Case
		if( len(trim(arguments.sortOrder)) ){
			options.ignoreCase = arguments.ignoreCase;
		}

		// Get listing
		var results = entityLoad(arguments.entityName, arguments.criteria, arguments.sortOrder, options);

		// Is it Null?
		if( isNull(results) ){ results = []; }

		// Objects or Query?
		if( arguments.asQuery ){
			results = entityToQuery(results);
		}

		return results;
	}

	/**
	* Allows the execution of HQL queries using several nice arguments and returns either an array of entities or a query as specified by the asQuery argument.
	* The params filtering can be using named or positional.
	* @tested true
	*/
	any function executeQuery(required string query,
							  any params=structnew(),
							  numeric offset=0,
					  		  numeric max=0,
					  		  numeric timeout=0,
						      boolean asQuery=true){
		var options = {};

		// Setup listing options
		if( arguments.offset neq 0 ){
			options.offset = arguments.offset;
		}
		if( arguments.max neq 0 ){
			options.maxresults = arguments.max;
		}
		if( arguments.timeout neq 0 ){
			options.timeout = arguments.timeout;
		}
		// Caching?
		if( getUseQueryCaching() ){
			options.cacheName  = getQueryCacheRegion();
			options.cacheable  = true;
		}

		// Get listing
		var results = ORMExecuteQuery( arguments.query, arguments.params, false, options );

		// Objects or Query?
		if( arguments.asQuery ){
			results = entityToQuery(results);
		}

		return results;
	}

	/**
	* Finds and returns the first result for the given query or null if no entity was found.
	* You can either use the query and params combination or send in an example entity to find.
	* @tested true
	*/
	any function find(string query,any params=structnew(), any example){
		var options = {maxresults=1};

		// Get entry by example
		if( structKeyExists( arguments, "example") ){
			return entityLoadByExample( arguments.example, true );
		}

		// Normal Find
		return ORMExecuteQuery( arguments.query, arguments.params, true, options);
	}

	/**
	* Find all the entities for the specified query and params or example
	* @tested true
	*/
	array function findAll(string query,
						   any params=structnew(),
						   numeric offset=0,
					       numeric max=0,
						   any example){
		var options = {};

		// Setup find options
		if( arguments.offset neq 0 ){
			options.offset = arguments.offset;
		}
		if( arguments.max neq 0 ){
			options.maxresults = arguments.max;
		}

		// Get entry by example
		if( structKeyExists( arguments, "example") ){
			return entityLoadByExample( arguments.example );
		}

		// Normal Find
		return ORMExecuteQuery( arguments.query, arguments.params, false, options);
	}

	/**
	* Find one entity or null if not found according to the passed in name value pairs into the function
	* ex: findWhere(entityName="Category", category="Training"), findWhere(entityName="Users", age=40);
	* @tested true
	*/
	any function findWhere(required string entityName){
		var buffer   = createObject("java","java.lang.StringBuffer").init('');
		var key      = "";
		var operator = "AND";
		var params	  = {};
		var idx	  = 1;

		buffer.append('from #arguments.entityName#');

		// Do we have params?
		if( structCount(arguments) gt 1){
			buffer.append(" WHERE");
		}
		// Go over Params
		for(key in arguments){
			// Build where parameterized
			if( key neq "entityName" ){
				params[key] = arguments[key];
				buffer.append(" #key# = :#key#");
				idx++;
				// Check AND?
				if( idx neq structCount(arguments) ){
					buffer.append(" AND");
				}
			}
		}

		// execute query as unique
		try{
			return ORMExecuteQuery( buffer.toString(), params, true, {maxresults=1});
		}
		catch("java.lang.NullPointerException" e){
			throw(message="A null pointer exception occurred when running the find operation",
			  detail="The most likely reason is that the keys in the passed in structure need to be case sensitive. Passed Keys=#structKeyList(params)#",
			  type="ORMService.MaybeInvalidParamCaseException");
		}
	}

	/**
	* Find one entity or null if not found according to the passed in name value pairs into the function
	* ex: findWhere(entityName="Category", category="Training"), findWhere(entityName="Users", age=40);
	* @tested true
	*/
	array function findAllWhere(required string entityName){
		var buffer   = createObject("java","java.lang.StringBuffer").init('');
		var key      = "";
		var operator = "AND";
		var params	  = {};
		var idx	  = 1;

		buffer.append('from #arguments.entityName#');

		// Do we have params?
		if( structCount(arguments) gt 1){
			buffer.append(" WHERE");
		}
		// Go over Params
		for(key in arguments){
			// Build where parameterized
			if( key neq "entityName" ){
				params[key] = arguments[key];
				buffer.append(" #key# = :#key#");
				idx++;
				// Check AND?
				if( idx neq structCount(arguments) ){
					buffer.append(" AND");
				}
			}
		}

		// execute query as unique
		try{
			return ORMExecuteQuery( buffer.toString(), params);
		}
		catch("java.lang.NullPointerException" e){
			throw(message="A null pointer exception occurred when running the find operation",
			  detail="The most likely reason is that the keys in the passed in structure need to be case sensitive. Passed Keys=#structKeyList(params)#",
			  type="ORMService.MaybeInvalidParamCaseException");
		}
	}

	/**
    * Get a new entity object by entity name and you can pass in any named parameter and the method will try to set it for you.
	* @tested true
    */
	any function new(required string entityName){
		var entity = entityNew(arguments.entityName);
		var key    = "";
		
		// iterate over arguments
		for( key in arguments ){
		
			// Check if method exists and not entityName
			if( key NEQ "entityName" and structKeyExists(entity, "set#key#") ){
				evaluate("entity.set#key#( arguments[key] )");
			}		
		}
		
		return entity;
	}

	/**
    * Refresh the state of an entity or array of entities from the database
	* @tested true
    */
	void function refresh(required any entity){
		var objects = arrayNew(1);

		if( not isArray(arguments.entity) ){
			arrayAppend(objects, arguments.entity);
		}
		else{
			objects = arguments.entity;
		}

		for( var x=1; x lte arrayLen(objects); x++){
			ORMGetSession().refresh( objects[x] );
		}
	}

	/**
    * Checks if the given entityName and id exists in the database
	* @tested true
    */
	boolean function exists(required entityName, required any id) {
		var target = get(argumentCollection=arguments);
		return isNull(target);
	}


	/**
	* Get an entity using a primary key, if the id is not found this method returns null
	* @tested true
    */
	any function get(required string entityName,required any id) {
		// Retrieve by ID
		return entityLoadByPK(arguments.entityName, arguments.id);
	}

	/**
	* Retrieve all the instances from the passed in entity name using the id argument if specified
	* The id can be a list of IDs or an array of IDs or none to retrieve all.
	* If the id is not found or returns null the array position will have an empty string in it in the specified order
	* @tested true
    */
	array function getAll(required string entityName,any id) {
		var results = [];

		// Return all entity values
		if( NOT structKeyExists(arguments,"id") ){
			return entityLoad(arguments.entityName);
		}

		// Convert ID to array if simple value
		if( isSimpleValue(arguments.id) ){ arguments.id = listToArray(arguments.id); }

		// Iterate and get
		for(var x=1; x lte arraylen(arguments.id); x++ ){
			var obj = entityLoadByPK(arguments.entityName,arguments.id[x]);
			if( isNull(obj) ){
				obj = '';
			}
			arrayAppend(results, obj);
		}

		return results;
	}

	/**
    * Delete an entity using hibernate transactions. The entity argument can be a single entity
	* or an array of entities. You can optionally flush the session also after committing
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
	* Delete using an entity name and an incoming id, you can also flush the session if needed
	* The method returns false if the passed in entityName and id is not found in the database.
	* @tested true
	*/
	boolean function deleteByID(required string entityName, required any id, boolean flush=false){
		var entity = get(argumentCollection=arguments);

		if( isNull(entity) ){ return false; }

		delete( entity,arguments.flush );

		return true;
	}

	/**
	* Delete by using an HQL query and iterating via the results, it is not performing a delete query but
	* it actually is a select query that should retrieve objects to remove
	* @tested true
	*/
	void function deleteByQuery(required string query, any params, numeric max=0, numeric offset=0, boolean flush=false ){
		var objects = arrayNew(1);
		var options = {};

		// Setup query options
		if( arguments.offset neq 0 ){
			options.offset = arguments.offset;
		}
		if( arguments.max neq 0 ){
			options.maxresults = arguments.max;
		}
		// Query
		if( structKeyExists(arguments, "params") ){
			objects = ORMExecuteQuery(arguments.query, arguments.params, false, options);
		}
		else{
			objects = ORMExecuteQuery(arguments.query, false, options);
		}

		delete( objects, arguments.flush );
	}

	/**
	* Deletes entities by using name value pairs as arguments to this function.  One mandatory argument is to pass the 'entityName'.
	* The rest of the arguments are used in the where class using AND notation and parameterized.
	* Ex: deleteWhere(entityName="User",age="4",isActive=true);
	* @tested true
	*/
	numeric function deleteWhere(required string entityName){
		 var buffer   = createObject("java","java.lang.StringBuffer").init('');
		 var key      = "";
		 var operator = "AND";
		 var params	  = {};
		 var idx	  = 1;

		 buffer.append('delete from #arguments.entityName#');

		 // Do we have arguments?
		 if( structCount(arguments) gt 1){
		 	buffer.append(" WHERE");
		 }
		 else{
		 	throw(message="No where arguments sent, aborting deletion"
				  detail="We will not do a full delete via this method, you need to pass in named value arguments.",
				  type="BaseORMService.NoWhereArgumentsFound");
		 }

		 // Go over Params
		 for(key in arguments){
		 	// Build where parameterized
			if( key neq "entityName" ){
				params[key] = arguments[key];
				buffer.append(" #key# = :#key#");
				idx++;
				// Check AND?
				if( idx neq structCount(arguments) ){
					buffer.append(" AND");
				}
			}
		 }

		 // execute query as unique for the count
		 try{
		 	return ORMExecuteQuery( buffer.toString(), params, true);
		 }
		 catch("java.lang.NullPointerException" e){
		 	throw(message="A null pointer exception occurred when running the query",
				  detail="The most likely reason is that the keys in the passed in structure need to be case sensitive. Passed Keys=#structKeyList(params)#",
				  type="BaseORMService.MaybeInvalidParamCaseException");
		 }
	}

	/**
    * Save an entity using hibernate transactions. You can optionally flush the session also
	* @tested true
    */
	any function save(required any entity, boolean forceInsert=false, boolean flush=false, boolean validate=false){

		if(arguments.validate){
			//TODO: CustomErrorMessage file path. it would be coldbox setting "ValidationErrorMessage" = "file name"
			var validator	= new coldbox.system.orm.hibernate.hyrule.Validator();
			var result		= validator.validate(arguments.entity);
			
			if(result.hasErrors()){
				// Return Array of error messages
				return result.getErrors();
			}
		}

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
		return true;
	}

	/**
	* Return the count of records in the DB for the given entity name. You can also pass an optional where statement
	* that can filter the count. Ex: count('User','age > 40 AND name="joe"'). You can even use params with this method:
	* Ex: count('User','age > ? AND name = ?',[40,"joe"])
	* @tested true
	*/
	numeric function count(required string entityName,string where="", any params=structNew()){
		 var buffer   = createObject("java","java.lang.StringBuffer").init('');
		 var key      = "";
		 var operator = "AND";

		 buffer.append('select count(*) from #arguments.entityName#');

		 // build params
		 if( len(trim(arguments.where)) ){
		 	buffer.append(" WHERE #arguments.where#");
		 }

		 // execute query as unique for the count
		 try{
		 	return ORMExecuteQuery( buffer.toString(), arguments.params, true);
		 }
		 catch("java.lang.NullPointerException" e){
		 	throw(message="A null pointer exception occurred when running the query",
				  detail="The most likely reason is that the keys in the passed in structure need to be case sensitive. Passed Keys=#structKeyList(arguments.params)#",
				  type="ORMService.MaybeInvalidParamCaseException");
		 }

	}

	/**
	* Returns the count by passing name value pairs as arguments to this function.  One mandatory argument is to pass the 'entityName'.
	* The rest of the arguments are used in the where class using AND notation and parameterized.
	* Ex: countWhere(entityName="User",age="20");
	* @tested true
	*/
	numeric function countWhere(required string entityName){
		 var buffer   = createObject("java","java.lang.StringBuffer").init('');
		 var key      = "";
		 var operator = "AND";
		 var params	  = {};
		 var idx	  = 1;

		 buffer.append('select count(*) from #arguments.entityName#');

		 // Do we have params?
		 if( structCount(arguments) gt 1){
		 	buffer.append(" WHERE");
		 }
		 // Go over Params
		 for(key in arguments){
		 	// Build where parameterized
			if( key neq "entityName" ){
				params[key] = arguments[key];
				buffer.append(" #key# = :#key#");
				idx++;
				// Check AND?
				if( idx neq structCount(arguments) ){
					buffer.append(" AND");
				}
			}
		 }

		 // execute query as unique for the count
		 try{
		 	return ORMExecuteQuery( buffer.toString(), params, true);
		 }
		 catch("java.lang.NullPointerException" e){
		 	throw(message="A null pointer exception occurred when running the count",
				  detail="The most likely reason is that the keys in the passed in structure need to be case sensitive. Passed Keys=#structKeyList(params)#",
				  type="ORMService.MaybeInvalidParamCaseException");
		 }
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
    * Evict entity objects from session. The argument can be one persistence entity or an array of entities
    */
	void function evictEntity(required any entity){
		var objects = arrayNew(1);

		if( not isArray(arguments.entities) ){
			arrayAppend(objects, arguments.entities);
		}
		else{
			objects = arguments.entities;
		}

		for( var x=1; x lte arrayLen(objects); x++){
			ORMGetSession().evict( objects[x] );
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
    * Merge an entity or array of entities back into the session
    */
	void function merge(required any entity){
		var objects = arrayNew(1);

		if( not isArray(arguments.entities) ){
			arrayAppend(objects, arguments.entities);
		}
		else{
			objects = arguments.entities;
		}

		for( var x=1; x lte arrayLen(objects); x++){
			entityMerge( objects[x] );
		}

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
	boolean function isSessionDirty(){
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
	* A nice onMissingMethod template to create awesome dynamic methods.
	* 
	*/
	any function onMissingMethod(String missingMethodName,Struct missingMethodArguments){
		var method = arguments.missingMethodName;
		var args   = arguments.missingMethodArguments;

	}

	/**
	* Returns the key (id field) of a given entity, either simple or composite keys.
	* If the key is a simple pk then it will return a string, if it is a composite key then it returns an array
	*/
	any function getKey(required string entityName){
		var hibernateMD =  ormGetSessionFactory().getClassMetaData(arguments.entityName);
		
		// Is this a simple key?
		if( hibernateMD.hasIdentifierProperty() ){
			return hibernateMD.getIdentifierPropertyName();
		}
		
		// Composite Keys?
		if( hibernateMD.getIdentifierType().isComponentType() ){
			// Do conversion to CF Array instead of java array, just in case
			return listToArray(arrayToList(hibernateMD.getIdentifierType().getPropertyNames()));
		}
		
		return "";
	}

	/**
	* Returns the Property Names of the entity
	*/
	array function getPropertyNames(required string entityName){
		return ormGetSessionFactory().getClassMetaData(arguments.entityName).getPropertyNames();
	}

	/**
	* Returns the table name of the of the entity
	*/
	string function getTableName(required string entityName){
		return ormGetSessionFactory().getClassMetadata(arguments.entityName).getTableName();
	}

}