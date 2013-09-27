<cfsetting showdebugoutput="false" >
<!--- One runner --->
<cfset r = new coldbox.system.testing.Runner( bundles="coldbox.testing.cases.testing.specs.AssertionsTest", labels="railo" ) >
<cfoutput>#r.run(reporter="simple")#</cfoutput>