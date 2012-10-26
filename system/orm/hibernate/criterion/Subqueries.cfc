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
	Subqueries function init() {
		subqueries   = CreateObject( "java", "org.hibernate.criterion.Subqueries" );  
		restrictions = CreateObject( "java", "org.hibernate.criterion.Restrictions" );
		return this;
	}
	// Get the native hibernate subqueries object: org.hibernate.criterion.Subqueries
	any function getNativeClass(){
		return subqueries;
	}
	any function subEq( required any value, required any nativeCriteria ) {
		return subqueries.eq( arguments.value, arguments.nativeCriteria );
	}
	any function subEqAll( required any value, required any nativeCriteria ) {
		return subqueries.eqAll( arguments.value, arguments.nativeCriteria );
	}
	any function subGe( required any value, required any nativeCriteria ) {
		return subqueries.ge( arguments.value, arguments.nativeCriteria );
	}
	any function subGeAll( required any value, required any nativeCriteria ) {
		return subqueries.geAll( arguments.value, arguments.nativeCriteria );
	}
	any function subGeSome( required any value, required any nativeCriteria ) {
		return subqueries.geSome( arguments.value, arguments.nativeCriteria );
	}
	any function subGt( required any value, required any nativeCriteria ) {
		return subqueries.gt( arguments.value, arguments.nativeCriteria );
	}
	any function subGtAll( required any value, required any nativeCriteria ) {
		return subqueries.gtAll( arguments.value, arguments.nativeCriteria );
	}
	any function subGtSome( required any value, required any nativeCriteria ) {
		return subqueries.gtSome( arguments.value, arguments.nativeCriteria );
	}
	any function subIn( required any value, required any nativeCriteria ) {
		return subqueries.in( arguments.value, arguments.nativeCriteria );
	}
	any function subLe( required any value, required any nativeCriteria ) {
		return subqueries.le( arguments.value, arguments.nativeCriteria );
	}
	any function subLeAll( required any value, required any nativeCriteria ) {
		return subqueries.leAll( arguments.value, arguments.nativeCriteria );
	}
	any function subLeSome( required any value, required any nativeCriteria ) {
		return subqueries.leSome( arguments.value, arguments.nativeCriteria );
	}
	any function subLt( required any value, required any nativeCriteria ) {
		return subqueries.lt( arguments.value, arguments.nativeCriteria );
	}
	any function subLtAll( required any value, required any nativeCriteria ) {
		return subqueries.ltAll( arguments.value, arguments.nativeCriteria );
	}
	any function subLtSome( required any value, required any nativeCriteria ) {
		return subqueries.ltSome( arguments.value, arguments.nativeCriteria );
	}
	any function subNe( required any value, required any nativeCriteria ) {
		return subqueries.ne( arguments.value, arguments.nativeCriteria );
	}
	any function subNotIn( required any value, required any nativeCriteria ) {
		return subqueries.notIn( arguments.value, arguments.nativeCriteria );
	}
	// where subquery returns a result
	any function exists( required any nativeCriteria ) {
		return subqueries.exists( arguments.nativeCriteria );
	}
	// where subquery returns no result
	any function notExists( required any nativeCriteria ) {
		return subqueries.notExists( arguments.nativeCriteria );
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