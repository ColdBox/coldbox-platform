component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.PastValidator();
	}

	public void function testInvalidDateReturnsFalse(){
		var prop = {value="I_AM_NOT_A_DATE"};
		var result = validator.isValid(prop);
		assertFalse(result);
	}

	public void function testInvalidPastDateReturnsFalse(){
		var prop = {value="01/10/2020",past="I_AM_NOT_A_DATE"};
		var result = validator.isValid(prop);		
		assertFalse(result);
	}
	
	public void function testValidDateReturnsTrue(){
		var prop = {value="12/15/2009",past=true};
		var result = validator.isValid(prop);				
		assertTrue(result);
	}
	
	/**
	 * When a past date is not given we assume the user wants to test the given
	 * date against now. Because the value is in the past from now this should pass.
	 */
	public void function testPastDateBlankReturnsTrue(){
		var prop = {value="12/30/2008",past=""};				
		var result = validator.isValid(prop);
		assertTrue(result);
	}
	
	/**
	 * If there is a date provided by past we want to compare against that date not now()
	 */
	public void function testValueInFuturedComparedToFutureReturnsTrue(){
		var prop = {value="12/30/2010",past="12/01/2011"};
		var result = validator.isValid(prop);
		assertTrue(result);
	}
		
}