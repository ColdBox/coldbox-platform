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
}