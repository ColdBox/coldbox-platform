component extends="coldbox.system.testing.BaseModelTest" {

	function setUp(){
		// Prepare mocks
		mockLogBox = createEmptyMock( "coldbox.system.logging.LogBox" );
		mockLogger = createEmptyMock( "coldbox.system.logging.Logger" ).$( "canDebug", false );
		mockLogBox.$( "getLogger", mockLogger );
		mockRequestService = createEmptyMock( "coldbox.system.web.services.RequestService" ).$(
			"getContext",
			getMockRequestContext()
		);
		mockController = createEmptyMock( "coldbox.system.web.Controller" ).$(
			"getRequestService",
			mockRequestService
		);

		this.state = createMock( "coldbox.system.web.context.InterceptorState" );
		this.event = getMockRequestContext();
		this.event.$( "getEventName", "event" );
		this.mock  = createMock( "coldbox.tests.resources.MockInterceptor" );
		this.mock2 = createMock( "coldbox.tests.resources.MockInterceptor" );
		this.key   = "cbox_interceptor_" & "mock";

		this.state.init( "unittest", mockLogBox, mockController );

		// register one interceptor for testing
		mockMetadata = {
			async         : false,
			asyncPriority : "normal",
			eventPattern  : ""
		};
		this.state.register( this.key, this.mock, mockMetadata );
	}

	function testgetInterceptor(){
		assertEquals( this.state.getInterceptor( this.key ), this.mock );
	}

	function testgetinterceptors(){
		assertTrue( this.state.getInterceptors().size() );
	}

	function testgetstate(){
		assertEquals( this.state.getState(), "unittest" );
	}

	function testprocess(){
		mockBuffer = createStub();
		this.state.process(
			event  = this.event,
			data   = structNew(),
			buffer = mockBuffer
		);
		assertEquals( this.event.getValue( "unittest" ), true );

		// Now process with other method for event pattern
		this.event.setValue( "unittest", false );
		this.mock.unittest = variables.unittest;
		this.state.$property(
			"metadataMap",
			"variables",
			{
				"#this.key#" : {
					async         : false,
					asyncPriority : "normal",
					eventPattern  : "^UnitTest"
				}
			}
		);
		this.state.process(
			event  = this.event,
			data   = structNew(),
			buffer = mockBuffer
		);
		assertEquals( false, this.event.getValue( "unittest" ) );

		// Now add event
		this.event.setValue( "event", "UnitTest.test" );
		this.state.process(
			event  = this.event,
			data   = structNew(),
			buffer = mockBuffer
		);
		assertEquals( true, this.event.getValue( "unittest" ) );
	}

	function testregister(){
		mockMetadata = {
			async         : false,
			asyncPriority : "normal",
			eventPattern  : ""
		};
		this.state.register( this.key, this.mock, mockMetadata );
		assertEquals( this.state.getInterceptor( this.key ), this.mock );
		assertEquals( this.state.getMetadataMap( this.key ), mockMetadata );
		// debug( this.state.getMetadataMap() );
	}

	function testsetstate(){
		this.state.setState( "nothing" );
		assertEquals( this.state.getState(), "nothing" );
	}

	function testunregister(){
		this.state.unregister( this.key );
		assertFalse( this.state.getINterceptors().size() );
		assertFalse( structKeyExists( this.state.getMetadataMap(), this.key ) );

		this.state.unregister( "nothing baby" );
	}

	function testInvoker(){
		// debug( this.state.getState() );

		// 1: Execute Normally
		// register one interceptor for testing
		this.state.unregister( this.key );
		mockMetadata = {
			async         : false,
			asyncPriority : "normal",
			eventPattern  : ""
		};
		mockInterceptor = createMock( "coldbox.tests.resources.MockInterceptor" ).$( "unittest" );
		this.state.register( this.key, mockInterceptor, mockMetadata );

		// Invoke
		makepublic( this.state, "invoker" );
		assertTrue( mockInterceptor.$never( "unittest" ) );
		mockBuffer = createStub();
		this.state.invoker(
			mockInterceptor,
			getMockRequestContext(),
			{},
			this.key,
			mockBuffer
		);
		assertTrue( mockInterceptor.$once( "unittest" ) );
	}

	function testInvokerThreaded(){
		// Mocks
		mockBuffer = createStub();
		getMockRequestContext().$( "getCollection", {} ).$( "getPrivateCollection", {} );

		// 1: Execute Threaded
		// register one interceptor for testing
		this.state.unregister( this.key );
		mockMetadata    = { async : true, asyncPriority : "high", eventPattern : "" };
		mockInterceptor = createMock( "coldbox.tests.resources.MockInterceptor" ).$( "unittest" );
		this.state.register( this.key, mockInterceptor, mockMetadata );

		// Invoke
		makepublic( this.state, "invokerAsync" );
		assertTrue( mockInterceptor.$never( "unittest" ) );
		this.state.invokerAsync(
			getMockRequestContext(),
			{},
			this.key,
			"high",
			mockBuffer
		);
		sleep( 5000 );
		assertTrue( mockInterceptor.$once( "unittest" ) );
		// debug( cfthread );
	}

	/**
	 * @eventPattern ^UnitTest
	 */
	private function unittest( event, data ){
		arguments.event.setValue( "unittest", true );
	}

}
