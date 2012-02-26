/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
*/
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.validation.result.ValidationResult"{

	function setup(){
		super.setup();
		model.init();
	}
	
	function testResultsMetadata(){
		assertTrue( structIsEmpty(model.getResultMetadata()) );
		mock = {
			name = "luis", value = "majano"
		};
		model.setResultMetadata( mock );
		assertEquals( mock, model.getResultMetadata() );
	}
	
	function testAddError(){
		mockError = getMockBox().createMock("coldbox.system.validation.result.ValidationError").init();
		mockError.configure("unit test","test");
		assertTrue( arrayLen(model.getErrors()) eq 0 );
		
		model.addError( mockError );
		assertTrue( arrayLen(model.getErrors()) eq 1 );
	}
	
	function testHasErrors(){
		assertFalse( model.hasErrors() );
		mockError = getMockBox().createMock("coldbox.system.validation.result.ValidationError").init().configure("unit test","test");
		model.addError( mockError );
		assertTrue( model.hasErrors() );
		
		model.clearErrors();
		
		// with fields
		assertFalse(  model.hasErrors('test') );
		mockError = getMockBox().createMock("coldbox.system.validation.result.ValidationError").init().configure("unit test","test");
		model.addError( mockError );
		assertTrue(  model.hasErrors('test') );
	}
	
	function testErrorCounts(){
		
		assertEquals( 0, model.getErrorCount() );
		assertEquals( 0, model.getErrorCount("test") );
		
		mockError = getMockBox().createMock("coldbox.system.validation.result.ValidationError").init().configure("unit test","test");
		model.addError( mockError );
		
		assertEquals( 1, model.getErrorCount() );
		assertEquals( 1, model.getErrorCount("test") );
		
	}
}