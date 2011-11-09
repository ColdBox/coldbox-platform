<cfcomponent output="false" extends="coldbox.system.testing.BaseTestCase">
	
	<!--- setup --->
	<cffunction name="setup" output="false" access="public" returntype="any" hint="">
		<cfscript>
			this.loadColdbox = false;
			scope = CreateObject("component","coldbox.system.core.collections.ScopeStorage").init();
		</cfscript>
	</cffunction>
	
	<cffunction name="testPut">
		<cfscript>
			scope.put("test",true,"session");
			assertTrue( scope.exists("test","session") );
			structdelete(session,"test");
		</cfscript>
	</cffunction>
	
	<cffunction name="testDelete">
		<cfscript>
			server.luis = "cool";
			assertTrue( scope.delete("luis","server") );
			
			assertFalse( scope.delete("luis","server") );
		</cfscript>
	</cffunction>
	
	<cffunction name="testGet">
		<cfscript>
			application.test = "test";
			
			assertEquals( scope.get(key="test",scope="application"), "test");
			structdelete(application, "test");
			
			assertEquals( scope.get("test","session",'false'), false);
			
			try{
				scope.get("test","session");
				fail("fails");
			}
			catch(Any e){
				//debug(e);
				if( e.type neq "ScopeStorage.KeyNotFound" ){
					fail("failed exception #e.type#");
				}
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="testExists">
		<cfscript>
			assertFalse( scope.exists("test","session") );
			application.test = "test";
			assertTrue( scope.exists(key="test",scope="application") );
			structdelete(application, "test");
			
		</cfscript>
	</cffunction>

	<cffunction name="getScope">
		<cfscript>
			scope.getScope("session");
			scope.getScope("application");
			scope.getScope("server");
			scope.getScope("client");
			scope.getScope("cookie");
			scope.getScope("cluster");
		</cfscript>
	</cffunction>

</cfcomponent>