component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		minValidator = new coldbox.system.orm.hibernate.hyrule.rules.MinValidator();
	}

	public void function testStringIsValidReturnsTrue(){
		var prop = {min=3,value="abcdefgh"};
		var result = minValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testStringIsValidReturnsFalse(){
		var prop = {min=3,value="ab"};
		var result = minValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testNumberIsValidReturnsTrue(){
		var prop = {min=3,value=5};
		var result = minValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testNumberIsMinReturnsTrue(){
		var prop = {min=3,value=3};
		var result = minValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testNumberIsValidReturnsFalse(){
		var prop = {min=3,value=1};
		var result = minValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testDateIsValidReturnsTrue(){
		var prop = {min='1/1/2010',value=dateFormat(now(),'mm/dd/yyyy')};
		var result = minValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testDateIsValidReturnsFalse(){
		var prop = {min=dateFormat(now(),'mm/dd/yyyy'),value='1/1/2010'};
		var result = minValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testArrayIsValidReturnsTrue(){
		var prop = {min=3,value=[1,2,3,4]};
		var result = minValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testArrayIsValidReturnsFalse(){
		var prop = {min=3,value=[1,2]};
		var result = minValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testStructIsValidReturnsTrue(){
		var prop = {min=1,value={first="Joe",last="Smith"}};
		var result = minValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testStructIsValidReturnsFalse(){
		var prop = {min=1,value={}};
		var result = minValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testQueryIsValidReturnsTrue(){
		var q = queryNew("First,Last");
		queryAddRow(q,2);
		querySetCell(q,"First","Joe",1);
		querySetCell(q,"Last","Smith",1);
		querySetCell(q,"First","Mike",2);
		querySetCell(q,"Last","Smith",2);

		var prop = {min=1,value=q};
		var result = minValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testQueryIsValidReturnsFalse(){
		var q = queryNew("First,Last");
		var prop = {min=1,value=q};
		var result = minValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testUnsupportedTypeReturnsFalse(){
		obj = createObject("component","WEB-INF.cftags.component");
		var prop = {min=10,value=obj};
		var result = minValidator.isValid(prop);
		assertFalse(result);
	}

}