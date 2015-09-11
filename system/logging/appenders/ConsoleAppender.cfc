/**
 *  A simple ConsoleAppender
 *
 *  @author      Luis Majano
 *  @createDate  04/12/2009
 *
 * *********************************************************************************** *
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp     *
 * www.coldbox.org | www.luismajano.com | www.ortussolutions.com                       *
 * *********************************************************************************** */
component extends="coldbox.system.logging.AbstractAppender" output="false" {

 /**
	*  Constructor
	*
	*  @name.hint        The unique name for this appender.
	*  @properties.hint  A map of configuration properties for the appender.
	*  @layout.hint      The layout class to use in this appender for custom message rendering.
	*  @levelMin.hint    The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	*  @levelMax.hint    The default log level for this appender, by default it is 4. Optional. ex: LogBox.logLevels.WARN
	*/
	public ConsoleAppender function init(required string name,
																								struct properties = {},
																								string layout     = "",
																								string levelMin   = 0,
																								string levelMax   = 4 ) {
		super.init(argumentCollection=arguments);
		instance.out = createObject("java","java.lang.System").out;
		return this;
	}

 /**
	*  Write entry into appender
	*
	*  @logEvent.hint  The logging event.
	*/
	public void function logMessage(required any logEvent) {
		if (hasCustomLayout()) {
			var entry = getCustomLayout().format(logEvent);
		} else {
			var entry = severityToString(logEvent.getseverity()) & " " & logEvent.getCategory() & " " & logEvent.getmessage() & " ExtraInfo: " & logEvent.getextraInfoAsString();
		}
		// log message
		instance.out.println(entry);
		return;
	}

}
