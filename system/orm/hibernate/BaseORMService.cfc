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
----------------------------------------------------------------------->
*/
import coldbox.system.orm.hibernate.util.*;

component accessors="true"{

	/**
	* The queryCacheRegion name property for all query caching produced in this service
	*/
	property name="queryCacheRegion" type="string" default="ORMService.defaultCache";

	/**
	* The bit that tells the service to enable query caching, disabled by default
	*/
	property name="useQueryCaching" type="boolean" default="false";

	/**
	* The bit that enables event handling via the ORM Event handler such as interceptions when new entities get created, etc, enabled by default.
	*/
	property name="eventHandling" type="boolean" default="true";

	/**
	* The system ORM event handler to transmitt ORM events to
	*/
	property name="ORMEventHandler";

	/**
	* The system ORM utility object
	*/
	property name="ORM";
	
	/**
	* The bit that enables automatic hibernate transactions on all save, saveAll, update, delete methods
	*/
	property name="useTransactions" type="boolean" default="true";

	/**
	* The bit that determines the default return value for list(), createCriteriaQuery() and executeQuery() as query or array
	*/
	property name="defaultAsQuery" type="boolean" default="true";
	
	/**
	* All calculated and parsed dynamic finders' and counters' HQL will be stored here for easier execution
	*/
	property name="HQLDynamicCache" type="struct";  
	
	// STATIC DYNAMIC FINDER VARIABLES
	ALL_CONDITIONALS 		= "LessThanEquals,LessThan,GreaterThanEquals,GreaterThan,Like,NotEqual,isNull,isNotNull,NotBetween,Between,NotInList,inList";
	ALL_CONDITIONALS_REGEX	= replace( ALL_CONDITIONALS, ",", "|", "all" );
	CONDITIONALS_SQL_MAP 	= { 
		"LessThanEquals" = "<=",
		"LessThan" = "<",
		"GreaterThanEquals" = ">=",
		"GreaterThan" = ">",
		"Like" = "like",
		"NotEqual" = "<>",
		"isNull" = "is null",
		"isNotNull" = "is not null",
		"NotBetween" = "not between",
		"between" = "between",
		"NotInList" = "not in",
		"InList" = "in" };

	/************************************** CONSTRUCTOR *********************************************/

	BaseORMService function init( 
		string queryCacheRegion="ORMService.defaultCache",
		boolean useQueryCaching=false,
		boolean eventHandling=true,
		boolean useTransactions=true,
		boolean defaultAsQuery=true
	){
		
		// setup local properties
		variables.queryCacheRegion 	= arguments.queryCacheRegion;
		variables.useQueryCaching 	= arguments.useQueryCaching;
		variables.eventHandling 	= arguments.eventHandling;
		variables.useTransactions 	= arguments.useTransactions;
		variables.defaultAsQuery 	= arguments.defaultAsQuery;
		variables.HQLDynamicCache	= {};

		// Create the ORM Utility component
		variables.ORM = new coldbox.system.orm.hibernate.util.ORMUtilFactory().getORMUtil();
		
		// Create the service ORM Event Handler
		if( directoryExists( expandPath("/wirebox") ) OR structKeyExists( application, "cblite" ) ){
			variables.ORMEventHandler = new coldbox.system.orm.hibernate.WBEventHandler();
		}
		else{
			variables.ORMEventHandler = new coldbox.system.orm.hibernate.EventHandler();
		}

		// Create our bean populator utility object
		variables.beanPopulator = new coldbox.system.core.dynamic.BeanPopulator();
		// Restrictions orm.hibernate.criterion.Restrictions
		variables.restrictions  = new coldbox.system.orm.hibernate.criterion.Restrictions();

		return this;
	}

	/************************************** PUBLIC *********************************************/

	/**
	* Create a virtual abstract service for a specfic entity.
	*/
	any function createService(required string entityName,
							   boolean useQueryCaching=getUseQueryCaching(),
							   string queryCacheRegion=getQueryCacheRegion(),
							   boolean eventHandling=getEventHandling()) {

		return new coldbox.system.orm.hibernate.VirtualEntityService( argumentCollection=arguments );
	}

	/**
	* List all of the instances of the passed in entity class name. You can pass in several optional arguments like
	* a struct of filtering criteria, a sortOrder string, offset, max, ignorecase, and timeout.
	* Caching for the list is based on the useQueryCaching class property and the cachename property is based on
	* the queryCacheRegion class property.
	*/
	any function list(required string entityName,
					  struct criteria=structnew(),
					  string sortOrder="",
					  numeric offset=0,
					  numeric max=0,
					  numeric timeout=0,
					  boolean ignoreCase=false,
					  boolean asQuery=getDefaultAsQuery()){
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
	*/
	any function executeQuery(required string query,
							   any params=structnew(),
							   numeric offset=0,
					  		   numeric max=0,
					  		   numeric timeout=0,
						       boolean ignorecase=false,
						       boolean asQuery=getDefaultAsQuery(),
						       boolean unique=false,
						       string datasource=""){
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
		if( Len(arguments.datasource) ){
			options.datasource = arguments.datasource;
		}
		options.ignorecase = arguments.ignorecase;
		// Caching?
		if( getUseQueryCaching() ){
			options.cacheName  = getQueryCacheRegion();
			options.cacheable  = true;
		}

		// Get listing
		var results = ORMExecuteQuery( arguments.query, arguments.params, arguments.unique, options );

		// Null Checks
		if( isNull(results) ){
			if( arguments.asQuery ){ return queryNew(""); }
			if (arguments.unique) {
				return;
			} else {
				return [];
			}
		}

		// Objects or Query?
		if( arguments.asQuery ){
			results = entityToQuery(results);
		}

		return results;
	}

	/**
	* Finds and returns the first result for the given query or null if no entity was found.
	* You can either use the query and params combination or send in an example entity to find.
	* @example.hint DEPRECATED. Use findByExample() instead, deprecated by 3.5
	*/
	any function findIt(string query,any params=structnew(), any example){
		var options = {maxresults=1};

		// Caching?
		if( getUseQueryCaching() ){
			options.cacheName  = getQueryCacheRegion();
			options.cacheable  = true;
		}

		// Get entry by example
		if( structKeyExists( arguments, "example") ){
			return findByExample( arguments.example, true );
		}

		// Normal Find
		return ORMExecuteQuery( arguments.query, arguments.params, true, options);
	}

	/**
	* Find all/single entities by example
	*/
	any function findByExample(any example,boolean unique=false){
		return entityLoadByExample(arguments.example,arguments.unique);
	}

	/**
	* Find all the entities for the specified query and params or example
	* @example.hint	DEPRECATED use findByExample() this will be dropped in 3.5
	*/
	array function findAll(string query,
						    any params=structnew(),
						    numeric offset=0,
					        numeric max=0,
					        numeric timeout=0,
					        boolean ignoreCase=false,
						    any example){

		// Get entry by example
		if( structKeyExists( arguments, "example") ){
			return findByExample( arguments.example );
		}

		// Normal Execute Query
		arguments.asQuery=false;
		return executeQuery( argumentCollection=arguments );
	}

	/**
	* Find one entity (or null if not found) according to a criteria structure
	*/
	any function findWhere(required string entityName, required struct criteria){
		// Caching?
		if( getUseQueryCaching() ){
			//if we are caching, we will use find all and return an array since entityLoad does not support both unique and caching
			var arEntity = findAllWhere( argumentCollection=arguments );
			//if we found an entity, return it
			if (arrayLen(arEntity)) {
				return arEntity[1];
			//else return NULL, just like entityLoad with unique would
			} else {
				return javaCast("null",0);
			}
		} else {
			return entityLoad( arguments.entityName, arguments.criteria, true );
		}
	}

	/**
	* Find all entities according to criteria structure
	*/
	array function findAllWhere(required string entityName, required struct criteria, string sortOrder=""){
		var options = {};
		// Caching?
		if( getUseQueryCaching() ){
			options.cacheName  = getQueryCacheRegion();
			options.cacheable  = true;
		}
		return entityLoad( arguments.entityName, arguments.criteria, arguments.sortOrder, options);
	}

	/**
    * Get a new entity object by entity name and you can pass in the properties structre also to bind the entity with properties
    * @entityName.hint The entity to create
    * @properties.hint The structure of data to populate the entity with. By default we will inspect for many-to-one, one-to-many and many-to-many relationships and compose them for you.
    * @composeRelationships.hint Automatically attempt to compose relationships from the incoming properties memento
    * @nullEmptyInclude.hint A list of keys to NULL when empty
    * @nullEmptyExclude.hint A list of keys to NOT NULL when empty
    * @ignoreEmpty.hint Ignore empty values on populations, great for ORM population
    * @include.hint A list of keys to include in the population from the incoming properties memento
    * @exclude.hint A list of keys to exclude in the population from the incoming properties memento
    */
	any function new(required string entityName, struct properties=structnew(), boolean composeRelationships=true, nullEmptyInclude="", nullEmptyExclude="", boolean ignoreEmpty=false, include="", exclude=""){
		var entity   = entityNew( arguments.entityName );

		// Properties exists?
		if( NOT structIsEmpty(arguments.properties) ){
			populate(target=entity, memento=arguments.properties, composeRelationships=arguments.composeRelationships,
					 nullEmptyInclude=arguments.nullEmptyInclude, nullEmptyExclude=arguments.nullEmptyExclude, ignoreEmpty=arguments.ignoreEmpty,
					 include=arguments.include, exclude=arguments.exclude );
		}

		// Event Handling? If enabled, call the postNew() interception
		if( getEventHandling() ){
			ORMEventHandler.postNew( entity, arguments.entityName );
		}

		return entity;
	}

	/**
    * Simple map to property population for entities
	* @memento.hint	The map/struct to populate the entity with
	* @scope.hint Use scope injection instead of setter injection, no need of setters, just tell us what scope to inject to
	* @trustedSetter.hint Do not check if the setter exists, just call it, great for usage with onMissingMethod() and virtual properties
	* @include.hint A list of keys to include in the population ONLY
	* @exclude.hint A list of keys to exclude from the population
    */
	any function populate(required any target,
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
	any function populateWithPrefix(required any target,
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
	any function populateFromJSON(required any target,
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
	* Populate from XML, for argument definitions look at the populate method
	* @root.hint The XML root element to start from
	* @xml.hint	The XML string or packet or XML object to populate from
	* @scope.hint Use scope injection instead of setter injection, no need of setters, just tell us what scope to inject to
	* @trustedSetter.hint Do not check if the setter exists, just call it, great for usage with onMissingMethod() and virtual properties
	* @include.hint A list of keys to include in the population ONLY
	* @exclude.hint A list of keys to exclude from the population
	*/
	any function populateFromXML(required any target,
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
	* Populate from Query, for argument definitions look at the populate method
	* @qry.hint The query to use for population
	* @rowNumber.hint	The row number to use for population
	* @scope.hint Use scope injection instead of setter injection, no need of setters, just tell us what scope to inject to
	* @trustedSetter.hint Do not check if the setter exists, just call it, great for usage with onMissingMethod() and virtual properties
	* @include.hint A list of keys to include in the population ONLY
	* @exclude.hint A list of keys to exclude from the population
	*/
	any function populateFromQuery(required any target,
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
    * Refresh the state of an entity or array of entities from the database
    */
	any function refresh(required any entity){
		var objects = arrayNew(1);

		if( not isArray(arguments.entity) ){
			arrayAppend(objects, arguments.entity);
		}
		else{
			objects = arguments.entity;
		}

		for( var x=1; x lte arrayLen(objects); x++){
			orm.getSession(orm.getEntityDatasource(objects[x])).refresh( objects[x] );
		}
		return this;
	}

	/**
    * Checks if the given entityName and id exists in the database, this method does not load the entity into session
	*/
	boolean function exists(required entityName, required any id) {
		var  options = {};
		options.datasource = orm.getEntityDatasource(arguments.entityName);

		// Do it DLM style
		var count = ORMExecuteQuery("select count(id) from #arguments.entityName# where id = ?",[arguments.id],true,options);
		return (count gt 0);
	}

	/**
	* Get an entity using a primary key, if the id is not found this method returns null, if the id=0 or blank it returns a new entity.
	* @entityName the name of the entity to retrieve
	* @id An optional primary key to use to retrieve the entity, if the id is 0 or empty
    */
	any function get(required string entityName,required any id,boolean returnNew=true) {

		// check if id exists so entityLoad does not throw error
		if( (isSimpleValue(arguments.id) and len(arguments.id)) OR NOT isSimpleValue(arguments.id) ){
			var entity = entityLoadByPK(arguments.entityName, arguments.id);
			// Check if not null, then return it
			if( NOT isNull(entity) ){
				return entity;
			}
		}

		// Check for return new?
		if( arguments.returnNew ){

			// Check if ID=0 or empty to do convenience new entity
			if( isSimpleValue(arguments.id) and ( arguments.id eq 0  OR len(arguments.id) eq 0 ) ){
				return new(entityName=arguments.entityName);
			}

		}
	}

	/**
	* Retrieve all the instances from the passed in entity name using the id argument if specified
	* The id can be a list of IDs or an array of IDs or none to retrieve all.
    */
	array function getAll(required string entityName,any id,string sortOrder="") {
		var results = [];

		// Return all entity values
		if( NOT structKeyExists(arguments,"id") ){
			return entityLoad(arguments.entityName,{},arguments.sortOrder);
		}

		// type safe conversions
		arguments.id = convertIDValueToJavaType(entityName=arguments.entityName, id=arguments.id);
		var q = "FROM #arguments.entityName# where id in (:idlist)";
		// ordering?
		if( len(arguments.sortOrder) ){
			q &= " ORDER BY #arguments.sortOrder#";
		}
		// Execute native hibernate query
		var query = orm.getSession(orm.getEntityDatasource(arguments.entityName)).createQuery(q);
		// parameter binding
		query.setParameterList("idlist",arguments.id);
		// Caching?
		if( getUseQueryCaching() ){
			query.setCacheRegion(getQueryCacheRegion());
			query.setCacheable(true);
		}
		return query.list();
	}

	/**
    * Delete an entity. The entity argument can be a single entity
	* or an array of entities. You can optionally flush the session also after committing
	* Transactions are used if useTransactions bit is set or the transactional argument is passed
    */
	any function delete(required any entity,boolean flush=false,boolean transactional=getUseTransactions()){
		// using transaction closure, well, semy closures :(
		if( arguments.transactional ){
			return $transactioned(variables.$delete, arguments);
		}
		$delete( argumentCollection=arguments );
		return this;
	}
	private any function $delete(required any entity,boolean flush=false){
		var objects = arrayNew(1);
		var objLen  = 0;

		if( not isArray(arguments.entity) ){
			arrayAppend(objects, arguments.entity);
		}
		else{
			objects = arguments.entity;
		}

		objLen = arrayLen(objects);
		for(var x=1; x lte objLen; x++){
			// Delete?
			entityDelete( objects[x] );
			// Flush?
			if( arguments.flush ){ orm.flush( orm.getEntityDatasource( objects[x] ) ); }
		}

		return this;
	}

	/**
	* Delete all entries for an entity DLM style and transaction safe. It also returns all the count of deletions
	* Transactions are used if useTransactions bit is set or the transactional argument is passed
	*/
	numeric function deleteAll(required string entityName,boolean flush=false,boolean transactional=getUseTransactions()){
		// using transaction closure, well, semy closures :(
		if( arguments.transactional ){
			return $transactioned(variables.$deleteAll, arguments);
		}
		return $deleteAll( argumentCollection=arguments );
	}
	private numeric function $deleteAll(required string entityName,boolean flush=false){
		var options = {};
		options.datasource = orm.getEntityDatasource(arguments.entityName);

		var count   = 0;
		count = ORMExecuteQuery("delete from #arguments.entityName#",false,options);

		// Auto Flush
		if( arguments.flush ){ orm.flush(options.datasource); }

		return count;
	}

	/**
	* Delete using an entity name and an incoming id, you can also flush the session if needed. The id parameter can be a single id or an array of IDs to delete
	* The method returns the count of deleted entities.
	* Transactions are used if useTransactions bit is set or the transactional argument is passed
	*/
	numeric function deleteByID(required string entityName, required any id, boolean flush=false, boolean transactional=getUseTransactions()){
		// using transaction closure, well, semy closures :(
		if( arguments.transactional ){
			return $transactioned(variables.$deleteByID, arguments);
		}
		return $deleteByID( argumentCollection=arguments );
	}
	private numeric function $deleteByID(required string entityName, required any id, boolean flush=false){
		var count   = 0;

		// type safe conversions
		arguments.id = convertIDValueToJavaType(entityName=arguments.entityName, id=arguments.id);

		// delete using lowercase id convention from hibernate for identifier
		var datasource = orm.getEntityDatasource(arguments.entityName);
		var query = orm.getSession(datasource).createQuery("delete FROM #arguments.entityName# where id in (:idlist)");
		query.setParameterList("idlist",arguments.id);
		count = query.executeUpdate();

		// Auto Flush
		if( arguments.flush ){ orm.flush(datasource); }

		return count;
	}

	/**
	* Delete by using an HQL query and iterating via the results, it is not performing a delete query but
	* it actually is a select query that should retrieve objects to remove
	* Transactions are used if useTransactions bit is set or the transactional argument is passed
	*/
	any function deleteByQuery(required string query, any params, numeric max=0, numeric offset=0, boolean flush=false, boolean transactional=getUseTransactions(), string datasource="" ){
		// using transaction closure, well, semy closures :(
		if( arguments.transactional ){
			return $transactioned(variables.$deleteByQuery, arguments);
		}
		$deleteByQuery( argumentCollection=arguments );
		return this;
	}
	private any function $deleteByQuery(required string query, any params, numeric max=0, numeric offset=0, boolean flush=false, string datasource=""){
		var objects = arrayNew(1);
		var options = {};

		// Setup query options
		if( arguments.offset neq 0 ){
			options.offset = arguments.offset;
		}
		if( arguments.max neq 0 ){
			options.maxresults = arguments.max;
		}
		if( Len(arguments.datasource) ){
			options.datasource = arguments.datasource;
		}
		// Query
		if( structKeyExists(arguments, "params") ){
			objects = ORMExecuteQuery(arguments.query, arguments.params, false, options);
		}
		else{
			objects = ORMExecuteQuery(arguments.query, false, options);
		}

		delete(entity=objects,flush=arguments.flush,transactional=arguments.transactional);
		return this;
	}

	/**
	* Deletes entities by using name value pairs as arguments to this function.  One mandatory argument is to pass the 'entityName'.
	* The rest of the arguments are used in the where class using AND notation and parameterized.
	* Ex: deleteWhere(entityName="User",age="4",isActive=true);
	* Transactions are used if useTransactions bit is set or the transactional argument is passed
	*/
	numeric function deleteWhere(required string entityName,boolean transactional=getUseTransactions()){
		// using transaction closure, well, semy closures :(
		if( arguments.transactional ){
			structDelete(arguments,"transactional");
			return $transactioned(variables.$deleteWhere, arguments);
		}
		structDelete(arguments,"transactional");
		return $deleteWhere( argumentCollection=arguments );
	}
	private numeric function $deleteWhere(required string entityName){
		var buffer   = createObject("java","java.lang.StringBuffer").init('');
		var key      = "";
		var operator = "AND";
		var params	  = {};
		var idx	  	  = 1;
		var count	  = 0;
		var options   = {};

		options.datasource = orm.getEntityDatasource(arguments.entityName);

		buffer.append('delete from #arguments.entityName#');

		// Do we have arguments?
		if( structCount(arguments) gt 1){
			buffer.append(" WHERE");
		}
		else{
			throw(message="No where arguments sent, aborting deletion",
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

		//start DLM deleteion
		try{
			count = ORMExecuteQuery( buffer.toString(), params, true, options);
		}
		catch("java.lang.NullPointerException" e){
			throw(message="A null pointer exception occurred when running the query",
			  detail="The most likely reason is that the keys in the passed in structure need to be case sensitive. Passed Keys=#structKeyList(params)#",
			  type="BaseORMService.MaybeInvalidParamCaseException");
		}
		catch(any e){
			rethrow;
		}
		return count;
	}

	/**
    * Saves an array of passed entities in specified order
	* @entities An array of entities to save
	* Transactions are used if useTransactions bit is set or the transactional argument is passed
    */
	any function saveAll(required entities, forceInsert=false, flush=false,boolean transactional=getUseTransactions()){
		// using transaction closure, well, semy closures :(
		if( arguments.transactional ){
			return $transactioned(variables.$saveAll, arguments);
		}
		return $saveAll( argumentCollection=arguments );
	}
	private any function $saveAll(required entities, forceInsert=false, flush=false){
		var count 			=  arrayLen(arguments.entities);
		var eventHandling 	=  getEventHandling();

		// iterate and save
		for(var x=1; x lte count; x++){
			// Event Handling? If enabled, call the preSave() interception
			if( eventHandling ){
				ORMEventHandler.preSave( arguments.entities[x] );
			}
			// Save it
			entitySave(arguments.entities[x], arguments.forceInsert);
			// Event Handling? If enabled, call the postSave() interception
			if( eventHandling ){
				ORMEventHandler.postSave( arguments.entities[x] );
			}
			// Auto Flush
			if( arguments.flush ){ orm.flush( orm.getEntityDatasource( arguments.entities[x] ) ); }
		}

		return true;
	}

	/**
    * Save an entity using hibernate transactions or not. You can optionally flush the session also
    */
	any function save(required any entity, boolean forceInsert=false, boolean flush=false, boolean transactional=getUseTransactions()){
		// using transaction closure, well, semy closures :(
		if( arguments.transactional ){
			return $transactioned(variables.$save, arguments);
		}
		return $save( argumentCollection=arguments );
	}
	any function $save(required any entity, boolean forceInsert=false, boolean flush=false){
		// Event handling flag
		var eventHandling = getEventHandling();

		// Event Handling? If enabled, call the preSave() interception
		if( eventHandling ){
			ORMEventHandler.preSave( arguments.entity );
		}

		// save
		entitySave(arguments.entity, arguments.forceInsert);

		// Auto Flush
		if( arguments.flush ){ orm.flush(orm.getEntityDatasource(arguments.entity)); }

		// Event Handling? If enabled, call the postSave() interception
		if( eventHandling ){
			ORMEventHandler.postSave( arguments.entity );
		}

		return true;
	}

	/**
	* Return the count of records in the DB for the given entity name. You can also pass an optional where statement
	* that can filter the count. Ex: count('User','age > 40 AND name="joe"'). You can even use params with this method:
	* Ex: count('User','age > ? AND name = ?',[40,"joe"])
	*/
	numeric function count(required string entityName,string where="", any params=structNew()){
		var buffer   = createObject("java","java.lang.StringBuffer").init('');
		var key      = "";
		var operator = "AND";
		var options = {};

		options.datasource = orm.getEntityDatasource(arguments.entityName);

		// Caching?
		if( getUseQueryCaching() ){
			options.cacheName  = getQueryCacheRegion();
			options.cacheable  = true;
		}
		buffer.append('select count(*) from #arguments.entityName#');

		// build params
		if( len(trim(arguments.where)) ){
			buffer.append(" WHERE #arguments.where#");
		}

		// execute query as unique for the count
		try{
			return ORMExecuteQuery( buffer.toString(), arguments.params, true, options);
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
	*/
	numeric function countWhere(required string entityName){
		var buffer   = createObject("java","java.lang.StringBuffer").init('');
		var key      = "";
		var operator = "AND";
		var params	  = {};
		var idx	  = 1;
		var options = {};

		options.datasource = orm.getEntityDatasource(arguments.entityName);

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
		// Caching?
		if( getUseQueryCaching() ){
			options.cacheName  = getQueryCacheRegion();
			options.cacheable  = true;
		}

		// execute query as unique for the count
		try{
			return ORMExecuteQuery( buffer.toString(), params, true, options);
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
	any function evict(required string entityName,string collectionName, any id){

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
				evictEntity( this.get(entityName=arguments.entityName,id=arguments.id) );
			else
				evictEntity( this.new(entityName=arguments.entityName) );
		}

		return this;
	}

	/**
    * Evict entity objects from session.
	* @entities The argument can be one persistence entity or an array of entities
    */
	any function evictEntity(required any entities){
		var objects = arrayNew(1);

		if( not isArray(arguments.entities) ){
			arrayAppend(objects, arguments.entities);
		}
		else{
			objects = arguments.entities;
		}

		for( var x=1; x lte arrayLen(objects); x++){
			orm.getSession(orm.getEntityDatasource(objects[x])).evict( objects[x] );
		}

		return this;
	}

	/**
    * Evict all queries in the default cache or the cache region passed
    */
	any function evictQueries(string cacheName, string datasource){
		orm.evictQueries( argumentCollection=arguments );
		return this;
	}

	/**
    * Merge an entity or array of entities back into the session
    */
	any function merge(required any entity){
		var objects = [];

		if( not isArray( arguments.entity ) ){
			arrayAppend( objects, arguments.entity );
		}
		else{
			objects = arguments.entity;
		}

		for( var x=1; x lte arrayLen( objects ); x++){
			entityMerge( objects[ x ] );
		}

		return this;
	}

	/**
	* Clear the session removes all the entities that are loaded or created in the session.
	* This clears the first level cache and removes the objects that are not yet saved to the database.
	*/
	any function clear(string datasource=orm.getDefaultDatasource()){
		orm.clearSession(arguments.datasource);
		return this;
	}

	/**
	* Checks if the session contains dirty objects that are awaiting persistence
	*/
	boolean function isSessionDirty(string datasource=orm.getDefaultDatasource()){
		return orm.getSession(arguments.datasource).isDirty();
	}

	/**
	* Checks if the current session contains the passed in entity
	*/
	boolean function sessionContains(required any entity){
		var ormSession = orm.getSession(orm.getEntityDatasource(arguments.entity));
		// weird CFML thing
		return ormSession.contains(arguments.entity);
	}

	/**
	* Information about the first-level (session) cache for the current session
	*/
	struct function getSessionStatistics(string datasource=orm.getDefaultDatasource()){
		var stats   = orm.getSession(arguments.datasource).getStatistics();
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
	*/
	any function onMissingMethod(string missingMethodName, struct missingMethodArguments){
		var method = arguments.missingMethodName;
		var args   = arguments.missingMethodArguments;
		
		// Dynamic Find Unique Finders
		if( left( method, 6 ) eq "findBy" and len( method ) GT 6 ){
			return findDynamically(missingMethodName=right( method, len( method ) - 6 ), missingMethodArguments=args, unique=true);
		}
		// Dynamic find All Finders
		if( left( method, 9 ) eq "findAllBy"  and len( method ) GT 9 ){
			return findDynamically(missingMethodName=right( method, len( method ) - 9 ), missingMethodArguments=args, unique=false);
		}
		// Dynamic countBy Finders
		if( left( method, 7 ) eq "countBy"  and len( method ) GT 7 ){
			return findDynamically(missingMethodName=right( method, len( method ) - 7 ), missingMethodArguments=args, unique=true, isCounting=true);
		}
		
		// Throw exception, method not found.
		throw(message="Invalid method call: #method#", detail="The dynamic/static method you called does not exist", type="BaseORMService.MissingMethodException");
	}
	
	/**
	* Compile HQL from a dynamic method call
	*/
	private any function compileHQLFromDynamicMethod(string missingMethodName, struct missingMethodArguments, boolean unique=true, boolean isCounting=false, struct params, entityName){
		var method 			= arguments.missingMethodName;
		var args   			= arguments.missingMethodArguments;
		
		// Get all real property names
		var realPropertyNames = getPropertyNames( arguments.entityName );
		// Match our method gramars ini the method string
		var methodGrammars = REMatchNoCase( "((?!(and|or|$))\w)+(#ALL_CONDITIONALS_REGEX#)?(and|or|$)", method );
		
		// Throw exception if no method grammars found
		if( !arrayLen( methodGrammars ) ){
			throw(message="Invalid dynamic method grammar expression. Please check your syntax. You could be missing property names or conditionals", 
				  detail="Expression: #method#", 
				  type="BaseORMService.InvalidMethodGrammar");
		}
		
		// Iterate over method grammars to build HQL Expressions
		var HQLExpressions = [];
		for( var thisGrammar in methodGrammars ){
			// create expression syntax
			var expression = { property = "", conditional = "eq", operator = "and", sql = "=" };

			// Check for Or expression, AND is default expression
			if( right( thisGrammar, 2 ) eq "or" ){
				expression.operator = "or";
			}
			// Remove operator now that we have it
			thisGrammar = REReplacenoCase( thisGrammar, "(and|or)$", "" );
			
			// Get property by removing conditionals from the expression
			expression.property = REReplacenoCase( thisGrammar, "(#ALL_CONDITIONALS_REGEX#)$", "" );
			// Verify if property exists in valid properties
			// TODO: Add relationships later 
			var realPropertyIndex = arrayFindNoCase( realPropertyNames, expression.property );
			if( realPropertyIndex EQ 0 ){
				throw(message="The property you requested #expression.property# is not a valid property in the #arguments.entityName# entity",
					  detail="Valid properties are #arrayToList( realPropertyNames )#",
					  type="BaseORMService.InvalidEntityProperty");
			}
			// now save the actual property name to the passed in property to avoid case issues with Hibernate
			expression.property = realPropertyNames[ realPropertyIndex ];
			// Remove property now from method expression
			thisGrammar = REReplacenoCase( thisGrammar, "#expression.property#", "" );
			
			// Get Conditional Operator now if it exists, else it defaults to EQ
			if( len( thisGrammar ) ){
				// Match the conditional statement
				var conditional = REMatchNoCase( "(#ALL_CONDITIONALS_REGEX#)$", thisGrammar );
				// Did we match?
				if( arrayLen( conditional ) ){
					expression.conditional = conditional[ 1 ];
					expression.sql = CONDITIONALS_SQL_MAP[ expression.conditional ];
				}
				else{
					throw(message="Invalid conditional statement in method expression: #thisGrammar#",
						  detail="Valid Conditionals: #ALL_CONDITIONALS#",
						  type="BaseORMService.InvalidConditionalExpression");
				}
			}
			
			// Add to expressions
			arrayAppend( HQLExpressions, expression );
		}
		// end compile grammars
		
		// Build the HQL
		var where = "";
		// Begin building the hql statement with or without counts
		var hql = "";
		if( arguments.isCounting ){
			hql &= "select count(id) ";
		}
		hql &= "from " & arguments.entityName;	
		
		var paramIndex = 1;
		for( var thisExpression in HQLExpressions ){
			if( len( where ) ){
				where = "#where# #thisExpression.operator# ";
			}
			switch( trim( thisExpression.conditional ) ){
				case "isNull" : case "isNotNull" : { 
					where = "#where# #thisExpression.property# #thisExpression.sql#";
					break; 
				}
				case "between" : case "notBetween" : {
					where = "#where# #thisExpression.property# #thisExpression.sql# :param#paramIndex++# and :param#paramIndex++#";
					break;
				}
				case "inList" : case "notInList" : {
					where = "#where# #thisExpression.property# #thisExpression.sql# (:param#paramIndex++#)";
					// Verify if the param is an array collection
					if( isSimpleValue( params["param#paramIndex-1#"] ) ){
						params["param#paramIndex-1#"] = listToArray( params["param#paramIndex-1#"] );
					}
					break;
				}
				default:{
					where = "#where# #thisExpression.property# #thisExpression.sql# :param#paramIndex++#";	
					break;	
				}
			}
		}	
		
		// Finalize the HQL
		return hql & " where #where#";
	}
	
	/**
	* A method for finding entity's dynamically, for example:
	* findByLastNameAndFirstName('User', 'Tester', 'Test');
	* findByLastNameOrFirstName('User', 'Tester', 'Test')
	* findAllByLastNameIsNotNull('User');
	* The first argument must be the 'entityName' or a named agument called 'entityname'
	* Any argument which is a structure will be used as options for the query: { ignorecase, maxresults, offset, cacheable, cachename, timeout }
	*/
	any function findDynamically(string missingMethodName, struct missingMethodArguments, boolean unique=true, boolean isCounting=false){
		var method 			= arguments.missingMethodName;
		var args   			= arguments.missingMethodArguments;
		var dynamicCacheKey = hash( arguments.toString() );
		var hql				= "";
		
		// setup the params to bind from the arguments, and also distinguish the incoming query options
		var params 	= {};
		var options = {};
		// Verify entityName, if does not exist, use the first argument.
		if( !structKeyExists(args, "entityName" ) ){
			arguments.entityName = args[ 1 ];
			// Remove it like a mighty ninja
			structDelete( args, "1" );
		}
		else{
			arguments.entityName = args.entityName;
			// Remove it like a mighty ninja
			structDelete( args, "entityName" );
		}
		// Process arguments to binding parameters, we use named as they bind better in HQL, go figure
		for(var i=1; i LTE ArrayLen( args ); i++){
			// Check if the argument is a structure, if it is, then these are the query options
			if( isStruct( args[ i ] ) ){
				options = args[ i ];
			}
			// Normal params
			else{
				params[ "param#i#" ] = args[ i ];
			}
		}
		// Check if we have already the signature for this request
		if( structKeyExists( HQLDynamicCache, dynamicCacheKey ) ){
			hql = HQLDynamicCache[ dynamicCacheKey ];
		}
		else{
			arguments.params = params;
			hql = compileHQLFromDynamicMethod( argumentCollection=arguments );
			// store compiled HQL
			HQLDynamicCache[ dynamicCacheKey ] = hql;
		}
		
		//results struct used for testing
		var results = structNew();
		results.method = method;
		results.params = params;
		results.options = options;
		results.unique = arguments.unique;
		results.isCounting = arguments.isCounting;
		results.hql = hql;
		
		//writeDump( ORMExecuteQuery( hql, params, arguments.unique, options) );
		//writeDump(results);abort;
		
		// execute query as unique for the count
		try{
			return ORMExecuteQuery( hql, params, arguments.unique, options);
		}
		catch(Any e){
			if( findNoCase("org.hibernate.NonUniqueResultException", e.detail) ){
		 		throw(message=e.message & e.detail,
					  detail="If you do not want unique results then use 'FindAllBy' instead of 'FindBy'",
				  	  type="ORMService.NonUniqueResultException");
			}
			throw(message=e.message & e.detail, type="BaseORMService.HQLQueryException", detail="Dynamic compiled query: #results.toString()#");
		}
		
	}
	

	/**
	* Returns the key (id field) of a given entity, either simple or composite keys.
	* If the key is a simple pk then it will return a string, if it is a composite key then it returns an array
	*/
	any function getKey(required string entityName){
		var hibernateMD =  orm.getSessionFactory(orm.getEntityDatasource(arguments.entityName)).getClassMetaData(arguments.entityName);

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
	* Returns the Property Names of the entity via hibernate metadata
	*/
	array function getPropertyNames(required string entityName){
		return orm.getSessionFactory( orm.getEntityDatasource(arguments.entityName) ).getClassMetaData( arguments.entityName ).getPropertyNames();
	}

	/**
	* Returns the table name that the current entity string belongs to via hibernate metadata
	*/
	string function getTableName(required string entityName){
		return orm.getSessionFactory( orm.getEntityDatasource(arguments.entityName) ).getClassMetadata( arguments.entityName ).getTableName();
	}

	/**
 	* Returns the entity name from a given entity object via session lookup or if new object via metadata lookup
	*/
	function getEntityGivenName(required entity) {
		if( sessionContains( arguments.entity ) ){
 			return orm.getSession( orm.getEntityDatasource(arguments.entity) ).getEntityName( entity );
 		}

 		// else long approach
 		var md = getMetadata( arguments.entity );
 		if( structKeyExists(md, "entityname") ){ return md.entityname; }
 		return listLast( md.name, ".");
 	}

	/**
	* Coverts an ID, list of ID's, or array of ID's values to the proper java type
	* The method returns a coverted array of ID's
	*/
	any function convertIDValueToJavaType(required entityName, required id){
		var hibernateMD = orm.getSessionFactory(orm.getEntityDatasource(arguments.entityName)).getClassMetaData(arguments.entityName);

		if(isDefined("hibernateMD") and not hibernateMD.getIdentifierType().isComponentType() ){
			//id conversion to array
			if( isSimpleValue(arguments.id) ){
				arguments.id = listToArray(arguments.id);
			}

			// Convert to hibernate native types
			for (var i=1; i lte arrayLen(arguments.id); i=i+1){
				arguments.id[i] = hibernateMD.getIdentifierType().fromStringValue(arguments.id[i]);
			}
		}

		return arguments.id;
	}
	
	/**
	* Coverts a value to the correct javaType for the property passed in
	* The method returns the value in the proper Java Type
	*/
	any function convertValueToJavaType(required entityName, required propertyName, required value){
		var hibernateMD = orm.getSessionFactory(orm.getEntityDatasource(arguments.entityName)).getClassMetaData(arguments.entityName);

		return hibernateMD.getPropertyType(arguments.propertyName).fromStringValue(arguments.value);
	}

	/**
	* Get our hibernate org.hibernate.criterion.Restrictions proxy object
	*/
	public any function getRestrictions(){
		return restrictions;
	}

	/**
	* Do a hibernate criteria based query with projections. You must pass an array of criterion objects by using the Hibernate Restrictions object that can be retrieved from this service using ''getRestrictions()''.  The Criteria interface allows to create and execute object-oriented queries. It is powerful alternative to the HQL but has own limitations. Criteria Query is used mostly in case of multi criteria search screens, where HQL is not very effective.
	*/
	public any function criteriaQuery(required entityName,
									  array criteria=ArrayNew(1),
					  		 		  string sortOrder="",
					  		 		  numeric offset=0,
					  				  numeric max=0,
					  		 		  numeric timeout=0,
					  		 		  boolean ignoreCase=false,
					  		 		  boolean asQuery=getDefaultAsQuery()){
		// create Criteria query object
		var qry = createCriteriaQuery(arguments.entityName, arguments.criteria);

		// Setup listing options
		if( arguments.offset NEQ 0 ){
			qry.setFirstResult(arguments.offset);
		}
		if(arguments.max GT 0){
			qry.setMaxResults(arguments.max);
		}
		if( arguments.timeout NEQ 0 ){
			qry.setTimeout(arguments.timeout);
		}

		// Caching
		if( getUseQueryCaching() ){
			qry.setCacheRegion(getQueryCacheRegion());
			qry.setCacheable(true);
		}

		// Sort Order Case
		if( Len(Trim(arguments.sortOrder)) ){
			var sortTypes = listToArray(arguments.sortOrder);
			for(var sortType in sortTypes) {
				var sortField = Trim(ListFirst(sortType," "));
				var sortDir = "ASC";
				var Order = CreateObject("java","org.hibernate.criterion.Order");

				if(ListLen(sortType," ") GTE 2){
					sortDir = ListGetAt(sortType,2," ");
				}

				switch(UCase(sortDir)) {
					case "DESC":
						var orderBy = Order.desc(sortField);
						break;
					default:
						var orderBy = Order.asc(sortField);
						break;
				}
				// ignore case
				if(arguments.ignoreCase){
					orderBy.ignoreCase();
				}
				// add order to query
				qry.addOrder(orderBy);
			}
		}

		// Get listing
		var results = qry.list();

		// Is it Null? If yes, return empty array
		if( isNull(results) ){ results = []; }

		// Objects or Query?
		if( arguments.asQuery ){
			results = EntityToQuery(results);
		}

		return results;
	}

	/**
	* Get the record count using hibernate projections and criterion for specific queries
	*/
	numeric function criteriaCount(required entityName, array criteria=ArrayNew(1)){
		// create a new criteria query object
		var qry = createCriteriaQuery(arguments.entityName, arguments.criteria);
		var projections = CreateObject("java","org.hibernate.criterion.Projections");

		qry.setProjection( projections.rowCount() );

		return qry.uniqueResult();
	}

	/**
	* Get a brand new criteria builder object
	* @entityName The name of the entity to bind this criteria query to
	* @useQueryCaching Activate query caching for the list operations
	* @queryCacheRegion The query cache region to use, which defaults to criterias.{entityName}
	* @defaultAsQuery To return results as queries or array of objects or reports, default is array as results might not match entities precisely
	*/
	any function newCriteria(
		required string entityName,
		boolean useQueryCaching=false,
		string queryCacheRegion=""
	){
		
		// mix in yourself as a dependency
		arguments.ORMService = this;
		// create new criteria builder
		return new CriteriaBuilder( argumentCollection=arguments );
	}

	/**
	* Create a new hibernate criteria object according to entityname and criterion array objects
	*/
	private any function createCriteriaQuery(required entityName, array criteria=ArrayNew(1)){
		var qry = orm.getSession(orm.getEntityDatasource(arguments.entityName)).createCriteria( arguments.entityName );

		for(var i=1; i LTE ArrayLen(arguments.criteria); i++) {
			if( isSimpleValue( arguments.criteria[i] ) ){
				// create criteria out of simple values for associations with alias
				qry.createCriteria( arguments.criteria[i], arguments.criteria[i] );
			}
			else{
				// add criterion
				qry.add( arguments.criteria[i] );
			}
		}

		return qry;
	}

	/**
	* My hibernate safe transaction closure wrapper
	* @method the method to closure
	* @argCollection the arguments to passthrough
	*/
	private any function $transactioned( required method, argCollection=structnew() ){
		// Are we already in a transaction?
		if( structKeyExists(request,"cbox_aop_transaction") ){
			return arguments.method(argumentCollection=arguments.argCollection);
		}

		// transaction safe call, start one
		// mark transaction began
		request["cbox_aop_transaction"] = true;
		transaction{

			try{
				// Call method
				results = arguments.method(argumentCollection=arguments.argCollection);
				// commit transaction
				transactionCommit();
			}
			catch(Any e){
				// remove pointer
				structDelete(request,"cbox_aop_transaction");
				// RollBack Transaction
				transactionRollback();
				//throw it
				rethrow;
			}

		}

		// remove pointer, out of transaction now.
		structDelete(request,"cbox_aop_transaction");
		// Results? If found, return them.
		if( NOT isNull(results) ){ return results; }

	}
}
