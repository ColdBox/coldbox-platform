component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.RangeValidator();
	}
	
	public void function testStringInRangeReturnsTrue(){
		var prop = {value="Hello",range="1,10"};
		assertTrue(validator.isValid(prop));
	}

	public void function testStringInRangeReturnsFalse(){		
		var prop = {value="YouReallySuckPHP",range="1,10"};
		assertFalse(validator.isValid(prop));
	}

	public void function testNumberInRangeReturnsTrue(){
		var prop = {value=7,range="1,10"};
		assertTrue(validator.isValid(prop));	
	}

	public void function testNumberInRangeReturnsFalse(){		
		var prop = {value=25,range="1,10"};
		assertFalse(validator.isValid(prop));
	}
	
	public void function testDateInRangeReturnsTrue(){
		var prop = {value="10/20/2010",range="01/01/2010,12/31/2010"};
		assertTrue(validator.isValid(prop));	
	}

	public void function testDateInRangeReturnsFalse(){		
		var prop = {value="08/21/1978",range="1/1/2010,12/31/2010"};
		assertFalse(validator.isValid(prop));
	}

}