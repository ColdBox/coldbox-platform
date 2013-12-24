<cfsetting showDebugOutput="false">
<!--- Executes all tests in the 'specs' folder with simple reporter by default --->
<cfparam name="url.reporter" 			default="simple">
<cfparam name="url.directory" 			default="">
<cfparam name="url.recurse" 			default="true" type="boolean">
<cfparam name="url.bundles" 			default="">
<cfparam name="url.labels" 				default="">
<cfparam name="url.reportpath" 			default="">
<cfparam name="url.propertiesFilename" 	default="TEST.properties">
<cfparam name="url.propertiesSummary" 	default="false" type="boolean">
<cfscript>

// decode paths
url.bundles 			= URLDecode( url.bundles );
url.directory 			= URLDecode( url.directory );
url.reportPath 			= URLDecode( url.reportPath );
url.propertiesFilename 	= URLDecode( url.propertiesFilename );

// prepare for tests for bundles or directories
if( len( url.bundles ) ){
	testbox = new coldbox.system.testing.TestBox( bundles=url.bundles, labels=url.labels );
}
else{
	testbox = new coldbox.system.testing.TestBox( directory={ mapping=url.directory, recurse=url.recurse}, labels=url.labels );
}

// Run Tests using correct reporter
results = testbox.run( reporter=url.reporter );

// Write TEST.properties in report destination path.
if( url.propertiesSummary ){
	testResult = testbox.getResult();
	errors = testResult.getTotalFail() + testResult.getTotalError();
	savecontent variable="propertiesReport"{
writeOutput( ( errors ? "test.failed=true" : "test.passed=true" ) & chr( 10 ) );
writeOutput( "test.labels=#arrayToList( testResult.getLabels() )#
test.bundles=#URL.bundles#
test.directory=#url.directory#
total.bundles=#testResult.getTotalBundles()#
total.suites=#testResult.getTotalSuites()#
total.specs=#testResult.getTotalSpecs()#
total.pass=#testResult.getTotalPass()#
total.fail=#testResult.getTotalFail()#
total.error=#testResult.getTotalError()#
total.skipped=#testResult.getTotalSkipped()#" );
	}
	fileWrite( url.reportpath & "/" & url.propertiesFilename, propertiesReport );
}

// do stupid JUnitReport task processing, if the report is ANTJunit
if( url.reporter eq "ANTJunit" ){
	// Produce individual test files due to how ANT JUnit report parses these.
	xmlReport = xmlParse( results );
	for( thisSuite in xmlReport.testsuites.XMLChildren ){
		fileWrite( url.reportpath & "/TEST-" & thisSuite.XMLAttributes.package & ".xml", toString( thisSuite ) );
	}
}

// Writeout Results
writeoutput( results );
</cfscript>
