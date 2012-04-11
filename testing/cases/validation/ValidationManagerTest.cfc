/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
*/
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.validation.ValidationManager"{

	function setup(){
		super.setup();
		mockRB = getMockBox().createEmptyMock("coldbox.system.plugins.ResourceBundle");
		model.init( mockWireBox, mockRB );
	}
	
	function testProcessRules(){
		results = getMockBox().createMock("coldbox.system.validation.result.ValidationResult").init();
		
		mockValidator = getMockBox().createMock("coldbox.testing.cases.validation.resources.MockValidator").$("validate",true);
		model.$("getValidator", mockValidator);
		mockRules = {
			required = true,
			sameAs = "joe"
		};
		getMockBox().prepareMock(this).$("getName","luis");
		
		model.processRules(results, mockRules, this,"name");
		AssertEquals( true, model.$times(2,"getValidator") );
		
	}
	
	function testGetConstraints(){
		assertTrue( structIsEmpty( model.getSharedConstraints() ) );
		data = { 'test' = {} };
		model.setSharedConstraints( data );
		debug( model.getSharedConstraints() );
		assertTrue( structIsEmpty( model.getSharedConstraints('test') ) );
	}
	
	function testGenericForm(){
		
		mockData = { name="luis", age="33" };
		mockConstraints = { 
			name = {required=true}, age = {required=true, max="35"}
		};
		
		r = model.validate(target=mockData,constraints=mockConstraints);
		assertEquals( false, r.hasErrors() );
			
		mockData = { name="luis", age="55" };
		r = model.validate(target=mockData,constraints=mockConstraints);
		assertEquals( true, r.hasErrors() );
		debug( r.getAllErrors() );
	}
	
}