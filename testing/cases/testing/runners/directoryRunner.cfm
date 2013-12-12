<cfsetting showdebugoutput="false" >
<cfparam name="url.reporter" default="simple">
<!--- Directory Runner --->
<cfset r = new coldbox.system.testing.TestBox( directory={ mapping = "coldbox.testing.cases.testing.specs", recurse = true } ) >
<cfoutput>#r.run(reporter=url.reporter)#</cfoutput>