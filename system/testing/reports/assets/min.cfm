<cfoutput>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="generator" content="TestBox v#testbox.getVersion()#">
	<title>Pass: #results.getTotalPass()# Fail: #results.getTotalFail()# Errors: #results.getTotalError()#</title>
	<link href="/coldbox/system/testing/reports/assets/css/simple.css" rel="stylesheet">
</head>

<body>

<!-- Header --->
<p>TestBox v#testbox.getVersion()#</p>

<!-- Global Stats --->
<div class="box" id="globalStats">
	<div class="buttonBar">
		<a href="?"><button title="Run all the tests">Run All</button></a>
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
</cfoutput>