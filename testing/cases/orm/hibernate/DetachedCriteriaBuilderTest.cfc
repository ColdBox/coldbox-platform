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
	// private method
	function testGetCriteriaQueryTranslator() {
		criteria.withProjections( count="Role.role" );
		makePublic( criteria, "getCriteriaQueryTranslator" );
		r = criteria.getCriteriaQueryTranslator();
		assertTrue( isInstanceOf( r, "org.hibernate.loader.criteria.CriteriaQueryTranslator" ) );
	}
	// private method
	function testGetCriteriaJoinWalker() {
		criteria.withProjections( count="Role.role" );
		makePublic( criteria, "getCriteriaQueryTranslator" );
		makePublic( criteria, "getCriteriaJoinWalker" );
		t = criteria.getCriteriaQueryTranslator();
		r = criteria.getCriteriaJoinWalker( t );
		assertTrue( isInstanceOf( r, "org.hibernate.loader.criteria.CriteriaJoinWalker" ) );
	}
	// private method
	function testReplaceQueryParameters() {
		criteria.withProjections( count="Role.role" );
		makePublic( criteria, "getCriteriaQueryTranslator" );
		makePublic( criteria, "getCriteriaJoinWalker" );
		makePublic( criteria, "replaceQueryParameters" );
		t = criteria.getCriteriaQueryTranslator();
		w = criteria.getCriteriaJoinWalker( t );
		sql = w.getSQLString();
		r = criteria.replaceQueryParameters( sql, t );
		assertTrue( isSimpleValue( r ) );
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
	function exists() {
		s = criteria.exists();
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.ExistsSubqueryExpression" ) );
	}
	function notExists() {
		s = criteria.notExists();
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.ExistsSubqueryExpression" ) );
	}
	function propertyEq(){
		s = criteria.propertyEq( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyEqAll(){
		s = criteria.propertyEqAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyGe(){
		s = criteria.propertyGe( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyGeAll(){
		s = criteria.propertyGeAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyGeSome(){
		s = criteria.propertyGeSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyGt(){
		s = criteria.propertyGt( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyGtAll(){
		s = criteria.propertyGtAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyGtSome(){
		s = criteria.propertyGtSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyIn(){
		s = criteria.propertyIn( "entry_id" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyLe(){
		s = criteria.propertyLe( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyLeAll(){
		s = criteria.propertyLeAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyLeSome(){
		s = criteria.propertyLeSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyLt(){
		s = criteria.propertyLt( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyLtAll(){
		s = criteria.propertyLtAll( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyLtSome(){
		s = criteria.propertyLtSome( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyNe(){
		s = criteria.propertyNe( "views" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
	function propertyNotIn(){
		s = criteria.propertyNotIn( "entry_id" );
		assertTrue( isInstanceOf( s, "org.hibernate.criterion.PropertySubqueryExpression" ) );
	}
}