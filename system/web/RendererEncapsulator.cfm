<!---
	Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
	www.ortussolutions.com
	---
	I encapsulate variables for rendered templates without the overhaed of a CFC creation

	@author Brad Wood <brad@ortussolutions.com>
	@author Luis Majano <lmajano@ortussolutions.com>
---><cfscript>
	// Unique Rendering Variables
	variables.isViewsHelperIncluded = false;
	variables.renderedHelpers 		= {};

	// Merge variables from renderer
	// Moved to simple for/loop to avoid closure memory issues and slowdowns
	for( myVar in attributes.rendererVariables ) {
		if( !listFindNoCase( "local,attributes,arguments", myVar ) ) {
			variables[ myVar ] = attributes.rendererVariables[ myVar ];
		}
	}

	// Localize context
	variables.event = attributes.event;
	variables.rc 	= attributes.rc;
	variables.prc 	= attributes.prc;

	// Spoof the arguments scope for backwards compat.  i.e. arguments.args
	variables.arguments = {
		view 			= attributes.view,
    	viewPath 		= attributes.viewPath,
    	viewHelperPath 	= attributes.viewHelperPath,
    	args 			= attributes.args
	};

 	// Also add these to variables as well for scope-less lookups
	structAppend( variables, variables.arguments, true );

	// global views helper
	if( len( variables.viewsHelper ) AND ! variables.isViewsHelperIncluded  ){
		include "#variables.viewsHelper#";
		variables.isViewsHelperIncluded = true;
	}

	// view helpers ( directory + view + whatever )
	if(
		arguments.viewHelperPath.len() AND
		NOT variables.renderedHelpers.keyExists( hash( arguments.viewHelperPath.toString() ) )
	){
		arguments.viewHelperPath.each( function( item ){
			include "#arguments.item#";
		} );
		variables.renderedHelpers[ hash( arguments.viewHelperPath.toString() ) ] = true;
	}

	// The actual view requested
	include "#arguments.viewPath#.cfm";
</cfscript>