<cfsetting showdebugoutput="false" >
<!--- Directory Runner --->
<cfset r = new coldbox.system.testing.TestBox( directory="coldbox.test.specs.testing.specs" ) >
<cfoutput>#r.run(reporter="simple")#</cfoutput>