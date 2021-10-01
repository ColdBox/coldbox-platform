component extends="tests.resources.BaseIntegrationTest" {

	function run( testResults, testBox ){
		describe( "Loader services", function(){
			beforeEach( function( currentSpec ){
				setup();
				ls = getController().getLoaderService();
			} );


			it( "can register handlers", function(){
				var context   = "";
				var dummyFile = getController().getSetting( "HandlersPath" ) & "/dummy.cfc";

				createFile( dummyFile );
				getController().getHandlerService().registerHandlers();

				try {
					assertTrue( listFindNoCase( getController().getSetting( "RegisteredHandlers" ), "dummy" ) );
				} finally {
					removeFile( dummyFile );
				}
			} );
		} );
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
