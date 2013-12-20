/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* A compat class for MXUnit Directory Test Suite
*/ 
component{

	function init( 
		required bundles,
		testSpecs=""
	){
	
		for( var thisArg in arguments ){
			variables[ thisArg ] = arguments[ thisArg ];
		}	
			
		return this;
	}	
	
	any function getResultsOutput( mode="simple" ){

		switch( arguments.mode ){
			case "junitxml" : { arguments.mode = "junit"; break; } 
			case "query" 	: case "array" 		: { arguments.mode = "raw"; break; }
			case "html" 	: case "rawhtml" 	: { arguments.mode = "simple"; break; }
			default 		: { arguments.mode = "simple"; }
		}

		var tb = new coldbox.system.testing.TestBox( bundles=variables.bundles );
		
		return tb.run( testSpecs=variables.testSpecs, reporter=arguments.mode );
	}

}