<cfsetting showdebugoutput="false" >
<!--- Directory Runner --->
<cfset r = new coldbox.system.testing.TestBox( directory="coldbox.testing.cases.testing.specs" ) >
<cfoutput>#r.run(reporter="simple")#</cfoutput>