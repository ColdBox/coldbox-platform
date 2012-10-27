component extends="coldbox.system.testing.BaseTestCase"{
	this.loadColdBox = false;
	function setup(){
		subCriteria   = getMockBox().createMock("coldbox.system.orm.hibernate.DetachedCriteriaBuilder");
		subCriteria.init("Comments","Comments");
		subqueries   = getMockBox().createMock("coldbox.system.orm.hibernate.criterion.Subqueries");
		subqueries.init( subCriteria.getNativeCriteria() );
	}
	function getNativeClass(){
		r = subqueries.getNativeClass();
		assertTrue( isInstanceOf(r,"org.hibernate.criterion.Subqueries") );
	}
	
	function testSubEq() {
		subCriteria.withProjection( property="fkentry_id" );
		s = subqueries.subEq( '88B82629-B264-B33E-D1A144F97641614E' );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubEqAll() {
		s = subqueries.subEqAll( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubGe() {
		s = subqueries.subGe( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubGeAll() {
		s = subqueries.subGeAll( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubGeSome() {
		s = subqueries.subGeSome( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubGt() {
		s = subqueries.subGt( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubGtAll() {
		s = subqueries.subGtAll( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubGtSome() {
		s = subqueries.subGtSome( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubIn() {
		s = subqueries.subIn( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubLe() {
		s = subqueries.subLe( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubLeAll() {
		s = subqueries.subLeAll( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubLeSome() {
		s = subqueries.subLeSome( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubLt() {
		s = subqueries.subLt( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubLtAll() {
		s = subqueries.subLtAll( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubLtSome() {
		s = subqueries.subLtSome( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubNe() {
		s = subqueries.subNe( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubNotIn() {
		s = subqueries.subNotIn( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function exists() {
		s = subqueries.exists();
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.ExistsSubqueryExpression" ) );
	}
	function notExists() {
		s = subqueries.notExists();
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.ExistsSubqueryExpression" ) );
	}
	function propertyEq(){
		s = subqueries.propertyEq( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyEqAll(){
		s = subqueries.propertyEqAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyGe(){
		s = subqueries.propertyGe( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyGeAll(){
		s = subqueries.propertyGeAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyGeSome(){
		s = subqueries.propertyGeSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyGt(){
		s = subqueries.propertyGt( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyGtAll(){
		s = subqueries.propertyGtAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyGtSome(){
		s = subqueries.propertyGtSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyIn(){
		s = subqueries.propertyIn( "entry_id" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyLe(){
		s = subqueries.propertyLe( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyLeAll(){
		s = subqueries.propertyLeAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyLeSome(){
		s = subqueries.propertyLeSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyLt(){
		s = subqueries.propertyLt( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyLtAll(){
		s = subqueries.propertyLtAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyLtSome(){
		s = subqueries.propertyLtSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyNe(){
		s = subqueries.propertyNe( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyNotIn(){
		s = subqueries.propertyNotIn( "entry_id" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
}