﻿<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init("UnitTest");
	}
	
	function testInit(){
		assertEquals( "UnitTest", mapping.getName() );
	}
	
	function testProcessMemento(){
		var data = {
			alias=["funky"],
			type="CFC",
			path="my.model.Funky",
			eagerInit = true,
			scope="singleton",
			cache={key="data", timeout="30"},
			DIConstructorArgs = [
				{name="val", value="0"},
				{name="transfer", ref="transfer"}
			],
			DIProperties = [
				{name="configBean", dsl="coldbox:configBean"},
				{name="user", dsl="provider:User"}
			],
			DISetters = [
				{name="Joke",value="You!"},
				{name="service", ref="MyService", argName="MyService"}
			],
			DIMethodArgs = [
				{name="Joke",value="You!"},
				{name="service", ref="MyService"}
			]
		};
	
		mapping.processMemento(data);
		
		assertEquals( data.alias, mapping.getAlias() );
		assertEquals( data.type, mapping.getTYpe() );
		assertEquals( data.path, mapping.getPath() );
		assertEquals( "init", mapping.getConstructor() );
		assertEquals( '', mapping.isAutowire() );
		assertEquals( true, mapping.isAutoInit() );
		assertEquals( true, mapping.isEagerInit() );
		assertEquals( data.scope, mapping.getScope() );
		assertEquals( "", mapping.getDSL() );
		assertEquals( "default", mapping.getCacheProperties().provider );
		assertEquals( "data", mapping.getCacheProperties().key );
		
		args = mapping.getDIConstructorArguments();
		assertEquals( 2, arrayLen(args));
		
		props = mapping.getDIProperties();
		assertEquals( 2, arrayLen(props));
		
		setters = mapping.getDISetters();
		assertEquals( 2, arrayLen(setters));
		assertEquals("Joke", setters[1].argName );
		assertEquals("MyService", setters[2].argName );
		
		
		args = mapping.getDIMethodArguments();
		assertEquals( 2, arrayLen(args));
		
		assertEquals( false, mapping.isAspect() );
		
		assertEquals( true, mapping.isAspectAutoBinding() );
		mapping.setAspectAutoBinding(false);
		assertEquals( false, mapping.isAspectAutoBinding() );
		
		assertEquals( '', mapping.getVirtualInheritance() );
		
		assertEquals( [], mapping.getMixins() );
	}
	
	function testProviderMethods(){
		assertEquals(0, arrayLen( mapping.getProviderMethods()) );
		mapping.addProviderMethod("createRandom", "MyRandomOBJ");
		assertEquals(1, arrayLen( mapping.getProviderMethods()) );
		methods = mapping.getProviderMethods();
		assertEquals( "MyRandomOBJ", methods[1].mapping);
		assertEquals( "createRandom", methods[1].method);
	}
	
</cfscript>
</cfcomponent>