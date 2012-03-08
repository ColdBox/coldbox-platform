/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
*/
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.validation.GenericObject"{

	function setup(){
		super.setup();
		model.init( {name="luis", age="33"} );
	}
	
	function testGett(){
		assertEquals("luis", model.getName() );
		assertEquals("33", model.getAge() );
		
	}
	
	function testBad() expectedException="GenericObject.InvalidKey"{
		assertEquals("luis", model.getThere() );
	}
	
}