<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	this.loadColdBox = false;
	
	function setup(){
		super.setup();
		
		scopeInfo = {
			enabled = true,
			scope 	= "application",
			key 	= "wirebox"
		};
		mockScopeStorage = getMockBox().createEmptyMock( "coldbox.system.core.collections.ScopeStorage" )
			.$( "exists",false);
		provider = getMockBox().createMock( "coldbox.system.ioc.Provider" )
			.init(scopeRegistration=scopeInfo, 
				  scopeStorage=mockScopeStorage,
				  name="UnitTest",
				  targetObject=this);
	}
	
	function testGetNoScope(){
		try{
			provider.get();
		}
		catch( "Provider.InjectorNotOnScope" e){
		}
		catch(Any e){ fail(e); }
	}
	
	function testGet(){
		// Mocks
		mockTarget = getMockBox().createStub().$( "verify", true);
		mockInjector = getMockBox().createEmptyMock( "coldbox.system.ioc.Injector" ).$( "getInstance", mockTarget);
		mockScopeStorage.$( "exists",true).$( "get", mockInjector);
		
		// 1. Execute get by name
		results = provider.get();
		assertEquals( "UnitTest", mockInjector.$callLog().getInstance[ 1 ].name );
		assertTrue( results.verify() );
		
		// 2. Execute get by dsl
		provider = getMockBox().createMock( "coldbox.system.ioc.Provider" )
			.init(scopeRegistration=scopeInfo, 
				  scopeStorage=mockScopeStorage, 
				  dsl="logbox:logger:{this}",
				  targetObject=this);
		results = provider.get();
		assertTrue( results.verify() );
		assertEquals( "logbox:logger:{this}", mockInjector.$callLog().getInstance[ 2 ].dsl );
	}
	
	function testProxyMethods(){
		// Mocks
		mockTarget = getMockBox().createStub()
			.$( "getTest", true)
			.$( "sayHello","luis" );
		mockInjector = getMockBox().createEmptyMock( "coldbox.system.ioc.Injector" ).$( "getInstance",mockTarget);
		mockScopeStorage.$( "exists",true).$( "get",mockInjector);
		provider.$( "get", mockTarget);
		
		// call proxy method
		r = provider.getTest();
		assertEquals(true, r);
		
		// call proxy method
		r = provider.sayHello();
		assertEquals( "luis", r);
	}
	
	
</cfscript>
</cfcomponent>