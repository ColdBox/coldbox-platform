<cfset totalIndex = 1>
<cfoutput>1..#results.getTotalSpecs()##chr(13)#
<cfloop array="#bundleStats#" index="thisBundle">
<cfloop array="#thisBundle.suiteStats#" index="suiteStats">#genSuiteReport( suiteStats, thisBundle )#</cfloop>
</cfloop>
</cfoutput>

<!--- LOCAL FUNCTIONS --->
<cffunction name="getStatusBit" output="false">
	<cfargument name="status">
	<cfscript>
		switch( arguments.status ){
			case "failed" : { return "not ok"; }
			case "error" : { return "not ok"; }
			case "skipped" : { return "ok"; }
			default : { return "ok"; }
		}		
	</cfscript>
</cffunction>

<cffunction name="renderOrigin" output="false">
	<cfargument name="origin">
	<cfscript>
		var sb = createObject( "java", "java.lang.StringBuilder" ).init("");
		for( var thisRow in arguments.origin ){
			for( var thisKey in thisRow ){
				sb.append( '## #thisKey#:#thisRow[ thisKey ]# #chr(13)#' );
			}
		}
		return sb.toString();
	</cfscript>
</cffunction>

<!--- Recursive Output --->
<cffunction name="genSuiteReport" output="false">
	<cfargument name="suiteStats">
	<cfargument name="bundleStats">

<cfsavecontent variable="local.report"><cfoutput><cfloop array="#arguments.suiteStats.specStats#" index="local.thisSpec"><!---
--->#getStatusBit( local.thisSpec.status )# #totalIndex# #arguments.suiteStats.name# #local.thisSpec.name#<!---
---><cfif local.thisSpec.status eq "failed"> ## TODO #local.thisSpec.failMessage# #chr(13)#
#renderOrigin( local.thisSpec.failorigin )#<!---
---><cfelseif local.thisSpec.status eq "skipped"> ## SKIP #chr(13)#<!---
---><cfelseif local.thisSpec.status eq "error"> ## TODO #local.thisSpec.error.message# #chr(13)#
## #replace( local.thisSpec.error.stackTrace , chr(10), '#chr(13)### ', "all" )# #chr(13)#<!---
---><cfelse>#chr(13)#</cfif>
<cfset totalIndex++><!---
---></cfloop><!---
---><cfif arrayLen( arguments.suiteStats.suiteStats )>
<cfloop array="#arguments.suiteStats.suiteStats#" index="local.nestedSuite">#genSuiteReport( local.nestedSuite, arguments.bundleStats )#</cfloop>
</cfif>	
</cfoutput>
</cfsavecontent>
<cfreturn local.report>
</cffunction>