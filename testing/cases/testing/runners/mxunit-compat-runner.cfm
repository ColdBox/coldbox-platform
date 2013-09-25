<cfsetting showdebugoutput="false" >
<cfset r = new coldbox.system.testing.Runner( "coldbox.testing.cases.testing.specs.MXUnitCompatTest" ) >
<cfoutput>#r.run(reporter="json")#</cfoutput>