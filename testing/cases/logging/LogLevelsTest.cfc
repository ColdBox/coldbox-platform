<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		logLevels = getMockBox().createMock(className="coldbox.system.logging.LogLevels");
	}
	
	function testLookupAsInt(){
		assertEquals( logLevels.lookupAsInt("OFF"), "-1" );
		assertEquals( logLevels.lookupAsInt("FATAL"), "0" );
		assertEquals( logLevels.lookupAsInt("ERROR"), "1" );
		assertEquals( logLevels.lookupAsInt("WARN"), "2" );
		assertEquals( logLevels.lookupAsInt("INFO"), "3" );
		assertEquals( logLevels.lookupAsInt("DEBUG"), "4" );
		assertEquals( logLevels.lookupAsInt("TRACE"), "5" );
	}
</cfscript>
</cfcomponent>