component extends="tests.resources.BaseIntegrationTest" {

	this.loadColdBox = false;

	function setup(){
		xml = createMock( className = "coldbox.system.core.conversion.XMLConverter" ).init();
	}

	function testObjectToXML(){
		test = new tests.resources.Test();

		results = xml.objectToXML( data = test );

		assertTrue( isXML( results ) );
	}

	function testArrayToXML(){
		// 1: No nesting
		test    = [ 1, 2, 3, 4 ];
		results = xml.arrayToXML( data = test, rootElement = "TestArray" );
		assertTrue( isXML( results ) );

		// nesting
		test = [ 1, 2, 3, { key : "test" } ];
		xml.$( "translateValue", "mock value" );
		results = xml.arrayToXML( data = test, rootElement = "TestArray" );
		assertTrue( isXML( results ) );
		// debug(results);
	}

	function testqueryToXML(){
		qTest = querySim(
			"id, name
						  1 | luis
						  2 | sana
						  3 | tom"
		);
		results = xml.queryToXML( data = qTest );
		assertTrue( isXML( results ) );
		// debug(results);

		results = xml.queryToXML( data = qTest, columnList = "id" );
		assertTrue( isXML( results ) );
		// debug(results);
	}

	function testStructToXML(){
		test = { name : "luis", age : "11" };

		results = xml.structToXML( test );
		assertTrue( isXML( results ) );
		// debug(results);

		results = xml.structToXML( data = test, rootElement = "People" );
		assertTrue( isXML( results ) );
		// debug(results);
	}

	function testNullsToXML(){
		test = {
			name    : "luis",
			age     : "11",
			testVal : javacast( "null", "" )
		};

		results = xml.structToXML( test );
		// debug(results);
		assertTrue( isXML( results ) );

		test    = [ javacast( "null", "" ), 1, 3, test ];
		results = xml.toXML( test );
		// debug(results);
		assertTrue( isXML( results ) );
	}

	function testToXML(){
		// 1: Simple Values
		results = xml.toXML( data = "luis" );
		// debug(results);
		assertTrue( isXML( results ) );

		// 2: Simple Array
		ar      = [ 1, 2, 3 ];
		results = xml.toXML( data = ar );
		// debug(results);
		assertTrue( isXML( results ) );

		// 3: Simple Struct
		struct  = { name : "luis", age : "11" };
		results = xml.toXML( data = struct );
		// debug(results);
		assertTrue( isXML( results ) );

		// 4: Query
		qTest = querySim(
			"id, name
						  1 | luis
						  2 | sana
						  3 | tom"
		);
		results = xml.toXML( data = qTest );
		// debug(results);
		assertTrue( isXML( results ) );

		// 5: Nestings
		nested = [
			1,
			2,
			3,
			{ name : "luis", age : "11" },
			5,
			{ name : "majano", age : "33" }
		];
		results = xml.toXML( data = nested );
		// debug(results);
		assertTrue( isXML( results ) );

		nested = {
			name      : "luis",
			age       : "21",
			nicknames : [ "pio", "lui", "lois" ]
		};
		results = xml.toXML( data = nested );
		// debug(results);
		assertTrue( isXML( results ) );
	}

}
