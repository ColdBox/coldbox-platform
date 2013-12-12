/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* A simple Documentation style reporter
*/ 
component{

	function init(){ 
		return this; 
	}

	/**
	* Get the name of the reporter
	*/
	function getName(){
		return "CodexWiki";
	}

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
		struct options={}
	){
		// content type
		getPageContext().getResponse().setContentType( "text/text" );
		
		// bundle stats
		bundleStats = arguments.results.getBundleStats();
		
		// prepare base links
		baseURL = "?";
		if( structKeyExists( url, "method") ){ baseURL&= "method=#URLEncodedFormat( url.method )#"; }
		if( structKeyExists( url, "output") ){ baseURL&= "output=#URLEncodedFormat( url.output )#"; }

		// prepare incoming params
		if( !structKeyExists( url, "testMethod") ){ url.testMethod = ""; }
		if( !structKeyExists( url, "testSpecs") ){ url.testSpecs = ""; }
		if( !structKeyExists( url, "testSuites") ){ url.testSuites = ""; }
		if( !structKeyExists( url, "testBundles") ){ url.testBundles = ""; }

		// prepare the report
		savecontent variable="local.report"{
			include "assets/codexwiki.cfm";
		}
		return local.report;
	}
	
}