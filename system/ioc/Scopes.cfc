<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	A scope enum CFC that gives you the scopes that WireBox uses by default
	

----------------------------------------------------------------------->
<cfcomponent hint="A lookup static CFC that gives you the scopes that WireBox uses by default. Declared Scopes are: NOSCOPE, PROTOTYPE, SINGLETON, SESSION, APPLICATION, REQUEST, SERVER, CACHEBOX" output="false"><cfscript>
	//DECLARED SCOPES
	this.NOSCOPE 		= "NoScope";
	this.PROTOTYPE  	= "NoScope";
	this.SINGLETON 		= "singleton"; 
	this.SESSION		= "session";
	this.APPLICATION	= "application";
	this.REQUEST		= "request";
	this.SERVER			= "server";
	this.CACHEBOX		= "cachebox";
	
	function isValidScope(scope){
		var key = "";
		for(key in this){
			if( isSimpleValue(this[key]) and this[key] eq arguments.scope ){
				return true;
			}
		}
		return false;
	}
	
	function getValidScopes(){
		var key = "";
		var scopes = {};
		for(key in this){
			if( isSimpleValue(this[key]) ){
				scopes[key] = this[key];
			}
		}
		return structKeyArray(scopes);
	}
</cfscript></cfcomponent>