component extends="coldbox.system.testing.BaseTestCase"{

	function setup(){
		restrictions   = getMockBox().createMock("coldbox.system.orm.hibernate.criterion.Restrictions");
		restrictions.init();
	}
	
	function testgetNativeClass(){
		r = restrictions.getNativeClass();
		assertTrue( isInstanceOf(r,"org.hibernate.criterion.Restrictions") );
	}
	
	function testBetween(){
		r = restrictions.between("balance",500,1000);
	}
	
	function testEQ(){
		r = restrictions.eq("balance",500);
		r = restrictions.isEq("balance",500);
	}
	
	function testEqProperty(){
		r = restrictions.eqProperty("balance","balance2");
	}
	
	function testGT(){
		r = restrictions.gt("balance",500);
		r = restrictions.isGT("balance",500);
	}
	
	function testgtProperty(){
		r = restrictions.gtProperty("balance","balance2");
	}
	
	function testGE(){
		r = restrictions.ge("balance",500);
		r = restrictions.isGe("balance",500);
	}
	
	function testgeProperty(){
		r = restrictions.geProperty("balance","balance2");
	}
	
	function testIDEq(){
		r = restrictions.idEq(45);
	}
	
	function testilike(){
		r = restrictions.ilike("firstname","lu%");
	}
	
	function testin(){
		r = restrictions.in("id",[1,2,3]);
		r = restrictions.in("id","1,2,3");
		r = restrictions.isIn("id","1,2,3");
	}
	
	function testisEmpty(){
		r = restrictions.isEmpty("comments");
	}
	function testisNotEmpty(){
		r = restrictions.isNotEmpty("comments");
	}
	
	function testIsNull(){
		r = restrictions.isNull("lastName");
	}
	function testIsNotNull(){
		r = restrictions.isNotNull("lastName");
	}
	
	function testlT(){
		r = restrictions.lt("balance",500);
		r = restrictions.islt("balance",500);
	}
	
	function testltProperty(){
		r = restrictions.ltProperty("balance","balance2");
	}
	
	function testle(){
		r = restrictions.le("balance",500);
		r = restrictions.isle("balance",500);
	}
	
	function testleProperty(){
		r = restrictions.leProperty("balance","balance2");
	}
	
	function testlike(){
		r = restrictions.like("balance","lui%");
	}
	
	function testne(){
		r = restrictions.ne("balance",500);
	}
	
	function testneProperty(){
		r = restrictions.neProperty("balance","balance2");
	}
	
	function testsizeEq(){
		r = restrictions.sizeEQ("comments",500);
	}
	function testsizeGT(){
		r = restrictions.sizeGT("comments",500);
	}
	function testsizeGE(){
		r = restrictions.sizeGE("comments",500);
	}
	function testsizeLT(){
		r = restrictions.sizeLT("comments",500);
	}
	function testsizeLE(){
		r = restrictions.sizeLE("comments",500);
	}
	function testsizeNE(){
		r = restrictions.sizeNE("comments",500);
	}
	
	function testConjunction(){
		r = restrictions.conjunction( [restrictions.between("balance",100,200), restrictions.lt("salary",20000) ] );
	}
	
	function testDisjunction(){
		r = restrictions.disjunction( [restrictions.between("balance",100,200), restrictions.lt("salary",20000) ] );
	}
	
	function testAnd(){
		r = restrictions.and( restrictions.between("balance",100,200), restrictions.lt("salary",20000) );
	}
	
	function testOr(){
		r = restrictions.or( restrictions.between("balance",100,200), restrictions.lt("salary",20000) );
	}
	
	function testNot(){
		r = restrictions.not( restrictions.gt("salary",200) );
	}
}