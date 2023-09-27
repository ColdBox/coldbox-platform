/**
 * We use this approach, because if not, we get conflicts with WireBox in COmmandBox.
 * So we have to isolate the mapping.
 */
component{

	this.name = "APIDOCS";
	this.sessionManagement 	= true;
	this.sessionTimeout 	= createTimeSpan( 0, 0, 1, 0 );
	this.setClientCookies 	= true;

	// API Root
	API_ROOT = getDirectoryFromPath( getCurrentTemplatePath() );
	// App Root
	COLDBOX_ROOT = url.keyExists( "root" ) ? url.root : REReplaceNoCase( API_ROOT, "apidocs(\\|\/)$", "" );

	// Core Mappings
	this.mappings[ "/docbox" ] 		= API_ROOT & "docbox";
	this.mappings[ "/testbox" ]  	= API_ROOT & "testbox";

	// Standlone mappings
	this.mappings[ "/coldbox" ] 	= url.keyExists( "root" ) ? url.root & "coldbox"	: COLDBOX_ROOT;
	this.mappings[ "/cachebox" ] 	= url.keyExists( "root" ) ? url.root & "cachebox"	: COLDBOX_ROOT;
	this.mappings[ "/logbox" ] 		= url.keyExists( "root" ) ? url.root & "logbox"		: COLDBOX_ROOT;
	this.mappings[ "/wirebox" ] 	= url.keyExists( "root" ) ? url.root & "wirebox"	: COLDBOX_ROOT;

	systemOutput( "**** Mappings #this.mappings.toString()# ", true );
}
