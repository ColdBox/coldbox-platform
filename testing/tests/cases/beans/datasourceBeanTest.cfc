<cfcomponent name="datasourceBeanTest" extends="coldbox.testing.tests.resources.baseMockCase">
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			this.dsn = createObject("component","coldbox.system.beans.datasourceBean");		
			
			this.memento = structnew();
			this.memento.name = "mydsn";
			this.memento.alias = "alias";
			this.memento.dbtype = "mysql";
			this.memento.username = "user";
			this.memento.password = "pass";
			
			this.dsn.init(this.memento);
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
	
	<!--- Begin specific tests --->
	
	<cffunction name="testGetterSetters" access="public" returnType="void">
		<cfscript>
			for(key in this.memento){
				evaluate("this.dsn.set#key#( this.memento[key] )");
			}
			
			for(key in this.memento){
				AssertEquals( this.memento[key] , evaluate("this.dsn.get#key#( key )" ) );
			}
						
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetmemento" access="public" returnType="void">
		<cfscript>
			this.dsn.setMemento(this.memento);
			assertEquals( this.dsn.getMemento(), this.memento);
		</cfscript>
	</cffunction>			
	
	<cffunction name="testsetmemento" access="public" returnType="void">
		<cfscript>
			this.dsn.setMemento(this.memento);
			assertEquals( this.dsn.getMemento(), this.memento);
		</cfscript>
	</cffunction>	

</cfcomponent>