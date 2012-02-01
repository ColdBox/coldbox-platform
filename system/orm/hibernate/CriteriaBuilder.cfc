/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano
Description :
	This is the ColdBox Criteria Builder Class that helps you create a nice programmatic
	DSL language for building hibernate criteria queries and projections without the added
	complexities.
	
We also setup several public properties:

this.PROJECTIONS - Maps to the Hibernate projections class: org.hibernate.criterion.Projections
this.RESTRICTIONS - Maps to our ColdBox restrictions class: coldbox.system.orm.hibernate.criterion.Restrictions

Join Types
this.FULL_JOIN 
	Specifies joining to an entity based on a full join.
this.INNER_JOIN 
	Specifies joining to an entity based on an inner join.
this.LEFT_JOIN 
	Specifies joining to an entity based on a left outer join.

Result Transformers
this.ALIAS_TO_ENTITY_MAP 
	Each row of results is a Map from alias to entity instance
this.DISTINCT_ROOT_ENTITY 
	Each row of results is a distinct instance of the root entity
this.PROJECTION 
	This result transformer is selected implicitly by calling setProjection()
this.ROOT_ENTITY 
	Each row of results is an instance of the root entity
	
*/
import coldbox.system.orm.hibernate.*;
component accessors="true"{
	
	// The criteria values this criteria builder builds upon.
	property name="criterias" type="array";
	// The native criteria object
	property name="nativeCriteria"  type="any";
	// The entity name this criteria builder is binded to
	property name="entityName" type="string";
	// The queryCacheRegion name property for all queries in this criteria object
	property name="queryCacheRegion" type="string" default="criterias.{entityName}";
	// The bit that tells the service to enable query caching, disabled by default
	property name="useQueryCaching" type="boolean" default="false";

/************************************** Constructor *********************************************/

	// Constructor
	CriteriaBuilder function init(required string entityName,
								  boolean useQueryCaching=false,
								  string queryCacheRegion=""){	
								  	  
		// Determine datasource for given entityName
		var orm			= getORMUtil();
		var datasource 	= orm.getEntityDatasource( arguments.entityName );	  
									
		// restrictions linkage
		this.restrictions = new criterion.Restrictions();
		// java projections linkage
		this.projections = CreateObject("java","org.hibernate.criterion.Projections");
		
		// local criterion values
		setCriterias( [] );
		// hibernate criteria query setup
		setNativeCriteria( orm.getSession( datasource ).createCriteria( arguments.entityName ) );
		// set entity name
		setEntityName( arguments.entityName );
		
		// Setup pseudo-static join types and transformer types:
		this.ALIAS_TO_ENTITY_MAP 	= nativeCriteria.ALIAS_TO_ENTITY_MAP;
		this.DISTINCT_ROOT_ENTITY 	= nativeCriteria.DISTINCT_ROOT_ENTITY;
		this.FULL_JOIN 				= nativeCriteria.FULL_JOIN;
		this.INNER_JOIN 			= nativeCriteria.INNER_JOIN;
		this.LEFT_JOIN 				= nativeCriteria.LEFT_JOIN;
		this.PROJECTION 			= nativeCriteria.PROJECTION;
		this.ROOT_ALIAS 			= nativeCriteria.ROOT_ALIAS;
		this.ROOT_ENTITY 			= nativeCriteria.ROOT_ENTITY;
		
		// caching?
		setUseQueryCaching( arguments.useQueryCaching );
		// caching region?
		if( len(trim(arguments.queryCacheRegion)) EQ 0 ){
			arguments.queryCacheRegion = "criterias.#arguments.entityName#";
		}
		setQueryCacheRegion( arguments.queryCacheRegion );
		 
		return this;
	}

/************************************** PUBLIC *********************************************/	
	
	// setter override
	any function setNativeCriteria(required any criteria){
		variables.nativeCriteria = arguments.criteria;
		return this;
	}
		
	/**
	* Add an ordering to the result set, you can add as many as you like
	* @property The name of the property to order on
	* @sortOrder The order type: asc or desc, defaults to asc
	* @ignoreCase Wether to ignore case or not, defaults to false
	*/
	any function order(required string property,string sortDir="asc",boolean ignoreCase=false){
		var order 	= CreateObject("java","org.hibernate.criterion.Order");
		var orderBy = "";
		// direction
		switch(UCase(arguments.sortDir)) {
			case "DESC":
				orderBy = order.desc(arguments.property);
				break;
			default:
				orderBy = order.asc(arguments.property);
				break;
		}
		// ignore case
		if(arguments.ignoreCase){
			orderBy.ignoreCase();
		}
		nativeCriteria.addOrder( orderBy );
		return this;
	}
	
	/**
	* Execute the criteria queries you have defined and return the results, you can pass optional parameters or define them via our methods
	*/
	any function list(numeric offset=0,
	  				  numeric max=0,
	  		 		  numeric timeout=0,
	  		 		  string  sortOrder="",
	  		 		  boolean ignoreCase=false,
	  		 		  boolean asQuery=false){
	  		 		  	 
		// Setup listing options
		if( arguments.offset NEQ 0 ){
			firstResult(arguments.offset);
		}
		if(arguments.max GT 0){
			maxResults(arguments.max);
		}
		if( arguments.timeout NEQ 0 ){
			this.timeout(arguments.timeout);
		}

		// Caching
		if( getUseQueryCaching() ){
			cache(true,getQueryCacheRegion());
		}

		// Sort Order 
		if( Len(Trim(arguments.sortOrder)) ){
			normalizeOrder( arguments.sortOrder, arguments.ignoreCase );
		}

		// Get listing
		var results = nativeCriteria.list();

		// Is it Null? If yes, return empty array
		if( isNull(results) ){ results = []; }

		// Objects or Query?
		if( arguments.asQuery ){
			results = EntityToQuery(results);
		}

		return results;
	}
	
	/**
	* Join an association, assigning an alias to the joined association.
	* @associationName The name of the association property
	* @alias The alias to use for this association property on restrictions
	* @jointType The hibernate join type to use, by default it uses an inner join. Available as properties: criteria.FULL_JOIN, criteria.INNER_JOIN, criteria.LEFT_JOIN
	*/
	any function createAlias(required string associationName, required string alias, numeric joinType){
		// No Join type
		if( NOT structKeyExists(arguments,"joinType") ){
			nativeCriteria.createAlias( arguments.associationName, arguments.alias );
			return this;
		}
		// With Join Type
		nativeCriteria.createAlias( arguments.associationName, arguments.alias, arguments.joinType );
		return this;
	}
	
	/**
	* Create a new Criteria, "rooted" at the associated entity and using an Inner Join
	* @associationName The name of the association property to root the restrictions with
	* @jointType The hibernate join type to use, by default it uses an inner join. Available as properties: criteria.FULL_JOIN, criteria.INNER_JOIN, criteria.LEFT_JOIN
	*/
	any function createCriteria(required string associationName,numeric joinType){
		// No Join type
		if( NOT structKeyExists(arguments,"joinType") ){
			nativeCriteria = nativeCriteria.createCriteria( arguments.associationName );
			return this;
		}
		
		// With Join Type
		nativeCriteria = nativeCriteria.createCriteria( arguments.associationName, arguments.joinType );
		return this;
	}
	
	// Enable caching of this query result, provided query caching is enabled for the underlying session factory.
	any function cache(required boolean cache=true,string cacheRegion){
		nativeCriteria.setCacheable( javaCast("boolean", arguments.cache) );
		if( structKeyExists(arguments,"cacheRegion") ){
			nativeCriteria.setCacheRegion( arguments.cacheRegion );
		}
		return this;
	}
	
	// Set the name of the cache region to use for query result caching.
	any function cacheRegion(required string cacheRegion){
		nativeCriteria.setCacheRegion( arguments.cacheRegion );
		return this;
	}
	
	// Set a fetch size for the underlying JDBC query.
	any function fetchSize(required numeric fetchSize){
		nativeCriteria.setFetchSize( javaCast("int", arguments.fetchSize) );
		return this;
	}
	
	// Set the first result to be retrieved or the offset integer
	any function firstResult(required numeric firstResult){
		nativeCriteria.setFirstResult( javaCast("int", arguments.firstResult) );
		return this;
	}
	
	// Set a limit upon the number of objects to be retrieved.
	any function maxResults(required numeric maxResults){
		nativeCriteria.setMaxResults( javaCast("int", arguments.maxResults) );
		return this;
	}
	
	// Set the read-only/modifiable mode for entities and proxies loaded by this Criteria, defaults to readOnly=true
	any function readOnly(boolean readOnly=true){
		nativeCriteria.setReadOnly( javaCast("boolean", arguments.readOnly) );
		return this;
	}
	
	// Set a timeout for the underlying JDBC query.
	any function timeout(required numeric timeout){
		nativeCriteria.setTimeout( javaCast("int", arguments.timeout) );
		return this;
	}
	
	// Convenience method to return a single instance that matches the built up criterias query, or null if the query returns no results.
	any function get(){
		return nativeCriteria.uniqueResult();
	}
	
	/**
	* Add a restriction to constrain the results to be retrieved
	* @criterion A single or array of criterions to add
	*/
	any function add(required any criterion){
		if( NOT isArray(arguments.criterion) ){
			arguments.criterion = [ arguments.criterion ];	
		}
		for(var i=1; i LTE ArrayLen(arguments.criterion); i++) {
			nativeCriteria.add( arguments.criterion[i] );
		}		
		return this;
	}
	
	/**
	* Sets a valid hibernate result transformer: org.hibernate.transform.ResultTransform to use on the results
	* @resultTransformer a custom result transform or you can use the included ones: criteria.ALIAS_TO_ENTITY_MAP, criteria.DISTINCT_ROOT_ENTITY, criteria.PROJECTION, criteria.ROOT_ENTITY.
	*/
	any function resultTransformer(any resultTransformer){
		nativeCriteria.setResultTransformer( arguments.resultTransformer );
		return this;
	}
	
	/**
	* Get the record count using hibernate projections for the given criterias
	*/
	numeric function count(){
		// else project on the local criterias
		nativeCriteria.setProjection( this.projections.rowCount() );
		var results = nativeCriteria.uniqueResult();
		// clear count like a ninja, so we can reuse this criteria object.
		nativeCriteria.setProjection( javacast("null","") );
		nativeCriteria.setResultTransformer( this.ROOT_ENTITY );
		return results;
	}
	
	/**
	* Setup a single or a projection list via native projections class: criteria.projections
	*/
	any function setProjection(any projection){
		nativeCriteria.setProjection( arguments.projection );
		return this;
	}
	
	/**
	* Setup projections for this criteria query, you can pass one or as many projection arguments as you like.
	* The majority of the arguments take in the property name to do the projection on, which will also use that as the alias for the column
	* or you can pass an alias after the property name separated by a : Ex: projections(avg="balance:avgBalance")
	* The alias on the projected value can be referred to in restrictions or orderings.
	* Please also note that the resulting array locations are done in alphabetical order of the arguments.
	* @avg The name of the property to avg or a list or array of property names
	* @count The name of the property to count or a list or array of property names
	* @countDistinct The name of the property to count distinct or a list or array of property names
	* @distinct The name of the property to do a distinct on, this can be a single property name a list or an array of property names
	* @groupProperty The name of the property to group by or a list or array of property names
	* @id The projected identifier value 
	* @max The name of the property to max or a list or array of property names
	* @min The name of the property to min or a list or array of property names
	* @property The name of the property to do a projected value on or a list or array of property names
	* @rowCount Do a row count on the criteria
	* @sum The name of the property to sum or a list or array of property names
	*/
	any function withProjections(string avg,string count,string countDistinct,any distinct, string groupProperty,boolean id,string max,string min,string property,boolean rowCount,string sum){
		// create our projection list
		var projectionList = this.PROJECTIONS.projectionList();
		var excludes = "id,rowCount,distinct";
		
		// iterate and add dynamically if the incoming argument exists, man, so much easier if we had closures.
		for(var pType in arguments){
			if( structKeyExists(arguments,pType) AND NOT listFindNoCase(excludes, pType) ){
				addProjection(arguments[pType], lcase(pType), projectionList);
			}
		}
		
		// id
		if( structKeyExists(arguments,"id") ){
			projectionList.add( this.PROJECTIONS.id() );
		}
		
		// rowCount
		if( structKeyExists(arguments,"rowCount") ){
			projectionList.add( this.PROJECTIONS.rowCount() );
		}
		
		// distinct
		if( structKeyExists(arguments,"distinct") ){
			addProjection(arguments.distinct,"property",projectionList);
			projectionList = this.PROJECTIONS.distinct(projectionList);
		}
		
		nativeCriteria.setProjection( projectionList );
		return this;
	}

	// funnel missing methods to restrictions.
	any function onMissingMethod(required string missingMethodName, required struct missingMethodArguments){
		
		// check for with{association} dynamic finder: 
		if( left(arguments.missingMethodName,4) eq "with" ){
			var args = { 
				associationName = right( arguments.missingMethodName, len(arguments.missingMethodName)-4)
			};
			// join type
			if( structKeyExists(arguments.missingMethodArguments,"1") ){
				args.joinType = arguments.missingMethodArguments[1];
			}
			if( structKeyExists(arguments.missingMethodArguments,"joinType") ){
				args.joinType = arguments.missingMethodArguments.joinType;
			}
			// create the dynamic criteria
			return createCriteria(argumentCollection=args);
		}
		
		// funnel missing methods to restrictions and append to criterias
		var r = evaluate("this.restrictions.#arguments.missingMethodName#(argumentCollection=arguments.missingMethodArguments)");
		nativeCriteria.add( r );
		
		return this;
	}
	
	/************************************** PRIVATE *********************************************/
	
	// Simplified additions of projections
	private function addProjection(any propertyName,any projectionType,any projectionList){
		// inflate to array
		if( isSimpleValue(arguments.propertyName) ){ arguments.propertyName = listToArray(arguments.propertyName); }
		// iterate array and add projections
		for(var thisP in arguments.propertyName){
			// add projection
			arguments.projectionList.add( evaluate("this.PROJECTIONS.#arguments.projectionType#( listFirst(thisP,':') )"), listLast(thisP,":") );
		}
	}
	
	// Normalize Sort orders
	private void function normalizeOrder(required string sortOrder,required boolean ignoreCase){
		
		var sortLen = listLen(arguments.sortOrder);
		
		for(var x=1; x lte sortLen; x++){
			var thisSort = listGetAt(arguments.sortOrder,x);
			var sortField = Trim(ListFirst(thisSort," "));
			var sortDir = "ASC";
			if(ListLen(thisSort," ") GTE 2){
				sortDir = ListGetAt(thisSort,2," ");
			}
			// add it to our ordering
			order(sortField,sortDir,arguments.ignoreCase);
		}
	}
	
	/**
	* Get ORM Util
	*/
	private function getORMUtil() {
		return new coldbox.system.orm.hibernate.util.ORMUtilFactory().getORMUtil();
	}
	
}
