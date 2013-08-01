component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		arrayValidator = new coldbox.system.orm.hibernate.hyrule.rules.ArrayValidator();
	}

	public void function testIsValidReturnsTrue(){
		var prop = {array=true,value=[]};
		var result = arrayValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testIsValidReturnsFalse(){
		var prop = {array=true,value=""};
		var result = arrayValidator.isValid(prop);
		assertFalse(result);
	}
}