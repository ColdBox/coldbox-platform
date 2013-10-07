/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* This TestBox runner is used to run and report on xUnit style test suites.
*/ 
interface{

	/**
	* Run the bundles setup in this Runner and produces an awesome report according to sepcified passed reporter
	* @bundles.hint The path, list of paths or array of paths of the spec bundle CFCs to run and test
	* @directory.hint The directory information struct to test: [ mapping = the path to the directory using dot notation (myapp.testing.specs), recurse = boolean, filter = closure that receives the path of the CFC found, it must return true to process or false to continue process ]	
	* @reporter.hint The type of reporter to use for the results, by default is uses our 'simple' report. You can pass in a core reporter string type or an instance of a coldbox.system.testing.reports.IReporter. You can also pass a struct if the reporter requires options: {type="", options={}}
	* @labels.hint The list or array of labels that a suite or spec must have in order to execute.
	* @options.hint A structure of configuration options that are optionally used to configure a runner.
	*/
	any function run( any bundles, struct directory, any reporter, any labels, struct options );

}