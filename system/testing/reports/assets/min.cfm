<cfoutput>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="generator" content="TestBox v#testbox.getVersion()#">
	<title>Pass: #results.getTotalPass()# Fail: #results.getTotalFail()# Errors: #results.getTotalError()#</title>
	<script><cfinclude template="/coldbox/system/testing/reports/assets/js/jquery.js"></script>
	<style><cfinclude template="/coldbox/system/testing/reports/assets/css/simple.css"></style>
	<script>
	$(document).ready(function() {
	});
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

<!-- Global Stats --->
<div class="box" id="globalStats">
	<div class="buttonBar">
		<a href="#baseURL#"><button title="Run all the tests">Run All</button></a>
	</div>

	<h3>Bundles/Suites/Specs: #results.getTotalBundles()#/#results.getTotalSuites()#/#results.getTotalSpecs()#  (#results.getTotalDuration()# ms)</h3>
	
	[ <span class="specStatus passed" data-status="passed">Pass: #results.getTotalPass()#</span> ]
	[ <span class="specStatus failed" data-status="failed">Failures: #results.getTotalFail()#</span> ]
	[ <span class="specStatus error" data-status="error">Errors: #results.getTotalError()#</span> ]
	[ <span class="specStatus skipped" data-status="skipped">Skipped: #results.getTotalSkipped()#</span> ]
	<br>
	<cfif arrayLen( results.getLabels() )>
	[ Labels Applied: #arrayToList( results.getLabels() )# ]
	</cfif>

</div>

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
</cfoutput>