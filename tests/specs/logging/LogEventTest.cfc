<cfcomponent extends="coldbox.system.testing.BaseModelTest">
	<cfscript>
	function setup(){
		log = createMock( className = "coldbox.system.logging.LogEvent" );
	}

	function testextraInfoSimple(){
		log.init( "unittest", 1, "hello", "unittest" );

		r = log.getExtraInfoAsString();

		assertEquals( "hello", r );
	}

	function testExtraInfoComplex(){
		c = { data : "hello", nums : [ 1, 2, 3 ] };
		log.init( "unittest", 1, c, "unittest" );
		r = log.getExtraInfoAsString();
		expect( r ).toBeJson();
	}

	function testExtraInfoConventionString(){
		extra = createObject( "component", "coldbox.tests.specs.logging.ExtraInfo" );
		log.init( "unittest", 1, extra, "unittest" );
		r = log.getExtraInfoAsString();
		// debug(r);

		assertEquals( serializeJSON( extra.getData() ), r );
	}

	function testExtraInfoCFC(){
		extra = createObject( "component", "coldbox.tests.specs.logging.ExtraInfo2" );
		log.init( "unittest", 1, extra, "unittest" );
		r = log.getExtraInfoAsString();
		// debug(r);
		assertTrue( isXML( r ) );
	}
	</cfscript>
</cfcomponent>
