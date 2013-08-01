<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		// create invocation
		invocation = getMockBox().createMock("coldbox.system.aop.MethodInvocation");
		
		// mock execution arguments
		args={
			id = createUUID(),
			createdDate = now()
		};
		
		// mock aspect interceptors
		interceptors = [
			getMockBox().createStub(),
			getMockBox().createStub()
		];
		
		// mock aspect methods
		interceptors[1].invokeMethod = variables.invokeMethod;
		interceptors[1].callCounter = 0;
		interceptors[2].invokeMethod = variables.invokeMethod2;
		interceptors[2].callCounter = 0;
		// mock mapping
		mockMapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init('UnitTest');
		//mock md
		mockMDOriginal = getMetadata(variables.saveUser);
		mockMD = URLEncodedFormat( serializeJSON( mockMDOriginal ) );
				
		// init the invocation
		invocation.init(method="saveUser",args=args,methodMetadata=mockMD,target=this,targetName="UnitTest",targetMapping=mockMapping,interceptors=interceptors);
	}
	
	function testInit(){
		assertEquals( 1, invocation.getInterceptorIndex() );
		assertEquals( 2, arrayLen( invocation.getInterceptors() ) );
		assertEquals( "saveUser", invocation.getMethod() );
		assertEquals( args, invocation.getArgs() );
		assertEquals( this, invocation.getTarget() );
		assertEquals( mockMapping, invocation.getTargetMapping() );
		assertTrue( isStruct( invocation.getMethodMetadata()  ));
	}
	
	function testIncrementInterceptorIndex(){
		assertEquals( 1, invocation.getInterceptorIndex() );
		invocation.incrementInterceptorIndex();		
		assertEquals( 2, invocation.getInterceptorIndex() );
	}
	
	function testProceed(){
		// mock the proxied method
		this.callCounter = 0;
		this.$wbAOPTargets["saveUser"] = {
			UDFPointer = variables.saveUser,
			interceptors = interceptors
		};
		mixerUtil = createObject("component","coldbox.system.aop.MixerUtil");
		this.$wbAOPInvokeProxy = mixerUtil.$wbAOPInvokeProxy;
		
		// proceed with AOP interception
		results = invocation.proceed(); 
		debug( results );
		// Assert the crazyness
		assertEquals(1, interceptors[1].callCounter );
		assertEquals(1, interceptors[2].callCounter );
		assertEquals("I am cool aspect2 aspect1", results );
			
	}	
</cfscript>

	<!--- saveUser --->    
    <cffunction name="saveUser" output="false" access="private" returntype="any" hint="The method we will proxy and intercept on">    
    	<cfscript>
			return "I am cool";	    
    	</cfscript>    
    </cffunction>

	<!--- invokeMethod --->    
    <cffunction name="invokeMethod" output="false" access="private" returntype="any" hint="invoke method mock, done in tags for cf8 testing">    
    	<cfargument name="invocation">
    	<cfscript>
			// increment this aspect call counter
			this.callCounter++;
			// Go down the rabbit hole
			return arguments.invocation.proceed() & " aspect1";
    	</cfscript>    
    </cffunction>
    
    <!--- invokeMethod2 --->    
    <cffunction name="invokeMethod2" output="false" access="private" returntype="any" hint="invoke method mock, done in tags for cf8 testing">    
    	<cfargument name="invocation">
    	<cfscript>
			// increment this aspect call counter
			this.callCounter++;
			// Go down the rabbit hole
			return arguments.invocation.proceed() & " aspect2";
    	</cfscript>    
    </cffunction>

</cfcomponent>