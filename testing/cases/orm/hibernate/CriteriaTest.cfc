component extends="coldbox.system.testing.BaseTestCase"{

	function setup(){
		criteria   = getMockBox().createMock("coldbox.system.orm.hibernate.Criteria");
		criteria.init();
	}
	
	function testBetween(){
		r = criteria.between("balance",500,1000);
	}
	
	function testEQ(){
		r = criteria.eq("balance",500);
		r = criteria.isEq("balance",500);
	}
	
	function testEqProperty(){
		r = criteria.eqProperty("balance","balance2");
	}
	
	function testGT(){
		r = criteria.gt("balance",500);
		r = criteria.isGT("balance",500);
	}
	
	function testgtProperty(){
		r = criteria.gtProperty("balance","balance2");
	}
	
	function testGE(){
		r = criteria.ge("balance",500);
		r = criteria.isGe("balance",500);
	}
	
	function testgeProperty(){
		r = criteria.geProperty("balance","balance2");
	}
	
	function testIDEq(){
		r = criteria.idEq(45);
	}
	
	function testilike(){
		r = criteria.ilike("firstname","lu%");
	}
	
	function testin(){
		r = criteria.in("id",[1,2,3]);
		r = criteria.in("id","1,2,3");
		r = criteria.isIn("id","1,2,3");
	}
	
	function testisEmpty(){
		r = criteria.isEmpty("comments");
	}
	function testisNotEmpty(){
		r = criteria.isNotEmpty("comments");
	}
	
	function testIsNull(){
		r = criteria.isNull("lastName");
	}
	function testIsNotNull(){
		r = criteria.isNotNull("lastName");
	}
	
	function testlT(){
		r = criteria.lt("balance",500);
		r = criteria.islt("balance",500);
	}
	
	function testltProperty(){
		r = criteria.ltProperty("balance","balance2");
	}
	
	function testle(){
		r = criteria.le("balance",500);
		r = criteria.isle("balance",500);
	}
	
	function testleProperty(){
		r = criteria.leProperty("balance","balance2");
	}
	
	function testlike(){
		r = criteria.like("balance","lui%");
	}
	
	function testne(){
		r = criteria.ne("balance",500);
	}
	
	function testneProperty(){
		r = criteria.neProperty("balance","balance2");
	}
	
	function testsizeEq(){
		r = criteria.sizeEQ("comments",500);
	}
	function testsizeGT(){
		r = criteria.sizeGT("comments",500);
	}
	function testsizeGE(){
		r = criteria.sizeGE("comments",500);
	}
	function testsizeLT(){
		r = criteria.sizeLT("comments",500);
	}
	function testsizeLE(){
		r = criteria.sizeLE("comments",500);
	}
	function testsizeNE(){
		r = criteria.sizeNE("comments",500);
	}
	
	function testConjunction(){
		r = criteria.conjunction( [criteria.restrictions.between("balance",100,200), criteria.restrictions.lt("salary",20000) ] );
	}
	
	function testDisjunction(){
		r = criteria.disjunction( [criteria.restrictions.between("balance",100,200), criteria.restrictions.lt("salary",20000) ] );
	}
	
	function testAnd(){
		r = criteria.and( criteria.restrictions.between("balance",100,200), criteria.restrictions.lt("salary",20000) );
	}
	
	function testOr(){
		r = criteria.or( criteria.restrictions.between("balance",100,200), criteria.restrictions.lt("salary",20000) );
	}
	
	function testNot(){
		r = criteria.not( criteria.restrictions.gt("salary",200) );
	}
}