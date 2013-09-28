<cfsetting showdebugoutput="false" >
<cfparam name="url.reporter" default="simple"> 
<!--- One runner --->
<cfset r = new coldbox.system.testing.runners.UnitRunner( bundles="coldbox.testing.cases.testing.specs.AssertionsTest", labels="railo" ) >
<cfoutput>#r.run(reporter="#url.reporter#")#</cfoutput>