/**
*********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* The different logging levels available in LogBox. Log levels available in the this scope: OFF=-1, FATAL=0, ERROR=1, WARN=2, INFO=3, DEBUG=4
* @author Luis Majano <lmajano@ortussolutions.com>
*/
component{

	// All Available Logging Levels for LogBox
	this.OFF 	= -1;
	this.FATAL 	= 0;
	this.ERROR 	= 1;
	this.WARN 	= 2;
	this.INFO 	= 3;
	this.DEBUG 	= 4;
	
	// List of valid levels
	this.VALIDLEVELS = "off,fatal,error,warn,info,debug";
	
	// Max
	this.MINLEVEL = -1;
	this.MAXLEVEL = 4;
	
	function lookup(level){
		switch(level){
			case -1: return "OFF";
			case 0: return "FATAL";
			case 1: return "ERROR";
			case 2: return "WARN";
			case 3: return "INFO";
			case 4: return "DEBUG";		
		}
	}
	
	function lookupAsInt(level){
		switch(level){
			case "OFF": return -1;
			case "FATAL": return 0;
			case "ERROR": return 1;
			case "WARN": return 2;
			case "WARNING" : return 2;
			case "INFO": return 3;
			case "INFORMATION" : return 3;
			case "DEBUG": return 4;	
			default: return 999;	
		}
	}
	
	function lookupCF(level){
		switch(level){
			case -1: return "OFF";
			case 0: return "Fatal";
			case 1: return "Error";
			case 2: return "Warning";
			case 3: return "Information";
			case 4: return "Information";
			default: return "Information";		
		}
	}
	
	function isLevelValid(level){
		return ( arguments.level gte this.MINLEVEL AND arguments.level lte this.MAXLEVEL );
	}
}