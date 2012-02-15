component extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.IsMatchValidator();
	}
	
	public void function testIsMatchNoCompareReturnsFalse(){
		var prop = {value="ColdFusion"};
		var result = validator.isValid(prop);
		assertFalse(result);
	}		
	
	public void function testIsMatchReturnsTrue(){
		var prop = {value="ColdFusion",compareto="ColdFusion"};
		var result = validator.isValid(prop);
		assertTrue(result);
	}
	
	public void function testIsMatchCompareCaseReturnsTrue(){
		var prop = {value="coldfusion",compareto="COLDFUSION",ignoreCase=true};
		var result = validator.isValid(prop);
		assertTrue(result);
	}		
	
	public void function testIsMatchCompareCaseReturnsFalse(){
		var prop = {value="coldfusion",compareto="COLDFUSION",ignoreCase=false};
		var result = validator.isValid(prop);
		assertFalse(result);
	}		

}