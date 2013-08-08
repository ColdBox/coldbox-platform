component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		assertFalseValidator = new coldbox.system.orm.hibernate.hyrule.rules.AssertFalseValidator();
	}

	public void function testIsValidReturnsTrue(){
		var prop = {assertfalse=true,value=false};
		var result =assertFalseValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testIsValidBooleanReturnsFalse(){
		var prop = {assertFalse=true,value=true};
		var result = assertFalseValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testIsValidNonBooleanReturnsFalse(){
		var prop = {assertFalse=true,value=""};
		var result = assertFalseValidator.isValid(prop);
		assertFalse(result);
	}

}