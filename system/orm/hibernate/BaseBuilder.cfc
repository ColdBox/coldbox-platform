/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Description: BaseBuilder is a common funnel through which both CriteriaBuilder and DetachedCriteriaBuilder can be run
			 It exposes properties and methods that both builders share in common, for a singular mechanism for building 
			 criteria queries and subqueries
			 
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
import org.hibernate.*;
component accessors="true"{
			
	/** 
	* The native criteria object
	*/
	property name="nativeCriteria"  type="any";
	/** 
	* The entity name this criteria builder is binded to
	*/
	property name="entityName" 		type="string";
	/** 
	* The bit that determines if we are tracking SQL
	*/
	property name="SQLLoggerActive" type="boolean" default="false";
	/** 
	* The system event manager
	*/
	property name="eventManager"  	type="any";

/************************************** Constructor *********************************************/

	// Constructor
	BaseBuilder function init( 
		required string entityName, 
		required any criteria, 
		required any restrictions,
		required any ORMService
	){				 
	
		// java projections linkage
		this.projections = CreateObject("java","org.hibernate.criterion.Projections");
		// restrictions linkage
		this.restrictions = arguments.restrictions;
		
		// hibernate criteria query setup - will be either CriteriaBuilder or DetachedCriteriaBuilder
		variables.nativeCriteria = arguments.criteria;
		// set entity name
		variables.entityName = arguments.entityName;
		// Link to orm service
		variables.ORMService = arguments.ORMService;
		// Link to system event handler
		variables.eventManager = arguments.ORMService.getORMEventHandler().getEventManager();
		// set sql logger usage
		variables.SQLLoggerActive = false;
		// add SQL Helper
		variables.SQLHelper = new coldbox.system.orm.hibernate.sql.SQLHelper( this );
		
		// Setup pseudo-static join types and transformer types:
		this.ALIAS_TO_ENTITY_MAP	= nativeCriteria.ALIAS_TO_ENTITY_MAP;
		this.DISTINCT_ROOT_ENTITY	= nativeCriteria.DISTINCT_ROOT_ENTITY;
		this.FULL_JOIN				= nativeCriteria.FULL_JOIN;
		this.INNER_JOIN				= nativeCriteria.INNER_JOIN;
		this.LEFT_JOIN				= nativeCriteria.LEFT_JOIN;
		this.PROJECTION				= nativeCriteria.PROJECTION;
		this.ROOT_ALIAS				= nativeCriteria.ROOT_ALIAS;
		this.ROOT_ENTITY			= nativeCriteria.ROOT_ENTITY;
		
		return this;
	}

/************************************** PUBLIC *********************************************/   
	
	// setter override
	any function setNativeCriteria( required any criteria ){
		variables.nativeCriteria = arguments.criteria;
		return this;
	}

	// setter override
	any function setEntityName( required any entityName ){
		variables.entityName = arguments.entityName;
		return this;
	}
		
	/**
	* Add an ordering to the result set, you can add as many as you like
	* @property The name of the property to order on
	* @sortOrder The order type: asc or desc, defaults to asc
	* @ignoreCase Wether to ignore case or not, defaults to false
	*/
	any function order( required string property, string sortDir="asc", boolean ignoreCase=false ){
		var order   = CreateObject( "java", "org.hibernate.criterion.Order" );
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
		
		// process interception
		if( ORMService.getEventHandling() ){
			variables.eventManager.processState( "onCriteriaBuilderAddition", {
				"type" = "Order",
				"criteriaBuilder" = this
			});
		}
		return this;
	}
	
	/**
	* Join an association, assigning an alias to the joined association.
	* @associationName The name of the association property
	* @alias The alias to use for this association property on restrictions
	* @jointType The hibernate join type to use, by default it uses an inner join. Available as properties: criteria.FULL_JOIN, criteria.INNER_JOIN, criteria.LEFT_JOIN
	*/
	any function createAlias( required string associationName, required string alias, numeric joinType ){
		// No Join type
		if( NOT structKeyExists(arguments,"joinType") ){
			// create alias
			nativeCriteria.createAlias( arguments.associationName, arguments.alias );

			// announce
			if( ORMService.getEventHandling() ){
				variables.eventManager.processState( "onCriteriaBuilderAddition", {
					"type" = "Alias",
					"criteriaBuilder" = this
				});
			}
				
			return this;
		}
		// With Join Type
		nativeCriteria.createAlias( arguments.associationName, arguments.alias, arguments.joinType );
		
		// announce
		if( ORMService.getEventHandling() ){
			variables.eventManager.processState( "onCriteriaBuilderAddition", {
				"type" = "Alias w/Join Type",
				"criteriaBuilder" = this
			});
		}

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
			// log sql if enabled
			if( canLogSql() ) {
				logSQL( "New Criteria" );
			}
			return this;
		}
		
		// With Join Type
		nativeCriteria = nativeCriteria.createCriteria( arguments.associationName, arguments.joinType );
		
		// announce
		if( ORMService.getEventHandling() ){
			variables.eventManager.processState( "onCriteriaBuilderAddition", {
				"type" = "New Criteria w/Join Type",
				"criteriaBuilder" = this
			});
		}

		return this;
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
	* Setup a single or a projection list via native projections class: criteria.projections
	*/
	any function setProjection(any projection){
		// set projection 
		nativeCriteria.setProjection( arguments.projection );
		
		// announce
		if( ORMService.getEventHandling() ){
			variables.eventManager.processState( "onCriteriaBuilderAddition", {
				"type" = "Projection",
				"criteriaBuilder" = this
			});
		}

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
	* @sqlProjection Do a projection based on arbitrary SQL string
	* @sqlGroupProjection Do a projection based on arbitrary SQL string, with grouping
	* @detachedSQLProjection Do a projection based on a DetachedCriteria builder config
	*/
	any function withProjections(
		string avg,
		string count,
		string countDistinct,
		any distinct, 
		string groupProperty,
		boolean id,
		string max,
		string min,
		string property,
		boolean rowCount,
		string sum,
		any sqlProjection,
		any sqlGroupProjection,
		any detachedSQLProjection
	){
		// create our projection list
		var projectionList = this.PROJECTIONS.projectionList();
		var excludes = "id,rowCount,distinct,sqlProjection,sqlGroupProjection,detachedSQLProjection";
		
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
		
		// detachedSQLProjection
		if( structKeyExists( arguments, "detachedSQLProjection" ) ) {
			// allow single or arrary of detachedSQLProjection
			var projectionCollection = !isArray( arguments.detachedSQLProjection ) ? [ arguments.detachedSQLProjection ] : arguments.detachedSQLProjection;
			// loop over array of detachedSQLProjections
			for( projection in projectionCollection ) {
				projectionList.add( projection.createDetachedSQLProjection() );
			}
		}

		// sqlProjection
		if( structKeyExists( arguments, "sqlProjection" ) ) {
			// allow for either an array of sqlProjections, or a stand-alone config for one
			var sqlargs = !isArray( arguments.sqlProjection ) ? [ arguments.sqlProjection ] : arguments.sqlProjection;
			// loop over sqlProjections
			for( var projection in sqlargs ) {
				var projectionArgs = prepareSQLProjection( projection );
				projectionList.add( this.PROJECTIONS.sqlProjection( projectionArgs.sql, projectionArgs.alias, projectionArgs.types ) );
			}
			
		}
		
		// sqlGroupProjection
		if( structKeyExists( arguments, "sqlGroupProjection" ) ) {
			// allow for either an array of sqlGroupProjections, or a stand-alone config for one
			var sqlargs = !isArray( arguments.sqlGroupProjection ) ? [ arguments.sqlGroupProjection ] : arguments.sqlGroupProjection;
			// loop over sqlGroupProjections
			for( var projection in sqlargs ) {
				var projectionArgs = prepareSQLProjection( projection );
				projectionList.add( this.PROJECTIONS.sqlGroupProjection( projectionArgs.sql, projectionArgs.group, projectionArgs.alias, projectionArgs.types ) );
			}
		}
		// add all the projections
		nativeCriteria.setProjection( projectionList );

		// announce
		if( ORMService.getEventHandling() ){
			variables.eventManager.processState( "onCriteriaBuilderAddition", {
				"type" = "Projection",
				"criteriaBuilder" = this
			});
		}

		return this;
	}

	/**
	* Coverts an ID, list of ID's, or array of ID's values to the proper java type
	* The method returns a coverted array of ID's
	*/
	any function convertIDValueToJavaType(required id){
		arguments.entityName = variables.entityName;
		return new BaseORMService().convertIDValueToJavaType(argumentCollection=arguments);
	}
	
	/**
	* Coverts a value to the correct javaType for the property passed in
	* The method returns the value in the proper Java Type
	*/
	any function convertValueToJavaType(required propertyName, required value){
		arguments.entityName = variables.entityName;
		return new BaseORMService().convertValueToJavaType(argumentCollection=arguments);
	}
	
	/**
	 * Returns the SQL string that will be prepared for the criteria object at the time of request
	 * @executable {Boolean} Whether or not to do query param replacements on returned SQL string 
	 * return string
	 */
	public string function getSQL( required boolean returnExecutableSql=false, required boolean formatSql=true ) {
		return SQLHelper.getSQL( argumentCollection=arguments );
	}

	/** 
	 * Gets the positional SQL parameter values from the criteria query
	 * return array
	 */
	public array function getPositionalSQLParameterValues() {
		return SQLHelper.getPositionalSQLParameterValues();
	}

	/**
	 * Gets positional SQL parameter types from the criteria query
	 * @simple {Boolean} Whether to return a simply array or full objects
	 * return any
	 */
	public any function getPositionalSQLParameterTypes( required boolean simple=true ) {
		return SQLHelper.getPositionalSQLParameterTypes( argumentCollection=arguments );
	}

	/**
	 * Returns a formatted array of parameter value and types
	 * return array
	 */
	public array function getPositionalSQLParameters() {
		return SQLHelper.getPositionalSQLParameters();
	}

	/**
	 * Retrieves the SQL Log
	 * return Array
	 */
	public array function getSQLLog() {
		return SQLHelper.getLog();
	}

	/**
	 * Triggers CriteriaBuilder to start internally logging the state of SQL at each iterative build
	 * @returnExecutableSql {Boolean} Whether or not to return sql with query params replaced with positional values
	 * @formatSql {Boolean} Whether or not to run sql through formatter and wrap the sql in <pre> tags for more readable output
	 * return CriteriaBuilder
	 */
	public any function startSqlLog( required Any returnExecutableSql=false, required Any formatSql=false ) {
		SQLHelper.setReturnExecutableSql( arguments.returnExecutableSql );
		SQLHelper.setFormatSql( arguments.formatSql );
		sqlLoggerActive = true;
		return this;
	}

	/**
	 * Stops CriteriaBuilder from continuing to internally log the state of SQL
	 * return CriteriaBuilder
	 */
	public any function stopSqlLog() {
		sqlLoggerActive = false;
		return this;
	}

	/**
	 * Allows for one-off sql logging at any point in the process of building up CriteriaBuilder; will log the SQL state at the time of the call
	 * @label {String} The label to use for the sql log record
	 * return void
	 */
	public void function logSQL( required String label ) {
		SQLHelper.log( argumentCollection=arguments );
	}

	/**
	 * Returns whether or not CriteriaBuilder is currently configured to log SQL
	 * return Boolean
	 */
	public boolean function canLogSql() {
		return sqlLoggerActive;
	}
	/************************************** PRIVATE *********************************************/
	
	/**
	 * Checks whether or not a projection is currently applied to the CriteriaBuilder
	 * return Boolean
	 */
	private boolean function hasProjection() {
		var projectionExists = false;
		if( !isNull( nativeCriteria.getProjection() ) ) {
			projectionExists = nativeCriteria.getProjection().getLength() ? true : false;
		}
		return projectionExists;
	}

	// Simplified additions of projections
	private function addProjection(any propertyName,any projectionType,any projectionList){
		// inflate to array
		if( isSimpleValue(arguments.propertyName) ){ arguments.propertyName = listToArray(arguments.propertyName); }
		// iterate array and add projections
		for(var thisP in arguments.propertyName){
			// add projection
			arguments.projectionList.add( evaluate("this.PROJECTIONS.#arguments.projectionType#( listFirst(thisP,':') )"), listLast(thisP,":") );
			
			// announce
			if( ORMService.getEventHandling() ){
				variables.eventManager.processState( "onCriteriaBuilderAddition", {
					"type" = "Projection",
					"criteriaBuilder" = this
				});
			}

		}
	}
	
	/**
	 * Helper method to prepare sqlProjection for addition to CriteriaBuilder
	 * @rawProjection {Struct} The raw projection configuration
	 * return Struct
	 */
	private struct function prepareSQLProjection( rawProjection ) {
		// get metadata for current root entity
		var metaData = ORMService.getORM().getSessionFactory( ORMService.getORM().getEntityDatasource( this.getentityName() ) )
						  .getClassMetaData( this.getentityName() );
		// establish projection struct
		var projection = {};
		// create empty array for propertyTypes
		var projection.types = [];
		// retrieve correct type for each specified property so list() doesn't bork
		for( var prop in listToArray( arguments.rawProjection.property ) ) {
			arrayAppend( projection.types, metaData.getPropertyType( prop ) );
		}
		var partialSQL = "";
		projection.sql = "";
		// if multiple subqueries have been specified, smartly separate them out into a sql string that will work
		for( var x=1; x<=listLen( arguments.rawProjection.sql ); x++ ) {
			partialSQL = listGetAt( arguments.rawProjection.sql, x );
			partialSQL = reFindNoCase( "^select", partialSQL ) ? "(#partialSQL#)" : partialSQL;
			partialSQL = partialSQL & " as #listGetAt( arguments.rawProjection.alias, x )#";
			projection.sql = listAppend( projection.sql, partialSQL );
		}
		// get all aliases
		projection.alias = listToArray( arguments.rawProjection.alias );
		// if there is a grouping spcified, add it to structure
		if( structKeyExists( arguments.rawProjection, "group" ) ) {
			projection.group = arguments.rawProjection.group;
		}
		return projection;
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
	
	// creates either a new criteria query, or a new restriction, and returns the result
	private any function createRestriction( required string missingMethodName, required struct missingMethodArguments ){
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
		//arguments.missingMethodArguments.nativeCriteria = getNativeCriteria();
		// funnel missing methods to restrictions and append to criterias
		var r = evaluate("this.restrictions.#arguments.missingMethodName#(argumentCollection=arguments.missingMethodArguments)");
		return r;
	}
}
