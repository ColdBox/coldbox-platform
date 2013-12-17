/**
* MXUnit compatibility for Test Suites
*/
component accessors="true"{

	property name="bundles";
	property name="testSpecs";
	
	// constructor
	function testSuite(){
		variables.bundles 	= [];
		variables.testSpecs = [];
		
		return this;
	}

	remote function addTest( required componentName, required method ){
		arrayAppend( variables.bundles, arguments.componentName );
		variables.testSpecs.addAll( listToArray( arguments.method ) );
		return this;
	}
	
	remote function add( required componentName, required methods ){
		arrayAppend( variables.bundles, arguments.componentName );
		variables.testSpecs.addAll( listToArray( arguments.methods ) );
		return this;
	}
	
	remote function addAll( required componentName ){
		arrayAppend( variables.bundles, arguments.componentName );	
		return this;
	}

	remote function run( testMethod="" ){
		if( len( arguments.testMethod ) ){
			variables.testSpecs.addAll( listToArray( arguments.testMethod ) );
		}
		return new Results( variables.bundles, variables.testSpecs );
	}

	/**
	* Run a test remotely like MXUnit
	* @testMethod.hint A list or array of test names that are the ones that will be executed ONLY!
	* @debug.hint Show debug output on the reports or not
	* @output.hint The type of reporter to run the test with
	*/
	remote function runTestRemote(any testMethod="", boolean debug=false, output="simple") output=true{
		var runner = new coldbox.system.testing.TestBox( bundles="#getMetadata(this).name#", reporter=arguments.output );

		// Produce report
		writeOutput( runner.run( testSpecs=arguments.testMethod ) );
	}

}