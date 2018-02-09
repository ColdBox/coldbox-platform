component extends="coldbox.system.testing.BaseModelTest"{

	function setup(){
		cfmlengine = new coldbox.system.core.util.CFMLEngine();
	}

	function testCFMLEngine(){
		version = listfirst(server.coldfusion.productversion);
		engine = server.coldfusion.productname;

		if( findnocase( "coldfusion", engine) ){
			enginetype = "adobe";
		} else if ( findnocase( "lucee", engine ) ){
			enginetype = "lucee";
		}

		AssertTrue( len( cfmlengine.getEngine() ) gt 0, "Engine test" );

		AssertTrue( isNumeric( cfmlengine.getVersion() ) , "Version Test" );

	}
}