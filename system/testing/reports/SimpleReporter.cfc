/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* A raw reporter
*/ 
component{

	function init(){ 
		return this; 
	}

	/**
	* Get the name of the reporter
	*/
	function getName(){
		return "Simple";
	}

	/**
	* Do the reporting thing here using the incoming test results
	* The report should return back in whatever format they desire and should set any
	* Specifc browser types if needed.
	* @results.hint The instance of the TestBox TestResult object to build a report on
	* @runner.hint The TestBox runner object
	*/
	any function runReport( 
		required coldbox.system.testing.TestResult results,
		required coldbox.system.testing.runners.IRunner runner
	){
		// bundle stats
		bundleStats = arguments.results.getBundleStats();
		
		// prepare the report
		savecontent variable="local.report"{
			include "assets/simple.cfm";
		}
		return local.report;
	}
	
}