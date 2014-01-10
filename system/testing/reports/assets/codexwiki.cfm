<cfoutput>
= Global Stats (#results.getTotalDuration()# ms) =

* '''Bundles/Suites/Specs:''' #results.getTotalBundles()#/#results.getTotalSuites()#/#results.getTotalSpecs()#
* '''Pass:''' #results.getTotalPass()#
* '''Failures:''' #results.getTotalFail()#
* '''Errors:''' #results.getTotalError()#
* '''Skipped:''' #results.getTotalSkipped()#
<cfif !arrayLen( results.getLabels() )>
* '''Labels Applied:''' #arrayToList( results.getLabels() )#
</cfif>

#chr(10)#

<cfloop array="#bundleStats#" index="thisBundle">
= #thisBundle.path# (#thisBundle.totalDuration# ms) =

* '''Suites/Specs:''' #thisBundle.totalSuites#/#thisBundle.totalSpecs#
* '''Pass:''' #thisBundle.totalPass#
* '''Failures:''' #thisBundle.totalFail#
* '''Errors:''' #thisBundle.totalError#
* '''Skipped:''' #thisBundle.totalSkipped#

#chr(10)#

<!-- Global Error --->
<cfif !isSimpleValue( thisBundle.globalException )>
== Global Bundle Exception ==
* #thisBundle.globalException.type#:#thisBundle.globalException.message#:#thisBundle.globalException.detail#
<pre>#thisBundle.globalException.stacktrace#</pre>
</cfif>

<cfloop array="#thisBundle.suiteStats#" index="suiteStats">
#genSuiteReport( suiteStats, thisBundle )#
</cfloop>
		
</cfloop>

<!--- Recursive Output --->
<cffunction name="genSuiteReport" output="false">
<cfargument name="suiteStats">
<cfargument name="bundleStats">
<cfargument name="level" default=2>

<cfset var headings = repeatString( "=", arguments.level )>

<cfsavecontent variable="local.report">
<cfoutput>#chr(10)#
#headings# #arguments.suiteStats.name# (#arguments.suiteStats.totalDuration# ms) #headings# #chr(10)#
<cfset arguments.level++>

<cfloop array="#arguments.suiteStats.specStats#" index="local.thisSpec">
<p>#local.thisSpec.name# (#local.thisSpec.totalDuration# ms)</p>
	
<cfif local.thisSpec.status eq "failed">
* '''#htmlEditFormat( local.thisSpec.failMessage )#'''
<pre>#local.thisSpec.failOrigin.toString()#</pre>
</cfif>

<cfif local.thisSpec.status eq "error">
* '''#htmlEditFormat( local.thisSpec.error.message )#'''
<pre>#local.thisSpec.error.stacktrace#</pre>
</cfif>
</cfloop>

<!--- Do we have nested suites --->
<cfif arrayLen( arguments.suiteStats.suiteStats )>
<cfloop array="#arguments.suiteStats.suiteStats#" index="local.nestedSuite">
#genSuiteReport( local.nestedSuite, arguments.bundleStats, arguments.level )#
</cfloop>
</cfif>	

</cfoutput>
</cfsavecontent>

<cfreturn local.report>
</cffunction>
</cfoutput>