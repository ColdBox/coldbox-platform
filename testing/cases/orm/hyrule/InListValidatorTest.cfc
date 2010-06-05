component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.InListValidator();
	}	

	public void function testIsInListReturnsTrue(){
		var prop = {value="Apples",inlist="Apples,Oranges,Bananas"};
		var result = validator.isValid(prop);
		assertTrue(result);
	}

	public void function testIsNotInListReturnsFalse(){
		var prop = {value="UNKNOWN_FRUIT",inlist="Apples,Oranges,Bananas"};
		var result = validator.isValid(prop);
		assertFalse(result);
	}

}