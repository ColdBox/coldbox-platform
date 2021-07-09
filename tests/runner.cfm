<!--- No debug output and request timeout --->
<cfsetting requesttimeout="999999" >
<cfsetting showDebugOutput="false">
<cfsetting enablecfoutputonly="true">
<!--- Executes all tests in the 'specs' folder with simple reporter by default --->
<cfparam name="url.reporter" 			default="simple">
<cfparam name="url.directory" 			default="tests.specs">

<!--- Regex list of exclusions --->
<cfparam name="url.directoryExcludes" 	default="/(cache|ioc|integration|logging|async)">
<cfparam name="url.recurse" 			default="true" type="boolean">
<cfparam name="url.bundles" 			default="">
<cfparam name="url.labels" 				default="">
<cfparam name="url.reportpath" 			default="#expandPath( '/tests/results' )#">
<cfparam name="url.propertiesFilename" 	default="TEST.properties">
<cfparam name="url.propertiesSummary" 	default="false" type="boolean">

<cfparam name="url.coverageEnabled" default="false">
<cfparam name="url.coverageSonarQubeXMLOutputPath" default="">
<cfparam name="url.coveragePathToCapture" default="#expandPath( '/coldbox/system' )#">
<cfparam name="url.coverageWhitelist" default="">
<cfparam name="url.coverageBlacklist" default="/stubs/**">
<cfparam name="url.coverageBrowserOutputDir" default="#expandPath( '/tests/results/coverageReport' )#">

<cfscript>
// Directory Filter: return true use, false do not process.
function directoryFilter( required bundlePath ){
	var excludeList = listToArray( url.directoryExcludes );
	// iterate and filter
	for( var thisExclude in excludeList ){
		if( reFindNoCase( thisExclude, arguments.bundlePath ) ){
			return false;
		}
	}
	// passed exclusion list
	return true;
}
// decode paths
url.bundles 			= URLDecode( url.bundles );
url.directory 			= URLDecode( url.directory );
url.reportPath 			= URLDecode( url.reportPath );
url.propertiesFilename 	= URLDecode( url.propertiesFilename );

// Report Path
if( !directoryExists( url.reportPath ) ){
	directoryCreate( url.reportPath );
}

options  =  {
	coverage : {
		enabled       	: url.coverageEnabled,
		pathToCapture 	: url.coveragePathToCapture,
		whitelist     	: url.coverageWhitelist,
		blacklist     	: url.coverageBlacklist,
		sonarQube     	: {
			XMLOutputPath : url.coverageSonarQubeXMLOutputPath
		},
		browser			: {
			outputDir : url.coverageBrowserOutputDir
		}
	}
};

// prepare for tests for bundles or directories
if( len( url.bundles ) ){
	testbox = new testbox.system.TestBox( bundles=url.bundles, labels=url.labels, options = options );
}
else{
	testbox = new testbox.system.TestBox( directory={ mapping=url.directory, filter=directoryFilter, recurse=url.recurse }, labels=url.labels, options = options );
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