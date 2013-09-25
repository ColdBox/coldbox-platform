<cfscript>
r = new coldbox.system.testing.Runner( "coldbox.testing.cases.testing.specs.MXUnitCompatTest" );
</cfscript>
<cfsetting showdebugoutput="false" >
<cfoutput>#r.run(reporter="json")#</cfoutput>