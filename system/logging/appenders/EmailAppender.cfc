/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * An appender that sends out emails
 *
 * Properties:
 *	- subject - Get's pre-pended with the category field.
 *	- from - required
 *	- to - required can be a ; list of emails
 *	- cc
 *	- bcc
 *	- mailserver (optional)
 *	- mailpassword (optional)
 *	- mailusername (optional)
 *	- mailport (optional - 25)
 **/
component accessors="true" extends="coldbox.system.logging.AbstractAppender" {

	/**
	 * Constructor
	 *
	 * @name       The unique name for this appender.
	 * @properties A map of configuration properties for the appender"
	 * @layout     The layout class to use in this appender for custom message rendering.
	 * @levelMin   The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	 * @levelMax   The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN
	 */
	function init(
		required name,
		struct properties = {},
		layout            = "",
		levelMin          = 0,
		levelMax          = 4
	){
		// Init supertype
		super.init( argumentCollection = arguments );

		// Property Checks
		if ( NOT propertyExists( "from" ) ) {
			throw( message = "from email is required", type = "EmailAppender.PropertyNotFound" );
		}
		if ( NOT propertyExists( "to" ) ) {
			throw( message = "to email(s) is required", type = "EmailAppender.PropertyNotFound" );
		}
		if ( NOT propertyExists( "subject" ) ) {
			throw( message = "subject is required", type = "EmailAppender.PropertyNotFound" );
		}
		if ( NOT propertyExists( "cc" ) ) {
			setProperty( "cc", "" );
		}
		if ( NOT propertyExists( "bcc" ) ) {
			setProperty( "bcc", "" );
		}
		if ( NOT propertyExists( "mailport" ) ) {
			setProperty( "mailport", 25 );
		}
		if ( NOT propertyExists( "mailserver" ) ) {
			setProperty( "mailserver", "" );
		}
		if ( NOT propertyExists( "mailpassword" ) ) {
			setProperty( "mailpassword", "" );
		}
		if ( NOT propertyExists( "mailusername" ) ) {
			setProperty( "mailusername", "" );
		}
		if ( NOT propertyExists( "useTLS" ) ) {
			setProperty( "useTLS", "false" );
		}
		if ( NOT propertyExists( "useSSL" ) ) {
			setProperty( "useSSL", "false" );
		}

		return this;
	}

	/**
	 * Write an entry into the appender. You must implement this method yourself.
	 *
	 * @logEvent The logging event to log
	 */
	function logMessage( required coldbox.system.logging.LogEvent logEvent ){
		var loge    = arguments.logEvent;
		var subject = "#severityToString( loge.getSeverity() )#-#loge.getCategory()#-#getProperty( "subject" )#";
		var entry   = "";

		try {
			if ( hasCustomLayout() ) {
				entry = getCustomLayout().format( loge );
				if ( structKeyExists( getCustomLayout(), "getSubject" ) ) {
					subject = getCustomLayout().getSubject( loge );
				}
			} else {
				savecontent variable="entry" {
					writeOutput(
						"
						<p>TimeStamp: #loge.getTimeStamp()#</p>
						<p>Severity: #loge.getSeverity()#</p>
						<p>Category: #loge.getCategory()#</p>
						<hr/>
						<p>#loge.getMessage()#</p>
						<hr/>
						<p>Extra Info Dump:</p>
					"
					);
					writeDump( var = loge.getExtraInfo(), top = 10 );
				}
			}

			if ( len( getProperty( "mailserver" ) ) ) {
				cfmail(
					to       = getProperty( "to" ),
					from     = getProperty( "from" ),
					cc       = getProperty( "cc" ),
					bcc      = getProperty( "bcc" ),
					type     = "text/html",
					useTLS   = getProperty( "useTLS" ),
					useSSL   = getProperty( "useSSL" ),
					server   = getProperty( "mailserver" ),
					port     = getProperty( "mailport" ),
					username = getProperty( "mailusername" ),
					password = getProperty( "mailpassword" ),
					subject  = subject
				) {
					writeOutput( entry );
				}
			} else {
				cfmail(
					to      = getProperty( "to" ),
					from    = getProperty( "from" ),
					cc      = getProperty( "cc" ),
					bcc     = getProperty( "bcc" ),
					type    = "text/html",
					useTLS  = getProperty( "useTLS" ),
					useSSL  = getProperty( "useSSL" ),
					subject = subject
				) {
					writeOutput( entry );
				}
			}
		} catch ( Any e ) {
			$log( "ERROR", "Error sending email from appender #getName()#. #e.message# #e.detail# #e.stacktrace#" );
		}

		return this;
	}

}
