component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		maxValidator = new coldbox.system.orm.hibernate.hyrule.rules.maxValidator();
	}

	public void function testStringIsValidReturnsTrue(){
		var prop = {max=10,value="abcdefgh"};
		var result = maxValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testStringIsValidReturnsFalse(){
		var prop = {max=1,value="ab"};
		var result = maxValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testNumberIsValidReturnsTrue(){
		var prop = {max=3,value=2};
		var result = maxValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testNumberIsMaxReturnsTrue(){
		var prop = {max=10,value=10};
		var result = maxValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testNumberIsValidReturnsFalse(){
		var prop = {max=10,value=20};
		var result = maxValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testDateIsValidReturnsTrue(){
		var prop = {max='1/1/2012',value=dateFormat(now(),'mm/dd/yyyy')};
		var result = maxValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testDateIsValidReturnsFalse(){
		var prop = {max='1/1/2010',value=dateFormat(now(),'mm/dd/yyyy')};
		var result = maxValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testArrayIsValidReturnsTrue(){
		var prop = {max=3,value=[1,2]};
		var result = maxValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testArrayIsValidReturnsFalse(){
		var prop = {max=2,value=[1,2,3,4]};
		var result = maxValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testStructIsValidReturnsTrue(){
		var prop = {max=5,value={first="Joe",last="Smith"}};
		var result = maxValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testStructIsValidReturnsFalse(){
		var prop = {max=1,value={first="Joe",last="Smith"}};
		var result = maxValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testQueryIsValidReturnsTrue(){
		var q = queryNew("First,Last");
		var prop = {max=10,value=q};
		var result = maxValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testQueryIsValidReturnsFalse(){
		var q = queryNew("First,Last");
		queryAddRow(q,2);
		querySetCell(q,"First","Joe",1);
		querySetCell(q,"Last","Smith",1);
		querySetCell(q,"First","Mike",2);
		querySetCell(q,"Last","Smith",2);

		var prop = {max=1,value=q};
		var result = maxValidator.isValid(prop);
		assertFalse(result);
	}

}