<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		scopeInfo = {
			enabled = true,
			scope 	= "application",
			key 	= "wirebox"
		};
		mockScopeStorage = getMockBox().createEmptyMock("coldbox.system.core.collections.ScopeStorage")
			.$("exists",false);
		provider = getMockBox().createMock("coldbox.system.ioc.Provider").init(scopeInfo,mockScopeStorage,"UnitTest");
	}
	
	function testGetNoScope(){
		try{
			provider.get();
		}
		catch("Provider.InjectorNotOnScope" e){
		}
		catch(Any e){ fail(e); }
	}
	
	function testGet(){
		mockTarget = getMockBox().createStub();
		mockInjector     = getMockBox().createEmptyMock("coldbox.system.ioc.Injector").$("getInstance",mockTarget);
		mockScopeStorage.$("exists",true).$("get",mockInjector);
		
		results = provider.get();
		assertEquals("UnitTest", mockInjector.$callLog().getInstance[1][1] );
		assertEquals(mockTarget, results);
		
	}
	
	function testProxyMethods(){
		mockTarget = getMockBox().createStub()
			.$("getTest", true)
			.$("sayHello","luis");
		mockScopeStorage.$("exists",true).$("get",mockInjector);
		provider.$("get", mockTarget);
		
		r = provider.getTest();
		assertEquals(true, r);
		
		r = provider.sayHello();
		assertEquals("luis", r);
	}
	
	
</cfscript>
</cfcomponent>