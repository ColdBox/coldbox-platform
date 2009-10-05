<cfcomponent extends="coldbox.system.testing.BaseTestCase">
	
	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		mockController = getMockFactory().createMock("coldbox.system.web.Controller");
		
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="tearDown" output="false" access="public" returntype="void" hint="">
		<cfscript>
		super.tearDown();
		</cfscript>
	</cffunction>
	
	<cffunction name="testAbstract" >
	</cffunction>
	
</cfcomponent>