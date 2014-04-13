<cfsetting showdebugoutput="false" >
<cfset r = new coldbox.system.testing.TestBox( "coldbox.test.specs.testing.specs.MXUnitCompatTest" ) >
<cfoutput>#r.run()#</cfoutput>