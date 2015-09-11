<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	A lookup static CFC that gives you the instantiation types that WireBox can talk to.
	

----------------------------------------------------------------------->
<cfcomponent hint="A lookup static CFC that gives you the instantiation types that WireBox can talk to. Declared Types are: CFC, JAVA, WEBSERVICE, RSS, DSL and CONSTANT" output="false"><cfscript>
	
	//DECLARED WIREBOX INSTANTIATION TYPES
	this.CFC 		= "cfc";
	this.JAVA		= "java";
	this.WEBSERVICE = "webservice"; 
	this.RSS		= "rss";	
	this.DSL		= "dsl";
	this.CONSTANT	= "constant";
	this.FACTORY	= "factory";
	this.PROVIDER	= "provider";
	
</cfscript></cfcomponent>