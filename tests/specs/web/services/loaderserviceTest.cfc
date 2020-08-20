component extends="tests.resources.BaseIntegrationTest"{

	function setup(){
		super.setup();

		ls = getController().getLoaderService();
	}

	function testRegisterHandlers(){
		var context   = "";
		var fs        = "/";
		var dummyFile = getController().getSetting( "HandlersPath" ) & fs & "dummy.cfc";

		createFile( dummyFile );
		getController().getHandlerService().registerHandlers();
		assertTrue( listFindNoCase( getController().getSetting( "RegisteredHandlers" ), "dummy" ) );
		removeFile( dummyFile );
	}


	function testProcessShutdown(){
		ls.processShutdown();
	}

	private function createFile( required filename ){
		var fileObj = createObject( "java", "java.io.File" ).init( javacast( "string", arguments.filename ) );
		fileObj.createNewFile();
	}

	private function removeFile( required filename ){
		var fileObj = createObject( "java", "java.io.File" ).init( javacast( "string", arguments.filename ) );
		return fileObj.delete();
	}

}