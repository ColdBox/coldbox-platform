/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
*/
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.validation.validators.RequiredValidator"{

	function setup(){
		super.setup();
		model.init();
	}
	
	function testValidate(){
		result = getMockBox().createMock("coldbox.system.validation.result.ValidationResult").init();
		// null
		r = model.validate(result,this,'test',javacast("null",""),"true");
		assertEquals( false, r );
		// empty
		r = model.validate(result,this,'test',"","true");
		assertEquals( false, r );
		
		// not empty
		r = model.validate(result,this,'test',"woot","true");
		assertEquals( true, r );
		
		// not empty
		r = model.validate(result,this,'test',"woot","false");
		assertEquals( true, r );
		
	}
	
	function testValidateComplex(){
		result = getMockBox().createMock("coldbox.system.validation.result.ValidationResult").init();
		// array
		r = model.validate(result,this,'test', [1,2,3] ,"true");
		assertEquals( true, r );
		
		// query
		r = model.validate(result,this,'test', querySim("id, name
		1 | Luis") ,"true");
		assertEquals( true, r );
		
		// struct
		r = model.validate(result,this,'test', { name="luis", awesome=true } ,"true");
		assertEquals( true, r );
		
		// object
		r = model.validate(result,this,'test', this ,"true");
		assertEquals( true, r );
	}
}