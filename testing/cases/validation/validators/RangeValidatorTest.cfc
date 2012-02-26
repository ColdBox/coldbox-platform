/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
*/
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.validation.validators.RangeValidator"{

	function setup(){
		super.setup();
		model.init();
	}
	
	function testValidateSimple(){
		result = getMockBox().createMock("coldbox.system.validation.result.ValidationResult").init();
		
		r = model.validate(result,this,'test',"10","1..10");
		assertEquals( true, r );
		
		r = model.validate(result,this,'test',"123","5..9");
		assertEquals( false, r );
		
		
	}
}