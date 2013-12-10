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
	
	any function getResultsOutput( reporter="simple" ){
		var tb = new coldbox.system.testing.TestBox( bundles=variables.bundles );
		
		return tb.run( testSpecs=variables.testSpecs, reporter=arguments.reporter );
	}

}