/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
*/
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.validation.validators.UDFValidator"{

	function setup(){
		super.setup();
		model.init();
	}
	
	function testValidate(){
		result = getMockBox().createMock("coldbox.system.validation.result.ValidationResult").init();
		
		// not empty
		r = model.validate(result,this,'test',"woot", variables.validate);
		assertEquals( false, r );
		
		// not empty
		r = model.validate(result,this,'test', 55, variables.validate2);
		assertEquals( true, r );
		
	}
	
	private function validate(value,target){
		return false;
	}
	
	private	function validate2(value,target){
		return arguments.value gt 4;
	}
}