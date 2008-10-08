<cfscript>
testSuite = CreateObject("component","mxunit.framework.TestSuite").TestSuite();
//Add all runnable methods in MyComponentTest  
testSuite.addAll("generalTest");  
testSuite.addAll("mainTest");

results = testSuite.run();  
writeOutput(results.getResultsOutput('html'));
</cfscript>