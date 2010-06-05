component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.FutureValidator();
	}

	public void function testInvalidDateReturnsFalse(){
		var prop = {value="I_AM_NOT_A_DATE"};
		var result = validator.isValid(prop);
		assertFalse(result);
	}

	public void function testFutureDateInvalidReturnsFalse(){
		var prop = {value=now(),future="I_AM_NOT_A_DATE"};
		var result = validator.isValid(prop);		
		assertFalse(result);
	}
	
	public void function testValidDateReturnsTrue(){
		var prop = {value="12/15/2012",future=true};
		var result = validator.isValid(prop);				
		assertTrue(result);
	}
	
	/**
	 * When a future date is not given we assume the user wants to test the given
	 * date against now. Because the value is in the future from now this should pass.
	 */
	public void function testFutureDateBlankReturnsTrue(){
		var prop = {value="12/30/2020",future=""};				
		var result = validator.isValid(prop);
		assertTrue(result);
	}
	
	/**
	 * If there is a date provided by future we want to compare against that date not now()
	 */
	public void function testValueInFuturedComparedToFutureReturnsTrue(){
		var prop = {value="12/30/2010",future="12/01/2010"};
		var result = validator.isValid(prop);
		assertTrue(result);
	}
		
}