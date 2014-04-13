/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
*/
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.validation.validators.InListValidator"{

	function setup(){
		super.setup();
		model.init();
	}
	
	function testValidate(){
		result = getMockBox().createMock("coldbox.system.validation.result.ValidationResult").init();
		
		
		// not empty
		r = model.validate(result,this,'test',"nancy","luis,joe,alexia,vero");
		assertEquals( false, r );
		
		// not empty
		r = model.validate(result,this,'test',"alexia","luis,joe,alexia,vero");
		assertEquals( true, r );
		
	}
	
	function getLuis(){ return 'luis'; }
}