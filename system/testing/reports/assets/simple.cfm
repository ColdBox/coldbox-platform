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
	/** status **/
	.passed { color: green; }
	.failed { color: orange; }
	.error { color: red; }
	.skipped{ color: blue;}
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
	$(document).ready(function() {
		// spec toggler
		$("span.specStatus").click( function(){
			toggleSpecs( $( this ).attr( "data-status" ), $( this ).attr( "data-bundleid" ) );
		} );
	});
	function toggleSpecs( type, bundleid ){
		$("div.spec").each( function(){
			var $this = $( this );
		
			// if bundleid passed and not the same bundle, skip
			if( bundleid != undefined && $this.attr( "data-bundleid" ) != bundleid ){
				return;
			}

			// toggle the opposite type
			if( !$this.hasClass( type ) ){
				$this.fadeOut();
			}
			else{
				// show the type you sent
				$this.fadeIn();
			}

		} );
	}
	</script>
</head>

<body>

<!-- Header --->
<p>TestBox v#runner.getVersion()# - Simple Reporter</p>

<!-- Global Stats --->
<div class="box" id="globalStats">
<h2>Global Stats (#results.getTotalDuration()# ms)</h2>
[ Bundles/Suites/Specs: #results.getTotalBundles()#/#results.getTotalSuites()#/#results.getTotalSpecs()# ]
[ <span class="specStatus passed" data-status="passed">Pass: #results.getTotalPass()#</span> ]
[ <span class="specStatus failed" data-status="failed">Failures: #results.getTotalFail()#</span> ]
[ <span class="specStatus error" data-status="error">Errors: #results.getTotalError()#</span> ]
[ <span class="specStatus skipped" data-status="skipped">Skipped: #results.getTotalSkipped()#</span> ]
<br>
<cfif arrayLen( results.getLabels() )>
[ Labels Applied: #arrayToList( results.getLabels() )# ]
</cfif>

</div>

<!--- Bundle Info --->
<cfloop array="#bundleStats#" index="thisBundle">
	<div class="box" id="bundleStats_#thisBundle.path#">
		
		<!--- bundle stats --->
		<h2>#thisBundle.path# (#thisBundle.totalDuration# ms)</h2>
		[ Suites/Specs: #thisBundle.totalSuites#/#thisBundle.totalSpecs# ]
		[ <span class="specStatus passed" 	data-status="passed" data-bundleid="#thisBundle.id#">Pass: #thisBundle.totalPass#</span> ]
		[ <span class="specStatus failed" 	data-status="failed" data-bundleid="#thisBundle.id#">Failures: #thisBundle.totalFail#</span> ]
		[ <span class="specStatus error" 	data-status="error" data-bundleid="#thisBundle.id#">Errors: #thisBundle.totalError#</span> ]
		[ <span class="specStatus skipped" 	data-status="skipped" data-bundleid="#thisBundle.id#">Skipped: #thisBundle.totalSkipped#</span> ]
		
		<!-- Iterate over suites -->
		<cfloop array="#thisBundle.suiteStats#" index="suiteStats">
		<div class="suite #lcase( suiteStats.status)#" data-bundleid="#thisBundle.id#">
		<dl>
			<!--- Suite info --->
			<dt class="#lcase( suiteStats.status )#"><strong>#suiteStats.name#</strong></dt>
			<cfloop array="#suiteStats.specStats#" index="thisSpec">
				<div class="spec #lcase( thisSpec.status )#" data-bundleid="#thisBundle.id#">
				<dd class="#lcase( thisSpec.status )#">
					#thisSpec.name# (#thisSpec.totalDuration# ms)
					<cfif thisSpec.status eq "failed">
						- <strong>#thisSpec.failMessage#</strong><br>
						<div class="box">
							<cfdump var="#thisSpec.failorigin#" expand=false label="Failure Origin">
						</div>
					</cfif>
					<cfif thisSpec.status eq "error">
						- <strong>#thisSpec.error.message#</strong><br>
						<div class="box">
							<cfdump var="#thisSpec.error#" expand=false label="Exception Structure">
						</div>
					</cfif>
				</dd>	
				</div>
			</cfloop>
		</dl>
		</div>
		</cfloop>
		
	</div>
</cfloop>

	</body>
</html>
</cfoutput>