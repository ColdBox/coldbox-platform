/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* The TestBox main reporting interface for producing awesome testing reports
*/ 
interface{

	/**
	* Get the name of the reporter
	*/
	function getName();

	/**
	* Do the reporting thing here using the incoming test results
	* The report should return back in whatever format they desire and should set any
	* Specifc browser types if needed.
	* @results.hint The instance of the TestBox TestResult object to build a report on
	* @testbox.hint The TestBox core object
	* @options.hint A structure of options this reporter needs to build the report with
	*/
	any function runReport( 
		required coldbox.system.testing.TestResult results,
		required coldbox.system.testing.TestBox testbox,
		struct options={} );
	
}