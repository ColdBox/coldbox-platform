<!---
	Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
	www.ortussolutions.com
	---
	I encapsulate variables for rendered templates without the overhaed of a CFC creation
	
	@author Brad Wood <brad@ortussolutions.com>
	@author Luis Majano <lmajano@ortussolutions.com>
---><cfscript>  
	// Merge variables from renderer
	for( _key in attributes.rendererVariables ) {
		// Skip local, attributes, and arguments scopes which Lucee tucks away inside of variables
		if( _key != 'local' && _key != 'attributes' && _key != 'arguments' ) {
			variables[ _key ] = attributes.rendererVariables[ _key ];
		}
	}
	
	// Views also expect these to be in the variables scope
	variables.event = attributes.event;
	variables.rc = attributes.rc;
	variables.prc = attributes.prc;
	
	// Spoof the arguments scope for backwards compat.  i.e. arguments.args
	variables.arguments = {
		view=attributes.view,
    	viewPath=attributes.viewPath,
    	viewHelperPath=attributes.viewHelperPath,
    	args=attributes.args
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

	include "#arguments.viewPath#.cfm";
</cfscript>