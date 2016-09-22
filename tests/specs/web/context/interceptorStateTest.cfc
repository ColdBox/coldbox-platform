<cfcomponent extends="coldbox.system.testing.BaseModelTest">
	
	<!--- setup and teardown --->
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			// Prepare mocks
			mockLogBox = createEmptyMock("coldbox.system.logging.LogBox");
			mockLogger = createEmptyMock("coldbox.system.logging.Logger").$("canDebug", false);
			mockLogBox.$("getLogger",mockLogger);
			mockRequestService = createEmptyMock( "coldbox.system.web.services.RequestService" )
				.$( "getContext", getMockRequestContext() );
			mockController = createEmptyMock( "coldbox.system.web.Controller" )
				.$( "getRequestService", mockRequestService );
			
			this.state = createMock("coldbox.system.web.context.InterceptorState");		
			this.event = getMockRequestContext();
			this.event.$("getEventName","event");
			this.mock = createMock("coldbox.tests.resources.MockInterceptor");
			this.mock2 = createMock("coldbox.tests.resources.MockInterceptor");
			this.key = "cbox_interceptor_" & "mock";
			
			this.state.init( 'unittest', mockLogBox, mockController );
			
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
			mockBuffer = getMockBox().createStub();
			this.state.process( event=this.event, interceptData=structnew(), buffer=mockBuffer );
			assertEquals( this.event.getValue('unittest'), true);
			
			// Now process with other method for event pattern
			this.event.setValue("unittest",false);
			this.mock.unittest = variables.unittest;
			this.state.$property("metadataMap","instance", { "#this.key#" = {async=false, asyncPriority="normal", eventPattern="^UnitTest"} } );
			this.state.process( event=this.event, interceptData=structnew(), buffer=mockBuffer );
			assertEquals(false, this.event.getValue('unittest'));
			
			// Now add event
			this.event.setValue("event","UnitTest.test");
			this.state.process( event=this.event, interceptData=structnew(), buffer=mockBuffer );
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
	
	<cffunction name="testInvoker" access="public" returnType="void">
		<cfscript>
			//debug( this.state.getState() );
			
			// 1: Execute Normally
			//register one interceptor for testing
			this.state.unregister( this.key );
			mockMetadata = { async=false, asyncPriority = "normal", eventPattern = "" };
			mockInterceptor = getMockBox().createMock("coldbox.tests.resources.MockInterceptor").$("unittest");
			this.state.register(this.key, mockInterceptor, mockMetadata );
			
			// Invoke
			makepublic( this.state, "invoker" );
			assertTrue( mockInterceptor.$never("unittest") );
			mockBuffer = getMockBox().createStub();
			this.state.invoker(mockInterceptor, getMockRequestContext(), {}, this.key, mockBuffer );
			assertTrue( mockInterceptor.$once("unittest") );
			
		</cfscript>
	</cffunction>	
	
	<cffunction name="testInvokerThreaded" access="public" returnType="void">
		<cfscript>
			// Mocks
			mockBuffer = getMockBox().createStub();
			getMockRequestContext().$( "getCollection", {} )
				.$( "getPrivateCollection", {} );
			
			// 1: Execute Threaded
			//register one interceptor for testing
			this.state.unregister( this.key );
			mockMetadata = { async=true, asyncPriority = "high", eventPattern = "" };
			mockInterceptor = getMockBox().createMock("coldbox.tests.resources.MockInterceptor").$("unittest");
			this.state.register( this.key, mockInterceptor, mockMetadata );
			
			// Invoke
			makepublic( this.state, "invokerAsync" );
			assertTrue( mockInterceptor.$never("unittest") );
			this.state.invokerAsync( getMockRequestContext(), {}, this.key, "high", mockBuffer );
			sleep( 1000 );
			assertTrue( mockInterceptor.$once("unittest") );
			debug( cfthread );
		</cfscript>
	</cffunction>		
	
	<cffunction name="unittest" access="private" returntype="void" eventPattern="^UnitTest">
		<cfargument name="event" 		 required="true" type="any" hint="The event object.">
		<cfargument name="interceptData" required="true" type="any" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
		<cfset arguments.event.setValue('unittest',true)>
	</cffunction>

</cfcomponent>