component extends="coldbox.system.testing.BaseTestCase"{
	this.loadColdbox = false;
	
	function beforeTests(){
		super.beforeTests();
		// Load our test injector for ORM entity binding
		new coldbox.system.ioc.Injector(binder="coldbox.testing.cases.orm.hibernate.WireBox");
	}
	function setup(){
		criteria   = getMockBox().createMock("coldbox.system.orm.hibernate.DetachedCriteriaBuilder");
		criteria.init("Role", "Role");
		orm = new coldbox.system.orm.hibernate.util.ORMUtilFactory().getORMUtil();
	}

	function testCreateDetachedSQLProjection() {
		criteria.withProjections( count="Role.role" );
		var r = criteria.createDetachedSQLProjection();
		assertTrue( isInstanceOf( r, 'org.hibernate.criterion.SQLProjection' ) );
	}
	
	function testGetNativeCriteria() {
		criteria.withProjections( count="Role.role" );
		assertTrue( isInstanceOf( criteria.getNativeCriteria(), "org.hibernate.impl.CriteriaImpl" ) );
	}
	
	// test missingmethod handler functions
	function testSubEq() {
		criteria.withProjection( property="fkentry_id" );
		s = criteria.subEq( '88B82629-B264-B33E-D1A144F97641614E', criteria );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubEqAll() {
		s = criteria.subEqAll( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubGe() {
		s = criteria.subGe( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubGeAll() {
		s = criteria.subGeAll( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubGeSome() {
		s = criteria.subGeSome( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubGt() {
		s = criteria.subGt( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubGtAll() {
		s = criteria.subGtAll( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubGtSome() {
		s = criteria.subGtSome( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubIn() {
		s = criteria.subIn( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubLe() {
		s = criteria.subLe( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubLeAll() {
		s = criteria.subLeAll( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubLeSome() {
		s = criteria.subLeSome( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubLt() {
		s = criteria.subLt( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubLtAll() {
		s = criteria.subLtAll( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubLtSome() {
		s = criteria.subLtSome( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubNe() {
		s = criteria.subNe( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testSubNotIn() {
		s = criteria.subNotIn( 500 );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.SimpleSubqueryExpression" ) );
	}
	function testExists() {
		s = criteria.exists();
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.ExistsSubqueryExpression" ) );
	}
	function testNotExists() {
		s = criteria.notExists();
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.ExistsSubqueryExpression" ) );
	}
	function testPropertyEq(){
		s = criteria.propertyEq( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyEqAll(){
		s = criteria.propertyEqAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyGe(){
		s = criteria.propertyGe( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyGeAll(){
		s = criteria.propertyGeAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyGeSome(){
		s = criteria.propertyGeSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyGt(){
		s = criteria.propertyGt( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyGtAll(){
		s = criteria.propertyGtAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyGtSome(){
		s = criteria.propertyGtSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyIn(){
		s = criteria.propertyIn( "entry_id" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyLe(){
		s = criteria.propertyLe( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyLeAll(){
		s = criteria.propertyLeAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyLeSome(){
		s = criteria.propertyLeSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyLt(){
		s = criteria.propertyLt( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyLtAll(){
		s = criteria.propertyLtAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyLtSome(){
		s = criteria.propertyLtSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyNe(){
		s = criteria.propertyNe( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function testPropertyNotIn(){
		s = criteria.propertyNotIn( "entry_id" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
}