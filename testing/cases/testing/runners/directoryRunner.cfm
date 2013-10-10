<cfsetting showdebugoutput="false" >
<!--- Directory Runner --->
<cfset r = new coldbox.system.testing.TestBox( directory={ mapping = "coldbox.testing.cases.testing.specs", recurse = true } ) >
<cfoutput>#r.run(reporter="simple")#</cfoutput>