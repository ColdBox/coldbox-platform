component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.NumericValidator();
	}

	public void function testIsValidReturnsTrue(){
		var prop = {value=10};
		assertTrue(validator.isValid(prop));
	}

	public void function testIsValidReturnsFalse(){
		var prop = {value="HELLO WORLD"};
		assertFalse(validator.isValid(prop));
	}
}