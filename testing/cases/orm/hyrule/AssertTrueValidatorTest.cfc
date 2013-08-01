component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		assertTrueValidator = new coldbox.system.orm.hibernate.hyrule.rules.AssertTrueValidator();
	}

	public void function testIsValidReturnsTrue(){
		var prop = {assertfalse=true,value=true};
		var result =assertTrueValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testIsValidBooleanReturnsFalse(){
		var prop = {assertFalse=true,value=false};
		var result = assertTrueValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testIsValidNonBooleanReturnsFalse(){
		var prop = {assertFalse=true,value=""};
		var result = assertTrueValidator.isValid(prop);
		assertFalse(result);
	}

}