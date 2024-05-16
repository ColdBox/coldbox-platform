component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		target = new coldbox.system.core.util.CFMLEngine();
	}

	function testGetVersion(){
		expect( target.getVersion() ).toBeNumeric();
	}

	function testGetFullVersion(){
		expect( target.getFullVersion() ).toBeString();
	}

	function testGetEngine(){
		expect( target.getEngine() ).toBeString();
	}

}
