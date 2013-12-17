<cfsetting showDebugOutput="false">
<!--- Executes all tests in the 'specs' folder with simple reporter by default --->
<cfparam name="url.reporter" 		default="simple">
<cfparam name="url.directory" 		default="test.specs">
<cfparam name="url.bundles" 		default="">
<cfparam name="url.reportpath" 		default="#expandPath( "/test/test-results" )#">
<cfscript>
// prepare for tests
if( len( url.bundles ) ){
	testbox = createObject( "component", "coldbox.system.testing.TestBox" ).init( bundles=url.bundles );
}
else{
	testbox = createObject( "component", "coldbox.system.testing.TestBox" ).init( directory=url.directory );
}
// Run Tests
results = testbox.run( reporter=url.reporter );
// do stupid JUnitReport task processing.
if( url.reporter eq "ANTJunit" ){
	xmlReport = xmlParse( results );
	for( thisSuite in xmlReport.testsuites.XMLChildren ){
		fileWrite( url.reportpath & "/TEST-" & thisSuite.XMLAttributes.name & ".xml", toString( thisSuite ) );
	}
}
writeoutput( results );
</cfscript>