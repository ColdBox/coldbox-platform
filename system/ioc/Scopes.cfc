<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	A scope enum CFC that gives you the scopes that WireBox uses by default
	

----------------------------------------------------------------------->
<cfcomponent hint="A lookup static CFC that gives you the scopes that WireBox uses by default" output="false">
<cfscript>
	//DECLARED SCOPES
	this.NOSCOPE 		= "NoScope";
	this.PROTOTYPE  	= "NoScope";
	this.SINGLETON 		= "singleton"; 
	this.SESSION		= "session";
	this.APPLICATION	= "application";
	this.REQUEST		= "request";
	this.SERVER			= "server";
	this.CACHEBOX		= "cachebox";
</cfscript>
</cfcomponent>