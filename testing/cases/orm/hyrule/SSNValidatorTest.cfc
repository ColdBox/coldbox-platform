component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.SSNValidator();
	}

	public void function testIsValidReturnsTrue(){
		var prop = {value="123-55-1234"};
		var result = validator.isValid(prop);
		assertTrue(result);
	}

	public void function testIsValidReturnsFalse(){
		var prop = {value="123456789"};
		var result = validator.isValid(prop);
		assertFalse(result);
	}
	
	public void function testBlankReturnsTrue(){
		var prop = {value=""};
		assertTrue(validator.isValid(prop));
	}
	
}