﻿<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.ioc.scopes.RequestScope">
<cfscript>

	function setup(){
		mockLogger = createEmptyMock( "coldbox.system.logging.Logger" ).$( "canDebug",true).$( "debug" ).$( "error" ).$( "canWarn",true).$( "warn" );
		mockLogBox = createEmptyMock( "coldbox.system.logging.LogBox" ).$( "getLogger", mockLogger);
		mockInjector = createMock( "coldbox.system.ioc.Injector" )
			.$( "getUtil", createMock( "coldbox.system.core.util.Util" ))
			.setLogBox( mockLogBox );

		scope = createMock( "coldbox.system.ioc.scopes.RequestScope" ).init( mockInjector );
		mockStub = createStub();
	}

	function testGetFromScopeExistsAlready(){
		var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init(name="RequestTest" );
		mapping.setThreadSafe( true );
		request[ "wirebox:RequestTest" ] = mockStub;
		var o = scope.getFromScope( mapping, {} );
		assertEquals( mockStub, o );

	}

	function testGetFromScope(){
		var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init(name="RequestTest" );
		mapping.setThreadSafe( true );
		mockInjector.$( "buildInstance", mockStub).$( "autowire", mockStub);
		var o = scope.getFromScope( mapping, {} );
		assertEquals( request[ "wirebox:RequestTest" ], o );

	}


</cfscript>
</cfcomponent>