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
component accessors="true" extends="coldbox.system.orm.hibernate.BaseBuilder" {
	
	// The criteria values this criteria builder builds upon.
	property name="criterias" type="array";
	// The queryCacheRegion name property for all queries in this criteria object
	property name="queryCacheRegion" type="string" default="criterias.{entityName}";
	// The bit that tells the service to enable query caching, disabled by default
	property name="useQueryCaching" type="boolean" default="false";

/************************************** Constructor *********************************************/

	// Constructor
	CriteriaBuilder function init(
		required string entityName,
		boolean useQueryCaching=false,
		string queryCacheRegion="",
		required any ORMService
	){	
								  	  
		// Determine datasource for given entityName
		var orm			 = getORMUtil();
		var datasource 	 = orm.getEntityDatasource( arguments.entityName );	  
		
		// setup basebuilder with criteria query and restrictions
		super.init( entityName=arguments.entityName, 
					criteria=orm.getSession( datasource ).createCriteria( arguments.entityName ), 
					restrictions=new criterion.Restrictions(), 
					ORMService=arguments.ORMService );    
		
		// local criterion values
		variables.criterias = [];	
		// caching?
		variables.useQueryCaching = arguments.useQueryCaching;
		// caching region?
		if( len( trim( arguments.queryCacheRegion ) ) EQ 0 ){
			arguments.queryCacheRegion = "criterias.#arguments.entityName#";
		}
		variables.queryCacheRegion = arguments.queryCacheRegion;
		 
		return this;
	}

/************************************** PUBLIC *********************************************/	
	
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
		
		// process interception
		if( ORMService.getEventHandling() ){
			variables.eventManager.processState( "beforeCriteriaBuilderList", {
				"criteriaBuilder" = this
			});
		}

		// Get listing
		var results = nativeCriteria.list();

		// Is it Null? If yes, return empty array
		if( isNull(results) ){ results = []; }

		// Objects or Query?
		if( arguments.asQuery ){
			results = EntityToQuery(results);
		}

		// process interception
		if( ORMService.getEventHandling() ){
			variables.eventManager.processState( "afterCriteriaBuilderList", {
				"criteriaBuilder" = this,
				"results" = results
			});
		}
		return results;
	}
	
	// pass off arguments to higher-level restriction builder, and handle the results
	any function onMissingMethod(required string missingMethodName, required struct missingMethodArguments) {
		// get the restriction/new criteria 
		var r = createRestriction( argumentCollection=arguments );
		// switch on the object type
		switch( getMetaData( r ).name ) {
			// if it's a builder, just return this
			case 'coldbox.system.orm.hibernate.CriteriaBuilder':
				break;
			// everything else is a real restriction; add it to native criteria, then return this
			default: 
				nativeCriteria.add( r );
				
				// process interception
				if( ORMService.getEventHandling() ){
					variables.eventManager.processState( "onCriteriaBuilderAddition", {
						"type" = "Restriction",
						"criteriaBuilder" = this
					});
				}

				break;
		}
		return this;
	}
	
	// create an instance of a detached criteriabuilder that can be added, like criteria, to the main criteria builder
	any function createSubcriteria( required string entityName, string alias="" ) {
		// create detached builder
		arguments.ORMService = variables.ORMService;
		var subcriteria = new DetachedCriteriaBuilder( argumentCollection=arguments );
		
		// process interception
		if( ORMService.getEventHandling() ){
			variables.eventManager.processState( "onCriteriaBuilderAddition", {
				"type" = "Subquery",
				"criteriaBuilder" = this
			});
		}

		// return the subscriteria instance so we can keep chaining methods to it, but rooted to the subcriteria
		return subcriteria;
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
		if( SQLHelper.canLogLimitOffset() ) {
			
			// process interception
			if( ORMService.getEventHandling() ){
				variables.eventManager.processState( "onCriteriaBuilderAddition", {
					"type" = "Offset",
					"criteriaBuilder" = this
				});
			}

		}
		return this;
	}
	
	// Set a limit upon the number of objects to be retrieved.
	any function maxResults(required numeric maxResults){
		nativeCriteria.setMaxResults( javaCast("int", arguments.maxResults) );
		if( SQLHelper.canLogLimitOffset() ) {
			
			// process interception
			if( ORMService.getEventHandling() ){
				variables.eventManager.processState( "onCriteriaBuilderAddition", {
					"type" = "Max",
					"criteriaBuilder" = this
				});
			}

		}
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
	* Get the record count using hibernate projections for the given criterias
	* @propertyName The name of the property to do the count on or do it for all row results instead
	*/
	numeric function count(propertyName=""){
		// process interception
		if( ORMService.getEventHandling() ){
			variables.eventManager.processState( "beforeCriteriaBuilderCount", {
				"criteriaBuilder" = this
			});
		}
		// else project on the local criterias
		if( len( arguments.propertyName ) ){
			nativeCriteria.setProjection( this.projections.countDistinct( arguments.propertyName ) );
		}
		else{
			nativeCriteria.setProjection( this.projections.distinct( this.projections.rowCount() ) );
		}

		// process interception
		if( ORMService.getEventHandling() ){
			variables.eventManager.processState( "onCriteriaBuilderAddition", {
				"type" = "Count",
				"criteriaBuilder" = this
			});
		}

		var results = nativeCriteria.uniqueResult();
		// clear count like a ninja, so we can reuse this criteria object.
		nativeCriteria.setProjection( javacast("null","") );
		nativeCriteria.setResultTransformer( this.ROOT_ENTITY );

		// process interception
		if( ORMService.getEventHandling() ){
			variables.eventManager.processState( "afterCriteriaBuilderCount", {
				"criteriaBuilder" = this,
				"results" = results
			});
		}

		return results;
	}
	
	/************************************** PRIVATE *********************************************/
	
	/**
	* Get ORM Util
	*/
	private function getORMUtil() {
		return new coldbox.system.orm.hibernate.util.ORMUtilFactory().getORMUtil();
	}
	
}
