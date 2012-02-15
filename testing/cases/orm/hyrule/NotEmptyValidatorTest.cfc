component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		nonEmptyValidator = new coldbox.system.orm.hibernate.hyrule.rules.NotEmptyValidator();
	}

	public void function testIsValidReturnTrue(){
		var prop = {notempty=true,value="nonemptystring"};
		var result = nonEmptyValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testIsValidReturnFalse(){
		var prop = {notempty=true,value=""};
		var result = nonEmptyValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testDateIsValidReturnTrue(){
		var prop = {notempty=true,value=now()};
		var result = nonEmptyValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testBooleanIsValidReturnTrue(){
		var prop = {notempty=true,value=false};
		var result = nonEmptyValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testEmptyArrayReturnsFalse(){
		var prop = {notempty=true,value=[]};
		var result = nonEmptyValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testValidArrayReturnsTrue(){
		var prop = {notempty=true,value=[1,2,3,4]};
		var result = nonEmptyValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testEmptyStructureReturnsFalse(){
		var prop = {notempty=true,value={}};
		var result = nonEmptyValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testValidStructureReturnsTrue(){
		var prop = {notempty=true,value={project="Hyrule"}};
		var result = nonEmptyValidator.isValid(prop);
		assertTrue(result);
	}

	public void function testEmptyQueryReturnsFalse(){
		var q = queryNew("First,Last,Street,City,State,Zip");
		var prop = {notempty=true,value=q};
		var result = nonEmptyValidator.isValid(prop);
		assertFalse(result);
	}

	public void function testValidQueryReturnsTrue(){
		var q = queryNew("First,Last");
		queryAddRow(q,1);
		querySetCell(q,"First","Joe",1);
		querySetCell(q,"Last","Smith",1);

		var prop = {notempty=true,value=q};
		var result = nonEmptyValidator.isValid(prop);
		assertTrue(result);
	}

	/**
	 * By default the NotEmptyValidator will trim all whitespace
	 * If you want to override this and allow whitespace you can pass
	 * false as the NotEmpty attribute. Remember if you do not provide a key
	 * it just defaults to true
	 */
	public void function testIsValidWhiteSpaceReturnsTrue(){
		var prop = {notempty=false,value=" "};
		var result = nonEmptyValidator.isValid(prop);
		assertTrue(result);
	}

}