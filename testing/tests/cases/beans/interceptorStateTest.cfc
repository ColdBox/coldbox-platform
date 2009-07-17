<cfcomponent name="interceptorStateTest" extends="coldbox.testing.tests.resources.baseMockCase">
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			this.state = createObject("component","coldbox.system.beans.interceptorState");		
			this.event = createobject("component","coldbox.system.beans.requestContext");
			this.mock = createObject("component","coldbox.testing.testinterceptors.mock");
			
			this.key = "cbox_interceptor_" & "mock";
			
			this.state.init('unittest');
			
			//register one interceptor for testing
			this.state.register(this.key,this.mock);
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
	
	<!--- Begin specific tests --->
	
	<cffunction name="testgetInterceptor" access="public" returnType="void">
		<cfscript>
			AssertEquals( this.state.getInterceptor(this.key), this.mock);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetinterceptors" access="public" returnType="void">
		<cfscript>
			assertEquals( getMetadata(this.state.getINterceptors()).name, "java.util.collections$synchronizedmap" );
			AssertTrue( this.state.getInterceptors().size() );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetstate" access="public" returnType="void">
		<cfscript>
			assertEquals( this.state.getState(), "unittest" );
		</cfscript>
	</cffunction>		

	<cffunction name="testprocess" access="public" returnType="void">
		<cfscript>
			this.state.process(this.event,structnew());
			assertEquals( this.event.getValue('unittest') , true);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testregister" access="public" returnType="void">
		<cfscript>
			this.state.register(this.key,this.mock);
			AssertEquals( this.state.getInterceptor(this.key), this.mock);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testsetinterceptors" access="public" returnType="void">
		<cfscript>
			this.state.setINterceptors( this.state.getInterceptors() );
			AssertTrue( this.state.getInterceptors().size());
		</cfscript>
	</cffunction>		
	
	<cffunction name="testsetstate" access="public" returnType="void">
		<cfscript>
			this.state.setState('nothing');
			assertEquals( this.state.getState(), "nothing" );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testunregister" access="public" returnType="void">
		<cfscript>
			
			this.state.unregister(this.key);
			AssertFalse( this.state.getINterceptors().size() );
			
			this.state.unregister('nothing baby');
		</cfscript>
	</cffunction>		
	

</cfcomponent>