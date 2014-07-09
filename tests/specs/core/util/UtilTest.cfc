﻿<cfcomponent extends="coldbox.system.testing.BaseModelTest">
<cfscript>
	function setup(){
		util = CreateObject("component","coldbox.system.core.util.Util");
		class1 = CreateObject("component","tests.resources.Class1");
	}

	function isInstanceCheck(){
		test = createObject("component","coldbox.tests.testhandlers.BaseTest");
		assertTrue( util.isInstanceCheck( test, "coldbox.system.EventHandler") );

		test = createObject("component","coldbox.tests.testhandlers.ehTest");
		assertTrue( util.isInstanceCheck( test, "coldbox.system.EventHandler") );

		test = createObject("component","coldbox.tests.testhandlers.TestNoInheritance");
		assertFalse( util.isInstanceCheck( test, "coldbox.system.EventHandler") );
	}

	function testStopClassRecursion(){
		stopRecursions = ["com.foo.bar","com.foobar","coldbox.system.coldbox"];

		makePublic(util,"stopClassRecursion");
		assertFalse( util.stopClassRecursion( "com.google", stopRecursions ) );
		assertTrue( util.stopClassRecursion( "com.foobar", stopRecursions ) );
	}

	function testGetInheritedMetaData(){
		md = util.getInheritedMetaData(class1);
		testGetInheritedMetaDataHelper(md);

		md = util.getInheritedMetaData("tests.resources.Class1");
		testGetInheritedMetaDataHelper(md);

	}

	function testGetInheritedMetaDataStopRecursion(){
		stopRecursions = ["tests.resources.Class2"];

		md = util.getInheritedMetaData(class1,stopRecursions);
		testGetInheritedMetaDataStopRecursionHelper(md);

		md = util.getInheritedMetaData("tests.resources.Class1",stopRecursions);
		testGetInheritedMetaDataStopRecursionHelper(md);

	}

	private function testGetInheritedMetaDataHelper(md){

		assertTrue( structKeyExists( md, "inheritanceTrail") );
		assertEquals( arrayLen(md.inheritanceTrail), 4 );
		assertEquals( md.inheritanceTrail[1], "tests.resources.Class1" );
		assertEquals( md.inheritanceTrail[2], "tests.resources.Class2" );
		assertEquals( md.inheritanceTrail[3], "tests.resources.Class3" );
		assertTrue( listFindNoCase("WEB-INF.cftags.component,railo-context.component", md.inheritanceTrail[4]) );

		assertEquals( md.output, true );
		assertEquals( md.scope, "server" );

		assertTrue( structKeyExists( md, "annotationClass1Only") );
		assertTrue( structKeyExists( md, "annotationClass2Only") );
		assertTrue( structKeyExists( md, "annotationClass3Only") );
		assertTrue( structKeyExists( md, "annotationClass1and2and3") );
		assertEquals( md.annotationClass1Only, "class1Value" );
		assertEquals( md.annotationClass2Only, "class2Value" );
		assertEquals( md.annotationClass3Only, "class3Value" );
		assertEquals( md.annotationClass1and2and3, "class1Value" );


		assertEquals( arrayLen(md.functions), 4 );
		assertTrue( itemExists(md.functions, "funcClass1Only") );
		assertEquals( getItemKey(md.functions, "funcClass1Only", "hint"), "Function defined in Class1" );
		assertTrue( itemExists(md.functions, "funcClass2Only") );
		assertEquals( getItemKey(md.functions, "funcClass2Only", "hint"), "Function defined in Class2" );
		assertTrue( itemExists(md.functions, "funcClass3Only") );
		assertEquals( getItemKey(md.functions, "funcClass3Only", "hint"), "Function defined in Class3" );
		assertTrue( itemExists(md.functions, "funcClass1and2and3") );
		assertEquals( getItemKey(md.functions, "funcClass1and2and3", "hint"), "Function defined in Class1" );

		assertEquals( arrayLen(md.properties), 4 );
		assertTrue( itemExists(md.properties, "propClass1Only") );
		assertEquals( getItemKey(md.properties, "propClass1Only", "default"), "class1Value" );
		assertTrue( itemExists(md.properties, "propClass2Only") );
		assertEquals( getItemKey(md.properties, "propClass2Only", "default"), "class2Value" );
		assertTrue( itemExists(md.properties, "propClass3Only") );
		assertEquals( getItemKey(md.properties, "propClass3Only", "default"), "class3Value" );
		assertTrue( itemExists(md.properties, "propClass1and2and3") );
		assertEquals( getItemKey(md.properties, "propClass1and2and3", "default"), "class1Value" );

	}

	private function testGetInheritedMetaDataStopRecursionHelper(md){

		assertTrue( structKeyExists( md, "inheritanceTrail") );
		assertEquals( arrayLen(md.inheritanceTrail), 1 );
		assertEquals( md.inheritanceTrail[1], "tests.resources.Class1" );

		assertEquals( md.output, true );
		assertEquals( md.scope, "server" );

		assertTrue( structKeyExists( md, "annotationClass1Only") );
		assertFalse( structKeyExists( md, "annotationClass2Only") );
		assertFalse( structKeyExists( md, "annotationClass3Only") );
		assertTrue( structKeyExists( md, "annotationClass1and2and3") );
		assertEquals( md.annotationClass1Only, "class1Value" );
		assertEquals( md.annotationClass1and2and3, "class1Value" );

		assertEquals( arrayLen(md.functions), 2 );
		assertTrue( itemExists(md.functions, "funcClass1Only") );
		assertEquals( getItemKey(md.functions, "funcClass1Only", "hint"), "Function defined in Class1" );
		assertFalse( itemExists(md.functions, "funcClass2Only") );
		assertFalse( itemExists(md.functions, "funcClass3Only") );
		assertTrue( itemExists(md.functions, "funcClass1and2and3") );
		assertEquals( getItemKey(md.functions, "funcClass1and2and3", "hint"), "Function defined in Class1" );

		assertEquals( arrayLen(md.properties), 2 );
		assertTrue( itemExists(md.properties, "propClass1Only") );
		assertEquals( getItemKey(md.properties, "propClass1Only", "default"), "class1Value" );
		assertFalse( itemExists(md.properties, "propClass2Only") );
		assertFalse( itemExists(md.properties, "propClass3Only") );
		assertTrue( itemExists(md.properties, "propClass1and2and3") );
		assertEquals( getItemKey(md.properties, "propClass1and2and3", "default"), "class1Value" );

	}


	private function itemExists(itemArray, itemName){
		for(i=1; i<=arrayLen(itemArray); i++){
			if(itemArray[i].name == itemName){
				return true;
			}
		}
		return false;
	}

	private function getItemKey(itemArray, itemName, key){
		for(i=1; i<=arrayLen(itemArray); i++){
			if(itemArray[i].name == itemName){
				return itemArray[i][key];
			}
		}
		fail("Item '#itemName#' doesn't exists.");
	}

</cfscript>
</cfcomponent>