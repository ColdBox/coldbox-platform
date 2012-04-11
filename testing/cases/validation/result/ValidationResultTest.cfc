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

	function testLocale(){
		assertFalse( model.hasLocale() );
		model.setLocale( 'en_US' );
		assertTrue( model.hasLocale() );
		assertEquals( 'en_US', model.getLocale() );
	}

	function testTargetName(){
		model.setTargetName( 'User' );
		assertEquals( 'User', model.getTargetName() );
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
		mockError.configure("unit test","test","45","inList","1,2,3");
		assertTrue( arrayLen(model.getErrors()) eq 0 );

		model.addError( mockError );
		assertTrue( arrayLen(model.getErrors()) eq 1 );

		// with custom messages
		mockError = getMockBox().createMock("coldbox.system.validation.result.ValidationError").init();
		mockError.configure("unit test","test","","required","true");
		mockConstraints = {
			"test" = {required = true, requiredMessage="This stuff is required dude!"}
		};
		model.init(constraints=mockConstraints);
		assertTrue( arrayLen(model.getErrors()) eq 0 );
		// test the custom messages now
		model.addError( mockError );
		assertTrue( arrayLen(model.getErrors()) eq 1 );
		r = model.getFieldErrors("test")[1];
		assertEquals( "This stuff is required dude!" , r.getMemento().message );

		// with i18n
		mockError = getMockBox().createMock("coldbox.system.validation.result.ValidationError").init();
		mockError.configure("unit test","test","45","inList","1,2,3");
		model.setLocale("en_US");
		mockRB = getMockBox().createEmptyMock("coldbox.system.plugins.ResourceBundle").$("getResource").$results("Your stuff doesn't work {field} {validationType} {validationData}");
		model.setResourceBundle( mockRB );

		model.addError( mockError );
		debug( mockError.getmemento() );
		assertEquals( "Your stuff doesn't work test inList 1,2,3", mockError.getMessage() );

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