<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano
Date        :	3/13/2009
Description :
	The log levels enum
----------------------------------------------------------------------->
<cfcomponent name="LogLevels" hint="The available log levels in LogBox" output="false">
<cfscript>
	// All Available Logging Levels for LogBox
	this.TRACE = 5;
	this.DEBUG = 4;
	this.INFORMATION = 3;
	this.INFO = 3;
	this.WARNING = 2;
	this.ERROR = 1;
	this.FATAL = 0;
	
	// List of valid levels
	this.VALIDLEVELS = "trace,debug,information,info,warning,error,fatal";
	// Max
	this.MINLEVEL = 0;
	this.MAXLEVEL = 5;
	
	function lookup(level){
		switch(level){
			case 0: return "FATAL";
			case 1: return "ERROR";
			case 2: return "WARNING";
			case 3: return "INFO";
			case 4: return "DEBUG";
			case 5: return "TRACE";			
		}
	}

</cfscript>
</cfcomponent>