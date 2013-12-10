<cfsetting showdebugoutput="false" >
<cfset r = new coldbox.system.testing.TestBox( "coldbox.testing.cases.testing.specs.MXUnitCompatTest" ) >
<cfoutput>#r.run(reporter="text")#</cfoutput>