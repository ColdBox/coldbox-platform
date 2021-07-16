component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		logBox    = new coldbox.system.logging.LogBox();
		localPort = getRandomPort();
		var prop  = {
			host              : "localhost",
			timeout           : "3",
			port              : localPort,
			persistConnection : false
		};

		socketAppender = createMock( className = "coldbox.system.logging.appenders.SocketAppender" )
			.init( "MyScoketAppender", prop )
			.setLogBox( logBox );

		loge = createMock( "coldbox.system.logging.LogEvent" ).init(
			"Unit Test Sample",
			0,
			structNew(),
			"UnitTest"
		);

		// create socket server
		request.socketServer= createObject( "java", "java.net.ServerSocket" ).init( javacast( "int", localPort ) );
		thread name         ="start-socket-#createUUID()#" {
			request.socketServer.accept();
		}
		// wait for socket to start up
		while ( !request.socketServer.isBound() ) {
			sleep( 500 );
		}
	}

	function teardown(){
		// stop socket server
		request.socketServer.close();
	}

	function testLogMessage(){
		for ( var x = 1; x lte 5; x++ ) {
			loge.setSeverity( x );
			loge.setTimestamp( now() );
			socketAppender.logMessage( loge );
		}
	}

	/**
	 * Get a random port for the specified host
	 * @host.hint host to get port on, defaults 127.0.0.1
	 **/
	function getRandomPort( host = "127.0.0.1" ){
		var nextAvail = createObject( "java", "java.net.ServerSocket" ).init(
			javacast( "int", 0 ),
			javacast( "int", 1 ),
			createObject( "java", "java.net.InetAddress" ).getByName( arguments.host )
		);
		var portNumber = nextAvail.getLocalPort();
		nextAvail.close();
		return portNumber;
	}

}
