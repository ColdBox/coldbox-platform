<cfsetting showdebugoutput="false" >
<!--- One runner --->
<cfset r = new coldbox.system.testing.runners.UnitRunner( "coldbox.testing.cases.testing.specs.Assertionscf9Test" ) >
<cfoutput>#r.run(reporter="simple")#</cfoutput>