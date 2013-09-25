<cfsetting showdebugoutput="false" >
<cfset r = new coldbox.system.testing.Runner( "coldbox.testing.cases.testing.specs.AssertionsTest" ) >
<cfoutput>#r.run(reporter="simple")#</cfoutput>