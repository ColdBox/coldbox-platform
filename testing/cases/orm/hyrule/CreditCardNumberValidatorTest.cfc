component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.CreditCardNumberValidator();
	}

	public void function testIsValidReturnsTrue(){
		var prop = {creditCard=true,value="4012888888881881"};
		var result = validator.isValid(prop);
		assertTrue(result);
	}

	public void function testIsValidReturnsFalse(){
		var prop = {creditcard=true,value="556165165165156165"};
		var result = validator.isValid(prop);
		assertFalse(result);
	}

	public void function testBlankReturnsTrue(){
		var prop = {value=""};
		assertTrue(validator.isValid(prop));
	}

}