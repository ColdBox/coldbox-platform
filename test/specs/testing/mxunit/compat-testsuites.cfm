<cfsetting showdebugoutput="false" >
<cfset suite = new coldbox.system.testing.compat.framework.TestSuite().TestSuite()>
<cfset suite.addAll( "coldbox.test.specs.testing.specs.MXUnitCompatTest" )>
<cfset r = suite.run()>
<cfoutput>#r.getResultsOutput( reporter="simple" )#</cfoutput>

<cfset suite = new coldbox.system.testing.compat.framework.TestSuite().TestSuite()>
<cfset suite.add( "coldbox.test.specs.testing.specs.MXUnitCompatTest", "testAssertTrue" )>
<cfset suite.add( "coldbox.test.specs.testing.specs.MXUnitCompatTest", "testAssert" )>
<cfset r = suite.run()>
<cfoutput>#r.getResultsOutput( reporter="simple" )#</cfoutput>
