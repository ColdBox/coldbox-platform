﻿component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		target = new coldbox.system.core.util.CFMLEngine();
	}

	function testGetVersion(){
		expect( target.getVersion() ).notToBeEmpty();
	}

	function testGetFullVersion(){
		expect( target.getFullVersion() ).toBeString( target.getFullVersion() );
	}

	function testGetEngine(){
		expect( target.getEngine() ).toBeString( target.getEngine() );
	}

}
