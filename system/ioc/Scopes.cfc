<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	A lookup static CFC that gives you the scopes that WireBox uses by default
	

----------------------------------------------------------------------->
<cfcomponent hint="A lookup static CFC that gives you the scopes that WireBox uses by default" output="false">
<cfscript>
	//DECLARED SCOPES
	this.NO_SCOPE 	= 0;
	this.PROTOTYPE  = 0;
	this.SINGLETON 	= 1; 
	this.SESSION	= 2;
	this.REQUEST	= 3;
	this.SERVER		= 4;
	this.CACHEBOX	= 5;	
	this.INVALID 	= -1;
	
	function lookup(scope){
		switch( listFirst(arguments.scope,":") ){
			case 0: return "NO_SCOPE";
			case 1: return "SINGLETON";
			case 2: return "SESSION";
			case 3: return "REQUEST";
			case 4: return "SERVER";
			case 5: return "CACHEBOX";		
		}
		return -1;
	}
	
	function isInvalid(scope){
		return (arguments.scope EQ this.INVALID);
	}
</cfscript>
</cfcomponent>