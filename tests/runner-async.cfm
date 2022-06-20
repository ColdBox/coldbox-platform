<cfsetting showDebugOutput="false">
<!--- Executes all tests in the 'specs' folder with simple reporter by default --->
<cfparam name="url.reporter" 		default="simple">
<cfparam name="url.directory" 		default="tests.specs.async">
<cfparam name="url.recurse" 		default="true" type="boolean">
<cfparam name="url.bundles" 		default="">
<cfparam name="url.labels" 			default="">
<cfparam name="url.reportpath" 		default="#expandPath( "/tests/results" )#">
<cfparam name="url.propertiesFilename" 	default="TEST.properties">
<cfparam name="url.propertiesSummary" 	default="false" type="boolean">

<cfparam name="url.coverageEnabled" default="false">
<cfparam name="url.coverageSonarQubeXMLOutputPath" default="">
<cfparam name="url.coveragePathToCapture" default="#expandPath( '/coldbox/system' )#">
<cfparam name="url.coverageWhitelist" default="">
<cfparam name="url.coverageBlacklist" default="/stubs/**">
<cfparam name="url.coverageBrowserOutputDir" default="#expandPath( '/tests/results/coverageReport' )#">

<!--- Include the TestBox HTML Runner --->
<cfif !server.keyExists( "lucee" ) && server.coldfusion.productVersion.listFirst() eq 2016>
	<h1>Skipping Adobe 2016, too many issues in ACF 2016</h1>
<cfelse>
	<cfinclude template="/testbox/system/runners/HTMLRunner.cfm" >
</cfif>
