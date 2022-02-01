component extends="coldbox.system.testing.BaseModelTest" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.beforeAll();
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "A Method Invocation", function(){
			beforeEach( function( currentSpec ){
				// create invocation
				invocation = createMock( "coldbox.system.aop.MethodInvocation" );

				// mock execution arguments
				args = { id : createUUID(), createdDate : now() };

				// mock aspect interceptors
				interceptors = [ createStub(), createStub() ];

				// mock aspect methods
				interceptors[ 1 ].invokeMethod = variables.invokeMethod;
				interceptors[ 1 ].callCounter = 0;
				interceptors[ 2 ].invokeMethod = variables.invokeMethod2;
				interceptors[ 2 ].callCounter = 0;
				// mock mapping
				mockMapping    = createMock( "coldbox.system.ioc.config.Mapping" ).init( "UnitTest" );
				// mock md
				mockMDOriginal = getMetadata( variables.saveUser );
				mockMD         = urlEncodedFormat( serializeJSON( mockMDOriginal ) );

				// init the invocation to test
				invocation.init(
					method         = "saveUser",
					args           = args,
					methodMetadata = mockMD,
					target         = this,
					targetName     = "UnitTest",
					targetMapping  = mockMapping,
					interceptors   = interceptors
				);
			} );

			it( "can be initialized", function(){
				expect( 1 ).toBe( invocation.getInterceptorIndex() );
				expect( 2 ).toBe( arrayLen( invocation.getInterceptors() ) );
				expect( "saveUser" ).toBe( invocation.getMethod() );
				expect( args ).toBe( invocation.getArgs() );
				expect( getMetadata( invocation.getTarget() ).name ).toInclude( "MethodInvocationTest" );
				expect( mockMapping ).toBe( invocation.getTargetMapping() );
				expect( invocation.getMethodMetadata() ).toBeStruct();
			} );

			it( "can increment its interceptor index", function(){
				expect( 1 ).toBe( invocation.getInterceptorIndex() );
				invocation.incrementInterceptorIndex();
				expect( 2 ).toBe( invocation.getInterceptorIndex() );
			} );

			it( "can proceed via proxies", function(){
				// mock the proxied method, which in our case, we are the target as well.
				this.callCounter                 = 0;
				this.$wbAOPTargets[ "saveUser" ] = {
					UDFPointer   : variables.saveUser,
					interceptors : interceptors
				};
				mixerUtil              = createMock( "coldbox.system.aop.MixerUtil" );
				this.$wbAOPInvokeProxy = mixerUtil.$wbAOPInvokeProxy;

				// proceed with AOP interception
				results = invocation.proceed();
				// debug( results );

				// Assert the crazyness
				expect( 1 ).toBe( interceptors[ 1 ].callCounter );
				expect( 1 ).toBe( interceptors[ 2 ].callCounter );
				expect( "I am cool aspect2 aspect1" ).toBe( results );
			} );
		} );
	}

	/*********************************** METHOD PROXIES ***********************************/

	// method proxy
	private function saveUser(){
		return "I am cool";
	}

	private function invokeMethod( invocation ){
		// increment this aspect call counter
		this.callCounter++;
		// Go down the rabbit hole
		return arguments.invocation.proceed() & " aspect1";
	}

	private function invokeMethod2( invocation ){
		// increment this aspect call counter
		this.callCounter++;
		// Go down the rabbit hole
		return arguments.invocation.proceed() & " aspect2";
	}

}
