<cfsetting showdebugoutput="false" >
<cfset suite = new coldbox.system.testing.compat.framework.TestSuite().TestSuite()>
<cfset suite.addAll( "coldbox.testing.cases.testing.specs.MXUnitCompatTest" )>
<cfset r = suite.run()>
<cfoutput>#r.getResultsOutput( reporter="simple" )#</cfoutput>

<cfset suite = new coldbox.system.testing.compat.framework.TestSuite().TestSuite()>
<cfset suite.add( "coldbox.testing.cases.testing.specs.MXUnitCompatTest", "testAssertTrue" )>
<cfset suite.add( "coldbox.testing.cases.testing.specs.MXUnitCompatTest", "testAssert" )>
<cfset r = suite.run()>
<cfoutput>#r.getResultsOutput( reporter="simple" )#</cfoutput>
