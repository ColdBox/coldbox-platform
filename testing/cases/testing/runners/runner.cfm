<cfsetting showdebugoutput="false" >
<cfparam name="url.reporter" default="simple"> 
<!--- One runner --->
<cfset r = new coldbox.system.testing.runners.UnitRunner( "coldbox.testing.cases.testing.specs.AssertionsTest" ) >
<cfoutput>#r.run(reporter="#url.reporter#")#</cfoutput>