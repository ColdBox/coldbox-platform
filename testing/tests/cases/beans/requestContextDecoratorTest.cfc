<cfcomponent name="requestContextDecoratorTest" extends="coldbox.testing.tests.resources.baseMockCase">
	
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			this.decorator = createObject("component","coldbox.system.beans.requestContextDecorator");		
			this.rc = createObject("component","coldbox.system.beans.requestContext");		
			this.controller = createObject("component","coldbox.system.controller");
			
			this.decorator.init(this.rc,this.controller);
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
		
	<!--- Begin specific tests --->
	
	<cffunction name="testRC" access="public" returnType="void">
		<cfscript>
			assertEquals( this.rc, this.decorator.getRequestContext() );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetController" access="public" returnType="void">
		<cfscript>
			makePublic(this.decorator,"getController","_getController");
			this.decorator.init(this.rc,this.controller);
			assertEquals( this.controller, this.decorator._getController() );
		</cfscript>
	</cffunction>
	
	

</cfcomponent>