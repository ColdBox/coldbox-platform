component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.PhoneValidator();
	}

	public void function testIsValidFormatWithDotsReturnsTrue(){
		var prop = {value="216.555.1212"};
		assertTrue(validator.isValid(prop));
	}

	public void function testIsValidFormatWithDashesReturnsTrue(){
		var prop = {value="216-555-1212"};
		assertTrue(validator.isValid(prop));
	}
	
	public void function testIsValidFormatWithStandardFormatReturnsTrue(){
		var prop = {value="(216) 555-1212"};
		assertTrue(validator.isValid(prop));
	}
	
	public void function testIsValidFormatNineDigitsReturnsTrue(){
		var prop = {value="2165551212"};
		assertTrue(validator.isValid(prop));
	}
	
	public void function testIsValidFormatTenDigitsReturnsTrue(){
		var prop = {value="12165551212"};
		assertTrue(validator.isValid(prop));
	}
	
	public void function testIsValidReturnsFalse(){
		var prop = {value="12165551212-23432"};
		assertFalse(validator.isValid(prop));		
	}

	public void function testBlankReturnsTrue(){
		var prop = {value=""};
		assertTrue(validator.isValid(prop));
	}
		
}