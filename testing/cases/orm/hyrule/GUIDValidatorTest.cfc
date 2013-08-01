component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.GUIDValidator();
	}

	public void function testIsValidReturnsTrue(){
		var prop = {value="D1AB7B35-2E73-4EB6-A101-053D59DE74E2"};
		var result = validator.isValid(prop);
		assertTrue(result);
	}

	public void function testIsValidReturnsFalse(){
		var prop = {value="NOT_A_GUID"};
		var result = validator.isValid(prop);
		assertFalse(result);
	}
	
	public void function testBlankReturnsTrue(){
		var prop = {value=""};
		assertTrue(validator.isValid(prop));
	}	
}