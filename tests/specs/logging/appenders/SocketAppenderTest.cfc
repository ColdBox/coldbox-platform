<cfcomponent extends="coldbox.system.testing.BaseModelTest">
<cfscript>
	function setup(){
		prop = {host="localhost",timeout="3",port=getRandomPort(),persistConnection=false};
		socket = createMock(className="coldbox.system.logging.appenders.SocketAppender");
		socket.init('MyScoketAppender',prop);

		loge = createMock(className="coldbox.system.logging.LogEvent");
		loge.init("Unit Test Sample",0,structnew(),"UnitTest");
	}

	function testLogMessage(){
		for(var x=1;x lte 5; x++){
			loge.setSeverity(x);
			loge.setTimestamp(now());

			socket.logMessage(loge);
		}
	}

	/**
	 * Get a random port for the specified host
	 * @host.hint host to get port on, defaults 127.0.0.1
 	 **/
	function getRandomPort( host="127.0.0.1" ){
		var nextAvail  = createObject( "java", "java.net.ServerSocket" ).init( javaCast( "int", 0 ),
												 javaCast( "int", 1 ),
												 createObject( "java", "java.net.InetAddress" ).getByName( arguments.host ) );
		var portNumber = nextAvail.getLocalPort();
		nextAvail.close();
		return portNumber;
	}
</cfscript>
</cfcomponent>