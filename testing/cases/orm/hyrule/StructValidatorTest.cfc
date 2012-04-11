component  extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.StructValidator();
	}

	public void function testIsValidReturnsTrue(){
		var prop = {value={}};
		assertTrue(validator.isValid(prop));
	}

	public void function testIsValidReturnsFalse(){
		var prop = {value=[]};
		assertFalse(validator.isValid(prop));
	}

}