component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		config = createMock( "coldbox.system.cache.config.DefaultConfiguration" );
	}

	function testConfigure(){
		config.configure();
	}

}
