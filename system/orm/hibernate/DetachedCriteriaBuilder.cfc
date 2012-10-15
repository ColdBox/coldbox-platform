/**
Description :
	Based on the general approach of CriteriaBuilder.cfc, DetachedCriteriaBuilder allows you 
	to create a detached criteria query that can be used:
		* in conjuction with critierion.Subqueries to add a programmatically built subquery as a criterion of another criteria query
		* as a detachedSQLProjection, which allows you to build a programmatic subquery that is added as a projection to another criteria query	
*/
import coldbox.system.orm.hibernate.*;
component accessors="true" extends="coldbox.system.orm.hibernate.BaseBuilder" {
	
	DetachedCriteriaBuilder function init( required String entityName, required String alias ) {
		// create new DetachedCriteria
		var criteria = createObject( "java", "org.hibernate.criterion.DetachedCriteria" ).forEntityName( arguments.entityName, arguments.alias );
		// setup base builder with detached criteria and subqueries
		super.init( arguments.entityName, criteria, new criterion.Subqueries() );
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
			case 'org.hibernate.criterion.NotExistsSubqueryExpression':
			case 'org.hibernate.criterion.SimpleSubqueryExpression':
				return r;
			// otherwise, just a restriction; add it to nativeCriteria, then return this so we can keep chaining
			default: 
				nativeCriteria.add( r );
				break;
		}
		return this;
	}
	// replace query parameter placeholders with their actual values (for detachedSQLProjection)
	public string function replaceQueryParameters( required string sql, required any translator  ) {
		var parameters = arguments.translator.getQueryParameters();
		// get parameter values and types
		var parameterValues = parameters.getPositionalParameterValues();
		var parameterTypes  = parameters.getPositionalParameterTypes();
		var paramPos = 0;
		var sqlstring = "";
		// loop over parameters; need to replace those pesky "?" with the real values
		for( var pv=1; pv<=arrayLen( parameterValues ); pv++ ) {
			// check the type of the parameter
			var pvTyped = parameterTypes[ pv ].getName()=="string" ? "'#parameterValues[ pv ]#'" : parameterValues[ pv ];
			// get position of parameter placeholder
			paramPos = findNoCase( "?", arguments.sql );
			// if parameter is a string type and is preceeded by "like", need to add like evaluators
			if( parameterTypes[ pv ].getName()=="string" && mid( arguments.sql, paramPos-5, 4 )=="like" ) {
				pvTyped = reReplaceNoCase( pvTyped, "^'", "'%", "one" );
				pvTyped = reReplaceNoCase( pvTyped, "'$", "%'", "one" );
			}
			// if comparing to root alias, remove quotations
			if( pvTyped contains "{alias}" ) {
				pvTyped = replaceNoCase( pvTyped, "'", "", "all" );
			}
			// remove parameter placeholders
			arguments.sql = reReplaceNoCase( arguments.sql, "\?", pvTyped, "one" );
		}
		return arguments.sql;
	}
	/************************************** PRIVATE *********************************************/
}