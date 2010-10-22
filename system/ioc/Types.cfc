<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	A lookup static CFC that gives you the instantiation types that WireBox can talk to.
	

----------------------------------------------------------------------->
<cfcomponent hint="A lookup static CFC that gives you the instantiation types that WireBox can talk to" output="false">
<cfscript>
	//DECLARED WIREBOX INSTANTIATION TYPES
	this.CFC 		= 0;
	this.JAVA		= 1;
	this.WEBSERVICE = 2; 
	this.RSS		= 3;	
</cfscript>
</cfcomponent>