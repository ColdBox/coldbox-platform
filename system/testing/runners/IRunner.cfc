/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* This TestBox runner is used to run and report on xUnit style test suites.
*/ 
interface{

	/**
	* Constructor
	* @options.hint The options for a runner
	*/
	function init( required struct options );

	/**
	* Execute a test run on a target bundle CFC
	* @target.hint The target bundle CFC to test
	* @testResults.hint The test results object to keep track of results for this test case
	*/
	any function run( 
		required any target,
		required coldbox.system.testing.TestResult testResults 
	);
	
}