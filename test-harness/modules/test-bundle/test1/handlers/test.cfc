component{

	any function index( event, rc, prc ){
		event.setView( "test/index" );
	}

	any function index2( event, rc, prc ){
		event.setView( view = "test/index", layout = "test1" );
	}

	any function index3( event, rc, prc ){
		event.setLayout( name = "simple", module = "layouttest" );
		event.setView( view = "hello" );
	}

	any function namespaceModel( event, rc, prc ){
		var oModel = getInstance( "TestService@test1" );
		return oModel.sayHello();
	}

	any function cfmlMapping( event, rc, prc ){
		var service = new cbModuleTest1.models.TestService();
		return service.sayHello();
	}
}
