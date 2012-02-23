component  extends="coldbox.system.testing.BaseTestCase" {

	public void function setup(){
		validator = new coldbox.system.orm.hibernate.hyrule.rules.SizeValidator();
	}
	
	public void function testListInRangeReturnsTrue(){
		var prop = {value="ColdFusion,Java,Go,C++,ActionScript",size="1,10"};
		assertTrue(validator.isValid(prop));
	}

	public void function testListInRangeReturnsFalse(){
		var prop = {value="ColdFusion,Java,Go,C++,ActionScript",size="1,3"};
		assertFalse(validator.isValid(prop));
	}

	public void function testArrayInRangeReturnsTrue(){
		var prop = {value=["ColdFusion","Java"],size="1,10"};
		assertTrue(validator.isValid(prop));
	}

	public void function testArrayInRangeReturnsFalse(){
		var prop = {value=["ColdFusion","Java","Groovy","Python"],size="1,3"};
		assertFalse(validator.isValid(prop));
	}
	
	public void function tesStructKeyCountInRangeReturnsTrue(){
		var prop = {value={name="Dan Vega",city="Cleveland",state="OH"},size="1,10"};
		assertTrue(validator.isValid(prop));
	}

	public void function testStructKeyCountInRangeReturnsFalse(){
		var prop = {value={name="Dan Vega",city="Cleveland",state="OH",zip="44113"},size="1,3"};
		assertFalse(validator.isValid(prop));
	}
}