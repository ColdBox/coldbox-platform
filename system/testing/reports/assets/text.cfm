<cfoutput>  _____         _   ____            
 |_   _|__  ___| |_| __ )  _____  __
   | |/ _ \/ __| __|  _ \ / _ \ \/ /
   | |  __/\__ \ |_| |_) | (_) >  < 
   |_|\___||___/\__|____/ \___/_/\_\ v#runner.getVersion()#

=============================================================                                    
Global Stats (#results.getTotalDuration()# ms)
=============================================================
->[Bundles/Suites/Specs: #results.getTotalBundles()#/#results.getTotalSuites()#/#results.getTotalSpecs()#]
->[Pass: #results.getTotalPass()#]
->[Failures: #results.getTotalFail()#]
->[Errors: #results.getTotalError()#]
->[Skipped: #results.getTotalSkipped()#]
->[Labels Applied: #arrayToList( results.getLabels() )#]
<cfloop array="#bundleStats#" index="thisBundle">
=============================================================
#thisBundle.path# (#thisBundle.totalDuration# ms)
=============================================================
->[Suites/Specs: #thisBundle.totalSuites#/#thisBundle.totalSpecs#]
->[Pass: #thisBundle.totalPass#]
->[Failures: #thisBundle.totalFail#]
->[Errors: #thisBundle.totalError#]
->[Skipped: #thisBundle.totalSkipped#]
<cfloop array="#thisBundle.suiteStats#" index="suiteStats">
#genSuiteReport( suiteStats, thisBundle )#
</cfloop>
=============================================================
</cfloop>

<!--- Recursive Output --->
<cffunction name="genSuiteReport" output="false">
	<cfargument name="suiteStats">
	<cfargument name="bundleStats">
	<cfargument name="level" default=0>

<cfsavecontent variable="local.report">
<cfoutput>
#repeatString( chr(9), arguments.level )#*#arguments.suiteStats.name# #chr(13)#
<cfset arguments.level++>
<cfloop array="#arguments.suiteStats.specStats#" index="local.thisSpec">
#repeatString( chr(9), arguments.level)##local.thisSpec.name# (#local.thisSpec.totalDuration# ms) #chr(13)#
			
	<cfif local.thisSpec.status eq "failed">
		- <strong>#local.thisSpec.failMessage#</strong><br>
		<div class="box">
			<cfdump var="#local.thisSpec.failorigin#" expand=false label="Failure Origin">
		</div>
	</cfif>
	
	<cfif local.thisSpec.status eq "error">
		- <strong>#local.thisSpec.error.message#</strong><br>
		<div class="box">
			<cfdump var="#local.thisSpec.error#" expand=false label="Exception Structure">
		</div>
	</cfif>
</cfloop>

<cfif arrayLen( arguments.suiteStats.suiteStats )>
<cfloop array="#arguments.suiteStats.suiteStats#" index="local.nestedSuite">#genSuiteReport( local.nestedSuite, arguments.bundleStats, arguments.level++ )#</cfloop>
</cfif>	

</cfoutput>
</cfsavecontent>

	<cfreturn local.report>
</cffunction>
</cfoutput>