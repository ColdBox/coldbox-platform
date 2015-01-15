<cfcomponent extends="coldbox.system.testing.BaseTestCase">
	<cfset this.loadColdBox = false>

	<!--- setup and teardown --->
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			mockDecorator 	= createObject("component","coldbox.system.web.context.RequestContextDecorator");
			mockContext   	= getMockRequestContext();
			mockController 	= getMockController();

			mockDecorator.init( mockContext, mockController );
		</cfscript>
	</cffunction>


	<!--- Begin specific tests --->
	<cffunction name="testRC" access="public" returnType="void">
		<cfscript>
			assertEquals( mockContext, mockDecorator.getRequestContext() );
		</cfscript>
	</cffunction>

	<cffunction name="testgetController" access="public" returnType="void">
		<cfscript>
			makePublic(mockDecorator,"getController","_getController");
			mockDecorator.init(mockContext, mockController);
			assertEquals( mockController, mockDecorator._getController() );
		</cfscript>
	</cffunction>


</cfcomponent>