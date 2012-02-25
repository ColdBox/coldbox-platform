/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
*/
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.validation.result.ValidationError"{

	function setup(){
		super.setup();
		model.init();
	}
	
	function testObject(){
		assertEquals( "", model.getMessage() );
		assertEquals( "", model.getField() );
		assertEquals( "", model.getRejectedValue() );
		
		model.configure("hello","name","oops");
		assertEquals( "hello", model.getMessage() );
		assertEquals( "name", model.getField() );
		assertEquals( "oops", model.getRejectedValue() );
		
		assertEquals( "hello", model.getMemento().message );
		assertEquals( "name", model.getMemento().field );
		assertEquals( "oops", model.getMemento().rejectedValue );
		
		
		
	}
}