<cfoutput>  _____         _   ____            
 |_   _|__  ___| |_| __ )  _____  __
   | |/ _ \/ __| __|  _ \ / _ \ \/ /
   | |  __/\__ \ |_| |_) | (_) >  < 
   |_|\___||___/\__|____/ \___/_/\_\ v#testBox.getVersion()#

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
<cfif !isSimpleValue( thisBundle.globalException )>
GLOBAL BUNDLE EXCEPTION
-> #thisBundle.globalException.type#:#thisBundle.globalException.message#:#thisBundle.globalException.detail#
=============================================================
STACKTRACE
=============================================================
#thisBundle.globalException.stacktrace#
=============================================================
END STACKTRACE
=============================================================
</cfif>

<cfloop array="#thisBundle.suiteStats#" index="suiteStats">
#genSuiteReport( suiteStats, thisBundle )#
</cfloop>
</cfloop>

=============================================================
Legend:
=============================================================
(P) = Passed
(-) = Skipped
(X) = Exception/Error
(!) = Failure
<cffunction name="getStatusBit" output="false">
	<cfargument name="status">
	<cfscript>
		switch( arguments.status ){
			case "failed" : { return "!"; }
			case "error" : { return "X"; }
			case "skipped" : { return "-"; }
			default : { return "+"; }
		}		
	</cfscript>
</cffunction>
<!--- Recursive Output --->
<cffunction name="genSuiteReport" output="false">
	<cfargument name="suiteStats">
	<cfargument name="bundleStats">
	<cfargument name="level" default=0>

<cfset var tabs = repeatString( "    ", arguments.level )>

<cfsavecontent variable="local.report">
<cfoutput>
#tabs#(#getStatusBit( arguments.suiteStats.status )#)#arguments.suiteStats.name# #chr(13)#
<cfset arguments.level++>
<cfloop array="#arguments.suiteStats.specStats#" index="local.thisSpec">
#repeatString( "    ", arguments.level )#(#getStatusBit( local.thisSpec.status )#)#local.thisSpec.name# (#local.thisSpec.totalDuration# ms) #chr(13)#
<cfif local.thisSpec.status eq "failed">
	-> Failure: #local.thisSpec.failMessage##chr(13)#
	-> Failure Origin: #local.thisSpec.failorigin.toString()# #chr(13)##chr(13)#
</cfif>
	
<cfif local.thisSpec.status eq "error">
	-> Error: #local.thisSpec.error.message##chr(13)#
	-> Exception Trace: #local.thisSpec.error.toString()# #chr(13)##chr(13)#
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