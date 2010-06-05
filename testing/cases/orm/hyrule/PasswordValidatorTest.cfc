component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.PasswordValidator();
	}
	
	public void function testIsValidPasswordReturnsTrue(){
		var prop = {password="1,10,low",value="mypassword"};
		assertTrue(validator.isValid(prop));
	}

	public void function testIsValidPasswordReturnsFalse(){
		var prop = {password="1,10,low",value="password"};
		assertFalse(validator.isValid(prop));
	}
	
	public void function testIsValidDoesNotMeetMinReturnsFalse(){
		var prop = {password="6,30,low",value="abc"};
		assertFalse(validator.isValid(prop));		
	}

	public void function testIsValidExceedsMaxReturnsFalse(){
		var prop = {password="1,10,low",value="abcdefghijklmnopqrstuvwxyz"};
		assertFalse(validator.isValid(prop));
	}
	
	/** 
	 * on medium level the password must contain letters and numbers
	 */
	public void function testIsValidMediumLevelReturnsTrue(){
		var prop = {password="1,30,medium",value="mySw33tPassw0rd"};
		assertTrue(validator.isValid(prop));
	}
	
	public void function testIsValidMediumLevelReturnsFalse(){
		var prop = {password="1,30,medium",value="mySweetPassword"};
		assertFalse(validator.isValid(prop));
	}
	
	/**
	 * on high level passwords must contain letters numbers and special characters
	 */
	public void function testIsValidHighLevelReturnsTrue(){
		var prop = {password="1,30,high",value="mySw33t@@Passw0rd"};
		assertTrue(validator.isValid(prop));
	}
	
	public void function testIsValidHighLevelReturnsFalse(){
		var prop = {password="1,30,high",value="mySw33tPassw0rd"};
		assertFalse(validator.isValid(prop));
	}

}