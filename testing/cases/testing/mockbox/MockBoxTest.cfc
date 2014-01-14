<cfcomponent extends="coldbox.system.testing.BaseSpec" displayname="MockBox Suite">
	
	<cfscript>
	
		function setup(){
			test = getMockBox().createEmptyMock( "coldbox.testing.cases.testing.resources.Test" );
		}
		
		function testMockRealMethods(){
			Test = getMockBox().createMock( "coldbox.testing.cases.testing.resources.Test" );
			test.getData();
			$assert.isEqual( -1, test.$count( "getData" ) );
			test.$( "getData", 1000 );
			$assert.isEqual( 0, test.$count( "getData" ) );
			test.getData();
			test.getData();
			$assert.isEqual( 2, test.$count( "getData" ) );
		
			// With DSL
			test.$reset().$( "getData" ).$results( 1000 );
			$assert.isEqual( 0, test.$count( "getData" ) );
			test.getData();
			test.getData();
			$assert.isEqual( 2, test.$count( "getData" ) );
			$assert.isEqual( 1000, test.getData() );
		}
		
		function testVirtualMethods(){
			Test = getMockBox().createMock( "coldbox.testing.cases.testing.resources.Test" );
			test.$( "virtualReturn" ).$results( 'Virtual Called Baby!!' );
			$assert.isEqual( 0, test.$count( "virtualReturn" ) );
			$assert.isEqual( "Virtual Called Baby!!", test.virtualReturn() );
			debug( test.$callLog() );
			$assert.isTrue( structKeyExists( test.$callLog(), "virtualReturn" ) );
		}
		
		function testProperties(){
			Test = getMockBox().createMock( "coldbox.testing.cases.testing.resources.Test" );
			// reload original property value
			original = test.getReload();
			test.$property( propertyName="reload", propertyScope="variables", mock=true );
			$assert.isEqual( true, test.getReload() );
		}
		
		function testMockPrivateMethods(){
			Test = getMockBox().createMock( "coldbox.testing.cases.testing.resources.Test" );
			name = test.getFullName();
			debug( name );
			test.$( "getName", "Mock Ruler" );
			$assert.isEqual( "Mock Ruler", test.getFullName() );
		}
		
		function testSpys(){
			Test = createObject( "component", "coldbox.testing.cases.testing.resources.Test" );
			getMockBox().prepareMock( test );
			// mock un-spy methods
			$assert.isEqual( 5, test.getData() );
			$assert.isEqual( 5, test.spyTest() );
			// spy the methods
			test.$( "getData" ).$results( 1000 );
			$assert.isEqual( 1000, test.getData() );
			$assert.isEqual( 0, test.spyTest() );
		}
		
		function testMockWithArguments(){
			Test = getMockBox().createMock( "coldbox.testing.cases.testing.resources.Test" );
			//unmocked
			$assert.isEqual( "/mockFactory", test.getSetting( "AppMapping" ) );
			$assert.isEqual( "NOT FOUND", test.getSetting( "DebugMode" ) );
		
			// Mock
			test.$( method='getSetting', callLogging=true ).$args( "AppMapping" ).$results( "mockbox.testing" );
			test.$( method='getSetting', callLogging=true ).$args( "DebugMode" ).$results( "true" );
			$assert.isEqual( "mockbox.testing", test.getSetting( "AppMapping" ) );
			$assert.isEqual( "true", test.getSetting( "DebugMode" ) );
		}
		
		function testCollaborator(){
			Test = createObject( "component", "coldbox.testing.cases.testing.resources.Test" );
			mockCollaborator = getMockBox().createMock( className="coldbox.testing.cases.testing.resources.Collaborator", 
		                                             callLogging=true );
		
			mockCollaborator.$( "getDataFromDB" ).$results( queryNew( "" ) );
			Test.setCollaborator( mockCollaborator );
			debug( mockCollaborator.$callLog() );
			$assert.isEqual( queryNew( "" ), test.displayData() );
		}
		
		function testStateMachineResults(){
			Test = getMockBox().createMock( "coldbox.testing.cases.testing.resources.Test" );
			test.$( "getSetting" ).$results( "S1", "S2", "S3" );
		
			$assert.isEqual( "S1", test.getSetting() );
			$assert.isEqual( "S2", test.getSetting() );
			$assert.isEqual( "S3", test.getSetting() );
			$assert.isEqual( "S1", test.getSetting() );
			$assert.isEqual( "S2", test.getSetting() );
		}
		
		function testStubs(){
			stub = getMockBox().createStub().$( "getName", "Luis Majano" );
			$assert.isEqual( "Luis Majano", stub.getName() );
		}
		
		function testVerifyOnce(){
			test.$( "displayData", queryNew( '' ) ).$( "testIt" ).$( "testNone" );
			test.testIt();
			$assert.isTrue( test.$once() );
			test.displayData();
			$assert.isTrue( test.$once( "displayData" ) );
		
			$assert.isFalse( test.$once( "testNone" ) );
		}
		
		function testVerifyNever(){
			test.$( "displayData", queryNew( '' ) );
			test.$( "testIt" );
			$assert.isTrue( test.$never() );
			test.testIt();
			$assert.isTrue( test.$never( "displayData" ) );
			test.displayData();
			$assert.isFalse( test.$never( "displayData" ) );
		}
		
		function testVerifyAtMost(){
			test.$( "displayData", queryNew( '' ) );
			test.displayData();
			test.displayData();
			test.displayData();
			test.displayData();
			test.displayData();
			$assert.isFalse( test.$atMost( 3 ) );
			$assert.isTrue( test.$atMost( 5 ) );
		}
		
		function testVerifyAtLeast(){
			test.$( "displayData", queryNew( '' ) );
			$assert.isTrue( test.$atLeast( 0 ) );
			test.displayData();
			test.displayData();
			test.displayData();
			test.displayData();
			test.displayData();
			$assert.isTrue( test.$atLeast( 3 ) );
		}
		
		function testVerifyCallCount(){
			test.$( "displayData", queryNew( '' ) );
			$assert.isTrue( test.$verifyCallCount( 0 ) );
			$assert.isFalse( test.$verifyCallCount( 1 ) );
		
			test.displayData();
			$assert.isEqual( true, test.$verifyCallCount( 1 ) );
		
			test.displayData();
			test.displayData();
			test.displayData();
			$assert.isEqual( true, test.$verifyCallCount( 4 ) );
			$assert.isEqual( true, test.$verifyCallCount( 4, "displayData" ) );
		}
		
		function testMockMethodCallCount(){
			test.$( "displayData", queryNew( '' ) );
			test.$( "getLuis", 1 );
		
			$assert.isEqual( 0, test.$count( "displayData" ) );
			$assert.isEqual( -1, test.$count( "displayData2" ) );
		
			test.displayData();
		
			$assert.isEqual( 1, test.$count( "displayData" ) );
		
			test.getLuis();
			test.getLuis();
			$assert.isEqual( 3, test.$count() );
		}
		
		function testMethodArgumentSignatures(){
			
			args = {
				string = "test" // string
				,integer = 23 // integer
				,xmlDoc = xmlNew()
				,query = queryNew('')
				,datetime = now()
				,boolean = true
				,realNumber = 2.5
				,structure = {key1 = 'value1',key2 = getMockBox().createStub()}
				,array = ['element1', getMockBox().createStub()]
				,object = getMockBox().createStub()
				,aNull = javaCast("null", "")
			};
			
			//1: Mock with positional and all calls should validate.
			test.$( "getSetting" )
				.$args( args.string, args.integer, args.xmlDoc, args.query, args.datetime, args.boolean, args.realNumber, args.structure, args.array, args.object )
				.$results( "UnitTest" );
		
			// Test positional
			results = test.getSetting( args.string, args.integer, args.xmlDoc, args.query, args.datetime, args.boolean, args.realNumber, args.structure, args.array, args.object );
			$assert.isEqual( "UnitTest", results );
			// Test case sensitivity
			args.string = "TEST";
			results = test.getSetting( args.string, args.integer, args.xmlDoc, args.query, args.datetime, args.boolean, args.realNumber, args.structure, args.array, args.object );
			$assert.isEqual( "UnitTest", results );
			args.string = "test";
			// Test increment/decrement value (ColdFusion bug converts integers to real numbers with increment and decrement operator)
			args.integer++; args.integer--;
			results = test.getSetting( args.string, args.integer, args.xmlDoc, args.query, args.datetime, args.boolean, args.realNumber, args.structure, args.array, args.object );
			$assert.isEqual( "UnitTest", results );
			args.integer = 23;
			args.integer = 23;
			
			//2. Mock with named values and all calls should validate.
			test.$( "getSetting" ).$args( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object ).$results( "UnitTest2" );
			
			// Test name-value pairs
			results = test.getSetting( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object );
			$assert.isEqual( "UnitTest2", results );
			// Test argCollection
			results = test.getSetting( argumentCollection=args );
			$assert.isEqual( "UnitTest2", results );
			// Test case sensitivity
			args.string = "TEST";
			results = test.getSetting( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object );
			$assert.isEqual( "UnitTest2", results );
			args.string = "test";
			// Test increment/decrement value (ColdFusion bug converts integers to real numbers with increment and decrement operator)
			args.integer++;args.integer--;
			results = test.getSetting( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object );
			$assert.isEqual( "UnitTest2", results );
			args.integer = 23;
			
			test.$( "getSetting" ).$args( argumentCollection=args ).$results( "UnitTest3" );
			// Test name-value pairs
			results = test.getSetting( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object );
			$assert.isEqual( "UnitTest3", results );
			// Test argCollection
			results = test.getSetting( argumentCollection=args );
			$assert.isEqual( "UnitTest3", results );
			// Test case sensitivity
			args.string = "TEST";
			results = test.getSetting( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object );
			$assert.isEqual( "UnitTest3", results );
			args.string = "test";
			// Test increment/decrement value (ColdFusion bug converts integers to real numbers with increment and decrement operator)
			args.integer++;args.integer--;
			results = test.getSetting( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object );
			$assert.isEqual( "UnitTest3", results );
		}
		
		function testGetProperty(){
			mock = getMockBox().createStub();
			mock.luis = "Majano";
			mock.$property( "cool", "variables", true ).$property( "number", "variables.instance", 7 );
		
			$assert.isEqual( "Majano", mock.$getProperty( name="luis", scope="this" ) );
			$assert.isEqual( true, mock.$getProperty( name="cool" ) );
			$assert.isEqual( true, mock.$getProperty( name="cool", scope="variables" ) );
			$assert.isEqual( 7, mock.$getProperty( name="number", scope="variables.instance" ) );
			$assert.isEqual( 7, mock.$getProperty( name="number", scope="instance" ) );
		}
		
		function testStubWithInheritance(){
			mock = getMockBox().createStub( extends="coldbox.system.EventHandler" );
			$assert.isTrue( isInstanceOf( mock, "coldbox.system.EventHandler" ) );
		}
		
		function testStubWithImplements(){
			mock = getMockBox().createStub( implements="coldbox.system.cache.ICacheProvider" );
			$assert.isTrue( isInstanceOf( mock, "coldbox.system.cache.ICacheProvider" ) );
		}
		
		function testContainsCFKeyword(){
			test = getMockBox().createMock("coldbox.testing.cases.testing.resources.Test");
			mockTest = getMockBox().createEmptyMock( "coldbox.testing.cases.testing.resources.ContainsTest" )
				.$("contains", true);
			$assert.isTrue( mockTest.contains() );
		}
		
		function testContainsClosureOrUDF(){
			mock = getMockBox().createStub();
			mock.$("mockMe", "Mocked" );
			
			$assert.isEqual( "Mocked" , mock.mockMe( variables.testFunction ) );
			$assert.isEqual( "Mocked" , mock.mockMe( test = variables.testFunction ) );
			$assert.isEqual( "Mocked" , mock.mockMe( [ variables.testFunction ] ) );
			$assert.isEqual( "Mocked" , mock.mockMe( test = [ variables.testFunction ] ) );
			$assert.isEqual( "Mocked" , mock.mockMe( { mockData = variables.testFunction } ) );
			$assert.isEqual( "Mocked" , mock.mockMe( test = { mockData = variables.testFunction } ) );
		}
		
		function testInterfaceContracts(){
			mock = getMockBox().createMock( "coldbox.testing.cases.testing.resources.MyInterfaceMock" );
			mock.$("testThis", "mocked!");
			
			$assert.isEqual( "mocked!", mock.testThis( "name", 35 ) );
		}

		function testCFUDF(){
			var mocked = getMockBox().createStub().$( "getLocale", "en-GB" );
			$assert.isEqual( "en-GB", local.mocked.getLocale() );
		}

		private function testFunction(){
			return "Hola Amigo!";
		}
	</cfscript>

</cfcomponent>