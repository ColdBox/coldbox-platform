/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
*/
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.validation.validators.SizeValidator"{

	function setup(){
		super.setup();
		model.init();
	}
	
	function testValidateSimple(){
		result = getMockBox().createMock("coldbox.system.validation.result.ValidationResult").init();
		
		r = model.validate(result,this,'test',"123","3");
		assertEquals( true, r );
		
		r = model.validate(result,this,'test',"123","5");
		assertEquals( false, r );
		
		r = model.validate(result,this,'test', [1,2,3] ,"5");
		assertEquals( false, r );
		
		r = model.validate(result,this,'test', [1,2,3] ,"3");
		assertEquals( true, r );
		
		r = model.validate(result,this,'test', {} ,"3");
		assertEquals( false, r );
		
		r = model.validate(result,this,'test', {t=1,ts=2,ttt=2} ,"3");
		assertEquals( true, r );
		
		r = model.validate(result,this,'test', queryNew("") ,"3");
		assertEquals( false, r );
		
		mockQuery =  querySim("id
		1
		2
		3");
		debug(mockQuery);
		r = model.validate(result,this,'test',mockQuery,"3");
		assertEquals( true, r );
		r = model.validate(result,this,'test',mockQuery,"5");
		assertEquals( false, r );
		
	}
	
	function testValidateComplex(){
		result = getMockBox().createMock("coldbox.system.validation.result.ValidationResult").init();
		
		r = model.validate(result,this,'test',"123","3..5");
		assertEquals( true, r );
		
		r = model.validate(result,this,'test',"123","5..10");
		assertEquals( false, r );
		
		r = model.validate(result,this,'test', [1,2,3] ,"4..10");
		assertEquals( false, r );
		
		r = model.validate(result,this,'test', [1,2,3] ,"1..3");
		assertEquals( true, r );
		
		r = model.validate(result,this,'test', {} ,"1..3");
		assertEquals( false, r );
		
		r = model.validate(result,this,'test', {t=1,ts=2,ttt=2} ,"1..3");
		assertEquals( true, r );
		
		r = model.validate(result,this,'test', queryNew("") ,"3..3");
		assertEquals( false, r );
		
		mockQuery =  querySim("id
		1
		2
		3");
		debug(mockQuery);
		r = model.validate(result,this,'test',mockQuery,"1..3");
		assertEquals( true, r );
		r = model.validate(result,this,'test',mockQuery,"5");
		assertEquals( false, r );
		
	}
}