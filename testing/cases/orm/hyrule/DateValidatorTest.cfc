component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.DateValidator();
	}

	public void function testIsValidReturnsTrue(){
		var prop = {value=now()};
		var result = validator.isValid(prop);
		assertTrue(result);
	}

	public void function testIsValidReturnsFalse(){
		var prop = {value="HelloWorld"};
		var result = validator.isValid(prop);
		assertFalse(result);
	}
	
}