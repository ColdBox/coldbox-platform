<cfcomponent extends="coldbox.system.testing.BaseModelTest">
	
	<!--- setup and teardown --->
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			mockLogBox = getMockBox().createEmptyMock("coldbox.system.logging.LogBox");
			mockLogger = getMockBox().createEmptyMock("coldbox.system.logging.Logger").$("canDebug", false);
			mockLogBox.$("getLogger",mockLogger);
			
			this.state = getMockBox().createMock("coldbox.system.web.context.InterceptorState");		
			this.event = getMockRequestContext();
			this.event.$("getEventName","event");
			this.mock = createObject("component","coldbox.testing.testinterceptors.mock");
			this.mock2 = createObject("component","coldbox.testing.testinterceptors.mock");
			
			this.key = "cbox_interceptor_" & "mock";
			
			this.state.init('unittest', mockLogBox);
			
			//register one interceptor for testing
			mockMetadata = { async=false, asyncPriority = "normal", eventPattern = "" };
			this.state.register(this.key, this.mock, mockMetadata );
		</cfscript>
	</cffunction>
	
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
			this.state.process( this.event, structnew() );
			assertEquals( this.event.getValue('unittest'), true);
			
			// Now process with other method for event pattern
			this.event.setValue("unittest",false);
			this.mock.unittest = variables.unittest;
			this.state.$property("metadataMap","instance", { "#this.key#" = {async=false, asyncPriority="normal", eventPattern="^UnitTest"} } );
			this.state.process(this.event,structnew());
			assertEquals(false, this.event.getValue('unittest'));
			
			// Now add event
			this.event.setValue("event","UnitTest.test");
			this.state.process(this.event,structnew());
			assertEquals(true,this.event.getValue('unittest'));
		</cfscript>
	</cffunction>		
	
	<cffunction name="testregister" access="public" returnType="void">
		<cfscript>
			mockMetadata = { async=false, asyncPriority = "normal", eventPattern = "" };
			this.state.register( this.key, this.mock, mockMetadata );
			AssertEquals( this.state.getInterceptor(this.key), this.mock);
			assertEquals( this.state.getMetadataMap( this.key ), mockMetadata );
			debug( this.state.getMetadataMap() );
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
			assertFalse( structKeyExists( this.state.getMetadataMap(), this.key ) );
			
			this.state.unregister('nothing baby');
		</cfscript>
	</cffunction>		
	
	<cffunction name="unittest" access="private" returntype="void" eventPattern="^UnitTest">
		<cfargument name="event" 		 required="true" type="any" hint="The event object.">
		<cfargument name="interceptData" required="true" type="any" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
		<cfset arguments.event.setValue('unittest',true)>
	</cffunction>

</cfcomponent>