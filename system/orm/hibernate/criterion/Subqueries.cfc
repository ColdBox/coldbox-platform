/**
Description :
	A proxy to hibernate org.hibernate.criterion.Subqueries object to allow
	for criteria based subquerying
*/
component singleton extends="coldbox.system.orm.hibernate.criterion.Restrictions" {
	// Constructor
	Subqueries function init() {
		subqueries   = CreateObject( "java", "org.hibernate.criterion.Subqueries" );  
		restrictions = CreateObject("java","org.hibernate.criterion.Restrictions");
		return this;
	}
	
	// Get the native hibernate subqueries object: org.hibernate.criterion.Subqueries
	any function getNativeClass(){
		return subqueries;
	}
	// where subquery returns a result
	any function exists( required any nativeCriteria ) {
		return subqueries.exists( arguments.nativeCriteria );
	}
	// where subquery returns no result
	any function notExists( required any nativeCriteria ) {
		return subqueries.exists( arguments.nativeCriteria );
	}
	any function propertyEq( required string property, required any nativeCriteria ){
		return subqueries.propertyEq( arguments.property, arguments.nativeCriteria );
	}
	any function propertyEqAll( required string property, required any nativeCriteria ){
		return subqueries.propertyEqAll( arguments.property, arguments.nativeCriteria );
	}
	any function propertyGe( required string property, required any nativeCriteria ){
		return subqueries.propertyGe( arguments.property, arguments.nativeCriteria );
	}
	any function propertyGeAll( required string property, required any nativeCriteria ){
		return subqueries.propertyGeAll( arguments.property, arguments.nativeCriteria );
	}
	any function propertyGeSome( required string property, required any nativeCriteria ){
		return subqueries.propertyGeSome( arguments.property, arguments.nativeCriteria );
	}
	any function propertyGt( required string property, required any nativeCriteria ){
		return subqueries.propertyGt( arguments.property, arguments.nativeCriteria );
	}
	any function propertyGtAll( required string property, required any nativeCriteria ){
		return subqueries.propertyGtAll( arguments.property, arguments.nativeCriteria );
	}
	any function propertyGtSome( required string property, required any nativeCriteria ){
		return subqueries.propertyGtSome( arguments.property, arguments.nativeCriteria );
	}
	any function propertyIn( required string property, required any nativeCriteria ){
		return subqueries.propertyIn( arguments.property, arguments.nativeCriteria );
	}
	any function propertyLe( required string property, required any nativeCriteria ){
		return subqueries.propertyLe( arguments.property, arguments.nativeCriteria );
	}
	any function propertyLeAll( required string property, required any nativeCriteria ){
		return subqueries.propertyLeAll( arguments.property, arguments.nativeCriteria );
	}
	any function propertyLeSome( required string property, required any nativeCriteria ){
		return subqueries.propertyLeSome( arguments.property, arguments.nativeCriteria );
	}
	any function propertyLt( required string property, required any nativeCriteria ){
		return subqueries.propertyLt( arguments.property, arguments.nativeCriteria );
	}
	any function propertyLtAll( required string property, required any nativeCriteria ){
		return subqueries.propertyLtAll( arguments.property, arguments.nativeCriteria );
	}
	any function propertyLtSome( required string property, required any nativeCriteria ){
		return subqueries.propertyLtSome( arguments.property, arguments.nativeCriteria );
	}
	any function propertyNe( required string property, required any nativeCriteria ){
		return subqueries.propertyNe( arguments.property, arguments.nativeCriteria );
	}
	any function propertyNotIn( required string property, required any nativeCriteria ){
		return subqueries.propertyNotIn( arguments.property, arguments.nativeCriteria );
	}
}