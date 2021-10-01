component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		cfmlengine = new coldbox.system.core.util.CFMLEngine();
	}

	function testCFMLEngine(){
		version = listFirst( server.coldfusion.productversion );
		engine  = server.coldfusion.productname;

		if ( findNoCase( "coldfusion", engine ) ) {
			enginetype = "adobe";
		} else if ( findNoCase( "lucee", engine ) ) {
			enginetype = "lucee";
		}

		assertTrue( len( cfmlengine.getEngine() ) gt 0, "Engine test" );

		assertTrue( isNumeric( cfmlengine.getVersion() ), "Version Test" );
	}

}
