<div>
<table align="center" >
	<tr>
		<td>
		<cfchart format="png" show3d="true" backgroundcolor="##eeeeee" gridlines="true">
			<cfchartseries type="pie" colorlist="85ca0a,1e3aca" >
				<cfchartdata item="Free Memory (KB)"  value="#JVMFreeMemory#">
				<cfchartdata item="Total Memory (KB)" value="#JVMTotalMemory#">
			</cfchartseries>
		</cfchart>
		</td>
		<td>
		<cfchart format="png" show3d="true" backgroundcolor="##eeeeee" chartwidth="150">
			<cfchartseries type="bar" colorlist="93C2FF,ED2939" >
				<cfchartdata item="Hits" value="#getColdboxOCM().getCachePerformance().hits#">
				<cfchartdata item="Misses" value="#getColdboxOCM().getCachePerformance().misses#">
			</cfchartseries>
		</cfchart>
		</td>
		<td>
		<cfset itemTypes = getColdboxOCM().getItemTypes()>
		<cfchart format="png" show3d="true" backgroundcolor="##eeeeee" gridlines="true">
			<cfchartseries type="pie" colorlist="93C2FF" >
				<cfchartdata item="Plugins" value="#itemTypes.plugins#">
				<cfchartdata item="Handlers" value="#itemTypes.handlers#">
				<cfchartdata item="IoC Objects" value="#itemTypes.ioc_beans#">
				<cfchartdata item="Other Objects" value="#itemTypes.other#">
			</cfchartseries>
		</cfchart>
		</td>
	</tr>
</table>
</div>