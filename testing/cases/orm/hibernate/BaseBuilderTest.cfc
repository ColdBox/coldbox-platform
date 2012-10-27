component extends="coldbox.system.testing.BaseTestCase" {

	this.loadColdbox = false;
	
	function beforeTests(){
		super.beforeTests();
		// Load our test injector for ORM entity binding
		new coldbox.system.ioc.Injector(binder="coldbox.testing.cases.orm.hibernate.WireBox");
	}
	
	function setup(){
		criteria   = getMockBox().createMock("coldbox.system.orm.hibernate.CriteriaBuilder");
		criteria.init("User");
		subCriteria   = getMockBox().createMock("coldbox.system.orm.hibernate.DetachedCriteriaBuilder");
		subCriteria.init("User","User2");

		// Test ID's
		testUserID = '88B73A03-FEFA-935D-AD8036E1B7954B76';
		testCatID  = '3A2C516C-41CE-41D3-A9224EA690ED1128';
		test2 = ["1","2"];
	}
	
	function testCreateCriteria(){

		r = criteria.init("Role")
			.createCriteria("users", criteria.INNER_JOIN )
				.like("lastName","M%")
			.list();

		assertEquals("Administrator", r[1].getRole() );

		// with join Type
		r = criteria.init("Role")
			.withusers( criteria.LEFT_JOIN ).like("lastName","M%")
			.list();
			
		assertEquals("Administrator", r[1].getRole() );
		// No Joins
		r = criteria.init("Role")
			.withusers().like("lastName","M%")
			.list();
		assertEquals("Administrator", r[1].getRole() );
	}

	function testCreateAlias(){
		r = criteria.init("Role")
			.createAlias("users", "u", criteria.INNER_JOIN )
			.like("u.lastName","M%")
			.list();

		assertEquals("Administrator", r[1].getRole() );
		// with join Type
		r = criteria.init("Role")
			.createAlias("users","u")
			.like("u.lastName","M%")
			.list();
		assertEquals("Administrator", r[1].getRole() );
	}

	function testResultTransformer(){
		r = criteria
			.resultTransformer( criteria.DISTINCT_ROOT_ENTITY )
			.list();
	}

	function testsetProjection(){
		r = criteria
			.setProjection( criteria.projections.rowCount() )
			.get();

		assertTrue( r gt 0 );
	}

	function testWithProjections(){
		r = criteria
			.withProjections(avg="lastLogin",rowCount=true,max="lastLogin")
			.list();
		
		assertTrue( isArray( r ) );
		
		r = criteria
			.withProjections(property="firstName,lastName")
			.list();
			
		assertTrue( isArray( r ) );
		
		r = criteria
			.withProjections( 
				detachedSQLProjection=[
					criteria.createSubcriteria( "Role", "Role" )
        			 .withProjections( count="Role.role" )
				]
			)
			.list();
		assertTrue( isArray( r ) );
	}

	function testOrder(){
		r = criteria.order("id");
		r = criteria.order("id","desc");
		r = criteria.order("id","desc",true);
		
		s = subCriteria.order("id");
		s = subCriteria.order("id","desc");
		s = subCriteria.order("id","desc",true);
	}
	
	function testBetween(){
		r = criteria.between("balance",500,1000);
		s = subCriteria.between("balance",500,1000);
	}

	function testEQ(){
		r = criteria.eq("balance",500);
		r = criteria.isEq("balance",500);
		
		s = subCriteria.eq("balance",500);
		s = subCriteria.isEq("balance",500);
	}

	function testEqProperty(){
		r = criteria.eqProperty("balance","balance2");
		s = subCriteria.eqProperty("balance","balance2");
	}

	function testGT(){
		r = criteria.gt("balance",500);
		r = criteria.isGT("balance",500);
		
		s = subCriteria.gt("balance",500);
		s = subCriteria.isGT("balance",500);
	}

	function testgtProperty(){
		r = criteria.gtProperty("balance","balance2");
		s = subCriteria.gtProperty("balance","balance2");
	}

	function testGE(){
		r = criteria.ge("balance",500);
		r = criteria.isGe("balance",500);
		
		s = subCriteria.ge("balance",500);
		s = subCriteria.isGe("balance",500);
	}

	function testgeProperty(){
		r = criteria.geProperty("balance","balance2");
		s = subCriteria.geProperty("balance","balance2");
	}

	function testIDEq(){
		r = criteria.idEq(45);
		s = subCriteria.idEq(45);
	}

	function testilike(){
		r = criteria.ilike("firstname","lu%");
		s = subCriteria.ilike("firstname","lu%");
	}

	function testin(){
		r = criteria.in("id",[1,2,3]);
		r = criteria.in("id","1,2,3");
		r = criteria.isIn("id","1,2,3");
		
		s = subCriteria.in("id",[1,2,3]);
		s = subCriteria.in("id","1,2,3");
		s = subCriteria.isIn("id","1,2,3");
	}

	function testisEmpty(){
		r = criteria.isEmpty("comments");
		s = subCriteria.isEmpty("comments");
	}
	function testisNotEmpty(){
		r = criteria.isNotEmpty("comments");
		s = subCriteria.isNotEmpty("comments");
	}

	function testIsNull(){
		r = criteria.isNull("lastName");
		s = subCriteria.isNull("lastName");
	}
	function testIsNotNull(){
		r = criteria.isNotNull("lastName");
		s = subCriteria.isNotNull("lastName");
	}

	function testlT(){
		r = criteria.lt("balance",500);
		r = criteria.islt("balance",500);
		
		s = subCriteria.lt("balance",500);
		s = subCriteria.islt("balance",500);
	}

	function testltProperty(){
		r = criteria.ltProperty("balance","balance2");
		s = subCriteria.ltProperty("balance","balance2");
	}

	function testle(){
		r = criteria.le("balance",500);
		r = criteria.isle("balance",500);
		
		s = subCriteria.le("balance",500);
		s = subCriteria.isle("balance",500);
	}

	function testleProperty(){
		r = criteria.leProperty("balance","balance2");
		s = subCriteria.leProperty("balance","balance2");
	}

	function testlike(){
		r = criteria.like("balance","lui%");
		s = subCriteria.like("balance","lui%");
	}

	function testne(){
		r = criteria.ne("balance",500);
		s = subCriteria.ne("balance",500);
	}

	function testneProperty(){
		r = criteria.neProperty("balance","balance2");
		s = subCriteria.neProperty("balance","balance2");
	}

	function testsizeEq(){
		r = criteria.sizeEQ("comments",500);
		s = subCriteria.sizeEQ("comments",500);
	}
	
	function testsizeGT(){
		r = criteria.sizeGT("comments",500);
		s = subCriteria.sizeGT("comments",500);
	}
	function testsizeGE(){
		r = criteria.sizeGE("comments",500);
		s = subCriteria.sizeGE("comments",500);
	}
	function testsizeLT(){
		r = criteria.sizeLT("comments",500);
		s = subCriteria.sizeLT("comments",500);
	}
	function testsizeLE(){
		r = criteria.sizeLE("comments",500);
		s = subCriteria.sizeLE("comments",500);
	}
	function testsizeNE(){
		r = criteria.sizeNE("comments",500);
		s = subCriteria.sizeNE("comments",500);
	}

	function testConjunction(){
		r = criteria.conjunction( [criteria.restrictions.between("balance",100,200), criteria.restrictions.lt("salary",20000) ] );
		s = subCriteria.conjunction( [subCriteria.restrictions.between("balance",100,200), subCriteria.restrictions.lt("salary",20000) ] );
	}

	function testDisjunction(){
		r = criteria.disjunction( [criteria.restrictions.between("balance",100,200), criteria.restrictions.lt("salary",20000) ] );
		s = subCriteria.disjunction( [subCriteria.restrictions.between("balance",100,200), subCriteria.restrictions.lt("salary",20000) ] );
	}

	function testAnd(){
		r = criteria.and( criteria.restrictions.between("balance",100,200), criteria.restrictions.isLt("salary",20000) );
		s = subCriteria.$and( subCriteria.restrictions.between("balance",100,200), subCriteria.restrictions.isLt("salary",20000) );
	}

	function testOr(){
		r = criteria.or( criteria.restrictions.between("balance",100,200), criteria.restrictions.lt("salary",20000) );
		s = subCriteria.or( subCriteria.restrictions.between("balance",100,200), subCriteria.restrictions.lt("salary",20000) );
	}

	function testNot(){
		r = criteria.not( criteria.restrictions.gt("salary",200) );
		s = subCriteria.not( subCriteria.restrictions.gt("salary",200) );
	}

	function testAdd(){
		r = criteria.add( criteria.restrictions.gt("salary",200) );
		s = subCriteria.add( subCriteria.restrictions.gt("salary",200));
	}
}