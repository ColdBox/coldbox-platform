component extends="tests.resources.BaseIntegrationTest" {

	this.loadColdBox = false;

	function setup(){
		super.setup();
		mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( "UnitTest" );
	}

	function testInit(){
		assertEquals( "UnitTest", mapping.getName() );
	}

	function testProcessMemento(){
		var data = {
			alias                  : [ "funky" ],
			type                   : "CFC",
			path                   : "my.models.Funky",
			eagerInit              : true,
			threadSafe             : true,
			scope                  : "singleton",
			cache                  : { key : "data", timeout : "30" },
			DIConstructorArguments : [
				{ name : "val", value : "0" },
				{ name : "transfer", ref : "transfer" }
			],
			DIProperties : [
				{ name : "user", dsl : "provider:User" },
				{
					name     : "nonRequired",
					dsl      : "provider:User",
					required : false
				}
			],
			DISetters : [
				{ name : "Joke", value : "You!" },
				{
					name    : "service",
					ref     : "MyService",
					argName : "MyService"
				}
			],
			DIMethodArguments : [
				{ name : "Joke", value : "You!" },
				{ name : "service", ref : "MyService" }
			]
		};

		mapping.processMemento( data );

		assertEquals( data.threadSafe, mapping.getThreadSafe() );
		assertEquals( data.alias, mapping.getAlias() );
		assertEquals( data.type, mapping.getTYpe() );
		assertEquals( data.path, mapping.getPath() );
		assertEquals( "init", mapping.getConstructor() );
		assertEquals( "", mapping.getAutoWire() );
		assertEquals( true, mapping.isAutoInit() );
		assertEquals( true, mapping.isEagerInit() );
		assertEquals( data.scope, mapping.getScope() );
		assertEquals( "", mapping.getDSL() );
		assertEquals( "default", mapping.getCacheProperties().provider );
		assertEquals( "data", mapping.getCacheProperties().key );

		args = mapping.getDIConstructorArguments();
		assertEquals( 2, arrayLen( args ) );

		props = mapping.getDIProperties();
		assertEquals( 2, arrayLen( props ) );
		assertFalse( props[ 2 ].required );

		setters = mapping.getDISetters();
		assertEquals( 2, arrayLen( setters ) );
		assertEquals( "Joke", setters[ 1 ].argName );
		assertEquals( "MyService", setters[ 2 ].argName );


		args = mapping.getDIMethodArguments();
		assertEquals( 2, arrayLen( args ) );

		assertEquals( false, mapping.isAspect() );

		assertEquals( true, mapping.isAspectAutoBinding() );
		mapping.setAspectAutoBinding( false );
		assertEquals( false, mapping.isAspectAutoBinding() );

		assertEquals( "", mapping.getVirtualInheritance() );

		assertEquals( [], mapping.getMixins() );
	}

	function testProcessMementoWithExcludes(){
		var data = {
			name                   : "abstractService",
			alias                  : [ "abstractService" ],
			type                   : "CFC",
			path                   : "path.to.abstractService",
			eagerInit              : true,
			scope                  : "singleton",
			cache                  : { key : "data", timeout : "30" },
			DIConstructorArguments : [
				{ name : "val", value : "0" },
				{ name : "transfer", ref : "transfer" }
			],
			DIProperties : [ { name : "user", dsl : "provider:User" } ],
			DISetters    : [
				{ name : "Joke", value : "You!" },
				{
					name    : "service",
					ref     : "MyService",
					argName : "MyService"
				}
			],
			DIMethodArguments : [
				{ name : "Joke", value : "You!" },
				{ name : "service", ref : "MyService" }
			]
		};

		mapping.processMemento( data, "name,alias,path" );

		// name should still be "UnitTest" and not "abstractService"
		assertEquals( "UnitTest", mapping.getName() );
		assertNotEquals( data.name, mapping.getName() );
		// alias should still be empty array [] and not [ "abstractService" ]
		assertEquals( 0, arrayLen( mapping.getAlias() ) );
		assertNotEquals( data.alias, mapping.getAlias() );
		// path should still be "" and not "path.to.abstractService"
		assertEquals( "", mapping.getPath() );
		assertNotEquals( data.path, mapping.getPath() );

		// process memento should have copied over all other data except the ones above
		assertEquals( data.type, mapping.getTYpe() );
		assertEquals( "init", mapping.getConstructor() );
		assertEquals( "", mapping.getAutoWire() );
		assertEquals( true, mapping.isAutoInit() );
		assertEquals( true, mapping.isEagerInit() );
		assertEquals( data.scope, mapping.getScope() );
		assertEquals( "", mapping.getDSL() );
		assertEquals( "default", mapping.getCacheProperties().provider );
		assertEquals( "data", mapping.getCacheProperties().key );
		assertEquals( 2, arrayLen( mapping.getDIConstructorArguments() ) );
		assertEquals( 1, arrayLen( mapping.getDIProperties() ) );

		setters = mapping.getDISetters();
		assertEquals( 2, arrayLen( setters ) );
		assertEquals( "Joke", setters[ 1 ].argName );
		assertEquals( "MyService", setters[ 2 ].argName );

		assertEquals( 2, arrayLen( mapping.getDIMethodArguments() ) );
		assertEquals( false, mapping.isAspect() );
		assertEquals( true, mapping.isAspectAutoBinding() );
		mapping.setAspectAutoBinding( false );
		assertEquals( false, mapping.isAspectAutoBinding() );
		assertEquals( "", mapping.getVirtualInheritance() );
		assertEquals( [], mapping.getMixins() );
	}

	function testProviderMethods(){
		assertEquals( 0, arrayLen( mapping.getProviderMethods() ) );
		mapping.addProviderMethod( "createRandom", "MyRandomOBJ" );
		assertEquals( 1, arrayLen( mapping.getProviderMethods() ) );
		methods = mapping.getProviderMethods();
		assertEquals( "MyRandomOBJ", methods[ 1 ].mapping );
		assertEquals( "createRandom", methods[ 1 ].method );
	}

}
