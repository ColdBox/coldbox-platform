/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* A compat class for MXUnit Directory Test Suite
*/ 
component{

	function init( 
		required directory,
		componentPath="",
		boolean recurse=true,
		excludes=""
	){
	
		for( var thisArg in arguments ){
			variables[ thisArg ] = arguments[ thisArg ];
		}	
			
		return this;
	}	
	
	any function getResultsOutput( reporter="simple" ){
		var dir = {
			recurse = variables.recurse,
			mapping = variables.componentPath
		};
		
		var tb = new coldbox.system.testing.TestBox( directory=dir, testBundles=variables.excludes, reporter=arguments.reporter );
		
		return tb.run();
	}

}