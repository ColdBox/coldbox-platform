/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Description :
	A proxy to hibernate org.hibernate.criterion.Subqueries object to allow
	for criteria based subquerying
*/
component singleton extends="coldbox.system.orm.hibernate.criterion.Restrictions"{
	
	// Constructor
	Subqueries function init( required criteria ) {
		detachedCriteria = arguments.criteria;
		subqueries   = CreateObject( "java", "org.hibernate.criterion.Subqueries" );  
		restrictions = CreateObject( "java", "org.hibernate.criterion.Restrictions" );
		return this;
	}
	// Get the native hibernate subqueries object: org.hibernate.criterion.Subqueries
	any function getNativeClass(){
		return subqueries;
	}
	any function subEq( required any value ) {
		return subqueries.eq( arguments.value, detachedCriteria );
	}
	any function subEqAll( required any value ) {
		return subqueries.eqAll( arguments.value, detachedCriteria );
	}
	any function subGe( required any value ) {
		return subqueries.ge( arguments.value, detachedCriteria );
	}
	any function subGeAll( required any value ) {
		return subqueries.geAll( arguments.value, detachedCriteria );
	}
	any function subGeSome( required any value ) {
		return subqueries.geSome( arguments.value, detachedCriteria );
	}
	any function subGt( required any value ) {
		return subqueries.gt( arguments.value, detachedCriteria );
	}
	any function subGtAll( required any value ) {
		return subqueries.gtAll( arguments.value, detachedCriteria );
	}
	any function subGtSome( required any value ) {
		return subqueries.gtSome( arguments.value, detachedCriteria );
	}
	any function subIn( required any value ) {
		return subqueries.in( arguments.value, detachedCriteria );
	}
	any function subLe( required any value ) {
		return subqueries.le( arguments.value, detachedCriteria );
	}
	any function subLeAll( required any value ) {
		return subqueries.leAll( arguments.value, detachedCriteria );
	}
	any function subLeSome( required any value ) {
		return subqueries.leSome( arguments.value, detachedCriteria );
	}
	any function subLt( required any value ) {
		return subqueries.lt( arguments.value, detachedCriteria );
	}
	any function subLtAll( required any value ) {
		return subqueries.ltAll( arguments.value, detachedCriteria );
	}
	any function subLtSome( required any value ) {
		return subqueries.ltSome( arguments.value, detachedCriteria );
	}
	any function subNe( required any value ) {
		return subqueries.ne( arguments.value, detachedCriteria );
	}
	any function subNotIn( required any value ) {
		return subqueries.notIn( arguments.value, detachedCriteria );
	}
	// where subquery returns a result
	any function exists() {
		return subqueries.exists( detachedCriteria );
	}
	// where subquery returns no result
	any function notExists() {
		return subqueries.notExists( detachedCriteria );
	}
	any function propertyEq( required string property ){
		return subqueries.propertyEq( arguments.property, detachedCriteria );
	}
	any function propertyEqAll( required string property ){
		return subqueries.propertyEqAll( arguments.property, detachedCriteria );
	}
	any function propertyGe( required string property ){
		return subqueries.propertyGe( arguments.property, detachedCriteria );
	}
	any function propertyGeAll( required string property ){
		return subqueries.propertyGeAll( arguments.property, detachedCriteria );
	}
	any function propertyGeSome( required string property ){
		return subqueries.propertyGeSome( arguments.property, detachedCriteria );
	}
	any function propertyGt( required string property ){
		return subqueries.propertyGt( arguments.property, detachedCriteria );
	}
	any function propertyGtAll( required string property ){
		return subqueries.propertyGtAll( arguments.property, detachedCriteria );
	}
	any function propertyGtSome( required string property ){
		return subqueries.propertyGtSome( arguments.property, detachedCriteria );
	}
	any function propertyIn( required string property ){
		return subqueries.propertyIn( arguments.property, detachedCriteria );
	}
	any function propertyLe( required string property ){
		return subqueries.propertyLe( arguments.property, detachedCriteria );
	}
	any function propertyLeAll( required string property ){
		return subqueries.propertyLeAll( arguments.property, detachedCriteria );
	}
	any function propertyLeSome( required string property ){
		return subqueries.propertyLeSome( arguments.property, detachedCriteria );
	}
	any function propertyLt( required string property ){
		return subqueries.propertyLt( arguments.property, detachedCriteria );
	}
	any function propertyLtAll( required string property ){
		return subqueries.propertyLtAll( arguments.property, detachedCriteria );
	}
	any function propertyLtSome( required string property ){
		return subqueries.propertyLtSome( arguments.property, detachedCriteria );
	}
	any function propertyNe( required string property ){
		return subqueries.propertyNe( arguments.property, detachedCriteria );
	}
	any function propertyNotIn( required string property ){
		return subqueries.propertyNotIn( arguments.property, detachedCriteria );
	}
}