/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A scope enum CFC that gives you the scopes that WireBox uses by default
 **/
component{

	// DECLARED SCOPES
	this.NOSCOPE 		= "NoScope";
	this.PROTOTYPE  	= "NoScope";
	this.SINGLETON 		= "singleton";
	this.SESSION		= "session";
	this.APPLICATION	= "application";
	this.REQUEST		= "request";
	this.SERVER			= "server";
	this.CACHEBOX		= "cachebox";

	/**
	 * Verify if an incoming scope is valid
	 *
	 * @scope The scope to check
	 */
	boolean function isValidScope( required scope ){
		for( var key in this ){
			if( isSimpleValue( this[ key ] ) and this[ key ] eq arguments.scope ){
				return true;
			}
		}
		return false;
	}

	/**
	 * Get all valid scopes as an array
	 */
	array function getValidScopes(){
		var scopes = {};
		for( var key in this){
			if( isSimpleValue( this[ key ] ) ){
				scopes[ key ] = this[ key ];
			}
		}
		return structKeyArray( scopes );
	}

}