<cfoutput>
<!-- Global Stats --->
<section class="stats" id="globalStats">

	<h1>Global Stats (#results.getTotalDuration()# ms)</h1>
	<p>
		Bundles/Suites/Specs: #results.getTotalBundles()#/#results.getTotalSuites()#/#results.getTotalSpecs()#
		<span class="specStatus passed" data-status="passed">Pass: #results.getTotalPass()#</span>
		<span class="specStatus failed" data-status="failed">Failures: #results.getTotalFail()#</span>
		<span class="specStatus error" data-status="error">Errors: #results.getTotalError()#</span
		<span class="specStatus skipped" data-status="skipped">Skipped: #results.getTotalSkipped()#</span>
		<br>
		<cfif arrayLen( results.getLabels() )>
		Labels Applied: #arrayToList( results.getLabels() )#
		</cfif>
	</p>
</section>

<!--- Bundle Info --->
<cfloop array="#bundleStats#" index="thisBundle">
	<section class="bundle" id="bundle-#thisBundle.path#">
		
		<!--- bundle stats --->
		<h1>#thisBundle.path# (#thisBundle.totalDuration# ms)</h1>
		<p>
			Suites/Specs: #thisBundle.totalSuites#/#thisBundle.totalSpecs#
			<span class="specStatus passed" 	data-status="passed" data-bundleid="#thisBundle.id#">Pass: #thisBundle.totalPass#</span>
			<span class="specStatus failed" 	data-status="failed" data-bundleid="#thisBundle.id#">Failures: #thisBundle.totalFail#</span>
			<span class="specStatus error" 	data-status="error" data-bundleid="#thisBundle.id#">Errors: #thisBundle.totalError#</span>
			<span class="specStatus skipped" 	data-status="skipped" data-bundleid="#thisBundle.id#">Skipped: #thisBundle.totalSkipped#</span>
		</p>

		<!-- Global Error --->
		<cfif !isSimpleValue( thisBundle.globalException )>
			<h2>Global Bundle Exception<h2>
			<p>#thisBundle.globalException.stacktrace#</p>
		</cfif>

		<!-- Iterate over bundle suites -->
		<cfloop array="#thisBundle.suiteStats#" index="suiteStats">
			<section class="suite #lcase( suiteStats.status)#" data-suiteid="#suiteStats.id#">
			<dl>
				#genSuiteReport( suiteStats, thisBundle )#
			</dl>
			</section>
		</cfloop>
		
	</section>
</cfloop>

<!--- Recursive Output --->
<cffunction name="genSuiteReport" output="false">
	<cfargument name="suiteStats">
	<cfargument name="bundleStats">
	
	<cfsavecontent variable="local.report">
		<cfoutput>
		<!--- Suite Results --->
		<h1>+#arguments.suiteStats.name# (#arguments.suiteStats.totalDuration# ms)</h1>
		<dl>
			<cfloop array="#arguments.suiteStats.specStats#" index="local.thisSpec">
				<!--- Spec Results --->
				<dt class="spec #lcase( local.thisSpec.status )#" data-bundleid="#arguments.bundleStats.id#" data-specid="#local.thisSpec.id#">
					#local.thisSpec.name# (#local.thisSpec.totalDuration# ms)
				</dt>
					
				<cfif local.thisSpec.status eq "failed">
					<dd>#htmlEditFormat( local.thisSpec.failMessage )#</dd>
					<dd><textarea cols="100" rows="20">#local.thisSpec.failOrigin.toString()#</textarea></dd>
				</cfif>
				
				<cfif local.thisSpec.status eq "error">
					<dd>#htmlEditFormat( local.thisSpec.error.message )#</dd>
					<dd><textarea cols="100" rows="20">#local.thisSpec.error.stacktrace#</textarea></dd>
				</cfif>
			</cfloop>

			<!--- Do we have nested suites --->
			<cfif arrayLen( arguments.suiteStats.suiteStats )>
				<cfloop array="#arguments.suiteStats.suiteStats#" index="local.nestedSuite">
					<section class="suite #lcase( arguments.suiteStats.status )#" data-bundleid="#arguments.bundleStats.id#">
					<dl>
						#genSuiteReport( local.nestedSuite, arguments.bundleStats )#
					</dl>
					</section>
				</cfloop>
			</cfif>	

		</dl>
		</cfoutput>
	</cfsavecontent>

	<cfreturn local.report>
</cffunction>
</cfoutput>