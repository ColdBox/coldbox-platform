/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* An XML reporter
*/ 
component{

	function init(){ 
		variables.converter = new coldbox.system.core.conversion.XMLConverter();
		return this; 
	}

	/**
	* Get the name of the reporter
	*/
	function getName(){
		return "XML";
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
		required coldbox.system.testing.runners.IRunner runner,
		struct options={} 
	){
		getPageContext().getResponse().setContentType( "application/xml" );
		return variables.converter.toXML( data=arguments.results.getMemento(), rootName="TestBox" );
	}
	
}