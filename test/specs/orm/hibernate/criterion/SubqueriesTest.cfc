component extends="coldbox.system.testing.BaseTestCase"{
	this.loadColdBox = false;
	function setup(){
		subCriteria = createObject( "java", "org.hibernate.criterion.DetachedCriteria" ).forEntityName( "User", "u" );
		subqueries   = getMockBox().createMock("coldbox.system.orm.hibernate.criterion.Subqueries");
		subqueries.init( subCriteria );
	}
	function testGetNativeClass(){
		r = subqueries.getNativeClass();
		assertTrue( isInstanceOf(r,"org.hibernate.criterion.Subqueries") );
	}
	
	function testSubEq() {
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
	function testexists() {
		s = subqueries.exists();
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.ExistsSubqueryExpression" ) );
	}
	function testNotExists() {
		s = subqueries.notExists();
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.ExistsSubqueryExpression" ) );
	}
	function testPropertyEq(){
		s = subqueries.propertyEq( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyEqAll(){
		s = subqueries.propertyEqAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyGe(){
		s = subqueries.propertyGe( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyGeAll(){
		s = subqueries.propertyGeAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyGeSome(){
		s = subqueries.propertyGeSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyGt(){
		s = subqueries.propertyGt( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyGtAll(){
		s = subqueries.propertyGtAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyGtSome(){
		s = subqueries.propertyGtSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyIn(){
		s = subqueries.propertyIn( "entry_id" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyLe(){
		s = subqueries.propertyLe( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyLeAll(){
		s = subqueries.propertyLeAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyLeSome(){
		s = subqueries.propertyLeSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyLt(){
		s = subqueries.propertyLt( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyLtAll(){
		s = subqueries.propertyLtAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyLtSome(){
		s = subqueries.propertyLtSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyNe(){
		s = subqueries.propertyNe( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyNotIn(){
		s = subqueries.propertyNotIn( "entry_id" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
}