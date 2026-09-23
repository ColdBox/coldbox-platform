<cfoutput>
<div class="perf-result">
	<h2>#prc.message#</h2>
	<p>Rendered at: #dateTimeFormat( prc.timestamp, "yyyy-mm-dd HH:nn:ss" )#</p>
	<p>ColdBox: #prc.version#</p>
	<cfif prc.keyExists( "_perfElapsed" )>
	<p>Request elapsed: #prc._perfElapsed#ms</p>
	</cfif>
</div>
</cfoutput>
