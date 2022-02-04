component{

	this.name = "APIDOCS" & hash( getCurrentTemplatePath() );
	this.sessionManagement 	= true;
	this.sessionTimeout 	= createTimeSpan( 0, 0, 1, 0 );
	this.setClientCookies 	= true;

	// API Root
	API_ROOT = getDirectoryFromPath( getCurrentTemplatePath() );
	// ColdBox Root
	COLDBOX_ROOT = REReplaceNoCase( API_ROOT, "apidocs(\\|\/)$", "" );

	// Core Mappings
	this.mappings[ "/docbox" ] 	= API_ROOT & "docbox";
	this.mappings[ "/testbox" ]  = API_ROOT & "testbox";

	// Standlone mappings
	this.mappings[ "/coldbox" ]  = ( structKeyExists( url, "coldbox_root" )  ? url.coldbox_root  : COLDBOX_ROOT );
	this.mappings[ "/cachebox" ] = ( structKeyExists( url, "cachebox_root" ) ? url.cachebox_root : COLDBOX_ROOT );
	this.mappings[ "/logbox" ] 	 = ( structKeyExists( url, "logbox_root" )   ? url.logbox_root   : COLDBOX_ROOT );
	this.mappings[ "/wirebox" ]  = ( structKeyExists( url, "wirebox_root" )  ? url.wirebox_root  : COLDBOX_ROOT );

}