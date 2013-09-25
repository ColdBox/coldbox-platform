<cfoutput>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="generator" content="TestBox v#runner.getVersion()#">
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
	.centered { text-align: center !important; }
	.inline{ display: inline !important; }
	.margin10{ margin: 10px; }
	.padding10{ padding: 10px; }
	.margin0{ margin: 0px; }
	.padding0{ padding: 0px; }
	.passed { color: green; }
	.failed { color: orange; }
	.error { color: red; }
	.float-right{ float: right;}
	.float-left{ float: left;}
	.box{ border:1px solid gray; margin: 10px 0px; padding: 10px; background-color: ##f5f5f5}
	dd{ margin: 3px 0px 3px 15px}
	</style>
	<script src="js/jquery.js"></script>
	<script>

	</script>
</head>

<body>

<!-- Header --->
<p>TestBox v#runner.getVersion()#</p>

<!-- Global Stats --->
<div class="box">
<h2>Global Stats</h2>
[ Bundles/Specs: #results.getBundleCount()#/#results.getSpecCount()# ]
[ Duration: #results.getTotalDuration()# ms ]
[ <span class="passed">Pass: #results.getTotalPass()#</span> ]
[ <span class="failed">Failures: #results.getTotalFail()#</span> ]
[ <span class="error">Errors: #results.getTotalError()#</span> ]
</div>

<!--- Bundle Stats --->
<cfloop collection="#bundleStats#" index="thisBundle">
	<cfset sBundle = bundleStats[ thisBundle ]>
	<div class="box">
	<h2>Bundle: #thisBundle#</h2>
	[ Specs: #sBundle.totalSpecs# ]
	[ Duration: #sBundle.totalDuration# ms ]
	[ <span class="passed">Pass: #sBundle.totalPass#</span> ]
	[ <span class="failed">Failures: #sBundle.totalFail#</span> ]
	[ <span class="error">Errors: #sBundle.totalError#</span> ]
	</div>
	<dl>
		<dt>#sBundle.name#</dt>
		<cfloop array="#sBundle.specs#" index="thisSpec">
			<dd class="#lcase( thisSpec.status )#">
				#thisSpec.name# (#thisSpec.totalDuration# ms)
				<cfif thisSpec.status eq "failed">
					- <strong>#thisSpec.failMessage#</strong><br>
					<div class="box">
						<cfdump var="#thisSpec.failorigin#">
					</div>
				</cfif>
				<cfif thisSpec.status eq "error">
					- <strong>#thisSpec.error.message#</strong><br>
					<div class="box">
						<cfdump var="#thisSpec.error#">
					</div>
				</cfif>
			</dd>	
		</cfloop>
	</dl>

</cfloop>

	</body>
</html>
</cfoutput>