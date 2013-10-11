<cfoutput>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="generator" content="TestBox v#testbox.getVersion()#">
	<title>Pass: #results.getTotalPass()# Fail: #results.getTotalFail()# Errors: #results.getTotalError()#</title>
	<style>
	body{
		font-family:  Monaco, "Lucida Console", monospace;
		font-size: 11px;
		font-weight: 300;
		line-height: 14px;
	}
	h1,h2,h3,h4{ margin-top: 3px;}
	h1{ font-size: 14px;}
	h2{ font-size: 13px;}
	h3{ font-size: 12px;}
	h4{ font-size: 11px; font-style: italic;}
	/** status **/
	.passed { color: green; }
	.failed { color: orange; }
	.error { color: red; }
	.skipped{ color: blue;}
	.dots{ font-size: 35px; clear: both; margin-bottom: 20px; }
	.dots span{ float: left; margin: -2px;}
	/** utility **/
	.centered { text-align: center !important; }
	.inline{ display: inline !important; }
	.margin10{ margin: 10px; }
	.padding10{ padding: 10px; }
	.margin0{ margin: 0px; }
	.padding0{ padding: 0px; }
	.float-right{ float: right;}
	.float-left{ float: left;}
	.box{ border:1px solid gray; margin: 10px 0px; padding: 10px; background-color: ##f5f5f5}
	##globalStats{ background-color: ##dceef4 }
	.specStatus{ cursor:pointer;}
	dd{ margin: 3px 0px 3px 15px}
	</style>
	<script src="/coldbox/system/testing/reports/assets/js/jquery.js"></script>
	<script>
	function showInfo( failMessage, specID, isError ){
		if( failMessage.length ){
			alert( "Failure Message: " + failMessage );
		}
		if( isError ){
			$("##error_" + specID).fadeToggle();
		}
	}
	</script>
</head>

<body>

	<!-- Header --->
	<p>TestBox v#testbox.getVersion()#</p>

	<!-- Stats --->
	<div class="box" id="globalStats">
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
				<a href="javascript:showInfo( '#thisSpec.failMessage#', '#thisSpec.id#', #NOT structIsEmpty( thisSpec.error )# )" 
				   title="#thisSpec.name# (#thisSpec.totalDuration# ms)" 
				   data-info="#thisSpec.failMessage#"><span class="#lcase( thisSpec.status )#">.</span></a>
				
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