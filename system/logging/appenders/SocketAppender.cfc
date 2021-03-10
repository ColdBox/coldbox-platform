/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A socket appender that logs to a socket
 *
 * Properties:
 * - host : the host to connect to
 * - port : the port to connect to
 * - timeout : the timeout in seconds. defaults to 5 seconds
 * - persistConnection : Whether to persist the connection or create a new one every log time. Defaults to true;
**/
component accessors="true" extends="coldbox.system.logging.AbstractAppender" {

	/**
	 * The actual socket server
	 */
	property name="socket";

	/**
	 * The socket writer class
	 */
	property name="socketWriter";

    /**
	 * Constructor
	 *
	 * @name The unique name for this appender.
	 * @properties A map of configuration properties for the appender"
	 * @layout The layout class to use in this appender for custom message rendering.
	 * @levelMin The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	 * @levelMax The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN
	 *
	 * @throws SocketAppender.HostNotFound,SocketAppender.PortNotFound
	 */
	function init(
		required name,
		struct properties={},
		layout="",
		levelMin=0,
		levelMax=4
	){
       	// Init supertype
		super.init( argumentCollection=arguments );

		// Verify properties
		if( NOT propertyExists( "host" ) ){
			throw( message="The host must be provided", type="SocketAppender.HostNotFound" );
		}
		if( NOT propertyExists( "port" ) ){
			throw( message="The port must be provided", type="SocketAppender.PortNotFound" );
		}
		if( NOT propertyExists( "timeout" ) OR NOT isNumeric( getProperty( "timeout" ) ) ){
			setProperty( "timeout", 5);
		}
		if( NOT propertyExists( "persistConnection" ) ){
			setProperty( "persistConnection", true );
		}

		// Socket storage
		variables.socket = "";
		variables.socketWriter = "";

		return this;
    }

    /**
	 * Write an entry into the appender. You must implement this method yourself.
	 *
	 * @logEvent The logging event to log
	 */
	function logMessage( required coldbox.system.logging.LogEvent logEvent ){
		var loge 	= arguments.logEvent;
		var entry 	= "";

		// Prepare entry to send.
		if( hasCustomLayout() ){
			entry = getCustomLayout().format( loge );
		}
		else{
			entry = "#severityToString( loge.getseverity() )# #loge.getCategory()# #loge.getmessage()# ExtraInfo: #loge.getextraInfoAsString()#";
		}

		// Open connection?
		if( NOT getProperty( "persistConnection" ) ){
			openConnection();
		}

		// Send data to Socket
		try{
			getSocketWriter().println(entry);
		} catch( Any e ) {
			$log(
				"ERROR",
				"#getName()# - Error sending entry to socket #getProperties().toString()#. #e.message# #e.detail#"
			);
		}

		// Close Connection?
		if( NOT getProperty( "persistConnection" ) ){
			closeConnection();
		}

		return this;
	}

	/**
	 * When registration occurs
	 */
	function onRegistration(){
		if ( getProperty( "persistConnection" ) ) {
			openConnection();
		}
		return this;
	}

	/**
	 * When Unregistration occurs
	 */
	function onUnRegistration(){
		if ( getProperty( "persistConnection" ) ) {
			closeConnection();
		}
		return this;
	}

	/****************************************** PRIVATE ***************************************/

	/**
	 * Open a socket connection
	 *
	 * @throws SocketAppender.ConnectionException
	 */
	private function openConnection(){
		try{
			variables.socket = createObject( "java", "java.net.Socket" ).init( getProperty( "host" ), javaCast( "int", getProperty( "port" ) ) );
		} catch( Any e ) {
			throw(
				message = "Error opening socket to #getProperty( "host" )#:#getProperty( "port" )#",
				detail  = e.message & e.detail & e.stacktrace,
				type    = "SocketAppender.ConnectionException"
			);
		}
		// Set Timeout
		variables.socket.setSoTimeout( javaCast( "int", getProperty( "timeout" ) * 1000 ) );

		//Prepare Writer
		variables.socketWriter = createObject( "java","java.io.PrintWriter" ).init( variables.socket.getOutputStream() );

		return this;
	}

	/**
	 * Close Connection
	 */
	function closeConnection(){
		getSocketWriter().close();
		getSocket().close();
		return this;
	}

}