/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Description :
	Based on the general approach of CriteriaBuilder.cfc, DetachedCriteriaBuilder allows you 
	to create a detached criteria query that can be used:
		* in conjuction with critierion.Subqueries to add a programmatically built subquery as a criterion of another criteria query
		* as a detachedSQLProjection, which allows you to build a programmatic subquery that is added as a projection to another criteria query	
*/
import coldbox.system.orm.hibernate.*;
component accessors="true" extends="coldbox.system.orm.hibernate.BaseBuilder" {
	
	/**
	* Constructor
	*/
	DetachedCriteriaBuilder function init( 
		required string entityName, 
		required string alias,
		required any ORMService 
	){
		// create new DetachedCriteria
		var criteria = createObject( "java", "org.hibernate.criterion.DetachedCriteria" ).forEntityName( arguments.entityName, arguments.alias );
		
		// setup base builder with detached criteria and subqueries
		super.init( entityName=arguments.entityName, 
					criteria=criteria, 
					restrictions=new criterion.Subqueries( criteria ),
					ORMService=arguments.ORMService );
		
		return this;
	}
	
	// pass off arguments to higher-level restriction builder, and handle the results
	any function onMissingMethod( required string missingMethodName, required struct missingMethodArguments ) {
		// get the restriction/new criteria
		var r = createRestriction( argumentCollection=arguments );
		// switch on the object type
		switch( getMetaData( r ).name ) {
			// if a detached criteria builder, just return this so we can keep chaining
			case 'coldbox.system.orm.hibernate.DetachedCriteriaBuilder':
				break;
			// if a subquery, we *need* to return the restrictino itself, or bad things happen
			case 'org.hibernate.criterion.PropertySubqueryExpression': 
			case 'org.hibernate.criterion.ExistsSubqueryExpression':
			case 'org.hibernate.criterion.SimpleSubqueryExpression':
				return r;
			// otherwise, just a restriction; add it to nativeCriteria, then return this so we can keep chaining
			default: 
				nativeCriteria.add( r );
				// process interception
				variables.eventManager.processState( "onCriteriaBuilderAddition", {
					"type" = "Subquery Restriction",
					"CriteriaBuilder" = this
				});
				break;
		}
		return this;
	}
	
	public any function getNativeCriteria() {
		var ormsession = variables.ORMService.getORM().getSession();
		return variables.nativeCriteria.getExecutableCriteria( ormsession );
	}

	public any function createDetachedSQLProjection() {
		// get the sql with replaced parameters
		var sql = SQLHelper.getSql( returnExecutableSql=true );
		var alias = SQLHelper.getProjectionAlias();
		var uniqueAlias = SQLHelper.generateSQLAlias();
			// by default, alias is this_...convert it to the alias provided
			sql = replaceNoCase( sql, "this_", SQLHelper.getRootSQLAlias(), 'all' );
			// wrap it up and uniquely alias it
			sql = "( #sql# ) as " & alias;
		// now that we have the sql string, we can create the sqlProjection
		return this.PROJECTIONS.sqlProjection( sql, [ alias ], SQLHelper.getProjectedTypes() );
	}
}