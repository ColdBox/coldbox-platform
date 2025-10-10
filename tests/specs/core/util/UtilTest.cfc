component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		util   = createMock( "coldbox.system.core.util.Util" );
		class1 = createObject( "component", "tests.resources.Class1" );
	}

	function isInstanceCheck(){
		test = createObject( "component", "coldbox.tests.testHandlers.BaseTest" );
		assertTrue( util.isInstanceCheck( test, "coldbox.system.EventHandler" ) );

		test = createObject( "component", "coldbox.tests.testHandlers.ehTest" );
		assertTrue( util.isInstanceCheck( test, "coldbox.system.EventHandler" ) );

		test = createObject( "component", "coldbox.tests.testHandlers.TestNoInheritance" );
		assertFalse( util.isInstanceCheck( test, "coldbox.system.EventHandler" ) );
	}

	function testStopClassRecursion(){
		var stopRecursions = [
			"com.foo.bar",
			"com.foobar",
			"coldbox.system.coldbox"
		];

		makePublic( util, "stopClassRecursion" );
		assertFalse( util.stopClassRecursion( "com.google", stopRecursions ) );
		assertTrue( util.stopClassRecursion( "com.foobar", stopRecursions ) );
	}

	function testGetInheritedMetaData(){
		var md = util.getInheritedMetaData( class1 );
		testGetInheritedMetaDataHelper( md );

		var md = util.getInheritedMetaData( "tests.resources.Class1" );
		testGetInheritedMetaDataHelper( md );
	}

	function testGetInheritedMetaDataStopRecursion(){
		var stopRecursions = [ "tests.resources.Class2" ];

		var md = util.getInheritedMetaData( class1, stopRecursions );
		testGetInheritedMetaDataStopRecursionHelper( md );

		var md = util.getInheritedMetaData( "tests.resources.Class1", stopRecursions );
		testGetInheritedMetaDataStopRecursionHelper( md );
	}

	private function testGetInheritedMetaDataHelper( md ){
		assertTrue( structKeyExists( md, "inheritanceTrail" ) );

		assertEquals( md.inheritanceTrail[ 1 ], "tests.resources.Class1" );
		assertEquals( md.inheritanceTrail[ 2 ], "tests.resources.Class2" );
		assertEquals( md.inheritanceTrail[ 3 ], "tests.resources.Class3" );

		assertEquals( md.scope, "server" );

		assertTrue( structKeyExists( md, "annotationClass1Only" ) );
		assertTrue( structKeyExists( md, "annotationClass2Only" ) );
		assertTrue( structKeyExists( md, "annotationClass3Only" ) );
		assertTrue( structKeyExists( md, "annotationClass1and2and3" ) );
		assertEquals( md.annotationClass1Only, "class1Value" );
		assertEquals( md.annotationClass2Only, "class2Value" );
		assertEquals( md.annotationClass3Only, "class3Value" );
		assertEquals( md.annotationClass1and2and3, "class1Value" );

		assertTrue( itemExists( md.functions, "funcClass1Only" ) );
		assertEquals( getItemKey( md.functions, "funcClass1Only", "hint" ), "Function defined in Class1" );
		assertTrue( itemExists( md.functions, "funcClass2Only" ) );
		assertEquals( getItemKey( md.functions, "funcClass2Only", "hint" ), "Function defined in Class2" );
		assertTrue( itemExists( md.functions, "funcClass3Only" ) );
		assertEquals( getItemKey( md.functions, "funcClass3Only", "hint" ), "Function defined in Class3" );
		assertTrue( itemExists( md.functions, "funcClass1and2and3" ) );
		assertEquals( getItemKey( md.functions, "funcClass1and2and3", "hint" ), "Function defined in Class1" );

		assertTrue( itemExists( md.properties, "propClass1Only" ) );
		assertEquals( getItemKey( md.properties, "propClass1Only", "default" ), "class1Value" );
		assertTrue( itemExists( md.properties, "propClass2Only" ) );
		assertEquals( getItemKey( md.properties, "propClass2Only", "default" ), "class2Value" );
		assertTrue( itemExists( md.properties, "propClass3Only" ) );
		assertEquals( getItemKey( md.properties, "propClass3Only", "default" ), "class3Value" );
		assertTrue( itemExists( md.properties, "propClass1and2and3" ) );
		assertEquals( getItemKey( md.properties, "propClass1and2and3", "default" ), "class1Value" );
	}

	private function testGetInheritedMetaDataStopRecursionHelper( md ){
		assertTrue( structKeyExists( md, "inheritanceTrail" ) );
		assertEquals( arrayLen( md.inheritanceTrail ), 1 );
		assertEquals( md.inheritanceTrail[ 1 ], "tests.resources.Class1" );

		if ( md.keyExists( "scope" ) ) {
			assertEquals( md.scope, "server" );
		} else {
			assertEquals( md.annotations.scope, "server" );
		}

		assertTrue( structKeyExists( md, "annotationClass1Only" ) );
		assertFalse( structKeyExists( md, "annotationClass2Only" ) );
		assertFalse( structKeyExists( md, "annotationClass3Only" ) );
		assertTrue( structKeyExists( md, "annotationClass1and2and3" ) );
		assertEquals( md.annotationClass1Only, "class1Value" );
		assertEquals( md.annotationClass1and2and3, "class1Value" );

		assertEquals( arrayLen( md.functions ), 2 );
		assertTrue( itemExists( md.functions, "funcClass1Only" ) );
		assertEquals( getItemKey( md.functions, "funcClass1Only", "hint" ), "Function defined in Class1" );
		assertFalse( itemExists( md.functions, "funcClass2Only" ) );
		assertFalse( itemExists( md.functions, "funcClass3Only" ) );
		assertTrue( itemExists( md.functions, "funcClass1and2and3" ) );
		assertEquals( getItemKey( md.functions, "funcClass1and2and3", "hint" ), "Function defined in Class1" );

		assertEquals( arrayLen( md.properties ), 2 );
		assertTrue( itemExists( md.properties, "propClass1Only" ) );
		assertEquals( getItemKey( md.properties, "propClass1Only", "default" ), "class1Value" );
		assertFalse( itemExists( md.properties, "propClass2Only" ) );
		assertFalse( itemExists( md.properties, "propClass3Only" ) );
		assertTrue( itemExists( md.properties, "propClass1and2and3" ) );
		assertEquals( getItemKey( md.properties, "propClass1and2and3", "default" ), "class1Value" );
	}


	private function itemExists( itemArray, itemName ){
		for ( var i = 1; i <= arrayLen( itemArray ); i++ ) {
			if ( itemArray[ i ].name == itemName ) {
				return true;
			}
		}
		return false;
	}

	private function getItemKey( itemArray, itemName, key ){
		for ( var i = 1; i <= arrayLen( itemArray ); i++ ) {
			if ( itemArray[ i ].name == itemName ) {
				if ( itemArray[ i ].keyExists( key ) ) {
					return itemArray[ i ][ key ];
				}
				// Else look for it in the annotations root
				if ( itemArray[ i ].annotations.keyExists( key ) ) {
					return itemArray[ i ].annotations[ key ];
				}
				// Else in the documentation root
				if ( itemArray[ i ].documentation.keyExists( key ) ) {
					return itemArray[ i ].documentation[ key ];
				}
			}
		}
		fail( "Item '#itemName#' doesn't exists." );
	}

}
