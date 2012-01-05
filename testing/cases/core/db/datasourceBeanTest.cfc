<cfcomponent name="datasourceBeanTest" extends="coldbox.system.testing.BaseTestCase">
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			dsn = createObject("component","coldbox.system.core.db.DatasourceBean");		
			
			memento = structnew();
			memento.name = "mydsn";
			memento.alias = "alias";
			memento.dbtype = "mysql";
			memento.username = "user";
			memento.password = "pass";
			
			dsn.init(memento);
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
	
	<!--- Begin specific tests --->
	
	<cffunction name="testGetterSetters" access="public" returnType="void">
		<cfscript>
			for(key in memento){
				evaluate("dsn.set#key#( memento[key] )");
			}
			
			for(key in memento){
				AssertEquals( memento[key] , evaluate("dsn.get#key#( key )" ) );
			}						
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetmemento" access="public" returnType="void">
		<cfscript>
			dsn.setMemento(memento);
			assertEquals( dsn.getMemento(), memento);
		</cfscript>
	</cffunction>			
	
	<cffunction name="testsetmemento" access="public" returnType="void">
		<cfscript>
			dsn.setMemento(memento);
			assertEquals( dsn.getMemento(), memento);
		</cfscript>
	</cffunction>	

</cfcomponent>