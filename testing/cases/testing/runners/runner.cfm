<cfscript>
r = new coldbox.system.testing.TestRunner( "coldbox.testing.cases.testing.specs.MXUnitCompatTest" );
results = r.run();
</cfscript>
<cfsetting showdebugoutput="false" >
<cfcontent type="application/json" reset="true">
<cfoutput>#serializeJSON( results )#</cfoutput>