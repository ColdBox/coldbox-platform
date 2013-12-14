<cfoutput>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="generator" content="TestBox v#testbox.getVersion()#">
	<title>Pass: #results.getTotalPass()# Fail: #results.getTotalFail()# Errors: #results.getTotalError()#</title>
	<style><cfinclude template="/coldbox/system/testing/reports/assets/css/simple.css"></style>
	<style>
	.dots{ font-size: 60px; clear: both; margin-bottom: 20px; }
	.dots span{ float: left; margin: -6px;}
	</style>
	<script><cfinclude template="/coldbox/system/testing/reports/assets/js/jquery.js"></script>
	<script>
	function showInfo( failMessage, specID, isError ){
		if( failMessage.length ){
			alert( "Failure Message: " + failMessage );
		}
		else if( isError || isError == 'yes' || isError == 'true' ){
			$("##error_" + specID).fadeToggle();
		}
	}
	function toggleDebug( specid ){
		$("div.debugdata").each( function(){
			var $this = $( this );
		
			// if bundleid passed and not the same bundle
			if( specid != undefined && $this.attr( "data-specid" ) != specid ){
				return;
			}
			// toggle.
			$this.fadeToggle();
		});
	}
	</script>
</head>
<body>

	<!-- Header --->
	<p>TestBox v#testbox.getVersion()#</p>

	<!-- Stats --->
	<div class="box" id="globalStats">

		<div class="buttonBar">
			<a href="#baseURL#"><button title="Run all the tests">Run All</button></a>
		</div>

		<cfif results.getTotalFail() gt 0>
			<cfset totalClass = "fail">
		<cfelseif results.getTotalError() gt 0>
			<cfset totalClass = "error">
		<cfelse>
			<cfset totalClass = "pass">
		</cfif>
		<p>
		<span class="#totalClass#">#results.getTotalSpecs()# test(s) in #results.getTotalSuites()# suite(s) from #results.getTotalBundles()# bundle(s) completed </span> (#results.getTotalDuration()# ms)
		</p>
		[ <span class="passed" 	data-status="passed">Pass: #results.getTotalPass()#</span> ]
		[ <span class="failed" 	data-status="failed">Failures: #results.getTotalFail()#</span> ]
		[ <span class="error" 	data-status="error">Errors: #results.getTotalError()#</span> ]
		[ <span class="skipped" data-status="skipped">Skipped: #results.getTotalSkipped()#</span> ]
	</div>

	<!--- Dots --->
	<div class="dots">
		<!--- Iterate over bundles --->
		<cfloop array="#bundleStats#" index="thisBundle">
			<!-- Iterate over suites -->
			<cfloop array="#thisBundle.suiteStats#" index="suiteStats">
				#genSuiteReport( suiteStats, thisBundle )#
			</cfloop>
		</cfloop>
	</div>

	<div style="clear:both;margin:20px">&nbsp;</div>

	<!--- Debug Panel --->
	<cfloop array="#bundleStats#" index="thisBundle">
		<!--- Debug Panel --->
		<cfif arrayLen( thisBundle.debugBuffer )>
			<h2>Debug Stream: #thisBundle.path# <button onclick="toggleDebug( '#thisBundle.id#' )" title="Toggle the test debug stream">+</button></h2>
			<div class="debugdata" data-specid="#thisBundle.id#">
				<p>The following data was collected in order as your tests ran via the <em>debug()</em> method:</p>
				<cfdump var="#thisBundle.debugBuffer#" />
			</div>
		</cfif>
	</cfloop>

	</body>
</html>

<!--- Recursive Output --->
<cffunction name="genSuiteReport" output="false">
	<cfargument name="suiteStats">
	<cfargument name="bundleStats">
	
	<cfset var thisSpec = "">
	
	<cfsavecontent variable="local.report">
		<cfoutput>
			
			<!--- Iterate over suite specs --->
			<cfloop array="#arguments.suiteStats.specStats#" index="thisSpec">
				<a href="javascript:showInfo( '#JSStringFormat( thisSpec.failMessage )#', '#thisSpec.id#', '#lcase( NOT structIsEmpty( thisSpec.error ) )#' )" 
				   title="#htmlEditFormat( thisSpec.name )# (#thisSpec.totalDuration# ms)" 
				   data-info="#HTMLEditFormat( thisSpec.failMessage )#"><span class="#lcase( thisSpec.status )#">.</span></a>
				
				<div style="display:none;" id="error_#thisSpec.id#"><cfdump var="#thisSpec.error#"></div>
			</cfloop>			

			<!--- Do we have nested suites --->
			<cfif arrayLen( arguments.suiteStats.suiteStats )>
				<cfloop array="#arguments.suiteStats.suiteStats#" index="local.nestedSuite">
					#genSuiteReport( local.nestedSuite, arguments.bundleStats )#
				</cfloop>
			</cfif>	

		</cfoutput>
	</cfsavecontent>

	<cfreturn local.report>
</cffunction>
</cfoutput>